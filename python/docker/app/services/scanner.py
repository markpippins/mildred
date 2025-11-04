"""
File scanning service - modernized version of the original scan.py
Handles resumable scanning with Redis state persistence
"""

import os
import asyncio
from datetime import datetime
from pathlib import Path
from typing import List, Optional, Dict, Any
import structlog

from database import get_redis, get_mongodb, get_mysql_session
from models.mongodb_models import FileMetadata, DirectoryMetadata
from models.mysql_models import LibraryPath, ScanOperation, OperationStatus
from services.metadata_processor import MetadataProcessor
from config import settings

logger = structlog.get_logger()


class ScannerService:
    """
    Modernized file scanner service
    
    Key improvements over original:
    - Async/await instead of blocking operations
    - Proper error handling and recovery
    - Cleaner state management with Redis
    - Batch processing for better performance
    """
    
    def __init__(self):
        self.redis_client = None
        self.mongodb = None
        self.metadata_processor = MetadataProcessor()
        self.scan_key_prefix = settings.redis_scan_key_prefix
        
    async def _init_clients(self):
        """Initialize database clients if not already done"""
        if not self.redis_client:
            self.redis_client = get_redis()
        if not self.mongodb:
            self.mongodb = get_mongodb()
    
    async def scan_all_libraries(self):
        """Scan all configured library paths"""
        await self._init_clients()
        
        async with get_mysql_session() as session:
            # TODO: Query all enabled library paths
            # For now, use a placeholder
            library_paths = ["/media/music", "/media/videos"]  # Placeholder
            
        for path in library_paths:
            if os.path.exists(path) and os.access(path, os.R_OK):
                await self.scan_path(path)
            else:
                logger.warning("Path not accessible", path=path)
    
    async def scan_path(self, root_path: str, deep_scan: bool = False):
        """
        Resumable scan of a specific path for media files
        
        Key features for robustness:
        - Persistent state in Redis for resume capability
        - Checkpoint-based progress tracking
        - Graceful handling of interruptions
        
        Args:
            root_path: Root directory to scan
            deep_scan: Whether to perform deep scanning (re-process existing files)
        """
        await self._init_clients()
        
        # Check for existing scan state
        scan_state = await self._get_or_create_scan_state(root_path, deep_scan)
        scan_id = scan_state["scan_id"]
        scan_key = f"{self.scan_key_prefix}state:{scan_id}"
        
        try:
            logger.info("Starting/resuming scan", 
                       path=root_path, 
                       scan_id=scan_id, 
                       deep_scan=deep_scan,
                       resume=scan_state.get("resume", False))
            
            # Build file list with resume capability
            file_queue = await self._build_resumable_file_queue(root_path, scan_state)
            
            files_processed = scan_state.get("files_processed", 0)
            batch = []
            checkpoint_interval = 50  # Save state every 50 files
            
            while file_queue:
                file_path = file_queue.pop(0)
                
                # Skip if already processed (unless deep scan)
                if not deep_scan and await self._is_file_processed(file_path):
                    await self._mark_file_completed(scan_key, file_path)
                    continue
                
                batch.append(file_path)
                
                # Process batch when it reaches the configured size
                if len(batch) >= settings.scan_batch_size:
                    processed = await self._process_file_batch_with_checkpoints(batch, scan_key)
                    files_processed += processed
                    batch = []
                    
                    # Update progress checkpoint
                    await self._update_scan_checkpoint(scan_key, files_processed, file_queue)
                
                # Periodic checkpoint even within batches
                if files_processed % checkpoint_interval == 0:
                    await self._update_scan_checkpoint(scan_key, files_processed, file_queue)
            
            # Process remaining files in batch
            if batch:
                processed = await self._process_file_batch_with_checkpoints(batch, scan_key)
                files_processed += processed
            
            # Mark scan as completed and cleanup
            await self._complete_scan(scan_key, files_processed)
            
            logger.info("Scan completed", path=root_path, files_processed=files_processed)
            
        except Exception as e:
            logger.error("Scan failed", path=root_path, error=str(e))
            await self._mark_scan_failed(scan_key, str(e))
            raise
    
    async def _process_directory(self, dir_path: str):
        """Process directory metadata"""
        try:
            stat_info = os.stat(dir_path)
            
            # Check if directory already exists in MongoDB
            existing = await self.mongodb.directory_metadata.find_one(
                {"absolute_path": dir_path}
            )
            
            if existing:
                # Update last_scanned timestamp
                await self.mongodb.directory_metadata.update_one(
                    {"_id": existing["_id"]},
                    {"$set": {"last_scanned": datetime.utcnow()}}
                )
            else:
                # Create new directory document
                dir_doc = DirectoryMetadata(
                    absolute_path=dir_path,
                    directory_name=os.path.basename(dir_path),
                    parent_path=os.path.dirname(dir_path),
                    last_scanned=datetime.utcnow()
                )
                
                await self.mongodb.directory_metadata.insert_one(dir_doc.dict(by_alias=True))
                
        except Exception as e:
            logger.warning("Failed to process directory", path=dir_path, error=str(e))
    
    async def _process_file_batch(self, file_paths: List[str]) -> int:
        """Process a batch of files concurrently"""
        tasks = []
        for file_path in file_paths:
            task = asyncio.create_task(self._process_single_file(file_path))
            tasks.append(task)
        
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Count successful processes
        successful = sum(1 for result in results if result is True)
        
        return successful
    
    async def _process_single_file(self, file_path: str) -> bool:
        """Process a single file and extract metadata"""
        try:
            # Get file stats
            stat_info = os.stat(file_path)
            
            # Skip files that are too large
            if stat_info.st_size > settings.max_file_size_mb * 1024 * 1024:
                logger.debug("Skipping large file", path=file_path, size=stat_info.st_size)
                return False
            
            # Extract metadata using the metadata processor
            metadata = await self.metadata_processor.process_file(file_path)
            
            if metadata:
                # Check if file already exists in MongoDB
                existing = await self.mongodb.file_metadata.find_one(
                    {"absolute_path": file_path}
                )
                
                if existing:
                    # Update existing document
                    await self.mongodb.file_metadata.update_one(
                        {"_id": existing["_id"]},
                        {"$set": metadata.dict(by_alias=True, exclude={"id"})}
                    )
                else:
                    # Insert new document
                    await self.mongodb.file_metadata.insert_one(metadata.dict(by_alias=True))
                
                return True
            
        except Exception as e:
            logger.error("Failed to process file", path=file_path, error=str(e))
        
        return False
    
    def _is_supported_file(self, filename: str) -> bool:
        """Check if file extension is supported"""
        ext = Path(filename).suffix.lower().lstrip('.')
        return ext in settings.supported_extensions
    
    async def _is_file_processed(self, file_path: str) -> bool:
        """Check if file has already been processed"""
        existing = await self.mongodb.file_metadata.find_one(
            {"absolute_path": file_path}
        )
        return existing is not None
    
    async def _get_resume_data(self, path: str) -> Optional[Dict[str, Any]]:
        """Get resume data for interrupted scans"""
        # TODO: Implement resume logic using Redis
        return None
    
    async def get_scan_status(self) -> Dict[str, Any]:
        """Get current scan status"""
        await self._init_clients()
        
        # Get all active scans
        active_keys = await self.redis_client.keys(f"{self.scan_key_prefix}active:*")
        active_scans = []
        
        for key in active_keys:
            scan_data = await self.redis_client.hgetall(key)
            if scan_data:
                active_scans.append(scan_data)
        
        return {
            "active_scans": len(active_scans),
            "scans": active_scans
        }
    
    async def _get_or_create_scan_state(self, root_path: str, deep_scan: bool) -> Dict[str, Any]:
        """Get existing scan state or create new one"""
        # Look for existing incomplete scan
        path_hash = abs(hash(root_path)) % (10 ** 8)  # Simple path hash
        scan_id = f"scan_{path_hash}"
        scan_key = f"{self.scan_key_prefix}state:{scan_id}"
        
        existing_state = await self.redis_client.hgetall(scan_key)
        
        if existing_state and existing_state.get("status") == "running":
            # Resume existing scan
            logger.info("Found existing scan to resume", scan_id=scan_id, path=root_path)
            existing_state["resume"] = True
            return existing_state
        else:
            # Create new scan state
            new_state = {
                "scan_id": scan_id,
                "path": root_path,
                "started_at": datetime.utcnow().isoformat(),
                "status": "running",
                "files_processed": 0,
                "deep_scan": str(deep_scan),
                "resume": False,
                "current_directory": "",
                "completed_files": "[]",  # JSON list of completed files
                "remaining_queue": "[]"   # JSON list of remaining files
            }
            
            await self.redis_client.hset(scan_key, mapping=new_state)
            return new_state
    
    async def _build_resumable_file_queue(self, root_path: str, scan_state: Dict[str, Any]) -> List[str]:
        """Build file queue with resume capability"""
        import json
        
        if scan_state.get("resume"):
            # Resume from saved queue
            try:
                remaining_queue = json.loads(scan_state.get("remaining_queue", "[]"))
                if remaining_queue:
                    logger.info("Resuming from saved queue", files_remaining=len(remaining_queue))
                    return remaining_queue
            except json.JSONDecodeError:
                logger.warning("Failed to parse saved queue, rebuilding")
        
        # Build new file queue
        file_queue = []
        completed_files = set()
        
        if scan_state.get("resume"):
            try:
                completed_files = set(json.loads(scan_state.get("completed_files", "[]")))
            except json.JSONDecodeError:
                pass
        
        logger.info("Building file queue", path=root_path)
        
        for root, dirs, files in os.walk(root_path):
            # Process directory metadata first
            await self._process_directory(root)
            
            for filename in files:
                file_path = os.path.join(root, filename)
                
                # Skip if already completed in this scan
                if file_path in completed_files:
                    continue
                
                # Check if file extension is supported
                if self._is_supported_file(filename):
                    file_queue.append(file_path)
        
        logger.info("File queue built", total_files=len(file_queue))
        return file_queue
    
    async def _process_file_batch_with_checkpoints(self, file_paths: List[str], scan_key: str) -> int:
        """Process file batch and update checkpoints"""
        import json
        
        successful = 0
        
        for file_path in file_paths:
            try:
                if await self._process_single_file(file_path):
                    successful += 1
                    await self._mark_file_completed(scan_key, file_path)
            except Exception as e:
                logger.error("Failed to process file in batch", file=file_path, error=str(e))
        
        return successful
    
    async def _mark_file_completed(self, scan_key: str, file_path: str):
        """Mark a file as completed in the scan state"""
        import json
        
        try:
            completed_files_json = await self.redis_client.hget(scan_key, "completed_files") or "[]"
            completed_files = json.loads(completed_files_json)
            completed_files.append(file_path)
            
            # Keep only last 1000 completed files to prevent memory issues
            if len(completed_files) > 1000:
                completed_files = completed_files[-1000:]
            
            await self.redis_client.hset(scan_key, "completed_files", json.dumps(completed_files))
        except Exception as e:
            logger.warning("Failed to update completed files", error=str(e))
    
    async def _update_scan_checkpoint(self, scan_key: str, files_processed: int, remaining_queue: List[str]):
        """Update scan checkpoint with current progress"""
        import json
        
        try:
            checkpoint_data = {
                "files_processed": files_processed,
                "remaining_queue": json.dumps(remaining_queue[-10000:]),  # Keep last 10k files
                "last_checkpoint": datetime.utcnow().isoformat()
            }
            
            await self.redis_client.hset(scan_key, mapping=checkpoint_data)
            logger.debug("Checkpoint updated", files_processed=files_processed, remaining=len(remaining_queue))
            
        except Exception as e:
            logger.warning("Failed to update checkpoint", error=str(e))
    
    async def _complete_scan(self, scan_key: str, files_processed: int):
        """Mark scan as completed and cleanup state"""
        completion_data = {
            "status": "completed",
            "completed_at": datetime.utcnow().isoformat(),
            "files_processed": files_processed,
            "remaining_queue": "[]"  # Clear queue
        }
        
        await self.redis_client.hset(scan_key, mapping=completion_data)
        
        # Set expiration for completed scan state (keep for 24 hours)
        await self.redis_client.expire(scan_key, 86400)
    
    async def _mark_scan_failed(self, scan_key: str, error_message: str):
        """Mark scan as failed but keep state for potential resume"""
        failure_data = {
            "status": "failed",
            "error": error_message,
            "failed_at": datetime.utcnow().isoformat()
        }
        
        await self.redis_client.hset(scan_key, mapping=failure_data)
        
        # Keep failed scan state for 7 days for debugging
        await self.redis_client.expire(scan_key, 604800)
    
    async def resume_failed_scans(self):
        """Resume any failed or interrupted scans on startup"""
        await self._init_clients()
        
        # Find all scan state keys
        scan_keys = await self.redis_client.keys(f"{self.scan_key_prefix}state:*")
        
        resumed_count = 0
        
        for scan_key in scan_keys:
            scan_state = await self.redis_client.hgetall(scan_key)
            
            if scan_state.get("status") == "running":
                root_path = scan_state.get("path")
                deep_scan = scan_state.get("deep_scan", "False").lower() == "true"
                
                if root_path and os.path.exists(root_path):
                    logger.info("Resuming interrupted scan", path=root_path)
                    try:
                        # Resume scan in background
                        asyncio.create_task(self.scan_path(root_path, deep_scan))
                        resumed_count += 1
                    except Exception as e:
                        logger.error("Failed to resume scan", path=root_path, error=str(e))
                        await self._mark_scan_failed(scan_key, f"Resume failed: {str(e)}")
        
        if resumed_count > 0:
            logger.info("Resumed interrupted scans", count=resumed_count)
        
        return resumed_count
    
    async def cleanup_old_scan_states(self, max_age_days: int = 30):
        """Cleanup old scan states to prevent Redis bloat"""
        await self._init_clients()
        
        cutoff_time = datetime.utcnow().timestamp() - (max_age_days * 86400)
        scan_keys = await self.redis_client.keys(f"{self.scan_key_prefix}state:*")
        
        cleaned_count = 0
        
        for scan_key in scan_keys:
            scan_state = await self.redis_client.hgetall(scan_key)
            
            if scan_state.get("started_at"):
                try:
                    started_at = datetime.fromisoformat(scan_state["started_at"]).timestamp()
                    if started_at < cutoff_time:
                        await self.redis_client.delete(scan_key)
                        cleaned_count += 1
                except ValueError:
                    # Invalid timestamp, delete it
                    await self.redis_client.delete(scan_key)
                    cleaned_count += 1
        
        if cleaned_count > 0:
            logger.info("Cleaned up old scan states", count=cleaned_count)
        
        return cleaned_count
"""
API routes for the media metadata service
"""

from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from typing import List, Optional
import structlog

from database import get_redis, get_mongodb, get_mysql_session
from models.mysql_models import LibraryPath, FileType, MetadataHandler
from services.scanner import ScannerService

logger = structlog.get_logger()
router = APIRouter()


# Library Management Routes
@router.get("/libraries", response_model=List[dict])
async def list_libraries():
    """List all configured library paths"""
    async with get_mysql_session() as session:
        # TODO: Implement proper SQLAlchemy query
        return {"message": "Library listing not yet implemented"}


@router.post("/libraries")
async def add_library(path: str, name: Optional[str] = None, scan_enabled: bool = True):
    """Add a new library path"""
    async with get_mysql_session() as session:
        # TODO: Implement library path creation
        return {"message": f"Library path {path} added"}


# Scanning Routes
@router.post("/scan/start")
async def start_scan(background_tasks: BackgroundTasks, path: Optional[str] = None):
    """Start a scan operation"""
    scanner = ScannerService()
    
    if path:
        # Scan specific path
        background_tasks.add_task(scanner.scan_path, path)
        return {"message": f"Started scanning {path}"}
    else:
        # Scan all configured libraries
        background_tasks.add_task(scanner.scan_all_libraries)
        return {"message": "Started scanning all libraries"}


@router.get("/scan/status")
async def get_scan_status():
    """Get current scan status"""
    redis_client = get_redis()
    
    # Get active scan operations from Redis
    active_scans = await redis_client.keys("scan:active:*")
    
    return {
        "active_scans": len(active_scans),
        "scan_operations": active_scans
    }


@router.post("/scan/stop")
async def stop_scan():
    """Stop all scan operations"""
    # TODO: Implement scan stopping logic
    return {"message": "Scan stop requested"}


# Search Routes
@router.get("/search")
async def search_files(
    q: Optional[str] = None,
    file_type: Optional[str] = None,
    limit: int = 50,
    offset: int = 0
):
    """Search for files by metadata"""
    mongodb = get_mongodb()
    
    # Build MongoDB query
    query = {}
    if q:
        query["$text"] = {"$search": q}
    if file_type:
        query["file_category"] = file_type
    
    # Execute search
    cursor = mongodb.file_metadata.find(query).skip(offset).limit(limit)
    results = await cursor.to_list(length=limit)
    
    return {
        "results": results,
        "total": await mongodb.file_metadata.count_documents(query),
        "limit": limit,
        "offset": offset
    }


@router.get("/files/{file_id}")
async def get_file_metadata(file_id: str):
    """Get detailed metadata for a specific file"""
    mongodb = get_mongodb()
    
    try:
        from bson import ObjectId
        file_doc = await mongodb.file_metadata.find_one({"_id": ObjectId(file_id)})
        
        if not file_doc:
            raise HTTPException(status_code=404, detail="File not found")
        
        return file_doc
    except Exception as e:
        raise HTTPException(status_code=400, detail="Invalid file ID")


# Statistics Routes
@router.get("/stats")
async def get_statistics():
    """Get system statistics"""
    mongodb = get_mongodb()
    
    # Get file counts by category
    pipeline = [
        {"$group": {
            "_id": "$file_category",
            "count": {"$sum": 1},
            "total_size": {"$sum": "$file_size"}
        }}
    ]
    
    category_stats = []
    async for doc in mongodb.file_metadata.aggregate(pipeline):
        category_stats.append(doc)
    
    total_files = await mongodb.file_metadata.count_documents({})
    total_directories = await mongodb.directory_metadata.count_documents({})
    
    return {
        "total_files": total_files,
        "total_directories": total_directories,
        "by_category": category_stats
    }


# Duplicate Detection Routes
@router.get("/duplicates/stats")
async def get_duplicate_statistics():
    """Get statistics about duplicates in the system"""
    from services.duplicate_detector import DuplicateDetector
    
    detector = DuplicateDetector()
    stats = await detector.get_duplicate_statistics()
    return stats


@router.post("/duplicates/detect")
async def detect_duplicates(background_tasks: BackgroundTasks, auto_mark: bool = False):
    """Start duplicate detection process"""
    from services.duplicate_detector import DuplicateDetector
    
    detector = DuplicateDetector()
    
    if auto_mark:
        background_tasks.add_task(detector.process_all_duplicates, 100, True)
        return {"message": "Started duplicate detection with auto-marking for deletion"}
    else:
        background_tasks.add_task(detector.process_all_duplicates, 100, False)
        return {"message": "Started duplicate detection (analysis only)"}


@router.get("/duplicates/candidates")
async def get_deletion_candidates(limit: int = 100):
    """Get files marked for deletion"""
    from services.duplicate_detector import DuplicateDetector
    
    detector = DuplicateDetector()
    candidates = await detector.get_deletion_candidates(limit)
    
    return {
        "deletion_candidates": candidates,
        "total_count": len(candidates)
    }


@router.get("/duplicates/groups")
async def get_duplicate_groups(method: str = "fingerprint", limit: int = 50):
    """Get duplicate groups"""
    from services.duplicate_detector import DuplicateDetector
    
    detector = DuplicateDetector()
    
    if method == "fingerprint":
        groups = await detector.find_duplicates_by_fingerprint(limit)
    elif method == "hash":
        groups = await detector.find_duplicates_by_content_hash(limit)
    else:
        raise HTTPException(status_code=400, detail="Method must be 'fingerprint' or 'hash'")
    
    return {
        "duplicate_groups": groups,
        "method": method,
        "total_groups": len(groups)
    }


# Rules Engine Routes
@router.get("/rules")
async def list_rules(enabled_only: bool = True):
    """List all deletion rules"""
    from services.rules_engine import RulesEngine
    
    engine = RulesEngine()
    rules = await engine.get_rules(enabled_only=enabled_only)
    
    return {
        "rules": [rule.dict() for rule in rules],
        "total_count": len(rules)
    }


@router.post("/rules")
async def create_rule(rule_data: dict):
    """Create a new deletion rule"""
    from services.rules_engine import RulesEngine
    from models.rules_models import DeletionRule
    
    try:
        rule = DeletionRule(**rule_data)
        engine = RulesEngine()
        rule_id = await engine.create_rule(rule)
        
        return {"rule_id": rule_id, "message": "Rule created successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid rule data: {str(e)}")


@router.put("/rules/{rule_id}")
async def update_rule(rule_id: str, updates: dict):
    """Update an existing rule"""
    from services.rules_engine import RulesEngine
    
    engine = RulesEngine()
    success = await engine.update_rule(rule_id, updates)
    
    if success:
        return {"message": "Rule updated successfully"}
    else:
        raise HTTPException(status_code=404, detail="Rule not found")


@router.delete("/rules/{rule_id}")
async def delete_rule(rule_id: str):
    """Delete a rule"""
    from services.rules_engine import RulesEngine
    
    engine = RulesEngine()
    success = await engine.delete_rule(rule_id)
    
    if success:
        return {"message": "Rule deleted successfully"}
    else:
        raise HTTPException(status_code=404, detail="Rule not found")


@router.post("/rules/defaults")
async def create_default_rules():
    """Create default deletion rules"""
    from services.rules_engine import RulesEngine
    
    engine = RulesEngine()
    rule_ids = await engine.create_default_rules()
    
    return {
        "created_rules": rule_ids,
        "message": f"Created {len(rule_ids)} default rules"
    }


@router.post("/rules/templates")
async def create_rule_from_template(template_name: str, parameters: dict = None):
    """Create a rule from a predefined template"""
    from services.rules_engine import RulesEngine
    from utils.rule_builder import (
        delete_low_quality_mp3s, prefer_albums_over_misc, 
        delete_very_small_files, prefer_lossless_over_lossy,
        review_compilation_duplicates
    )
    
    if parameters is None:
        parameters = {}
    
    # Template mapping
    templates = {
        "delete_low_quality_mp3s": lambda: delete_low_quality_mp3s(
            parameters.get("bitrate_threshold", 128)
        ),
        "prefer_albums_over_misc": prefer_albums_over_misc,
        "delete_very_small_files": lambda: delete_very_small_files(
            parameters.get("size_threshold", 1024 * 1024)
        ),
        "prefer_lossless_over_lossy": prefer_lossless_over_lossy,
        "review_compilation_duplicates": review_compilation_duplicates
    }
    
    if template_name not in templates:
        raise HTTPException(
            status_code=400, 
            detail=f"Unknown template. Available: {list(templates.keys())}"
        )
    
    try:
        rule = templates[template_name]()
        engine = RulesEngine()
        rule_id = await engine.create_rule(rule)
        
        return {
            "rule_id": rule_id,
            "template": template_name,
            "message": "Rule created from template"
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Failed to create rule: {str(e)}")


@router.get("/rules/templates")
async def list_rule_templates():
    """List available rule templates"""
    templates = {
        "delete_low_quality_mp3s": {
            "description": "Delete MP3 files below specified bitrate when better versions exist",
            "parameters": {
                "bitrate_threshold": {"type": "int", "default": 128, "description": "Bitrate threshold in kbps"}
            }
        },
        "prefer_albums_over_misc": {
            "description": "Delete files in misc directories when album versions exist",
            "parameters": {}
        },
        "delete_very_small_files": {
            "description": "Delete very small files when larger versions exist",
            "parameters": {
                "size_threshold": {"type": "int", "default": 1048576, "description": "Size threshold in bytes"}
            }
        },
        "prefer_lossless_over_lossy": {
            "description": "Delete lossy audio files when lossless versions exist",
            "parameters": {}
        },
        "review_compilation_duplicates": {
            "description": "Mark compilation duplicates for manual review",
            "parameters": {}
        }
    }
    
    return {"templates": templates}


# Duplicate Resolution Routes
@router.post("/duplicates/resolve")
async def resolve_duplicates(
    background_tasks: BackgroundTasks,
    dry_run: bool = True,
    batch_size: int = 50
):
    """Start duplicate resolution using rules engine"""
    from services.duplicate_resolver import DuplicateResolver
    
    resolver = DuplicateResolver()
    
    if dry_run:
        # Return preview for dry runs
        preview = await resolver.preview_resolution(limit=10)
        return {
            "message": "Dry run completed",
            "preview_results": preview
        }
    else:
        # Start background resolution
        background_tasks.add_task(resolver.resolve_all_duplicates, batch_size, False)
        return {"message": "Started duplicate resolution with rules engine"}


@router.get("/duplicates/resolution-stats")
async def get_resolution_statistics():
    """Get statistics about duplicate resolutions"""
    from services.duplicate_resolver import DuplicateResolver
    
    resolver = DuplicateResolver()
    stats = await resolver.get_resolution_statistics()
    return stats


@router.get("/duplicates/preview")
async def preview_duplicate_resolution(limit: int = 10):
    """Preview duplicate resolution without making changes"""
    from services.duplicate_resolver import DuplicateResolver
    
    resolver = DuplicateResolver()
    preview = await resolver.preview_resolution(limit)
    
    return {
        "preview_results": preview,
        "total_previewed": len(preview)
    }


# Configuration Routes
@router.get("/config/file-types")
async def list_file_types():
    """List supported file types"""
    async with get_mysql_session() as session:
        # TODO: Implement file type listing
        return {"message": "File type listing not yet implemented"}


@router.get("/config/handlers")
async def list_metadata_handlers():
    """List metadata handlers"""
    async with get_mysql_session() as session:
        # TODO: Implement handler listing
        return {"message": "Handler listing not yet implemented"}
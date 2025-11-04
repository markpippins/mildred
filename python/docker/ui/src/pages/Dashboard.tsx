import React from 'react'
import {
  Grid,
  Card,
  CardContent,
  Typography,
  Box,
  LinearProgress,
  Chip,
  Button,
  Alert,
} from '@mui/material'
import {
  PlayArrow as PlayIcon,
  Stop as StopIcon,
  Refresh as RefreshIcon,
  Storage as StorageIcon,
  Scanner as ScannerIcon,
  ContentCopy as DuplicateIcon,
  Analytics as StatsIcon,
} from '@mui/icons-material'
import { useSystemStatus, useFileStats, useDuplicateStats, useScanStatus, useStartScan, useStopScan } from '@/hooks/useApi'
import { formatDistanceToNow } from 'date-fns'

const Dashboard: React.FC = () => {
  const { data: systemStatus, isLoading: systemLoading } = useSystemStatus()
  const { data: fileStats, isLoading: fileStatsLoading } = useFileStats()
  const { data: duplicateStats, isLoading: duplicateStatsLoading } = useDuplicateStats()
  const { data: scanStatus, isLoading: scanStatusLoading } = useScanStatus()
  
  const startScanMutation = useStartScan()
  const stopScanMutation = useStopScan()

  const formatNumber = (num: number) => {
    return new Intl.NumberFormat().format(num)
  }

  const formatBytes = (bytes: number) => {
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB']
    if (bytes === 0) return '0 Bytes'
    const i = Math.floor(Math.log(bytes) / Math.log(1024))
    return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + sizes[i]
  }

  const getUptimeString = (seconds: number) => {
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    return `${hours}h ${minutes}m`
  }

  const hasActiveScans = scanStatus && scanStatus.active_scans > 0
  const isScanning = hasActiveScans

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Dashboard
      </Typography>

      {/* System Status Alert */}
      {systemStatus && systemStatus.system_status !== 'running' && (
        <Alert severity="warning" sx={{ mb: 3 }}>
          System status: {systemStatus.system_status}
        </Alert>
      )}

      {/* Quick Actions */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Quick Actions
          </Typography>
          <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
            <Button
              variant="contained"
              startIcon={isScanning ? <StopIcon /> : <PlayIcon />}
              onClick={() => isScanning ? stopScanMutation.mutate() : startScanMutation.mutate()}
              disabled={startScanMutation.isPending || stopScanMutation.isPending}
              color={isScanning ? 'error' : 'primary'}
            >
              {isScanning ? 'Stop Scan' : 'Start Scan'}
            </Button>
            
            <Button
              variant="outlined"
              startIcon={<RefreshIcon />}
              onClick={() => window.location.reload()}
            >
              Refresh Data
            </Button>
          </Box>
        </CardContent>
      </Card>

      <Grid container spacing={3}>
        {/* System Overview */}
        <Grid item xs={12} md={6} lg={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <StorageIcon color="primary" sx={{ mr: 1 }} />
                <Typography variant="h6">System</Typography>
              </Box>
              
              {systemLoading ? (
                <LinearProgress />
              ) : systemStatus ? (
                <Box>
                  <Typography variant="body2" color="text.secondary">
                    Version: {systemStatus.version}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Uptime: {getUptimeString(systemStatus.uptime_seconds)}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Started: {formatDistanceToNow(new Date(systemStatus.startup_time))} ago
                  </Typography>
                  <Box sx={{ mt: 1 }}>
                    <Chip
                      label={systemStatus.system_status}
                      color={systemStatus.system_status === 'running' ? 'success' : 'warning'}
                      size="small"
                    />
                  </Box>
                </Box>
              ) : (
                <Typography color="error">Failed to load system status</Typography>
              )}
            </CardContent>
          </Card>
        </Grid>

        {/* File Statistics */}
        <Grid item xs={12} md={6} lg={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <StatsIcon color="primary" sx={{ mr: 1 }} />
                <Typography variant="h6">Files</Typography>
              </Box>
              
              {fileStatsLoading ? (
                <LinearProgress />
              ) : fileStats ? (
                <Box>
                  <Typography variant="h4" color="primary">
                    {formatNumber(fileStats.total_files)}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Total Files Indexed
                  </Typography>
                  <Typography variant="body2" color="text.secondary" sx={{ mt: 1 }}>
                    {formatNumber(fileStats.total_directories)} directories
                  </Typography>
                  
                  {fileStats.by_category.length > 0 && (
                    <Box sx={{ mt: 2 }}>
                      {fileStats.by_category.slice(0, 3).map((category) => (
                        <Box key={category._id} sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                          <Typography variant="caption" color="text.secondary">
                            {category._id}:
                          </Typography>
                          <Typography variant="caption" color="text.secondary">
                            {formatNumber(category.count)}
                          </Typography>
                        </Box>
                      ))}
                    </Box>
                  )}
                </Box>
              ) : (
                <Typography color="error">Failed to load file statistics</Typography>
              )}
            </CardContent>
          </Card>
        </Grid>

        {/* Scan Status */}
        <Grid item xs={12} md={6} lg={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <ScannerIcon color="primary" sx={{ mr: 1 }} />
                <Typography variant="h6">Scanning</Typography>
              </Box>
              
              {scanStatusLoading ? (
                <LinearProgress />
              ) : scanStatus ? (
                <Box>
                  <Typography variant="h4" color={hasActiveScans ? 'warning' : 'success'}>
                    {scanStatus.active_scans}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Active Scans
                  </Typography>
                  
                  {hasActiveScans && scanStatus.scans.length > 0 && (
                    <Box sx={{ mt: 2 }}>
                      {scanStatus.scans.slice(0, 2).map((scan, index) => (
                        <Box key={index} sx={{ mb: 1 }}>
                          <Typography variant="caption" color="text.secondary" noWrap>
                            {scan.path}
                          </Typography>
                          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                            <Chip
                              label={scan.status}
                              size="small"
                              color={scan.status === 'running' ? 'warning' : 'default'}
                            />
                            <Typography variant="caption" color="text.secondary">
                              {formatNumber(parseInt(scan.files_processed))} files
                            </Typography>
                          </Box>
                        </Box>
                      ))}
                    </Box>
                  )}
                </Box>
              ) : (
                <Typography color="error">Failed to load scan status</Typography>
              )}
            </CardContent>
          </Card>
        </Grid>

        {/* Duplicate Statistics */}
        <Grid item xs={12} md={6} lg={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <DuplicateIcon color="primary" sx={{ mr: 1 }} />
                <Typography variant="h6">Duplicates</Typography>
              </Box>
              
              {duplicateStatsLoading ? (
                <LinearProgress />
              ) : duplicateStats ? (
                <Box>
                  <Typography variant="h4" color="warning">
                    {formatNumber(duplicateStats.duplicate_groups)}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Duplicate Groups
                  </Typography>
                  
                  <Box sx={{ mt: 1 }}>
                    <Typography variant="body2" color="text.secondary">
                      {formatNumber(duplicateStats.duplicate_files)} total duplicates
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      {formatNumber(duplicateStats.deletion_candidates)} marked for deletion
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      {formatNumber(duplicateStats.best_quality_files)} best quality marked
                    </Typography>
                  </Box>
                </Box>
              ) : (
                <Typography color="error">Failed to load duplicate statistics</Typography>
              )}
            </CardContent>
          </Card>
        </Grid>

        {/* Recent Activity */}
        <Grid item xs={12}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Recent Activity
              </Typography>
              
              {scanStatus && scanStatus.scans.length > 0 ? (
                <Box>
                  {scanStatus.scans.map((scan, index) => (
                    <Box
                      key={index}
                      sx={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'center',
                        py: 1,
                        borderBottom: index < scanStatus.scans.length - 1 ? 1 : 0,
                        borderColor: 'divider',
                      }}
                    >
                      <Box>
                        <Typography variant="body1">{scan.path}</Typography>
                        <Typography variant="caption" color="text.secondary">
                          Started: {formatDistanceToNow(new Date(scan.started_at))} ago
                        </Typography>
                      </Box>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <Typography variant="body2" color="text.secondary">
                          {formatNumber(parseInt(scan.files_processed))} files
                        </Typography>
                        <Chip
                          label={scan.status}
                          size="small"
                          color={
                            scan.status === 'running' ? 'warning' :
                            scan.status === 'completed' ? 'success' : 'error'
                          }
                        />
                      </Box>
                    </Box>
                  ))}
                </Box>
              ) : (
                <Typography color="text.secondary">
                  No recent scan activity
                </Typography>
              )}
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  )
}

export default Dashboard
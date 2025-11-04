import React, { useState } from 'react'
import {
  Box,
  Typography,
  Card,
  CardContent,
  Button,
  Grid,
  LinearProgress,
  Chip,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  FormControlLabel,
  Switch,
  Alert,
  IconButton,
  Tooltip,
} from '@mui/material'
import {
  PlayArrow as PlayIcon,
  Stop as StopIcon,
  Refresh as RefreshIcon,
  Scanner as ScannerIcon,
  Folder as FolderIcon,
  Settings as SettingsIcon,
  Info as InfoIcon,
} from '@mui/icons-material'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { useScanStatus, useStartScan, useStopScan, useLibraries } from '@/hooks/useApi'
import { formatDistanceToNow } from 'date-fns'
import type { StartScanForm } from '@/types/api'

const scanFormSchema = z.object({
  path: z.string().optional(),
  deep_scan: z.boolean().default(false),
})

type ScanFormData = z.infer<typeof scanFormSchema>

const Scanning: React.FC = () => {
  const [startScanDialogOpen, setStartScanDialogOpen] = useState(false)
  
  const { data: scanStatus, isLoading: scanStatusLoading } = useScanStatus()
  const { data: libraries } = useLibraries()
  const startScanMutation = useStartScan()
  const stopScanMutation = useStopScan()

  const { control, handleSubmit, reset, watch } = useForm<ScanFormData>({
    resolver: zodResolver(scanFormSchema),
    defaultValues: {
      deep_scan: false,
    },
  })

  const watchedPath = watch('path')

  const handleStartScanDialog = () => {
    reset()
    setStartScanDialogOpen(true)
  }

  const handleCloseScanDialog = () => {
    setStartScanDialogOpen(false)
    reset()
  }

  const handleSubmitScan = (data: ScanFormData) => {
    const scanData: StartScanForm = {}
    if (data.path) scanData.path = data.path
    if (data.deep_scan) scanData.deep_scan = data.deep_scan

    startScanMutation.mutate(scanData, {
      onSuccess: () => {
        handleCloseScanDialog()
      },
    })
  }

  const handleQuickScan = (path?: string, deepScan: boolean = false) => {
    const scanData: StartScanForm = {}
    if (path) scanData.path = path
    if (deepScan) scanData.deep_scan = deepScan

    startScanMutation.mutate(scanData)
  }

  const formatNumber = (num: string | number) => {
    const n = typeof num === 'string' ? parseInt(num) : num
    return new Intl.NumberFormat().format(n)
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'running': return 'warning'
      case 'completed': return 'success'
      case 'failed': return 'error'
      default: return 'default'
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'running': return <ScannerIcon className="spin" />
      case 'completed': return <ScannerIcon />
      case 'failed': return <ScannerIcon />
      default: return <ScannerIcon />
    }
  }

  const hasActiveScans = scanStatus && scanStatus.active_scans > 0
  const activeScanOperations = scanStatus?.scans.filter(scan => scan.status === 'running') || []

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4">Scanning</Typography>
        <Box sx={{ display: 'flex', gap: 1 }}>
          <Button
            variant="outlined"
            startIcon={<RefreshIcon />}
            onClick={() => window.location.reload()}
          >
            Refresh
          </Button>
          <Button
            variant="contained"
            startIcon={hasActiveScans ? <StopIcon /> : <PlayIcon />}
            onClick={() => hasActiveScans ? stopScanMutation.mutate() : handleStartScanDialog()}
            disabled={startScanMutation.isPending || stopScanMutation.isPending}
            color={hasActiveScans ? 'error' : 'primary'}
          >
            {hasActiveScans ? 'Stop All Scans' : 'Start Scan'}
          </Button>
        </Box>
      </Box>

      {/* Scan Status Overview */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <ScannerIcon color="primary" sx={{ mr: 1 }} />
                <Typography variant="h6">Active Scans</Typography>
              </Box>
              
              {scanStatusLoading ? (
                <LinearProgress />
              ) : (
                <Box>
                  <Typography variant="h3" color={hasActiveScans ? 'warning' : 'success'}>
                    {scanStatus?.active_scans || 0}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Currently Running
                  </Typography>
                </Box>
              )}
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <FolderIcon color="primary" sx={{ mr: 1 }} />
                <Typography variant="h6">Library Paths</Typography>
              </Box>
              
              <Box>
                <Typography variant="h3" color="primary">
                  {libraries?.length || 0}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Configured Paths
                </Typography>
                {libraries && (
                  <Typography variant="caption" color="text.secondary">
                    {libraries.filter(lib => lib.scan_enabled).length} enabled for scanning
                  </Typography>
                )}
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <InfoIcon color="primary" sx={{ mr: 1 }} />
                <Typography variant="h6">Total Operations</Typography>
              </Box>
              
              <Box>
                <Typography variant="h3" color="info">
                  {scanStatus?.scans.length || 0}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Recent Scans
                </Typography>
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Quick Actions */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Quick Actions
          </Typography>
          <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
            <Button
              variant="outlined"
              startIcon={<PlayIcon />}
              onClick={() => handleQuickScan()}
              disabled={startScanMutation.isPending || hasActiveScans}
            >
              Scan All Libraries
            </Button>
            <Button
              variant="outlined"
              startIcon={<ScannerIcon />}
              onClick={() => handleQuickScan(undefined, true)}
              disabled={startScanMutation.isPending || hasActiveScans}
            >
              Deep Scan All
            </Button>
            {libraries && libraries.length > 0 && (
              <>
                {libraries.slice(0, 3).map((library) => (
                  <Button
                    key={library.id}
                    variant="outlined"
                    size="small"
                    startIcon={<FolderIcon />}
                    onClick={() => handleQuickScan(library.path)}
                    disabled={startScanMutation.isPending || hasActiveScans}
                  >
                    Scan {library.name || library.path.split('/').pop()}
                  </Button>
                ))}
              </>
            )}
          </Box>
        </CardContent>
      </Card>

      {/* Active Scans Progress */}
      {hasActiveScans && (
        <Card sx={{ mb: 3 }}>
          <CardContent>
            <Typography variant="h6" gutterBottom sx={{ display: 'flex', alignItems: 'center' }}>
              <ScannerIcon className="pulse" sx={{ mr: 1 }} />
              Active Scan Progress
            </Typography>
            
            {activeScanOperations.map((scan, index) => (
              <Box key={index} sx={{ mb: 2 }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
                  <Typography variant="body1" sx={{ fontFamily: 'monospace' }}>
                    {scan.path}
                  </Typography>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Typography variant="body2" color="text.secondary">
                      {formatNumber(scan.files_processed)} files processed
                    </Typography>
                    <Chip
                      icon={getStatusIcon(scan.status)}
                      label={scan.status}
                      size="small"
                      color={getStatusColor(scan.status)}
                    />
                  </Box>
                </Box>
                <LinearProgress variant="indeterminate" />
                <Typography variant="caption" color="text.secondary">
                  Started: {formatDistanceToNow(new Date(scan.started_at))} ago
                  {scan.deep_scan === 'true' && ' • Deep Scan'}
                </Typography>
              </Box>
            ))}
          </CardContent>
        </Card>
      )}

      {/* Scan History */}
      <Card>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Recent Scan Operations
          </Typography>
          
          {scanStatusLoading ? (
            <LinearProgress />
          ) : scanStatus && scanStatus.scans.length > 0 ? (
            <TableContainer component={Paper} variant="outlined">
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>Path</TableCell>
                    <TableCell>Status</TableCell>
                    <TableCell>Files Processed</TableCell>
                    <TableCell>Started</TableCell>
                    <TableCell>Type</TableCell>
                    <TableCell>Actions</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {scanStatus.scans.map((scan, index) => (
                    <TableRow key={index}>
                      <TableCell>
                        <Typography variant="body2" sx={{ fontFamily: 'monospace' }}>
                          {scan.path}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Chip
                          icon={getStatusIcon(scan.status)}
                          label={scan.status}
                          size="small"
                          color={getStatusColor(scan.status)}
                        />
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2">
                          {formatNumber(scan.files_processed)}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2">
                          {formatDistanceToNow(new Date(scan.started_at))} ago
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Box sx={{ display: 'flex', gap: 0.5 }}>
                          {scan.deep_scan === 'true' && (
                            <Chip label="Deep" size="small" color="info" />
                          )}
                          <Chip label="Standard" size="small" color="default" />
                        </Box>
                      </TableCell>
                      <TableCell>
                        {scan.status === 'running' && (
                          <Tooltip title="Stop this scan">
                            <IconButton
                              size="small"
                              color="error"
                              onClick={() => stopScanMutation.mutate()}
                              disabled={stopScanMutation.isPending}
                            >
                              <StopIcon />
                            </IconButton>
                          </Tooltip>
                        )}
                        {scan.error && (
                          <Tooltip title={scan.error}>
                            <IconButton size="small" color="error">
                              <InfoIcon />
                            </IconButton>
                          </Tooltip>
                        )}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          ) : (
            <Box sx={{ textAlign: 'center', py: 4 }}>
              <ScannerIcon sx={{ fontSize: 64, color: 'text.secondary', mb: 2 }} />
              <Typography variant="h6" color="text.secondary" gutterBottom>
                No Scan Operations Yet
              </Typography>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                Start your first scan to begin indexing your media collection
              </Typography>
              <Button
                variant="contained"
                startIcon={<PlayIcon />}
                onClick={handleStartScanDialog}
              >
                Start Your First Scan
              </Button>
            </Box>
          )}
        </CardContent>
      </Card>

      {/* Start Scan Dialog */}
      <Dialog open={startScanDialogOpen} onClose={handleCloseScanDialog} maxWidth="sm" fullWidth>
        <form onSubmit={handleSubmit(handleSubmitScan)}>
          <DialogTitle>Start New Scan</DialogTitle>
          <DialogContent>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 1 }}>
              <Alert severity="info">
                Leave path empty to scan all configured library paths, or specify a specific path to scan.
              </Alert>

              <Controller
                name="path"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    label="Specific Path (Optional)"
                    fullWidth
                    helperText="Leave empty to scan all library paths"
                    placeholder="/media/music/new-albums"
                  />
                )}
              />

              <Controller
                name="deep_scan"
                control={control}
                render={({ field }) => (
                  <FormControlLabel
                    control={<Switch {...field} checked={field.value} />}
                    label="Deep Scan"
                  />
                )}
              />

              <Alert severity="warning">
                Deep scan will re-process all files, even if they've been scanned before. 
                This is useful after updating metadata extraction rules but takes longer.
              </Alert>

              {watchedPath && (
                <Alert severity="info">
                  Scanning specific path: <code>{watchedPath}</code>
                </Alert>
              )}
            </Box>
          </DialogContent>
          <DialogActions>
            <Button onClick={handleCloseScanDialog}>Cancel</Button>
            <Button
              type="submit"
              variant="contained"
              disabled={startScanMutation.isPending}
              startIcon={<PlayIcon />}
            >
              Start Scan
            </Button>
          </DialogActions>
        </form>
      </Dialog>
    </Box>
  )
}

export default Scanning
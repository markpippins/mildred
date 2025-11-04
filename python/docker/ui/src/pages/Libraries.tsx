import React, { useState } from 'react'
import {
  Box,
  Typography,
  Card,
  CardContent,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Chip,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  FormControlLabel,
  Switch,
  Alert,
  Tooltip,
} from '@mui/material'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Folder as FolderIcon,
  Scanner as ScannerIcon,
  Settings as SettingsIcon,
} from '@mui/icons-material'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { useLibraries, useCreateLibrary, useUpdateLibrary, useDeleteLibrary } from '@/hooks/useApi'
import type { LibraryPath, CreateLibraryPathForm } from '@/types/api'

const librarySchema = z.object({
  path: z.string().min(1, 'Path is required'),
  name: z.string().optional(),
  scan_enabled: z.boolean().default(true),
  deep_scan: z.boolean().default(false),
  path_type: z.enum(['album', 'compilation', 'recent', 'general']).default('general'),
  auto_delete_duplicates: z.boolean().default(false),
  delete_lower_quality: z.boolean().default(true),
  quality_threshold: z.number().min(0).max(1000).default(100),
  preferred_formats: z.string().default('FLAC,MP3'),
  deletion_priority: z.number().min(0).max(100).default(50),
})

type LibraryFormData = z.infer<typeof librarySchema>

const Libraries: React.FC = () => {
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingLibrary, setEditingLibrary] = useState<LibraryPath | null>(null)
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false)
  const [libraryToDelete, setLibraryToDelete] = useState<LibraryPath | null>(null)

  const { data: libraries, isLoading, error } = useLibraries()
  const createLibraryMutation = useCreateLibrary()
  const updateLibraryMutation = useUpdateLibrary()
  const deleteLibraryMutation = useDeleteLibrary()

  const { control, handleSubmit, reset, formState: { errors } } = useForm<LibraryFormData>({
    resolver: zodResolver(librarySchema),
    defaultValues: {
      scan_enabled: true,
      deep_scan: false,
      path_type: 'general',
      auto_delete_duplicates: false,
      delete_lower_quality: true,
      quality_threshold: 100,
      preferred_formats: 'FLAC,MP3',
      deletion_priority: 50,
    },
  })

  const handleOpenDialog = (library?: LibraryPath) => {
    if (library) {
      setEditingLibrary(library)
      reset({
        path: library.path,
        name: library.name || '',
        scan_enabled: library.scan_enabled,
        deep_scan: library.deep_scan,
        path_type: library.path_type,
        auto_delete_duplicates: library.auto_delete_duplicates,
        delete_lower_quality: library.delete_lower_quality,
        quality_threshold: library.quality_threshold,
        preferred_formats: library.preferred_formats,
        deletion_priority: library.deletion_priority,
      })
    } else {
      setEditingLibrary(null)
      reset()
    }
    setDialogOpen(true)
  }

  const handleCloseDialog = () => {
    setDialogOpen(false)
    setEditingLibrary(null)
    reset()
  }

  const handleSubmitForm = (data: LibraryFormData) => {
    if (editingLibrary) {
      updateLibraryMutation.mutate(
        { id: editingLibrary.id, data },
        {
          onSuccess: () => {
            handleCloseDialog()
          },
        }
      )
    } else {
      createLibraryMutation.mutate(data, {
        onSuccess: () => {
          handleCloseDialog()
        },
      })
    }
  }

  const handleDeleteClick = (library: LibraryPath) => {
    setLibraryToDelete(library)
    setDeleteConfirmOpen(true)
  }

  const handleConfirmDelete = () => {
    if (libraryToDelete) {
      deleteLibraryMutation.mutate(libraryToDelete.id, {
        onSuccess: () => {
          setDeleteConfirmOpen(false)
          setLibraryToDelete(null)
        },
      })
    }
  }

  const getPathTypeColor = (type: string) => {
    switch (type) {
      case 'album': return 'primary'
      case 'compilation': return 'secondary'
      case 'recent': return 'warning'
      default: return 'default'
    }
  }

  const getPriorityColor = (priority: number) => {
    if (priority >= 80) return 'error'
    if (priority >= 60) return 'warning'
    return 'success'
  }

  if (error) {
    return (
      <Alert severity="error">
        Failed to load library paths. Please check your connection and try again.
      </Alert>
    )
  }

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4">Library Paths</Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => handleOpenDialog()}
        >
          Add Library Path
        </Button>
      </Box>

      <Card>
        <CardContent>
          <Typography variant="h6" gutterBottom sx={{ display: 'flex', alignItems: 'center' }}>
            <FolderIcon sx={{ mr: 1 }} />
            Configured Paths
          </Typography>
          
          {isLoading ? (
            <Typography>Loading library paths...</Typography>
          ) : libraries && libraries.length > 0 ? (
            <TableContainer component={Paper} variant="outlined">
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>Path</TableCell>
                    <TableCell>Name</TableCell>
                    <TableCell>Type</TableCell>
                    <TableCell>Scan Settings</TableCell>
                    <TableCell>Duplicate Rules</TableCell>
                    <TableCell>Actions</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {libraries.map((library) => (
                    <TableRow key={library.id}>
                      <TableCell>
                        <Typography variant="body2" sx={{ fontFamily: 'monospace' }}>
                          {library.path}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        {library.name || (
                          <Typography variant="body2" color="text.secondary" fontStyle="italic">
                            No name
                          </Typography>
                        )}
                      </TableCell>
                      <TableCell>
                        <Chip
                          label={library.path_type}
                          size="small"
                          color={getPathTypeColor(library.path_type)}
                        />
                      </TableCell>
                      <TableCell>
                        <Box sx={{ display: 'flex', gap: 0.5, flexWrap: 'wrap' }}>
                          <Chip
                            label={library.scan_enabled ? 'Enabled' : 'Disabled'}
                            size="small"
                            color={library.scan_enabled ? 'success' : 'default'}
                          />
                          {library.deep_scan && (
                            <Chip label="Deep" size="small" color="info" />
                          )}
                        </Box>
                      </TableCell>
                      <TableCell>
                        <Box sx={{ display: 'flex', gap: 0.5, flexWrap: 'wrap' }}>
                          {library.auto_delete_duplicates && (
                            <Chip label="Auto Delete" size="small" color="warning" />
                          )}
                          <Tooltip title={`Deletion Priority: ${library.deletion_priority}`}>
                            <Chip
                              label={`P${library.deletion_priority}`}
                              size="small"
                              color={getPriorityColor(library.deletion_priority)}
                            />
                          </Tooltip>
                        </Box>
                      </TableCell>
                      <TableCell>
                        <Box sx={{ display: 'flex', gap: 0.5 }}>
                          <IconButton
                            size="small"
                            onClick={() => handleOpenDialog(library)}
                            color="primary"
                          >
                            <EditIcon />
                          </IconButton>
                          <IconButton
                            size="small"
                            onClick={() => handleDeleteClick(library)}
                            color="error"
                          >
                            <DeleteIcon />
                          </IconButton>
                        </Box>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          ) : (
            <Box sx={{ textAlign: 'center', py: 4 }}>
              <FolderIcon sx={{ fontSize: 64, color: 'text.secondary', mb: 2 }} />
              <Typography variant="h6" color="text.secondary" gutterBottom>
                No Library Paths Configured
              </Typography>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                Add library paths to start scanning your media collection
              </Typography>
              <Button
                variant="contained"
                startIcon={<AddIcon />}
                onClick={() => handleOpenDialog()}
              >
                Add Your First Library Path
              </Button>
            </Box>
          )}
        </CardContent>
      </Card>

      {/* Add/Edit Dialog */}
      <Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="md" fullWidth>
        <form onSubmit={handleSubmit(handleSubmitForm)}>
          <DialogTitle>
            {editingLibrary ? 'Edit Library Path' : 'Add Library Path'}
          </DialogTitle>
          <DialogContent>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 1 }}>
              <Controller
                name="path"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    label="Path"
                    fullWidth
                    error={!!errors.path}
                    helperText={errors.path?.message || 'Absolute path to the directory (e.g., /media/music)'}
                    placeholder="/media/music"
                  />
                )}
              />

              <Controller
                name="name"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    label="Name (Optional)"
                    fullWidth
                    helperText="Friendly name for this library path"
                    placeholder="Music Collection"
                  />
                )}
              />

              <Controller
                name="path_type"
                control={control}
                render={({ field }) => (
                  <FormControl fullWidth>
                    <InputLabel>Path Type</InputLabel>
                    <Select {...field} label="Path Type">
                      <MenuItem value="album">Album</MenuItem>
                      <MenuItem value="compilation">Compilation</MenuItem>
                      <MenuItem value="recent">Recent</MenuItem>
                      <MenuItem value="general">General</MenuItem>
                    </Select>
                  </FormControl>
                )}
              />

              <Box sx={{ display: 'flex', gap: 2 }}>
                <Controller
                  name="scan_enabled"
                  control={control}
                  render={({ field }) => (
                    <FormControlLabel
                      control={<Switch {...field} checked={field.value} />}
                      label="Enable Scanning"
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
              </Box>

              <Typography variant="h6" sx={{ mt: 2, display: 'flex', alignItems: 'center' }}>
                <SettingsIcon sx={{ mr: 1 }} />
                Duplicate Deletion Rules
              </Typography>

              <Box sx={{ display: 'flex', gap: 2 }}>
                <Controller
                  name="auto_delete_duplicates"
                  control={control}
                  render={({ field }) => (
                    <FormControlLabel
                      control={<Switch {...field} checked={field.value} />}
                      label="Auto Delete Duplicates"
                    />
                  )}
                />

                <Controller
                  name="delete_lower_quality"
                  control={control}
                  render={({ field }) => (
                    <FormControlLabel
                      control={<Switch {...field} checked={field.value} />}
                      label="Delete Lower Quality"
                    />
                  )}
                />
              </Box>

              <Box sx={{ display: 'flex', gap: 2 }}>
                <Controller
                  name="quality_threshold"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      label="Quality Threshold"
                      type="number"
                      fullWidth
                      error={!!errors.quality_threshold}
                      helperText={errors.quality_threshold?.message || 'Minimum quality difference to trigger deletion'}
                      inputProps={{ min: 0, max: 1000 }}
                    />
                  )}
                />

                <Controller
                  name="deletion_priority"
                  control={control}
                  render={({ field }) => (
                    <TextField
                      {...field}
                      label="Deletion Priority"
                      type="number"
                      fullWidth
                      error={!!errors.deletion_priority}
                      helperText={errors.deletion_priority?.message || 'Higher = more likely to be deleted (0-100)'}
                      inputProps={{ min: 0, max: 100 }}
                    />
                  )}
                />
              </Box>

              <Controller
                name="preferred_formats"
                control={control}
                render={({ field }) => (
                  <TextField
                    {...field}
                    label="Preferred Formats"
                    fullWidth
                    helperText="Comma-separated list of preferred formats (e.g., FLAC,MP3)"
                    placeholder="FLAC,MP3,OGG"
                  />
                )}
              />
            </Box>
          </DialogContent>
          <DialogActions>
            <Button onClick={handleCloseDialog}>Cancel</Button>
            <Button
              type="submit"
              variant="contained"
              disabled={createLibraryMutation.isPending || updateLibraryMutation.isPending}
            >
              {editingLibrary ? 'Update' : 'Create'}
            </Button>
          </DialogActions>
        </form>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <Dialog open={deleteConfirmOpen} onClose={() => setDeleteConfirmOpen(false)}>
        <DialogTitle>Confirm Deletion</DialogTitle>
        <DialogContent>
          <Typography>
            Are you sure you want to delete the library path "{libraryToDelete?.path}"?
            This will not delete the actual files, only remove it from the scanning configuration.
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteConfirmOpen(false)}>Cancel</Button>
          <Button
            onClick={handleConfirmDelete}
            color="error"
            variant="contained"
            disabled={deleteLibraryMutation.isPending}
          >
            Delete
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}

export default Libraries
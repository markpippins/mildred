import React from 'react'
import {
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
  LinearProgress,
  Alert,
} from '@mui/material'
import {
  Analytics as AnalyticsIcon,
  Storage as StorageIcon,
  ContentCopy as DuplicateIcon,
  Category as CategoryIcon,
} from '@mui/icons-material'
import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'
import { useFileStats, useDuplicateStats } from '@/hooks/useApi'

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8']

const Statistics: React.FC = () => {
  const { data: fileStats, isLoading: fileStatsLoading, error: fileStatsError } = useFileStats()
  const { data: duplicateStats, isLoading: duplicateStatsLoading, error: duplicateStatsError } = useDuplicateStats()

  const formatNumber = (num: number) => {
    return new Intl.NumberFormat().format(num)
  }

  const formatBytes = (bytes: number) => {
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB']
    if (bytes === 0) return '0 Bytes'
    const i = Math.floor(Math.log(bytes) / Math.log(1024))
    return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + sizes[i]
  }

  // Prepare chart data
  const categoryChartData = fileStats?.by_category.map((category, index) => ({
    name: category._id || 'Unknown',
    value: category.count,
    size: category.total_size,
    color: COLORS[index % COLORS.length]
  })) || []

  const duplicateChartData = duplicateStats ? [
    { name: 'Unique Files', value: (fileStats?.total_files || 0) - duplicateStats.duplicate_files },
    { name: 'Duplicate Files', value: duplicateStats.duplicate_files },
    { name: 'Deletion Candidates', value: duplicateStats.deletion_candidates },
  ] : []

  if (fileStatsError || duplicateStatsError) {
    return (
      <Alert severity="error">
        Failed to load statistics. Please check your connection and try again.
      </Alert>
    )
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Statistics
      </Typography>

      {/* Overview Cards */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid item xs={12} md={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <StorageIcon color="primary" sx={{ mr: 1 }} />
                <Typography variant="h6">Total Files</Typography>
              </Box>
              
              {fileStatsLoading ? (
                <LinearProgress />
              ) : fileStats ? (
                <Box>
                  <Typography variant="h3" color="primary">
                    {formatNumber(fileStats.total_files)}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Indexed Files
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    {formatNumber(fileStats.total_directories)} directories
                  </Typography>
                </Box>
              ) : (
                <Typography color="error">Failed to load</Typography>
              )}
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <CategoryIcon color="primary" sx={{ mr: 1 }} />
                <Typography variant="h6">Categories</Typography>
              </Box>
              
              {fileStatsLoading ? (
                <LinearProgress />
              ) : fileStats ? (
                <Box>
                  <Typography variant="h3" color="primary">
                    {fileStats.by_category.length}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    File Types
                  </Typography>
                  {fileStats.by_category.length > 0 && (
                    <Typography variant="caption" color="text.secondary">
                      Largest: {fileStats.by_category[0]._id} ({formatNumber(fileStats.by_category[0].count)})
                    </Typography>
                  )}
                </Box>
              ) : (
                <Typography color="error">Failed to load</Typography>
              )}
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={3}>
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
                  <Typography variant="h3" color="warning">
                    {formatNumber(duplicateStats.duplicate_groups)}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Duplicate Groups
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    {formatNumber(duplicateStats.duplicate_files)} total duplicates
                  </Typography>
                </Box>
              ) : (
                <Typography color="error">Failed to load</Typography>
              )}
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <AnalyticsIcon color="primary" sx={{ mr: 1 }} />
                <Typography variant="h6">Storage</Typography>
              </Box>
              
              {fileStatsLoading ? (
                <LinearProgress />
              ) : fileStats ? (
                <Box>
                  <Typography variant="h3" color="primary">
                    {formatBytes(fileStats.by_category.reduce((sum, cat) => sum + cat.total_size, 0))}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Total Size
                  </Typography>
                </Box>
              ) : (
                <Typography color="error">Failed to load</Typography>
              )}
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Charts */}
      <Grid container spacing={3}>
        {/* File Categories Pie Chart */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Files by Category
              </Typography>
              
              {fileStatsLoading ? (
                <LinearProgress />
              ) : categoryChartData.length > 0 ? (
                <ResponsiveContainer width="100%" height={300}>
                  <PieChart>
                    <Pie
                      data={categoryChartData}
                      cx="50%"
                      cy="50%"
                      labelLine={false}
                      label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                      outerRadius={80}
                      fill="#8884d8"
                      dataKey="value"
                    >
                      {categoryChartData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                      ))}
                    </Pie>
                    <Tooltip formatter={(value) => formatNumber(value as number)} />
                  </PieChart>
                </ResponsiveContainer>
              ) : (
                <Typography color="text.secondary" sx={{ textAlign: 'center', py: 4 }}>
                  No data available
                </Typography>
              )}
            </CardContent>
          </Card>
        </Grid>

        {/* File Categories Bar Chart */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                File Count by Category
              </Typography>
              
              {fileStatsLoading ? (
                <LinearProgress />
              ) : categoryChartData.length > 0 ? (
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart data={categoryChartData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="name" />
                    <YAxis tickFormatter={formatNumber} />
                    <Tooltip formatter={(value) => formatNumber(value as number)} />
                    <Bar dataKey="value" fill="#8884d8" />
                  </BarChart>
                </ResponsiveContainer>
              ) : (
                <Typography color="text.secondary" sx={{ textAlign: 'center', py: 4 }}>
                  No data available
                </Typography>
              )}
            </CardContent>
          </Card>
        </Grid>

        {/* Duplicate Analysis */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Duplicate Analysis
              </Typography>
              
              {duplicateStatsLoading ? (
                <LinearProgress />
              ) : duplicateStats ? (
                <Box>
                  <Box sx={{ mb: 2 }}>
                    <Typography variant="body2" color="text.secondary">
                      Duplicate Groups: {formatNumber(duplicateStats.duplicate_groups)}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      Total Duplicate Files: {formatNumber(duplicateStats.duplicate_files)}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      Deletion Candidates: {formatNumber(duplicateStats.deletion_candidates)}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      Best Quality Marked: {formatNumber(duplicateStats.best_quality_files)}
                    </Typography>
                  </Box>

                  {duplicateChartData.length > 0 && (
                    <ResponsiveContainer width="100%" height={200}>
                      <PieChart>
                        <Pie
                          data={duplicateChartData}
                          cx="50%"
                          cy="50%"
                          labelLine={false}
                          label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                          outerRadius={60}
                          fill="#8884d8"
                          dataKey="value"
                        >
                          {duplicateChartData.map((entry, index) => (
                            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                          ))}
                        </Pie>
                        <Tooltip formatter={(value) => formatNumber(value as number)} />
                      </PieChart>
                    </ResponsiveContainer>
                  )}
                </Box>
              ) : (
                <Typography color="error">Failed to load duplicate statistics</Typography>
              )}
            </CardContent>
          </Card>
        </Grid>

        {/* Storage by Category */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Storage by Category
              </Typography>
              
              {fileStatsLoading ? (
                <LinearProgress />
              ) : categoryChartData.length > 0 ? (
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart data={categoryChartData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="name" />
                    <YAxis tickFormatter={formatBytes} />
                    <Tooltip formatter={(value) => formatBytes(value as number)} />
                    <Bar dataKey="size" fill="#82ca9d" />
                  </BarChart>
                </ResponsiveContainer>
              ) : (
                <Typography color="text.secondary" sx={{ textAlign: 'center', py: 4 }}>
                  No data available
                </Typography>
              )}
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  )
}

export default Statistics
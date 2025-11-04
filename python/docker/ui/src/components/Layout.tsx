import React, { useState } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import {
  AppBar,
  Box,
  CssBaseline,
  Drawer,
  IconButton,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Toolbar,
  Typography,
  Chip,
  Tooltip,
} from '@mui/material'
import {
  Menu as MenuIcon,
  Dashboard as DashboardIcon,
  Folder as FolderIcon,
  Scanner as ScannerIcon,
  Analytics as AnalyticsIcon,
  Brightness4 as DarkModeIcon,
  Brightness7 as LightModeIcon,
  Circle as CircleIcon,
} from '@mui/icons-material'
import { useTheme } from '@/contexts/ThemeContext'
import { useSystemStatus, useHealth } from '@/hooks/useApi'

const drawerWidth = 240

interface LayoutProps {
  children: React.ReactNode
}

const Layout: React.FC<LayoutProps> = ({ children }) => {
  const [mobileOpen, setMobileOpen] = useState(false)
  const { mode, toggleTheme } = useTheme()
  const location = useLocation()
  const navigate = useNavigate()
  
  const { data: systemStatus } = useSystemStatus()
  const { data: health } = useHealth()

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen)
  }

  const menuItems = [
    { text: 'Dashboard', icon: <DashboardIcon />, path: '/' },
    { text: 'Libraries', icon: <FolderIcon />, path: '/libraries' },
    { text: 'Scanning', icon: <ScannerIcon />, path: '/scanning' },
    { text: 'Statistics', icon: <AnalyticsIcon />, path: '/statistics' },
  ]

  const getStatusColor = (status?: string) => {
    switch (status) {
      case 'running':
      case 'healthy':
      case 'connected':
        return 'success'
      case 'shutting_down':
        return 'warning'
      case 'error':
      case 'unhealthy':
      case 'disconnected':
        return 'error'
      default:
        return 'default'
    }
  }

  const drawer = (
    <div>
      <Toolbar>
        <Typography variant="h6" noWrap component="div">
          Media Metadata
        </Typography>
      </Toolbar>
      <List>
        {menuItems.map((item) => (
          <ListItem key={item.text} disablePadding>
            <ListItemButton
              selected={location.pathname === item.path}
              onClick={() => navigate(item.path)}
            >
              <ListItemIcon>{item.icon}</ListItemIcon>
              <ListItemText primary={item.text} />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
    </div>
  )

  return (
    <Box sx={{ display: 'flex' }}>
      <CssBaseline />
      <AppBar
        position="fixed"
        sx={{
          width: { sm: `calc(100% - ${drawerWidth}px)` },
          ml: { sm: `${drawerWidth}px` },
        }}
      >
        <Toolbar>
          <IconButton
            color="inherit"
            aria-label="open drawer"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ mr: 2, display: { sm: 'none' } }}
          >
            <MenuIcon />
          </IconButton>
          
          <Typography variant="h6" noWrap component="div" sx={{ flexGrow: 1 }}>
            {menuItems.find(item => item.path === location.pathname)?.text || 'Dashboard'}
          </Typography>

          {/* System Status Indicators */}
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mr: 2 }}>
            {systemStatus && (
              <Tooltip title={`System: ${systemStatus.system_status}`}>
                <Chip
                  icon={<CircleIcon />}
                  label={systemStatus.system_status}
                  size="small"
                  color={getStatusColor(systemStatus.system_status)}
                  variant="outlined"
                />
              </Tooltip>
            )}
            
            {health && (
              <Tooltip title="Database Health">
                <Chip
                  icon={<CircleIcon />}
                  label={health.status}
                  size="small"
                  color={getStatusColor(health.status)}
                  variant="outlined"
                />
              </Tooltip>
            )}

            {systemStatus && systemStatus.active_scans > 0 && (
              <Tooltip title={`${systemStatus.active_scans} active scans`}>
                <Chip
                  icon={<ScannerIcon />}
                  label={systemStatus.active_scans}
                  size="small"
                  color="info"
                  className="pulse"
                />
              </Tooltip>
            )}
          </Box>

          <IconButton color="inherit" onClick={toggleTheme}>
            {mode === 'dark' ? <LightModeIcon /> : <DarkModeIcon />}
          </IconButton>
        </Toolbar>
      </AppBar>
      
      <Box
        component="nav"
        sx={{ width: { sm: drawerWidth }, flexShrink: { sm: 0 } }}
        aria-label="navigation menu"
      >
        <Drawer
          variant="temporary"
          open={mobileOpen}
          onClose={handleDrawerToggle}
          ModalProps={{
            keepMounted: true, // Better open performance on mobile.
          }}
          sx={{
            display: { xs: 'block', sm: 'none' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
          }}
        >
          {drawer}
        </Drawer>
        <Drawer
          variant="permanent"
          sx={{
            display: { xs: 'none', sm: 'block' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
          }}
          open
        >
          {drawer}
        </Drawer>
      </Box>
      
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 3,
          width: { sm: `calc(100% - ${drawerWidth}px)` },
        }}
      >
        <Toolbar />
        {children}
      </Box>
    </Box>
  )
}

export default Layout
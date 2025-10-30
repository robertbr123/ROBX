import React from 'react';
import {
  AppBar,
  Toolbar,
  Typography,
  IconButton,
  Badge,
  Box,
  Tooltip,
  Avatar,
} from '@mui/material';
import {
  Menu as MenuIcon,
  Notifications as NotificationsIcon,
  Settings as SettingsIcon,
  TrendingUp as TrendingUpIcon,
} from '@mui/icons-material';
import { useWebSocket } from '../../services/WebSocketService';

const Navbar = ({ onMenuClick }) => {
  const { connected, signals } = useWebSocket();
  
  // Count recent signals (last 5 minutes)
  const recentSignals = signals.filter(signal => {
    const signalTime = new Date(signal.timestamp * 1000);
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);
    return signalTime > fiveMinutesAgo && signal.signal !== 'HOLD';
  }).length;

  return (
    <AppBar 
      position="fixed" 
      sx={{ 
        zIndex: (theme) => theme.zIndex.drawer + 1,
        backgroundColor: 'background.paper',
        borderBottom: '1px solid #333',
      }}
    >
      <Toolbar>
        {/* Menu Button */}
        <IconButton
          color="inherit"
          aria-label="open drawer"
          onClick={onMenuClick}
          edge="start"
          sx={{ mr: 2 }}
        >
          <MenuIcon />
        </IconButton>

        {/* Logo and Title */}
        <Box sx={{ display: 'flex', alignItems: 'center', flexGrow: 1 }}>
          <TrendingUpIcon sx={{ mr: 1, color: 'primary.main' }} />
          <Typography 
            variant="h6" 
            noWrap 
            component="div"
            sx={{ 
              fontWeight: 'bold',
              color: 'primary.main',
            }}
          >
            ROBX
          </Typography>
          <Typography 
            variant="subtitle2" 
            sx={{ 
              ml: 1, 
              color: 'text.secondary',
              display: { xs: 'none', sm: 'block' }
            }}
          >
            Trading Bot B3
          </Typography>
        </Box>

        {/* Connection Status */}
        <Box sx={{ display: 'flex', alignItems: 'center', mr: 2 }}>
          <Box
            sx={{
              width: 8,
              height: 8,
              borderRadius: '50%',
              backgroundColor: connected ? 'success.main' : 'error.main',
              mr: 1,
            }}
          />
          <Typography variant="caption" color="text.secondary">
            {connected ? 'Online' : 'Offline'}
          </Typography>
        </Box>

        {/* Notifications */}
        <Tooltip title="Sinais recentes">
          <IconButton color="inherit" sx={{ mr: 1 }}>
            <Badge badgeContent={recentSignals} color="error">
              <NotificationsIcon />
            </Badge>
          </IconButton>
        </Tooltip>

        {/* Settings */}
        <Tooltip title="Configurações">
          <IconButton color="inherit" sx={{ mr: 1 }}>
            <SettingsIcon />
          </IconButton>
        </Tooltip>

        {/* User Avatar */}
        <Avatar
          sx={{ 
            width: 32, 
            height: 32, 
            bgcolor: 'primary.main',
            fontSize: '0.875rem',
          }}
        >
          DT
        </Avatar>
      </Toolbar>
    </AppBar>
  );
};

export default Navbar;
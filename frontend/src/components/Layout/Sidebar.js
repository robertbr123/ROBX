import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import {
  Drawer,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Tooltip,
  Divider,
  Box,
  Typography,
} from '@mui/material';
import {
  Dashboard as DashboardIcon,
  TrendingUp as TrendingUpIcon,
  Analytics as AnalyticsIcon,
  Notifications as NotificationsIcon,
  Business as BusinessIcon,
  Settings as SettingsIcon,
  ShowChart as ShowChartIcon,
} from '@mui/icons-material';

const DRAWER_WIDTH = 240;
const COLLAPSED_WIDTH = 60;

const menuItems = [
  {
    text: 'Dashboard',
    icon: <DashboardIcon />,
    path: '/dashboard',
  },
  {
    text: 'Market Watch',
    icon: <ShowChartIcon />,
    path: '/market',
  },
  {
    text: 'Análise Técnica',
    icon: <AnalyticsIcon />,
    path: '/analysis',
  },
  {
    text: 'Sinais de Trading',
    icon: <NotificationsIcon />,
    path: '/signals',
  },
  {
    text: 'Portfólio',
    icon: <BusinessIcon />,
    path: '/portfolio',
  },
];

const bottomMenuItems = [
  {
    text: 'Configurações',
    icon: <SettingsIcon />,
    path: '/settings',
  },
];

const Sidebar = ({ open, onToggle }) => {
  const navigate = useNavigate();
  const location = useLocation();

  const handleItemClick = (path) => {
    navigate(path);
  };

  const renderMenuItem = (item, isActive) => (
    <ListItem key={item.text} disablePadding>
      <Tooltip 
        title={!open ? item.text : ''} 
        placement="right"
        arrow
      >
        <ListItemButton
          onClick={() => handleItemClick(item.path)}
          sx={{
            minHeight: 48,
            justifyContent: open ? 'initial' : 'center',
            px: 2.5,
            backgroundColor: isActive ? 'primary.main' : 'transparent',
            color: isActive ? 'primary.contrastText' : 'text.primary',
            '&:hover': {
              backgroundColor: isActive ? 'primary.dark' : 'action.hover',
            },
            borderRadius: 1,
            mx: 1,
            mb: 0.5,
          }}
        >
          <ListItemIcon
            sx={{
              minWidth: 0,
              mr: open ? 3 : 'auto',
              justifyContent: 'center',
              color: isActive ? 'primary.contrastText' : 'text.secondary',
            }}
          >
            {item.icon}
          </ListItemIcon>
          <ListItemText 
            primary={item.text}
            sx={{ 
              opacity: open ? 1 : 0,
              display: open ? 'block' : 'none',
            }}
          />
        </ListItemButton>
      </Tooltip>
    </ListItem>
  );

  return (
    <Drawer
      variant="permanent"
      open={open}
      sx={{
        width: open ? DRAWER_WIDTH : COLLAPSED_WIDTH,
        flexShrink: 0,
        '& .MuiDrawer-paper': {
          width: open ? DRAWER_WIDTH : COLLAPSED_WIDTH,
          boxSizing: 'border-box',
          backgroundColor: 'background.paper',
          borderRight: '1px solid #333',
          transition: 'width 0.3s',
          overflow: 'hidden',
          mt: 8, // Account for navbar height
        },
      }}
    >
      <Box sx={{ overflow: 'auto', height: '100%', display: 'flex', flexDirection: 'column' }}>
        {/* Main Menu Items */}
        <List sx={{ flexGrow: 1, pt: 2 }}>
          {menuItems.map((item) => {
            const isActive = location.pathname === item.path;
            return renderMenuItem(item, isActive);
          })}
        </List>

        {/* Divider */}
        <Divider sx={{ mx: 1, opacity: 0.3 }} />

        {/* Market Status */}
        {open && (
          <Box sx={{ p: 2 }}>
            <Typography variant="caption" color="text.secondary">
              B3 - Bovespa
            </Typography>
            <Box sx={{ display: 'flex', alignItems: 'center', mt: 0.5 }}>
              <Box
                sx={{
                  width: 6,
                  height: 6,
                  borderRadius: '50%',
                  backgroundColor: 'success.main',
                  mr: 1,
                }}
              />
              <Typography variant="caption" color="success.main">
                Mercado Aberto
              </Typography>
            </Box>
          </Box>
        )}

        {/* Bottom Menu Items */}
        <List sx={{ pb: 2 }}>
          {bottomMenuItems.map((item) => {
            const isActive = location.pathname === item.path;
            return renderMenuItem(item, isActive);
          })}
        </List>
      </Box>
    </Drawer>
  );
};

export default Sidebar;
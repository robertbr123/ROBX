import React from 'react';
import { Routes, Route } from 'react-router-dom';
import { Box } from '@mui/material';

// Layout Components
import Navbar from './components/Layout/Navbar';
import Sidebar from './components/Layout/Sidebar';

// Pages
import Dashboard from './pages/Dashboard';
import MarketWatch from './pages/MarketWatch';
import TechnicalAnalysis from './pages/TechnicalAnalysis';
import Signals from './pages/Signals';
import Portfolio from './pages/Portfolio';
import Settings from './pages/Settings';

// Services
import { WebSocketProvider } from './services/WebSocketService';

function App() {
  const [sidebarOpen, setSidebarOpen] = React.useState(true);

  const handleSidebarToggle = () => {
    setSidebarOpen(!sidebarOpen);
  };

  return (
    <WebSocketProvider>
      <Box sx={{ display: 'flex', minHeight: '100vh' }}>
        {/* Navigation Bar */}
        <Navbar onMenuClick={handleSidebarToggle} />
        
        {/* Sidebar */}
        <Sidebar open={sidebarOpen} onToggle={handleSidebarToggle} />
        
        {/* Main Content */}
        <Box
          component="main"
          sx={{
            flexGrow: 1,
            pt: 8, // Account for navbar height
            pl: sidebarOpen ? '240px' : '60px',
            transition: 'padding-left 0.3s',
            backgroundColor: 'background.default',
            minHeight: '100vh',
          }}
        >
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/market" element={<MarketWatch />} />
            <Route path="/analysis" element={<TechnicalAnalysis />} />
            <Route path="/signals" element={<Signals />} />
            <Route path="/portfolio" element={<Portfolio />} />
            <Route path="/settings" element={<Settings />} />
          </Routes>
        </Box>
      </Box>
    </WebSocketProvider>
  );
}

export default App;
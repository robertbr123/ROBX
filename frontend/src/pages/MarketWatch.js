import React from 'react';
import { Box, Typography } from '@mui/material';

const MarketWatch = () => {
  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" component="h1" fontWeight="bold" gutterBottom>
        Market Watch
      </Typography>
      <Typography color="text.secondary">
        Página em desenvolvimento - Monitoramento avançado de mercado
      </Typography>
    </Box>
  );
};

export default MarketWatch;
import React from 'react';
import { Box, Typography } from '@mui/material';

const Signals = () => {
  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" component="h1" fontWeight="bold" gutterBottom>
        Sinais de Trading
      </Typography>
      <Typography color="text.secondary">
        Página em desenvolvimento - Sinais de compra e venda em tempo real
      </Typography>
    </Box>
  );
};

export default Signals;
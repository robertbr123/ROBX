import React from 'react';
import { Box, Typography } from '@mui/material';

const Portfolio = () => {
  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" component="h1" fontWeight="bold" gutterBottom>
        Portfólio
      </Typography>
      <Typography color="text.secondary">
        Página em desenvolvimento - Análise de portfólio e performance
      </Typography>
    </Box>
  );
};

export default Portfolio;
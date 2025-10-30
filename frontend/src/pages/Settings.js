import React from 'react';
import { Box, Typography } from '@mui/material';

const Settings = () => {
  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" component="h1" fontWeight="bold" gutterBottom>
        Configurações
      </Typography>
      <Typography color="text.secondary">
        Página em desenvolvimento - Configurações do sistema e preferências
      </Typography>
    </Box>
  );
};

export default Settings;
import React from 'react';
import {
  Card,
  CardContent,
  Box,
  Typography,
  Chip,
  IconButton,
  Tooltip,
} from '@mui/material';
import {
  TrendingUp as TrendingUpIcon,
  TrendingDown as TrendingDownIcon,
  ShowChart as ShowChartIcon,
  Info as InfoIcon,
} from '@mui/icons-material';

const SignalCard = ({ signal, compact = false }) => {
  const getSignalColor = (signalType) => {
    switch (signalType) {
      case 'BUY':
        return 'success';
      case 'SELL':
        return 'error';
      default:
        return 'default';
    }
  };

  const getSignalIcon = (signalType) => {
    switch (signalType) {
      case 'BUY':
        return <TrendingUpIcon />;
      case 'SELL':
        return <TrendingDownIcon />;
      default:
        return <ShowChartIcon />;
    }
  };

  const getStrengthLabel = (strength) => {
    if (strength >= 80) return 'Muito Forte';
    if (strength >= 70) return 'Forte';
    if (strength >= 60) return 'Moderado';
    if (strength >= 50) return 'Fraco';
    return 'Muito Fraco';
  };

  const formatCurrency = (value) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL',
    }).format(value);
  };

  const formatTime = (timestamp) => {
    const date = new Date(timestamp * 1000);
    return date.toLocaleTimeString('pt-BR', {
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  if (compact) {
    return (
      <Box
        sx={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          p: 1,
          border: '1px solid #333',
          borderRadius: 1,
          backgroundColor: 'background.paper',
        }}
      >
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <Chip
            icon={getSignalIcon(signal.signal)}
            label={signal.signal}
            size="small"
            color={getSignalColor(signal.signal)}
            variant="outlined"
          />
          <Typography variant="body2" fontWeight="medium">
            {signal.symbol.replace('.SA', '')}
          </Typography>
        </Box>
        
        <Box sx={{ textAlign: 'right' }}>
          <Typography variant="body2" fontWeight="medium">
            {formatCurrency(signal.price || signal.current_price)}
          </Typography>
          <Typography variant="caption" color="text.secondary">
            {signal.strength || signal.signal_strength}% força
          </Typography>
        </Box>
      </Box>
    );
  }

  return (
    <Card 
      sx={{ 
        border: `2px solid ${
          signal.signal === 'BUY' ? 'success.main' : 
          signal.signal === 'SELL' ? 'error.main' : 'grey.500'
        }`,
        backgroundColor: 'background.paper',
      }}
    >
      <CardContent sx={{ pb: 2 }}>
        {/* Header */}
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Typography variant="h6" fontWeight="bold">
              {signal.symbol.replace('.SA', '')}
            </Typography>
            <Chip
              icon={getSignalIcon(signal.signal)}
              label={signal.signal}
              color={getSignalColor(signal.signal)}
              size="small"
            />
          </Box>
          
          <Tooltip title="Mais informações">
            <IconButton size="small">
              <InfoIcon />
            </IconButton>
          </Tooltip>
        </Box>

        {/* Price and Strength */}
        <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
          <Box>
            <Typography variant="body2" color="text.secondary">
              Preço Atual
            </Typography>
            <Typography variant="h6" fontWeight="bold">
              {formatCurrency(signal.price || signal.current_price)}
            </Typography>
          </Box>
          
          <Box sx={{ textAlign: 'right' }}>
            <Typography variant="body2" color="text.secondary">
              Força do Sinal
            </Typography>
            <Typography 
              variant="h6" 
              fontWeight="bold"
              color={
                (signal.strength || signal.signal_strength) >= 70 ? 'success.main' : 
                (signal.strength || signal.signal_strength) >= 50 ? 'warning.main' : 'error.main'
              }
            >
              {signal.strength || signal.signal_strength}%
            </Typography>
            <Typography variant="caption" color="text.secondary">
              {getStrengthLabel(signal.strength || signal.signal_strength)}
            </Typography>
          </Box>
        </Box>

        {/* Reason */}
        {signal.reason && (
          <Box sx={{ mb: 2 }}>
            <Typography variant="body2" color="text.secondary" gutterBottom>
              Motivo
            </Typography>
            <Typography variant="body2">
              {signal.reason}
            </Typography>
          </Box>
        )}

        {/* Technical Indicators Summary */}
        {signal.indicators && (
          <Box sx={{ mb: 2 }}>
            <Typography variant="body2" color="text.secondary" gutterBottom>
              Indicadores
            </Typography>
            <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
              {signal.indicators.rsi && (
                <Chip
                  label={`RSI: ${signal.indicators.rsi.toFixed(1)}`}
                  size="small"
                  variant="outlined"
                  color={
                    signal.indicators.rsi < 30 ? 'success' :
                    signal.indicators.rsi > 70 ? 'error' : 'default'
                  }
                />
              )}
              {signal.indicators.trend && (
                <Chip
                  label={signal.indicators.trend}
                  size="small"
                  variant="outlined"
                  color={
                    signal.indicators.trend === 'UPTREND' ? 'success' :
                    signal.indicators.trend === 'DOWNTREND' ? 'error' : 'default'
                  }
                />
              )}
              {signal.indicators.volume_ratio && (
                <Chip
                  label={`Vol: ${signal.indicators.volume_ratio.toFixed(1)}x`}
                  size="small"
                  variant="outlined"
                  color={signal.indicators.volume_ratio > 1.5 ? 'primary' : 'default'}
                />
              )}
            </Box>
          </Box>
        )}

        {/* Timestamp */}
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Typography variant="caption" color="text.secondary">
            {signal.timestamp ? formatTime(signal.timestamp) : 'Agora'}
          </Typography>
          
          {/* Risk Level */}
          {signal.risk_level && (
            <Chip
              label={`Risco: ${signal.risk_level}`}
              size="small"
              color={
                signal.risk_level === 'LOW' ? 'success' :
                signal.risk_level === 'MEDIUM' ? 'warning' : 'error'
              }
              variant="outlined"
            />
          )}
        </Box>
      </CardContent>
    </Card>
  );
};

export default SignalCard;
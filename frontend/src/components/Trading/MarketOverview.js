import React from 'react';
import {
  Grid,
  Card,
  CardContent,
  Typography,
  Box,
  Chip,
  LinearProgress,
} from '@mui/material';
import {
  TrendingUp as TrendingUpIcon,
  TrendingDown as TrendingDownIcon,
  ShowChart as ShowChartIcon,
} from '@mui/icons-material';

const MarketOverview = ({ data }) => {
  if (!data) {
    return (
      <Box sx={{ textAlign: 'center', py: 4 }}>
        <Typography color="text.secondary">
          Carregando dados do mercado...
        </Typography>
      </Box>
    );
  }

  const formatCurrency = (value) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL',
    }).format(value);
  };

  const formatPercent = (value) => {
    return `${value >= 0 ? '+' : ''}${value.toFixed(2)}%`;
  };

  const getChangeColor = (change) => {
    return change >= 0 ? 'success.main' : 'error.main';
  };

  const getChangeIcon = (change) => {
    return change >= 0 ? <TrendingUpIcon /> : <TrendingDownIcon />;
  };

  const renderStockCard = (stock, title) => (
    <Card sx={{ height: '100%' }}>
      <CardContent>
        <Typography variant="h6" gutterBottom sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          {title === 'Maiores Altas' && <TrendingUpIcon color="success" />}
          {title === 'Maiores Baixas' && <TrendingDownIcon color="error" />}
          {title === 'Mais Negociadas' && <ShowChartIcon color="primary" />}
          {title}
        </Typography>
        
        {stock && stock.length > 0 ? (
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
            {stock.slice(0, 3).map((item, index) => (
              <Box
                key={index}
                sx={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  p: 1,
                  backgroundColor: 'background.default',
                  borderRadius: 1,
                }}
              >
                <Box>
                  <Typography variant="body2" fontWeight="medium">
                    {item.symbol?.replace('.SA', '') || 'N/A'}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    {formatCurrency(item.price || 0)}
                  </Typography>
                </Box>
                
                <Box sx={{ textAlign: 'right' }}>
                  <Typography
                    variant="body2"
                    sx={{ color: getChangeColor(item.change_percent || 0) }}
                    fontWeight="medium"
                  >
                    {formatPercent(item.change_percent || 0)}
                  </Typography>
                  {title === 'Mais Negociadas' && (
                    <Typography variant="caption" color="text.secondary">
                      Vol: {(item.volume || 0).toLocaleString()}
                    </Typography>
                  )}
                </Box>
              </Box>
            ))}
          </Box>
        ) : (
          <Typography color="text.secondary">
            Dados não disponíveis
          </Typography>
        )}
      </CardContent>
    </Card>
  );

  return (
    <Box>
      {/* Market Status */}
      <Box sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 2 }}>
        <Chip
          icon={<ShowChartIcon />}
          label={data.market_status === 'open' ? 'Mercado Aberto' : 'Mercado Fechado'}
          color={data.market_status === 'open' ? 'success' : 'default'}
          variant="outlined"
        />
        <Typography variant="body2" color="text.secondary">
          Última atualização: {new Date(data.timestamp).toLocaleTimeString('pt-BR')}
        </Typography>
      </Box>

      {/* Market Categories */}
      <Grid container spacing={3}>
        <Grid item xs={12} md={4}>
          {renderStockCard(data.top_gainers, 'Maiores Altas')}
        </Grid>
        
        <Grid item xs={12} md={4}>
          {renderStockCard(data.top_losers, 'Maiores Baixas')}
        </Grid>
        
        <Grid item xs={12} md={4}>
          {renderStockCard(data.most_active, 'Mais Negociadas')}
        </Grid>
      </Grid>

      {/* Market Sentiment Indicator */}
      <Card sx={{ mt: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Sentimento do Mercado
          </Typography>
          
          <Box sx={{ mb: 2 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
              <Typography variant="body2">Altas vs Baixas</Typography>
              <Typography variant="body2">
                {data.top_gainers?.length || 0} altas / {data.top_losers?.length || 0} baixas
              </Typography>
            </Box>
            
            <LinearProgress
              variant="determinate"
              value={
                data.top_gainers?.length && data.top_losers?.length
                  ? (data.top_gainers.length / (data.top_gainers.length + data.top_losers.length)) * 100
                  : 50
              }
              sx={{
                height: 8,
                borderRadius: 4,
                backgroundColor: 'error.dark',
                '& .MuiLinearProgress-bar': {
                  backgroundColor: 'success.main',
                },
              }}
            />
          </Box>

          <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
            <Chip
              label="B3"
              variant="outlined"
              size="small"
            />
            <Chip
              label={`${(data.top_gainers?.length || 0) + (data.top_losers?.length || 0)} ativos`}
              variant="outlined"
              size="small"
            />
            <Chip
              label="Tempo Real"
              color="primary"
              variant="outlined"
              size="small"
            />
          </Box>
        </CardContent>
      </Card>
    </Box>
  );
};

export default MarketOverview;
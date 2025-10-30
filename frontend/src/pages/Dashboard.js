import React, { useState, useEffect } from 'react';
import {
  Box,
  Grid,
  Card,
  CardContent,
  Typography,
  Button,
  Chip,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  LinearProgress,
} from '@mui/material';
import {
  TrendingUp as TrendingUpIcon,
  TrendingDown as TrendingDownIcon,
  ShowChart as ShowChartIcon,
  Notifications as NotificationsIcon,
} from '@mui/icons-material';

// Services
import { marketAPI, recommendationsAPI } from '../services/ApiService';
import { useWebSocket } from '../services/WebSocketService';

// Components
import StockChart from '../components/Charts/StockChart';
import SignalCard from '../components/Trading/SignalCard';
import MarketOverview from '../components/Trading/MarketOverview';

const Dashboard = () => {
  const [loading, setLoading] = useState(true);
  const [marketOverview, setMarketOverview] = useState(null);
  const [topSignals, setTopSignals] = useState([]);
  const [watchlistData, setWatchlistData] = useState([]);
  const [selectedSymbol, setSelectedSymbol] = useState('PETR4.SA');

  const { connected, subscribeToSignals, getLatestSignals } = useWebSocket();

  // Load initial data
  useEffect(() => {
    const loadDashboardData = async () => {
      setLoading(true);
      try {
        // Load market overview
        const overviewResponse = await marketAPI.getOverview();
        if (overviewResponse.success) {
          setMarketOverview(overviewResponse.data);
        }

        // Load top signals
        const signalsResponse = await recommendationsAPI.getLatestSignals(5);
        if (signalsResponse.success) {
          setTopSignals(signalsResponse.data.signals);
        }

        // Load watchlist data
        const watchlistResponse = await recommendationsAPI.getWatchlistSignals();
        if (watchlistResponse.success) {
          setWatchlistData(watchlistResponse.data.watchlist.slice(0, 10));
        }
      } catch (error) {
        console.error('Error loading dashboard data:', error);
      } finally {
        setLoading(false);
      }
    };

    loadDashboardData();
  }, []);

  // Subscribe to real-time signals
  useEffect(() => {
    if (connected) {
      subscribeToSignals();
    }
  }, [connected, subscribeToSignals]);

  // Update signals from WebSocket
  useEffect(() => {
    const realtimeSignals = getLatestSignals(5);
    if (realtimeSignals.length > 0) {
      setTopSignals(realtimeSignals);
    }
  }, [getLatestSignals]);

  const formatCurrency = (value) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL',
    }).format(value);
  };

  const formatPercent = (value) => {
    return `${value >= 0 ? '+' : ''}${value.toFixed(2)}%`;
  };

  const getSignalColor = (signal) => {
    switch (signal) {
      case 'BUY':
        return 'success';
      case 'SELL':
        return 'error';
      default:
        return 'default';
    }
  };

  const getSignalIcon = (signal) => {
    switch (signal) {
      case 'BUY':
        return <TrendingUpIcon />;
      case 'SELL':
        return <TrendingDownIcon />;
      default:
        return <ShowChartIcon />;
    }
  };

  if (loading) {
    return (
      <Box sx={{ p: 3 }}>
        <Typography variant="h4" gutterBottom>
          Carregando Dashboard...
        </Typography>
        <LinearProgress />
      </Box>
    );
  }

  return (
    <Box sx={{ p: 3 }}>
      {/* Header */}
      <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Typography variant="h4" component="h1" fontWeight="bold">
          Dashboard ROBX
        </Typography>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <Chip
            icon={connected ? <TrendingUpIcon /> : <TrendingDownIcon />}
            label={connected ? 'Online' : 'Offline'}
            color={connected ? 'success' : 'error'}
            variant="outlined"
          />
        </Box>
      </Box>

      <Grid container spacing={3}>
        {/* Market Overview Cards */}
        <Grid item xs={12} md={8}>
          <Card sx={{ mb: 3 }}>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Visão Geral do Mercado B3
              </Typography>
              <MarketOverview data={marketOverview} />
            </CardContent>
          </Card>

          {/* Main Chart */}
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                <Typography variant="h6">
                  Gráfico - {selectedSymbol}
                </Typography>
                <Box sx={{ display: 'flex', gap: 1 }}>
                  {['PETR4.SA', 'VALE3.SA', 'ITUB4.SA'].map(symbol => (
                    <Button
                      key={symbol}
                      size="small"
                      variant={selectedSymbol === symbol ? 'contained' : 'outlined'}
                      onClick={() => setSelectedSymbol(symbol)}
                    >
                      {symbol.replace('.SA', '')}
                    </Button>
                  ))}
                </Box>
              </Box>
              <StockChart symbol={selectedSymbol} height={400} />
            </CardContent>
          </Card>
        </Grid>

        {/* Right Sidebar */}
        <Grid item xs={12} md={4}>
          {/* Trading Signals */}
          <Card sx={{ mb: 3 }}>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <NotificationsIcon sx={{ mr: 1 }} />
                <Typography variant="h6">
                  Sinais de Trading
                </Typography>
              </Box>
              
              {topSignals.length > 0 ? (
                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                  {topSignals.map((signal, index) => (
                    <SignalCard key={index} signal={signal} />
                  ))}
                </Box>
              ) : (
                <Typography color="text.secondary">
                  Nenhum sinal ativo no momento
                </Typography>
              )}

              <Button
                fullWidth
                variant="outlined"
                sx={{ mt: 2 }}
                href="/signals"
              >
                Ver Todos os Sinais
              </Button>
            </CardContent>
          </Card>

          {/* Watchlist */}
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Watchlist B3
              </Typography>
              
              <TableContainer>
                <Table size="small">
                  <TableHead>
                    <TableRow>
                      <TableCell>Ativo</TableCell>
                      <TableCell align="right">Preço</TableCell>
                      <TableCell align="right">Var%</TableCell>
                      <TableCell align="center">Sinal</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {watchlistData.map((stock) => (
                      <TableRow key={stock.symbol}>
                        <TableCell>
                          <Typography variant="body2" fontWeight="medium">
                            {stock.symbol.replace('.SA', '')}
                          </Typography>
                        </TableCell>
                        <TableCell align="right">
                          <Typography variant="body2">
                            {formatCurrency(stock.current_price)}
                          </Typography>
                        </TableCell>
                        <TableCell 
                          align="right"
                          sx={{
                            color: stock.change_percent >= 0 ? 'success.main' : 'error.main'
                          }}
                        >
                          <Typography variant="body2">
                            {formatPercent(stock.change_percent)}
                          </Typography>
                        </TableCell>
                        <TableCell align="center">
                          <Chip
                            icon={getSignalIcon(stock.signal)}
                            label={stock.signal}
                            size="small"
                            color={getSignalColor(stock.signal)}
                            variant="outlined"
                          />
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
              
              <Button
                fullWidth
                variant="outlined"
                sx={{ mt: 2 }}
                href="/market"
              >
                Ver Market Watch
              </Button>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default Dashboard;
import React, { useState, useEffect } from 'react';
import { Box, Typography, Select, MenuItem, FormControl, InputLabel } from '@mui/material';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend,
  TimeScale,
} from 'chart.js';
import { Line, Bar } from 'react-chartjs-2';
import 'chartjs-adapter-date-fns';

import { marketAPI, analysisAPI } from '../../services/ApiService';
import { useWebSocket } from '../../services/WebSocketService';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend,
  TimeScale
);

const StockChart = ({ symbol, height = 400 }) => {
  const [chartData, setChartData] = useState(null);
  const [indicators, setIndicators] = useState(null);
  const [timeframe, setTimeframe] = useState('1d');
  const [chartType, setChartType] = useState('price');
  const [loading, setLoading] = useState(true);

  const { getMarketData, subscribeToMarketData } = useWebSocket();

  // Load historical data and indicators
  useEffect(() => {
    const loadChartData = async () => {
      setLoading(true);
      try {
        // Get historical data
        const period = timeframe === '5m' ? '1d' : '3mo';
        const interval = timeframe;
        
        const historyResponse = await marketAPI.getHistorical(symbol, period, interval);
        
        if (historyResponse.success) {
          const data = historyResponse.data.data;
          
          const timestamps = data.map(item => new Date(item.timestamp));
          const prices = data.map(item => item.close);
          const volumes = data.map(item => item.volume);
          const highs = data.map(item => item.high);
          const lows = data.map(item => item.low);

          setChartData({
            timestamps,
            prices,
            volumes,
            highs,
            lows,
          });
        }

        // Get technical indicators
        const indicatorsResponse = await analysisAPI.getIndicators(symbol, timeframe);
        if (indicatorsResponse.success) {
          setIndicators(indicatorsResponse.data.indicators);
        }

      } catch (error) {
        console.error('Error loading chart data:', error);
      } finally {
        setLoading(false);
      }
    };

    loadChartData();
  }, [symbol, timeframe]);

  // Subscribe to real-time data
  useEffect(() => {
    const unsubscribe = subscribeToMarketData(symbol);
    return unsubscribe;
  }, [symbol, subscribeToMarketData]);

  // Update with real-time data
  useEffect(() => {
    const realtimeData = getMarketData(symbol);
    if (realtimeData && chartData) {
      // Update the last data point with real-time data
      setChartData(prev => ({
        ...prev,
        prices: [...prev.prices.slice(0, -1), realtimeData.price],
      }));
    }
  }, [getMarketData, symbol, chartData]);

  const getPriceChartConfig = () => {
    if (!chartData) return null;

    const datasets = [
      {
        label: 'Preço',
        data: chartData.prices,
        borderColor: 'rgb(0, 200, 83)',
        backgroundColor: 'rgba(0, 200, 83, 0.1)',
        borderWidth: 2,
        fill: true,
        tension: 0.1,
      }
    ];

    // Add moving averages if available
    if (indicators?.moving_averages) {
      if (indicators.moving_averages.sma_20) {
        datasets.push({
          label: 'SMA 20',
          data: chartData.prices.map(() => indicators.moving_averages.sma_20),
          borderColor: 'rgb(255, 159, 64)',
          backgroundColor: 'transparent',
          borderWidth: 1,
          pointRadius: 0,
        });
      }
      
      if (indicators.moving_averages.sma_50) {
        datasets.push({
          label: 'SMA 50',
          data: chartData.prices.map(() => indicators.moving_averages.sma_50),
          borderColor: 'rgb(54, 162, 235)',
          backgroundColor: 'transparent',
          borderWidth: 1,
          pointRadius: 0,
        });
      }
    }

    return {
      labels: chartData.timestamps,
      datasets,
    };
  };

  const getVolumeChartConfig = () => {
    if (!chartData) return null;

    return {
      labels: chartData.timestamps,
      datasets: [
        {
          label: 'Volume',
          data: chartData.volumes,
          backgroundColor: 'rgba(54, 162, 235, 0.6)',
          borderColor: 'rgb(54, 162, 235)',
          borderWidth: 1,
        }
      ],
    };
  };

  const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'top',
        labels: {
          color: '#ffffff',
        },
      },
      title: {
        display: true,
        text: `${symbol} - ${chartType === 'price' ? 'Preço' : 'Volume'}`,
        color: '#ffffff',
      },
      tooltip: {
        mode: 'index',
        intersect: false,
        callbacks: {
          label: function(context) {
            if (chartType === 'price') {
              return `${context.dataset.label}: R$ ${context.parsed.y.toFixed(2)}`;
            } else {
              return `${context.dataset.label}: ${context.parsed.y.toLocaleString()}`;
            }
          }
        }
      },
    },
    scales: {
      x: {
        type: 'time',
        time: {
          unit: timeframe === '5m' ? 'minute' : 'day',
        },
        ticks: {
          color: '#b0b0b0',
        },
        grid: {
          color: '#333',
        },
      },
      y: {
        ticks: {
          color: '#b0b0b0',
          callback: function(value) {
            if (chartType === 'price') {
              return `R$ ${value.toFixed(2)}`;
            } else {
              return value.toLocaleString();
            }
          }
        },
        grid: {
          color: '#333',
        },
      },
    },
    interaction: {
      mode: 'nearest',
      axis: 'x',
      intersect: false,
    },
  };

  if (loading) {
    return (
      <Box sx={{ height, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Typography>Carregando gráfico...</Typography>
      </Box>
    );
  }

  const chartConfig = chartType === 'price' ? getPriceChartConfig() : getVolumeChartConfig();

  if (!chartConfig) {
    return (
      <Box sx={{ height, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Typography>Dados não disponíveis</Typography>
      </Box>
    );
  }

  return (
    <Box>
      {/* Chart Controls */}
      <Box sx={{ display: 'flex', gap: 2, mb: 2 }}>
        <FormControl size="small" sx={{ minWidth: 120 }}>
          <InputLabel>Timeframe</InputLabel>
          <Select
            value={timeframe}
            label="Timeframe"
            onChange={(e) => setTimeframe(e.target.value)}
          >
            <MenuItem value="5m">5 min</MenuItem>
            <MenuItem value="1h">1 hora</MenuItem>
            <MenuItem value="1d">1 dia</MenuItem>
          </Select>
        </FormControl>

        <FormControl size="small" sx={{ minWidth: 120 }}>
          <InputLabel>Tipo</InputLabel>
          <Select
            value={chartType}
            label="Tipo"
            onChange={(e) => setChartType(e.target.value)}
          >
            <MenuItem value="price">Preço</MenuItem>
            <MenuItem value="volume">Volume</MenuItem>
          </Select>
        </FormControl>
      </Box>

      {/* Chart */}
      <Box sx={{ height }}>
        {chartType === 'price' ? (
          <Line data={chartConfig} options={chartOptions} />
        ) : (
          <Bar data={chartConfig} options={chartOptions} />
        )}
      </Box>

      {/* Technical Indicators Summary */}
      {indicators && (
        <Box sx={{ mt: 2, p: 2, bgcolor: 'background.paper', borderRadius: 1 }}>
          <Typography variant="subtitle2" gutterBottom>
            Indicadores Técnicos
          </Typography>
          <Box sx={{ display: 'flex', gap: 3, flexWrap: 'wrap' }}>
            {indicators.rsi && (
              <Typography variant="body2">
                RSI: <strong>{indicators.rsi.toFixed(1)}</strong>
              </Typography>
            )}
            {indicators.macd && (
              <Typography variant="body2">
                MACD: <strong>{indicators.macd.macd?.toFixed(3)}</strong>
              </Typography>
            )}
            {indicators.bollinger_bands && (
              <Typography variant="body2">
                BB Pos: <strong>{(indicators.bollinger_bands.position * 100).toFixed(1)}%</strong>
              </Typography>
            )}
          </Box>
        </Box>
      )}
    </Box>
  );
};

export default StockChart;
import axios from 'axios';

// API Base Configuration
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
api.interceptors.request.use(
  (config) => {
    // Add auth token if available
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor
api.interceptors.response.use(
  (response) => {
    return response.data;
  },
  (error) => {
    console.error('API Error:', error);
    return Promise.reject(error);
  }
);

// Market Data API
export const marketAPI = {
  // Get real-time quote
  getQuote: (symbol) => api.get(`/api/v1/market/quote/${symbol}`),
  
  // Get historical data
  getHistorical: (symbol, period = '1mo', interval = '1d') => 
    api.get(`/api/v1/market/historical/${symbol}`, { 
      params: { period, interval } 
    }),
  
  // Get intraday data
  getIntraday: (symbol, interval = '5m') => 
    api.get(`/api/v1/market/intraday/${symbol}`, { 
      params: { interval } 
    }),
  
  // Get market overview
  getOverview: () => api.get('/api/v1/market/overview'),
  
  // Search symbols
  searchSymbols: (query) => 
    api.get('/api/v1/market/search', { params: { q: query } }),
  
  // Get company info
  getCompanyInfo: (symbol) => api.get(`/api/v1/market/info/${symbol}`),
  
  // Get B3 symbols list
  getSymbols: () => api.get('/api/v1/market/symbols'),
  
  // Get market status
  getStatus: () => api.get('/api/v1/market/status'),
  
  // Get batch quotes
  getBatchQuotes: (symbols) => 
    api.get(`/api/v1/market/batch/${symbols.join(',')}`),
};

// Technical Analysis API
export const analysisAPI = {
  // Full technical analysis
  analyzeSymbol: (symbol, timeframe = '1d') => 
    api.get(`/api/v1/analysis/analyze/${symbol}`, { 
      params: { timeframe } 
    }),
  
  // Get specific indicators
  getIndicators: (symbol, timeframe = '1d', indicators = 'rsi,macd,bollinger') => 
    api.get(`/api/v1/analysis/indicators/${symbol}`, { 
      params: { timeframe, indicators } 
    }),
  
  // Get trading signal
  getSignal: (symbol, timeframe = '1d') => 
    api.get(`/api/v1/analysis/signal/${symbol}`, { 
      params: { timeframe } 
    }),
  
  // Multi-timeframe analysis
  getMultiTimeframe: (symbol) => 
    api.get(`/api/v1/analysis/multi-timeframe/${symbol}`),
  
  // Get RSI
  getRSI: (symbol, timeframe = '1d', period = 14) => 
    api.get(`/api/v1/analysis/rsi/${symbol}`, { 
      params: { timeframe, period } 
    }),
  
  // Get MACD
  getMACD: (symbol, timeframe = '1d') => 
    api.get(`/api/v1/analysis/macd/${symbol}`, { 
      params: { timeframe } 
    }),
  
  // Get Bollinger Bands
  getBollingerBands: (symbol, timeframe = '1d') => 
    api.get(`/api/v1/analysis/bollinger/${symbol}`, { 
      params: { timeframe } 
    }),
  
  // Get trend analysis
  getTrend: (symbol, timeframe = '1d') => 
    api.get(`/api/v1/analysis/trend/${symbol}`, { 
      params: { timeframe } 
    }),
};

// Trading Recommendations API
export const recommendationsAPI = {
  // Get latest signals
  getLatestSignals: (limit = 10) => 
    api.get('/api/v1/recommendations/signals', { 
      params: { limit } 
    }),
  
  // Get signals by type
  getSignalsByType: (signalType, limit = 10) => 
    api.get(`/api/v1/recommendations/signals/${signalType}`, { 
      params: { limit } 
    }),
  
  // Get watchlist signals
  getWatchlistSignals: () => 
    api.get('/api/v1/recommendations/watchlist'),
  
  // Get trading opportunities
  getOpportunities: (minStrength = 60, signalTypes = 'BUY,SELL') => 
    api.get('/api/v1/recommendations/opportunities', { 
      params: { min_strength: minStrength, signal_types: signalTypes } 
    }),
  
  // Analyze portfolio
  analyzePortfolio: (symbols, weights = null) => {
    const params = { symbols: symbols.join(',') };
    if (weights) {
      params.weights = weights.join(',');
    }
    return api.get('/api/v1/recommendations/portfolio-analysis', { params });
  },
  
  // Analyze sector
  analyzeSector: (sector) => 
    api.get(`/api/v1/recommendations/sector-analysis/${sector}`),
};

// General API utilities
export const apiUtils = {
  // Health check
  healthCheck: () => api.get('/health'),
  
  // Get API status
  getStatus: () => api.get('/'),
};

export default api;
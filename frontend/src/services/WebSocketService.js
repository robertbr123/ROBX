import React, { createContext, useContext, useEffect, useState, useCallback } from 'react';
import { io } from 'socket.io-client';
import { toast } from 'react-toastify';

const WebSocketContext = createContext();

export const useWebSocket = () => {
  const context = useContext(WebSocketContext);
  if (!context) {
    throw new Error('useWebSocket must be used within a WebSocketProvider');
  }
  return context;
};

export const WebSocketProvider = ({ children }) => {
  const [socket, setSocket] = useState(null);
  const [connected, setConnected] = useState(false);
  const [marketData, setMarketData] = useState({});
  const [signals, setSignals] = useState([]);
  const [connectionStatus, setConnectionStatus] = useState('disconnected');

  const WS_BASE_URL = process.env.REACT_APP_WS_URL || 'ws://localhost:8000';

  // Initialize WebSocket connection
  useEffect(() => {
    const newSocket = io(WS_BASE_URL, {
      transports: ['websocket'],
      upgrade: false,
    });

    newSocket.on('connect', () => {
      console.log('📡 WebSocket connected');
      setConnected(true);
      setConnectionStatus('connected');
      toast.success('Conectado ao servidor de dados em tempo real');
    });

    newSocket.on('disconnect', () => {
      console.log('📡 WebSocket disconnected');
      setConnected(false);
      setConnectionStatus('disconnected');
      toast.warning('Desconectado do servidor de dados');
    });

    newSocket.on('connect_error', (error) => {
      console.error('WebSocket connection error:', error);
      setConnectionStatus('error');
      toast.error('Erro na conexão com o servidor');
    });

    setSocket(newSocket);

    return () => {
      newSocket.close();
    };
  }, [WS_BASE_URL]);

  // Subscribe to market data for a symbol
  const subscribeToMarketData = useCallback((symbol) => {
    if (!socket || !connected) {
      console.warn('Cannot subscribe: WebSocket not connected');
      return;
    }

    console.log(`📊 Subscribing to market data for ${symbol}`);
    
    // Create WebSocket connection for specific symbol
    const marketSocket = new WebSocket(`${WS_BASE_URL.replace('http', 'ws')}/ws/market/${symbol}`);
    
    marketSocket.onopen = () => {
      console.log(`Market data connection opened for ${symbol}`);
    };
    
    marketSocket.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        if (data.type === 'market_data') {
          setMarketData(prev => ({
            ...prev,
            [symbol]: {
              ...data.data,
              timestamp: data.timestamp,
            }
          }));
        }
      } catch (error) {
        console.error('Error parsing market data:', error);
      }
    };
    
    marketSocket.onerror = (error) => {
      console.error(`Market data error for ${symbol}:`, error);
    };
    
    marketSocket.onclose = () => {
      console.log(`Market data connection closed for ${symbol}`);
    };

    return () => {
      marketSocket.close();
    };
  }, [socket, connected, WS_BASE_URL]);

  // Subscribe to trading signals
  const subscribeToSignals = useCallback(() => {
    if (!socket || !connected) {
      console.warn('Cannot subscribe to signals: WebSocket not connected');
      return;
    }

    console.log('🔔 Subscribing to trading signals');
    
    // Create WebSocket connection for signals
    const signalsSocket = new WebSocket(`${WS_BASE_URL.replace('http', 'ws')}/ws/signals`);
    
    signalsSocket.onopen = () => {
      console.log('Signals connection opened');
    };
    
    signalsSocket.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        
        if (data.type === 'trading_signals') {
          setSignals(prev => [...data.signals, ...prev].slice(0, 50)); // Keep last 50 signals
        } else if (data.type === 'new_signal') {
          const newSignal = {
            symbol: data.symbol,
            signal: data.signal,
            price: data.price,
            indicators: data.indicators,
            timestamp: data.timestamp,
          };
          
          setSignals(prev => [newSignal, ...prev].slice(0, 50));
          
          // Show notification for strong signals
          if (data.signal !== 'HOLD') {
            const signalColor = data.signal === 'BUY' ? '🟢' : '🔴';
            toast.info(
              `${signalColor} ${data.signal} ${data.symbol} - R$ ${data.price?.toFixed(2)}`,
              {
                autoClose: 8000,
              }
            );
          }
        }
      } catch (error) {
        console.error('Error parsing signals data:', error);
      }
    };
    
    signalsSocket.onerror = (error) => {
      console.error('Signals WebSocket error:', error);
    };
    
    signalsSocket.onclose = () => {
      console.log('Signals connection closed');
    };

    return () => {
      signalsSocket.close();
    };
  }, [socket, connected, WS_BASE_URL]);

  // Unsubscribe from market data
  const unsubscribeFromMarketData = useCallback((symbol) => {
    setMarketData(prev => {
      const newData = { ...prev };
      delete newData[symbol];
      return newData;
    });
  }, []);

  // Get market data for a symbol
  const getMarketData = useCallback((symbol) => {
    return marketData[symbol] || null;
  }, [marketData]);

  // Get latest signals
  const getLatestSignals = useCallback((limit = 10) => {
    return signals.slice(0, limit);
  }, [signals]);

  // Get signals for a specific symbol
  const getSignalsForSymbol = useCallback((symbol, limit = 5) => {
    return signals
      .filter(signal => signal.symbol === symbol)
      .slice(0, limit);
  }, [signals]);

  // Clear all data
  const clearData = useCallback(() => {
    setMarketData({});
    setSignals([]);
  }, []);

  const value = {
    // Connection status
    connected,
    connectionStatus,
    
    // Market data
    marketData,
    subscribeToMarketData,
    unsubscribeFromMarketData,
    getMarketData,
    
    // Trading signals
    signals,
    subscribeToSignals,
    getLatestSignals,
    getSignalsForSymbol,
    
    // Utilities
    clearData,
  };

  return (
    <WebSocketContext.Provider value={value}>
      {children}
    </WebSocketContext.Provider>
  );
};
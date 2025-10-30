"""
Market Data Service
Serviço para obtenção de dados da B3 em tempo real
"""

import yfinance as yf
import pandas as pd
import asyncio
from typing import Dict, List, Optional
from datetime import datetime, timedelta
import aiohttp
import json
from dataclasses import dataclass

@dataclass
class MarketQuote:
    """Estrutura para cotação de mercado"""
    symbol: str
    price: float
    change: float
    change_percent: float
    volume: int
    high: float
    low: float
    open_price: float
    timestamp: datetime

class MarketDataService:
    """Serviço para dados de mercado da B3"""
    
    def __init__(self):
        self.cache = {}
        self.cache_timeout = 60  # 1 minuto
        
        # Principais ações da B3 para monitoramento
        self.b3_symbols = [
            "PETR4.SA",   # Petrobras
            "VALE3.SA",   # Vale
            "ITUB4.SA",   # Itaú
            "BBDC4.SA",   # Bradesco
            "ABEV3.SA",   # Ambev
            "MGLU3.SA",   # Magazine Luiza
            "WEGE3.SA",   # WEG
            "RENT3.SA",   # Localiza
            "LREN3.SA",   # Lojas Renner
            "JBSS3.SA",   # JBS
            "SUZB3.SA",   # Suzano
            "RAIL3.SA",   # Rumo
            "UGPA3.SA",   # Ultrapar
            "CYRE3.SA",   # Cyrela
            "CCRO3.SA",   # CCR
            "EGIE3.SA",   # Engie
            "TAEE11.SA",  # Taesa
            "TRPL4.SA",   # Transmissão Paulista
            "VIVT3.SA",   # Telefônica Brasil
            "TOTS3.SA"    # Totvs
        ]
    
    async def get_realtime_data(self, symbol: str) -> Optional[Dict]:
        """Obtém dados em tempo real para um símbolo"""
        try:
            # Check cache first
            cache_key = f"{symbol}_realtime"
            if cache_key in self.cache:
                cache_time, data = self.cache[cache_key]
                if (datetime.now() - cache_time).seconds < self.cache_timeout:
                    return data
            
            # Get data from Yahoo Finance
            ticker = yf.Ticker(symbol)
            info = ticker.info
            
            # Get current price and daily data
            hist = ticker.history(period="1d", interval="1m")
            
            if hist.empty:
                return None
            
            current = hist.iloc[-1]
            
            data = {
                "symbol": symbol,
                "price": float(current['Close']),
                "open": float(current['Open']),
                "high": float(current['High']),
                "low": float(current['Low']),
                "volume": int(current['Volume']),
                "change": float(current['Close'] - hist.iloc[0]['Open']),
                "change_percent": float((current['Close'] - hist.iloc[0]['Open']) / hist.iloc[0]['Open'] * 100),
                "timestamp": datetime.now().isoformat(),
                "market_cap": info.get("marketCap"),
                "currency": info.get("currency", "BRL")
            }
            
            # Cache the data
            self.cache[cache_key] = (datetime.now(), data)
            
            return data
            
        except Exception as e:
            print(f"Error getting realtime data for {symbol}: {e}")
            return None
    
    async def get_historical_data(self, symbol: str, period: str = "1mo", interval: str = "1d") -> Optional[pd.DataFrame]:
        """Obtém dados históricos para análise técnica"""
        try:
            cache_key = f"{symbol}_{period}_{interval}"
            if cache_key in self.cache:
                cache_time, data = self.cache[cache_key]
                if (datetime.now() - cache_time).seconds < 300:  # 5 minutes cache
                    return data
            
            ticker = yf.Ticker(symbol)
            data = ticker.history(period=period, interval=interval)
            
            if data.empty:
                return None
            
            # Add technical indicators columns
            data['SMA_20'] = data['Close'].rolling(window=20).mean()
            data['SMA_50'] = data['Close'].rolling(window=50).mean()
            data['Volume_SMA'] = data['Volume'].rolling(window=20).mean()
            
            # Cache the data
            self.cache[cache_key] = (datetime.now(), data)
            
            return data
            
        except Exception as e:
            print(f"Error getting historical data for {symbol}: {e}")
            return None
    
    async def get_intraday_data(self, symbol: str, interval: str = "5m") -> Optional[pd.DataFrame]:
        """Obtém dados intraday para day trading"""
        try:
            ticker = yf.Ticker(symbol)
            
            # Get last 5 days of intraday data
            data = ticker.history(period="5d", interval=interval)
            
            if data.empty:
                return None
            
            # Filter only today's data for day trading
            today = datetime.now().date()
            data = data[data.index.date == today]
            
            return data
            
        except Exception as e:
            print(f"Error getting intraday data for {symbol}: {e}")
            return None
    
    async def get_market_overview(self) -> Dict:
        """Obtém visão geral do mercado B3"""
        try:
            overview = {
                "timestamp": datetime.now().isoformat(),
                "market_status": "open",  # Simplified - could check actual market hours
                "top_gainers": [],
                "top_losers": [],
                "most_active": []
            }
            
            # Get data for main B3 symbols
            quotes = []
            for symbol in self.b3_symbols[:10]:  # Limit to avoid rate limiting
                data = await self.get_realtime_data(symbol)
                if data:
                    quotes.append(data)
                await asyncio.sleep(0.1)  # Small delay between requests
            
            if quotes:
                # Sort by change percent
                quotes.sort(key=lambda x: x['change_percent'], reverse=True)
                
                overview["top_gainers"] = quotes[:5]
                overview["top_losers"] = quotes[-5:]
                
                # Sort by volume for most active
                quotes.sort(key=lambda x: x['volume'], reverse=True)
                overview["most_active"] = quotes[:5]
            
            return overview
            
        except Exception as e:
            print(f"Error getting market overview: {e}")
            return {}
    
    async def search_symbol(self, query: str) -> List[Dict]:
        """Busca símbolos na B3"""
        try:
            # Simple search in our known symbols
            results = []
            query_upper = query.upper()
            
            for symbol in self.b3_symbols:
                if query_upper in symbol or query_upper in symbol.replace(".SA", ""):
                    # Get basic info
                    ticker = yf.Ticker(symbol)
                    info = ticker.info
                    
                    results.append({
                        "symbol": symbol,
                        "name": info.get("longName", symbol),
                        "sector": info.get("sector", "N/A"),
                        "currency": info.get("currency", "BRL")
                    })
            
            return results[:10]  # Limit results
            
        except Exception as e:
            print(f"Error searching symbols: {e}")
            return []
    
    async def get_company_info(self, symbol: str) -> Optional[Dict]:
        """Obtém informações da empresa"""
        try:
            ticker = yf.Ticker(symbol)
            info = ticker.info
            
            company_info = {
                "symbol": symbol,
                "name": info.get("longName", "N/A"),
                "sector": info.get("sector", "N/A"),
                "industry": info.get("industry", "N/A"),
                "market_cap": info.get("marketCap"),
                "employees": info.get("fullTimeEmployees"),
                "website": info.get("website"),
                "description": info.get("longBusinessSummary", "N/A")[:500],  # Limit description
                "pe_ratio": info.get("trailingPE"),
                "dividend_yield": info.get("dividendYield"),
                "52_week_high": info.get("fiftyTwoWeekHigh"),
                "52_week_low": info.get("fiftyTwoWeekLow"),
                "currency": info.get("currency", "BRL")
            }
            
            return company_info
            
        except Exception as e:
            print(f"Error getting company info for {symbol}: {e}")
            return None
    
    def get_b3_symbols(self) -> List[str]:
        """Retorna lista de símbolos principais da B3"""
        return self.b3_symbols.copy()
    
    async def is_market_open(self) -> bool:
        """Verifica se o mercado está aberto (B3: 10:00 - 17:30 BRT)"""
        try:
            now = datetime.now()
            
            # Simple check - B3 is open Monday to Friday, 10:00 to 17:30 BRT
            if now.weekday() >= 5:  # Saturday or Sunday
                return False
            
            market_open = now.replace(hour=10, minute=0, second=0)
            market_close = now.replace(hour=17, minute=30, second=0)
            
            return market_open <= now <= market_close
            
        except Exception as e:
            print(f"Error checking market status: {e}")
            return True  # Default to open
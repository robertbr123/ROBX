"""
Technical Analysis Service
Serviço para análise técnica e geração de sinais de trading
"""

import pandas as pd
import numpy as np
from typing import Dict, List, Optional, Tuple
from datetime import datetime, timedelta
import asyncio

# Technical Analysis Library
try:
    import talib
    TALIB_AVAILABLE = True
except ImportError:
    TALIB_AVAILABLE = False
    print("⚠️  TA-Lib não disponível. Usando implementações próprias.")

from .market_service import MarketDataService
from dataclasses import dataclass

@dataclass
class TradingSignal:
    """Estrutura para sinal de trading"""
    symbol: str
    signal: str  # BUY, SELL, HOLD
    strength: float  # 0-100
    price: float
    indicators: Dict
    timestamp: datetime
    reason: str

class TechnicalAnalysisService:
    """Serviço de análise técnica para geração de sinais"""
    
    def __init__(self):
        self.market_service = MarketDataService()
        self.signals_cache = {}
        
    def calculate_rsi(self, prices: pd.Series, period: int = 14) -> pd.Series:
        """Calcula RSI (Relative Strength Index)"""
        if TALIB_AVAILABLE:
            return talib.RSI(prices.values, timeperiod=period)
        
        # Implementação própria do RSI
        delta = prices.diff()
        gain = delta.where(delta > 0, 0)
        loss = -delta.where(delta < 0, 0)
        
        avg_gain = gain.rolling(window=period).mean()
        avg_loss = loss.rolling(window=period).mean()
        
        rs = avg_gain / avg_loss
        rsi = 100 - (100 / (1 + rs))
        
        return rsi
    
    def calculate_macd(self, prices: pd.Series) -> Tuple[pd.Series, pd.Series, pd.Series]:
        """Calcula MACD (Moving Average Convergence Divergence)"""
        if TALIB_AVAILABLE:
            macd, signal, hist = talib.MACD(prices.values)
            return pd.Series(macd), pd.Series(signal), pd.Series(hist)
        
        # Implementação própria do MACD
        ema_12 = prices.ewm(span=12).mean()
        ema_26 = prices.ewm(span=26).mean()
        macd = ema_12 - ema_26
        signal = macd.ewm(span=9).mean()
        histogram = macd - signal
        
        return macd, signal, histogram
    
    def calculate_bollinger_bands(self, prices: pd.Series, period: int = 20, std_dev: int = 2) -> Tuple[pd.Series, pd.Series, pd.Series]:
        """Calcula Bollinger Bands"""
        if TALIB_AVAILABLE:
            upper, middle, lower = talib.BBANDS(prices.values, timeperiod=period, nbdevup=std_dev, nbdevdn=std_dev)
            return pd.Series(upper), pd.Series(middle), pd.Series(lower)
        
        # Implementação própria
        sma = prices.rolling(window=period).mean()
        std = prices.rolling(window=period).std()
        upper = sma + (std * std_dev)
        lower = sma - (std * std_dev)
        
        return upper, sma, lower
    
    def calculate_moving_averages(self, prices: pd.Series) -> Dict[str, pd.Series]:
        """Calcula médias móveis"""
        return {
            'SMA_5': prices.rolling(window=5).mean(),
            'SMA_10': prices.rolling(window=10).mean(),
            'SMA_20': prices.rolling(window=20).mean(),
            'SMA_50': prices.rolling(window=50).mean(),
            'EMA_5': prices.ewm(span=5).mean(),
            'EMA_10': prices.ewm(span=10).mean(),
            'EMA_20': prices.ewm(span=20).mean(),
            'EMA_50': prices.ewm(span=50).mean()
        }
    
    def calculate_stochastic(self, high: pd.Series, low: pd.Series, close: pd.Series, period: int = 14) -> Tuple[pd.Series, pd.Series]:
        """Calcula Stochastic Oscillator"""
        if TALIB_AVAILABLE:
            k, d = talib.STOCH(high.values, low.values, close.values)
            return pd.Series(k), pd.Series(d)
        
        # Implementação própria
        lowest_low = low.rolling(window=period).min()
        highest_high = high.rolling(window=period).max()
        
        k_percent = 100 * ((close - lowest_low) / (highest_high - lowest_low))
        d_percent = k_percent.rolling(window=3).mean()
        
        return k_percent, d_percent
    
    def calculate_williams_r(self, high: pd.Series, low: pd.Series, close: pd.Series, period: int = 14) -> pd.Series:
        """Calcula Williams %R"""
        if TALIB_AVAILABLE:
            return talib.WILLR(high.values, low.values, close.values, timeperiod=period)
        
        # Implementação própria
        highest_high = high.rolling(window=period).max()
        lowest_low = low.rolling(window=period).min()
        
        williams_r = -100 * ((highest_high - close) / (highest_high - lowest_low))
        
        return williams_r
    
    def calculate_volume_indicators(self, data: pd.DataFrame) -> Dict[str, pd.Series]:
        """Calcula indicadores de volume"""
        volume = data['Volume']
        close = data['Close']
        
        # On Balance Volume (OBV)
        obv = (volume * np.where(close.diff() > 0, 1, -1)).cumsum()
        
        # Volume Rate of Change
        volume_roc = volume.pct_change(periods=10) * 100
        
        # Volume SMA
        volume_sma = volume.rolling(window=20).mean()
        
        return {
            'OBV': obv,
            'Volume_ROC': volume_roc,
            'Volume_SMA': volume_sma,
            'Volume_Ratio': volume / volume_sma
        }
    
    async def analyze_symbol(self, symbol: str, timeframe: str = "1d") -> Optional[Dict]:
        """Análise completa de um símbolo"""
        try:
            # Get historical data
            if timeframe == "1d":
                data = await self.market_service.get_historical_data(symbol, period="3mo", interval="1d")
            else:
                data = await self.market_service.get_intraday_data(symbol, interval="5m")
            
            if data is None or data.empty:
                return None
            
            # Calculate all indicators
            analysis = await self._perform_technical_analysis(data, symbol)
            
            # Generate trading signal
            signal = self._generate_signal(analysis)
            
            return {
                "symbol": symbol,
                "timeframe": timeframe,
                "current_price": float(data['Close'].iloc[-1]),
                "signal": signal.signal,
                "signal_strength": signal.strength,
                "reason": signal.reason,
                "indicators": analysis,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            print(f"Error analyzing {symbol}: {e}")
            return None
    
    async def _perform_technical_analysis(self, data: pd.DataFrame, symbol: str) -> Dict:
        """Executa análise técnica completa"""
        close = data['Close']
        high = data['High']
        low = data['Low']
        volume = data['Volume']
        
        # RSI
        rsi = self.calculate_rsi(close)
        current_rsi = float(rsi.iloc[-1]) if not pd.isna(rsi.iloc[-1]) else 50
        
        # MACD
        macd, macd_signal, macd_hist = self.calculate_macd(close)
        current_macd = float(macd.iloc[-1]) if not pd.isna(macd.iloc[-1]) else 0
        current_macd_signal = float(macd_signal.iloc[-1]) if not pd.isna(macd_signal.iloc[-1]) else 0
        current_macd_hist = float(macd_hist.iloc[-1]) if not pd.isna(macd_hist.iloc[-1]) else 0
        
        # Bollinger Bands
        bb_upper, bb_middle, bb_lower = self.calculate_bollinger_bands(close)
        current_price = float(close.iloc[-1])
        bb_position = (current_price - float(bb_lower.iloc[-1])) / (float(bb_upper.iloc[-1]) - float(bb_lower.iloc[-1]))
        
        # Moving Averages
        mas = self.calculate_moving_averages(close)
        
        # Stochastic
        stoch_k, stoch_d = self.calculate_stochastic(high, low, close)
        current_stoch_k = float(stoch_k.iloc[-1]) if not pd.isna(stoch_k.iloc[-1]) else 50
        current_stoch_d = float(stoch_d.iloc[-1]) if not pd.isna(stoch_d.iloc[-1]) else 50
        
        # Williams %R
        williams_r = self.calculate_williams_r(high, low, close)
        current_williams = float(williams_r.iloc[-1]) if not pd.isna(williams_r.iloc[-1]) else -50
        
        # Volume indicators
        volume_indicators = self.calculate_volume_indicators(data)
        
        # Price action analysis
        price_change = (current_price - float(close.iloc[-2])) / float(close.iloc[-2]) * 100
        
        # Trend analysis
        sma_20 = float(mas['SMA_20'].iloc[-1]) if not pd.isna(mas['SMA_20'].iloc[-1]) else current_price
        sma_50 = float(mas['SMA_50'].iloc[-1]) if not pd.isna(mas['SMA_50'].iloc[-1]) else current_price
        
        trend = "SIDEWAYS"
        if current_price > sma_20 > sma_50:
            trend = "UPTREND"
        elif current_price < sma_20 < sma_50:
            trend = "DOWNTREND"
        
        return {
            "rsi": current_rsi,
            "macd": {
                "macd": current_macd,
                "signal": current_macd_signal,
                "histogram": current_macd_hist
            },
            "bollinger_bands": {
                "upper": float(bb_upper.iloc[-1]),
                "middle": float(bb_middle.iloc[-1]),
                "lower": float(bb_lower.iloc[-1]),
                "position": bb_position
            },
            "stochastic": {
                "k": current_stoch_k,
                "d": current_stoch_d
            },
            "williams_r": current_williams,
            "moving_averages": {
                "sma_20": sma_20,
                "sma_50": sma_50,
                "ema_20": float(mas['EMA_20'].iloc[-1]) if not pd.isna(mas['EMA_20'].iloc[-1]) else current_price
            },
            "volume": {
                "current": int(volume.iloc[-1]),
                "average": int(volume.rolling(20).mean().iloc[-1]),
                "ratio": float(volume_indicators['Volume_Ratio'].iloc[-1]) if not pd.isna(volume_indicators['Volume_Ratio'].iloc[-1]) else 1.0
            },
            "price_action": {
                "change_percent": price_change,
                "trend": trend
            }
        }
    
    def _generate_signal(self, analysis: Dict) -> TradingSignal:
        """Gera sinal de trading baseado na análise técnica"""
        symbol = ""  # Will be set by caller
        current_price = 0  # Will be set by caller
        
        # Initialize scores
        buy_score = 0
        sell_score = 0
        reasons = []
        
        # RSI Analysis
        rsi = analysis["rsi"]
        if rsi < 30:
            buy_score += 25
            reasons.append("RSI oversold (<30)")
        elif rsi > 70:
            sell_score += 25
            reasons.append("RSI overbought (>70)")
        elif rsi < 45:
            buy_score += 10
            reasons.append("RSI favorable for buying")
        elif rsi > 55:
            sell_score += 10
            reasons.append("RSI favorable for selling")
        
        # MACD Analysis
        macd_hist = analysis["macd"]["histogram"]
        if macd_hist > 0 and analysis["macd"]["macd"] > analysis["macd"]["signal"]:
            buy_score += 20
            reasons.append("MACD bullish crossover")
        elif macd_hist < 0 and analysis["macd"]["macd"] < analysis["macd"]["signal"]:
            sell_score += 20
            reasons.append("MACD bearish crossover")
        
        # Bollinger Bands Analysis
        bb_position = analysis["bollinger_bands"]["position"]
        if bb_position < 0.2:
            buy_score += 15
            reasons.append("Price near lower Bollinger Band")
        elif bb_position > 0.8:
            sell_score += 15
            reasons.append("Price near upper Bollinger Band")
        
        # Stochastic Analysis
        stoch_k = analysis["stochastic"]["k"]
        stoch_d = analysis["stochastic"]["d"]
        if stoch_k < 20 and stoch_d < 20:
            buy_score += 15
            reasons.append("Stochastic oversold")
        elif stoch_k > 80 and stoch_d > 80:
            sell_score += 15
            reasons.append("Stochastic overbought")
        
        # Williams %R Analysis
        williams = analysis["williams_r"]
        if williams < -80:
            buy_score += 10
            reasons.append("Williams %R oversold")
        elif williams > -20:
            sell_score += 10
            reasons.append("Williams %R overbought")
        
        # Moving Average Analysis
        trend = analysis["price_action"]["trend"]
        if trend == "UPTREND":
            buy_score += 15
            reasons.append("Price in uptrend")
        elif trend == "DOWNTREND":
            sell_score += 15
            reasons.append("Price in downtrend")
        
        # Volume Analysis
        volume_ratio = analysis["volume"]["ratio"]
        if volume_ratio > 1.5:
            if buy_score > sell_score:
                buy_score += 10
                reasons.append("High volume supports buy signal")
            else:
                sell_score += 10
                reasons.append("High volume supports sell signal")
        
        # Determine final signal
        total_score = max(buy_score, sell_score)
        
        if buy_score > sell_score and buy_score >= 40:
            signal = "BUY"
            strength = min(buy_score, 100)
        elif sell_score > buy_score and sell_score >= 40:
            signal = "SELL" 
            strength = min(sell_score, 100)
        else:
            signal = "HOLD"
            strength = 50
            reasons = ["No clear signal - market conditions unclear"]
        
        return TradingSignal(
            symbol=symbol,
            signal=signal,
            strength=strength,
            price=current_price,
            indicators=analysis,
            timestamp=datetime.now(),
            reason="; ".join(reasons[:3])  # Top 3 reasons
        )
    
    async def get_latest_signals(self) -> List[Dict]:
        """Obtém os sinais mais recentes para múltiplos símbolos"""
        try:
            signals = []
            symbols = self.market_service.get_b3_symbols()[:10]  # Limit to avoid rate limiting
            
            for symbol in symbols:
                analysis = await self.analyze_symbol(symbol)
                if analysis and analysis["signal"] != "HOLD":
                    signals.append(analysis)
                    
                # Small delay between requests
                await asyncio.sleep(0.1)
            
            # Sort by signal strength
            signals.sort(key=lambda x: x["signal_strength"], reverse=True)
            
            return signals[:5]  # Return top 5 signals
            
        except Exception as e:
            print(f"Error getting latest signals: {e}")
            return []
    
    async def analyze_multiple_timeframes(self, symbol: str) -> Dict:
        """Análise em múltiplos timeframes"""
        try:
            timeframes = ["1d", "5m"]
            results = {}
            
            for tf in timeframes:
                analysis = await self.analyze_symbol(symbol, tf)
                if analysis:
                    results[tf] = analysis
            
            return results
            
        except Exception as e:
            print(f"Error in multi-timeframe analysis for {symbol}: {e}")
            return {}
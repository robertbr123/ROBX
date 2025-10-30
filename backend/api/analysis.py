"""
Technical Analysis API Routes
Rotas para análise técnica e indicadores
"""

from fastapi import APIRouter, HTTPException, Query
from typing import Optional

try:
    # Try relative import first (when run as package)
    from ..services.analysis_service import TechnicalAnalysisService
except ImportError:
    # Fall back to absolute import (when run directly)
    import sys
    import os
    sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    from services.analysis_service import TechnicalAnalysisService

router = APIRouter()
analysis_service = TechnicalAnalysisService()

@router.get("/analyze/{symbol}")
async def analyze_symbol(
    symbol: str,
    timeframe: str = Query("1d", description="Timeframe: 1d (daily) or 5m (intraday)")
):
    """Análise técnica completa de um símbolo"""
    try:
        analysis = await analysis_service.analyze_symbol(symbol, timeframe)
        
        if not analysis:
            raise HTTPException(status_code=404, detail=f"Could not analyze {symbol}")
        
        return {
            "success": True,
            "data": analysis
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error analyzing {symbol}: {str(e)}")

@router.get("/indicators/{symbol}")
async def get_indicators(
    symbol: str,
    timeframe: str = Query("1d", description="Timeframe: 1d or 5m"),
    indicators: str = Query("rsi,macd,bollinger", description="Comma-separated indicators: rsi,macd,bollinger,stoch,williams,ma")
):
    """Obtém indicadores técnicos específicos"""
    try:
        analysis = await analysis_service.analyze_symbol(symbol, timeframe)
        
        if not analysis:
            raise HTTPException(status_code=404, detail=f"Could not get indicators for {symbol}")
        
        # Filter requested indicators
        requested_indicators = [ind.strip().lower() for ind in indicators.split(",")]
        filtered_indicators = {}
        
        indicator_mapping = {
            "rsi": "rsi",
            "macd": "macd",
            "bollinger": "bollinger_bands",
            "stoch": "stochastic", 
            "williams": "williams_r",
            "ma": "moving_averages",
            "volume": "volume"
        }
        
        for req_ind in requested_indicators:
            if req_ind in indicator_mapping:
                key = indicator_mapping[req_ind]
                if key in analysis["indicators"]:
                    filtered_indicators[req_ind] = analysis["indicators"][key]
        
        return {
            "success": True,
            "data": {
                "symbol": symbol,
                "timeframe": timeframe,
                "current_price": analysis["current_price"],
                "indicators": filtered_indicators,
                "timestamp": analysis["timestamp"]
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting indicators for {symbol}: {str(e)}")

@router.get("/signal/{symbol}")
async def get_trading_signal(
    symbol: str,
    timeframe: str = Query("1d", description="Timeframe: 1d or 5m")
):
    """Obtém sinal de trading para um símbolo"""
    try:
        analysis = await analysis_service.analyze_symbol(symbol, timeframe)
        
        if not analysis:
            raise HTTPException(status_code=404, detail=f"Could not generate signal for {symbol}")
        
        return {
            "success": True,
            "data": {
                "symbol": symbol,
                "timeframe": timeframe,
                "signal": analysis["signal"],
                "strength": analysis["signal_strength"],
                "price": analysis["current_price"],
                "reason": analysis["reason"],
                "timestamp": analysis["timestamp"]
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating signal for {symbol}: {str(e)}")

@router.get("/multi-timeframe/{symbol}")
async def multi_timeframe_analysis(symbol: str):
    """Análise em múltiplos timeframes"""
    try:
        analysis = await analysis_service.analyze_multiple_timeframes(symbol)
        
        if not analysis:
            raise HTTPException(status_code=404, detail=f"Could not perform multi-timeframe analysis for {symbol}")
        
        return {
            "success": True,
            "data": {
                "symbol": symbol,
                "timeframes": analysis
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error in multi-timeframe analysis for {symbol}: {str(e)}")

@router.get("/rsi/{symbol}")
async def get_rsi(
    symbol: str,
    timeframe: str = Query("1d", description="Timeframe: 1d or 5m"),
    period: int = Query(14, description="RSI period")
):
    """Obtém RSI específico"""
    try:
        analysis = await analysis_service.analyze_symbol(symbol, timeframe)
        
        if not analysis:
            raise HTTPException(status_code=404, detail=f"Could not calculate RSI for {symbol}")
        
        rsi_value = analysis["indicators"]["rsi"]
        
        # RSI interpretation
        interpretation = "NEUTRAL"
        if rsi_value < 30:
            interpretation = "OVERSOLD"
        elif rsi_value > 70:
            interpretation = "OVERBOUGHT"
        elif rsi_value < 45:
            interpretation = "BEARISH"
        elif rsi_value > 55:
            interpretation = "BULLISH"
        
        return {
            "success": True,
            "data": {
                "symbol": symbol,
                "timeframe": timeframe,
                "rsi": rsi_value,
                "period": period,
                "interpretation": interpretation,
                "timestamp": analysis["timestamp"]
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error calculating RSI for {symbol}: {str(e)}")

@router.get("/macd/{symbol}")
async def get_macd(
    symbol: str,
    timeframe: str = Query("1d", description="Timeframe: 1d or 5m")
):
    """Obtém MACD específico"""
    try:
        analysis = await analysis_service.analyze_symbol(symbol, timeframe)
        
        if not analysis:
            raise HTTPException(status_code=404, detail=f"Could not calculate MACD for {symbol}")
        
        macd_data = analysis["indicators"]["macd"]
        
        # MACD interpretation
        signal_type = "NEUTRAL"
        if macd_data["histogram"] > 0 and macd_data["macd"] > macd_data["signal"]:
            signal_type = "BULLISH"
        elif macd_data["histogram"] < 0 and macd_data["macd"] < macd_data["signal"]:
            signal_type = "BEARISH"
        
        return {
            "success": True,
            "data": {
                "symbol": symbol,
                "timeframe": timeframe,
                "macd": macd_data["macd"],
                "signal": macd_data["signal"],
                "histogram": macd_data["histogram"],
                "signal_type": signal_type,
                "timestamp": analysis["timestamp"]
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error calculating MACD for {symbol}: {str(e)}")

@router.get("/bollinger/{symbol}")
async def get_bollinger_bands(
    symbol: str,
    timeframe: str = Query("1d", description="Timeframe: 1d or 5m")
):
    """Obtém Bollinger Bands específicas"""
    try:
        analysis = await analysis_service.analyze_symbol(symbol, timeframe)
        
        if not analysis:
            raise HTTPException(status_code=404, detail=f"Could not calculate Bollinger Bands for {symbol}")
        
        bb_data = analysis["indicators"]["bollinger_bands"]
        current_price = analysis["current_price"]
        
        # Bollinger Bands interpretation
        position = bb_data["position"]
        interpretation = "MIDDLE"
        
        if position < 0.2:
            interpretation = "NEAR_LOWER_BAND"
        elif position > 0.8:
            interpretation = "NEAR_UPPER_BAND"
        elif position < 0.1:
            interpretation = "BELOW_LOWER_BAND"
        elif position > 0.9:
            interpretation = "ABOVE_UPPER_BAND"
        
        return {
            "success": True,
            "data": {
                "symbol": symbol,
                "timeframe": timeframe,
                "current_price": current_price,
                "upper_band": bb_data["upper"],
                "middle_band": bb_data["middle"],
                "lower_band": bb_data["lower"],
                "position": position,
                "interpretation": interpretation,
                "timestamp": analysis["timestamp"]
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error calculating Bollinger Bands for {symbol}: {str(e)}")

@router.get("/trend/{symbol}")
async def get_trend_analysis(
    symbol: str,
    timeframe: str = Query("1d", description="Timeframe: 1d or 5m")
):
    """Análise de tendência"""
    try:
        analysis = await analysis_service.analyze_symbol(symbol, timeframe)
        
        if not analysis:
            raise HTTPException(status_code=404, detail=f"Could not analyze trend for {symbol}")
        
        price_action = analysis["indicators"]["price_action"]
        moving_averages = analysis["indicators"]["moving_averages"]
        current_price = analysis["current_price"]
        
        return {
            "success": True,
            "data": {
                "symbol": symbol,
                "timeframe": timeframe,
                "current_price": current_price,
                "trend": price_action["trend"],
                "change_percent": price_action["change_percent"],
                "moving_averages": moving_averages,
                "timestamp": analysis["timestamp"]
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error analyzing trend for {symbol}: {str(e)}")
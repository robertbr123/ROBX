"""
Trading Recommendations API Routes
Rotas para recomendações e sinais de trading
"""

from fastapi import APIRouter, HTTPException, Query
from typing import List, Optional
import asyncio

try:
    # Try relative imports first (when run as package)
    from ..services.analysis_service import TechnicalAnalysisService
    from ..services.market_service import MarketDataService
except ImportError:
    # Fall back to absolute imports (when run directly)
    import sys
    import os
    sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    from services.analysis_service import TechnicalAnalysisService
    from services.market_service import MarketDataService

router = APIRouter()
analysis_service = TechnicalAnalysisService()
market_service = MarketDataService()

@router.get("/signals")
async def get_latest_signals(
    limit: int = Query(10, description="Maximum number of signals to return")
):
    """Obtém os sinais de trading mais recentes"""
    try:
        signals = await analysis_service.get_latest_signals()
        
        # Limit results
        if limit:
            signals = signals[:limit]
        
        return {
            "success": True,
            "data": {
                "signals": signals,
                "count": len(signals),
                "generated_at": signals[0]["timestamp"] if signals else None
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting signals: {str(e)}")

@router.get("/signals/{signal_type}")
async def get_signals_by_type(
    signal_type: str,
    limit: int = Query(10, description="Maximum number of signals to return")
):
    """Obtém sinais por tipo (BUY, SELL, HOLD)"""
    try:
        signal_type_upper = signal_type.upper()
        
        if signal_type_upper not in ["BUY", "SELL", "HOLD"]:
            raise HTTPException(status_code=400, detail="Signal type must be BUY, SELL, or HOLD")
        
        all_signals = await analysis_service.get_latest_signals()
        
        # Filter by signal type
        filtered_signals = [s for s in all_signals if s["signal"] == signal_type_upper]
        
        # Limit results
        if limit:
            filtered_signals = filtered_signals[:limit]
        
        return {
            "success": True,
            "data": {
                "signal_type": signal_type_upper,
                "signals": filtered_signals,
                "count": len(filtered_signals)
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting {signal_type} signals: {str(e)}")

@router.get("/watchlist")
async def get_watchlist_signals():
    """Obtém sinais para uma watchlist de ações principais da B3"""
    try:
        # Get popular B3 stocks
        symbols = market_service.get_b3_symbols()[:15]  # Top 15 most popular
        
        watchlist_data = []
        
        # Analyze each symbol
        tasks = []
        for symbol in symbols:
            tasks.append(analysis_service.analyze_symbol(symbol))
        
        analyses = await asyncio.gather(*tasks, return_exceptions=True)
        
        for symbol, analysis in zip(symbols, analyses):
            if isinstance(analysis, Exception):
                continue
                
            if analysis:
                watchlist_data.append({
                    "symbol": symbol,
                    "current_price": analysis["current_price"],
                    "signal": analysis["signal"],
                    "signal_strength": analysis["signal_strength"],
                    "change_percent": analysis["indicators"]["price_action"]["change_percent"],
                    "volume_ratio": analysis["indicators"]["volume"]["ratio"],
                    "rsi": analysis["indicators"]["rsi"],
                    "trend": analysis["indicators"]["price_action"]["trend"]
                })
        
        # Sort by signal strength
        watchlist_data.sort(key=lambda x: x["signal_strength"], reverse=True)
        
        return {
            "success": True,
            "data": {
                "watchlist": watchlist_data,
                "count": len(watchlist_data),
                "last_updated": watchlist_data[0]["timestamp"] if watchlist_data else None
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting watchlist: {str(e)}")

@router.get("/opportunities")
async def get_trading_opportunities(
    min_strength: int = Query(60, description="Minimum signal strength (0-100)"),
    signal_types: str = Query("BUY,SELL", description="Comma-separated signal types")
):
    """Encontra oportunidades de trading com alta probabilidade"""
    try:
        allowed_signals = [s.strip().upper() for s in signal_types.split(",")]
        
        # Get all latest signals
        all_signals = await analysis_service.get_latest_signals()
        
        # Filter by strength and signal type
        opportunities = []
        for signal in all_signals:
            if (signal["signal"] in allowed_signals and 
                signal["signal_strength"] >= min_strength):
                
                # Add additional context
                opportunity = {
                    "symbol": signal["symbol"],
                    "signal": signal["signal"],
                    "strength": signal["signal_strength"],
                    "price": signal["current_price"],
                    "reason": signal["reason"],
                    "indicators": {
                        "rsi": signal["indicators"]["rsi"],
                        "trend": signal["indicators"]["price_action"]["trend"],
                        "volume_ratio": signal["indicators"]["volume"]["ratio"]
                    },
                    "risk_level": "HIGH" if signal["signal_strength"] < 70 else "MEDIUM" if signal["signal_strength"] < 85 else "LOW",
                    "timestamp": signal["timestamp"]
                }
                
                opportunities.append(opportunity)
        
        # Sort by strength
        opportunities.sort(key=lambda x: x["strength"], reverse=True)
        
        return {
            "success": True,
            "data": {
                "opportunities": opportunities,
                "count": len(opportunities),
                "criteria": {
                    "min_strength": min_strength,
                    "signal_types": allowed_signals
                }
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error finding opportunities: {str(e)}")

@router.get("/portfolio-analysis")
async def analyze_portfolio(
    symbols: str = Query(..., description="Comma-separated symbols to analyze"),
    weights: Optional[str] = Query(None, description="Comma-separated portfolio weights (optional)")
):
    """Análise de portfólio de ações"""
    try:
        symbol_list = [s.strip().upper() for s in symbols.split(",")]
        
        if len(symbol_list) > 10:
            raise HTTPException(status_code=400, detail="Maximum 10 symbols allowed")
        
        # Parse weights if provided
        weight_list = None
        if weights:
            try:
                weight_list = [float(w.strip()) for w in weights.split(",")]
                if len(weight_list) != len(symbol_list):
                    raise HTTPException(status_code=400, detail="Number of weights must match number of symbols")
                if abs(sum(weight_list) - 1.0) > 0.01:
                    raise HTTPException(status_code=400, detail="Weights must sum to 1.0")
            except ValueError:
                raise HTTPException(status_code=400, detail="Invalid weight format")
        else:
            # Equal weights
            weight_list = [1.0 / len(symbol_list)] * len(symbol_list)
        
        # Analyze each symbol
        portfolio_analysis = []
        total_score = 0
        
        tasks = []
        for symbol in symbol_list:
            tasks.append(analysis_service.analyze_symbol(symbol))
        
        analyses = await asyncio.gather(*tasks, return_exceptions=True)
        
        for symbol, weight, analysis in zip(symbol_list, weight_list, analyses):
            if isinstance(analysis, Exception):
                continue
                
            if analysis:
                weighted_score = analysis["signal_strength"] * weight
                total_score += weighted_score
                
                portfolio_analysis.append({
                    "symbol": symbol,
                    "weight": weight,
                    "current_price": analysis["current_price"],
                    "signal": analysis["signal"],
                    "signal_strength": analysis["signal_strength"],
                    "weighted_score": weighted_score,
                    "contribution": weighted_score / 100,  # Percentage contribution
                    "rsi": analysis["indicators"]["rsi"],
                    "trend": analysis["indicators"]["price_action"]["trend"]
                })
        
        # Portfolio recommendation
        portfolio_signal = "HOLD"
        if total_score >= 65:
            portfolio_signal = "BUY"
        elif total_score <= 35:
            portfolio_signal = "SELL"
        
        return {
            "success": True,
            "data": {
                "portfolio": {
                    "symbols": symbol_list,
                    "total_score": total_score,
                    "recommendation": portfolio_signal,
                    "risk_level": "LOW" if total_score >= 75 or total_score <= 25 else "MEDIUM"
                },
                "individual_analysis": portfolio_analysis,
                "summary": {
                    "buy_signals": len([a for a in portfolio_analysis if a["signal"] == "BUY"]),
                    "sell_signals": len([a for a in portfolio_analysis if a["signal"] == "SELL"]),
                    "hold_signals": len([a for a in portfolio_analysis if a["signal"] == "HOLD"])
                }
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error analyzing portfolio: {str(e)}")

@router.get("/sector-analysis/{sector}")
async def analyze_sector(sector: str):
    """Análise de setor específico"""
    try:
        # This is a simplified sector analysis
        # In a real implementation, you would have sector mapping
        sector_symbols = {
            "financials": ["ITUB4.SA", "BBDC4.SA", "SANB11.SA"],
            "energy": ["PETR4.SA", "VALE3.SA"],
            "consumer": ["ABEV3.SA", "LREN3.SA", "MGLU3.SA"],
            "industrials": ["WEGE3.SA", "RAIL3.SA"]
        }
        
        sector_lower = sector.lower()
        if sector_lower not in sector_symbols:
            raise HTTPException(status_code=404, detail=f"Sector {sector} not found")
        
        symbols = sector_symbols[sector_lower]
        
        # Analyze sector symbols
        sector_analysis = []
        
        tasks = []
        for symbol in symbols:
            tasks.append(analysis_service.analyze_symbol(symbol))
        
        analyses = await asyncio.gather(*tasks, return_exceptions=True)
        
        for symbol, analysis in zip(symbols, analyses):
            if isinstance(analysis, Exception):
                continue
                
            if analysis:
                sector_analysis.append({
                    "symbol": symbol,
                    "signal": analysis["signal"],
                    "strength": analysis["signal_strength"],
                    "price": analysis["current_price"],
                    "change_percent": analysis["indicators"]["price_action"]["change_percent"]
                })
        
        # Calculate sector metrics
        if sector_analysis:
            avg_strength = sum(a["strength"] for a in sector_analysis) / len(sector_analysis)
            avg_change = sum(a["change_percent"] for a in sector_analysis) / len(sector_analysis)
            
            buy_count = len([a for a in sector_analysis if a["signal"] == "BUY"])
            sell_count = len([a for a in sector_analysis if a["signal"] == "SELL"])
            
            sector_sentiment = "NEUTRAL"
            if buy_count > sell_count:
                sector_sentiment = "BULLISH"
            elif sell_count > buy_count:
                sector_sentiment = "BEARISH"
        else:
            avg_strength = 50
            avg_change = 0
            sector_sentiment = "NEUTRAL"
        
        return {
            "success": True,
            "data": {
                "sector": sector,
                "sentiment": sector_sentiment,
                "average_strength": avg_strength,
                "average_change": avg_change,
                "stocks": sector_analysis,
                "summary": {
                    "total_stocks": len(sector_analysis),
                    "buy_signals": buy_count if sector_analysis else 0,
                    "sell_signals": sell_count if sector_analysis else 0
                }
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error analyzing sector {sector}: {str(e)}")
"""
Market Data API Routes
Rotas para dados de mercado da B3
"""

from fastapi import APIRouter, HTTPException, Query
from typing import List, Optional
import asyncio

from ..services.market_service import MarketDataService

router = APIRouter()
market_service = MarketDataService()

@router.get("/quote/{symbol}")
async def get_quote(symbol: str):
    """Obtém cotação atual de um símbolo"""
    try:
        data = await market_service.get_realtime_data(symbol)
        
        if not data:
            raise HTTPException(status_code=404, detail=f"Symbol {symbol} not found")
        
        return {
            "success": True,
            "data": data
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching quote: {str(e)}")

@router.get("/historical/{symbol}")
async def get_historical(
    symbol: str,
    period: str = Query("1mo", description="Period: 1d, 5d, 1mo, 3mo, 6mo, 1y, 2y, 5y, 10y, ytd, max"),
    interval: str = Query("1d", description="Interval: 1m, 2m, 5m, 15m, 30m, 60m, 90m, 1h, 1d, 5d, 1wk, 1mo, 3mo")
):
    """Obtém dados históricos de um símbolo"""
    try:
        data = await market_service.get_historical_data(symbol, period, interval)
        
        if data is None or data.empty:
            raise HTTPException(status_code=404, detail=f"No historical data found for {symbol}")
        
        # Convert DataFrame to dict
        data_dict = {
            "symbol": symbol,
            "period": period,
            "interval": interval,
            "data": []
        }
        
        for index, row in data.iterrows():
            data_dict["data"].append({
                "timestamp": index.isoformat(),
                "open": float(row["Open"]),
                "high": float(row["High"]),
                "low": float(row["Low"]),
                "close": float(row["Close"]),
                "volume": int(row["Volume"])
            })
        
        return {
            "success": True,
            "data": data_dict
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching historical data: {str(e)}")

@router.get("/intraday/{symbol}")
async def get_intraday(
    symbol: str,
    interval: str = Query("5m", description="Interval: 1m, 2m, 5m, 15m, 30m, 60m, 90m")
):
    """Obtém dados intraday para day trading"""
    try:
        data = await market_service.get_intraday_data(symbol, interval)
        
        if data is None or data.empty:
            raise HTTPException(status_code=404, detail=f"No intraday data found for {symbol}")
        
        # Convert DataFrame to dict
        data_dict = {
            "symbol": symbol,
            "interval": interval,
            "data": []
        }
        
        for index, row in data.iterrows():
            data_dict["data"].append({
                "timestamp": index.isoformat(),
                "open": float(row["Open"]),
                "high": float(row["High"]),
                "low": float(row["Low"]),
                "close": float(row["Close"]),
                "volume": int(row["Volume"])
            })
        
        return {
            "success": True,
            "data": data_dict
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching intraday data: {str(e)}")

@router.get("/overview")
async def get_market_overview():
    """Obtém visão geral do mercado B3"""
    try:
        overview = await market_service.get_market_overview()
        
        return {
            "success": True,
            "data": overview
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching market overview: {str(e)}")

@router.get("/search")
async def search_symbols(q: str = Query(..., description="Search query")):
    """Busca símbolos na B3"""
    try:
        results = await market_service.search_symbol(q)
        
        return {
            "success": True,
            "data": {
                "query": q,
                "results": results
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error searching symbols: {str(e)}")

@router.get("/info/{symbol}")
async def get_company_info(symbol: str):
    """Obtém informações da empresa"""
    try:
        info = await market_service.get_company_info(symbol)
        
        if not info:
            raise HTTPException(status_code=404, detail=f"Company info not found for {symbol}")
        
        return {
            "success": True,
            "data": info
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching company info: {str(e)}")

@router.get("/symbols")
async def get_b3_symbols():
    """Lista principais símbolos da B3"""
    try:
        symbols = market_service.get_b3_symbols()
        
        return {
            "success": True,
            "data": {
                "symbols": symbols,
                "count": len(symbols)
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching symbols: {str(e)}")

@router.get("/status")
async def get_market_status():
    """Verifica status do mercado"""
    try:
        is_open = await market_service.is_market_open()
        
        return {
            "success": True,
            "data": {
                "market_open": is_open,
                "exchange": "B3",
                "timezone": "America/Sao_Paulo"
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error checking market status: {str(e)}")

@router.get("/batch/{symbols}")
async def get_batch_quotes(symbols: str):
    """Obtém cotações em lote (símbolos separados por vírgula)"""
    try:
        symbol_list = [s.strip() for s in symbols.split(",")]
        
        if len(symbol_list) > 20:
            raise HTTPException(status_code=400, detail="Maximum 20 symbols allowed")
        
        results = {}
        
        # Get quotes in parallel
        tasks = []
        for symbol in symbol_list:
            tasks.append(market_service.get_realtime_data(symbol))
        
        quotes = await asyncio.gather(*tasks, return_exceptions=True)
        
        for symbol, quote in zip(symbol_list, quotes):
            if isinstance(quote, Exception):
                results[symbol] = {"error": str(quote)}
            else:
                results[symbol] = quote
        
        return {
            "success": True,
            "data": results
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching batch quotes: {str(e)}")
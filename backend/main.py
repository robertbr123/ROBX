"""
ROBX Trading Bot - Main Application
Sistema de trading para análise da B3 com interface web
"""

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import uvicorn
import asyncio
import json
from typing import List
import os
from dotenv import load_dotenv

from api.routes import market_data, analysis, recommendations
from services.market_service import MarketDataService
from services.analysis_service import TechnicalAnalysisService
from services.websocket_manager import WebSocketManager

# Load environment variables
load_dotenv()

# Create FastAPI app
app = FastAPI(
    title="ROBX Trading Bot API",
    description="Sistema de trading automatizado para análise da B3",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://127.0.0.1:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize services
market_service = MarketDataService()
analysis_service = TechnicalAnalysisService()
websocket_manager = WebSocketManager()

# Include routers
app.include_router(market_data.router, prefix="/api/v1/market", tags=["Market Data"])
app.include_router(analysis.router, prefix="/api/v1/analysis", tags=["Technical Analysis"])
app.include_router(recommendations.router, prefix="/api/v1/recommendations", tags=["Trading Signals"])

@app.get("/")
async def root():
    """API Root endpoint"""
    return {
        "message": "ROBX Trading Bot API",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs"
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": asyncio.get_event_loop().time()
    }

@app.websocket("/ws/market/{symbol}")
async def websocket_market_data(websocket: WebSocket, symbol: str):
    """WebSocket endpoint for real-time market data"""
    await websocket_manager.connect(websocket, symbol)
    try:
        while True:
            # Get real-time data for symbol
            data = await market_service.get_realtime_data(symbol)
            
            # Send data to connected clients
            await websocket_manager.send_to_symbol(symbol, {
                "type": "market_data",
                "symbol": symbol,
                "data": data,
                "timestamp": asyncio.get_event_loop().time()
            })
            
            # Wait before next update (adjust frequency as needed)
            await asyncio.sleep(1)
            
    except WebSocketDisconnect:
        websocket_manager.disconnect(websocket, symbol)
    except Exception as e:
        print(f"WebSocket error for {symbol}: {e}")
        websocket_manager.disconnect(websocket, symbol)

@app.websocket("/ws/signals")
async def websocket_trading_signals(websocket: WebSocket):
    """WebSocket endpoint for trading signals"""
    await websocket_manager.connect_signals(websocket)
    try:
        while True:
            # Check for new trading signals
            signals = await analysis_service.get_latest_signals()
            
            if signals:
                await websocket_manager.send_signals({
                    "type": "trading_signals",
                    "signals": signals,
                    "timestamp": asyncio.get_event_loop().time()
                })
            
            # Check every 30 seconds for new signals
            await asyncio.sleep(30)
            
    except WebSocketDisconnect:
        websocket_manager.disconnect_signals(websocket)
    except Exception as e:
        print(f"WebSocket signals error: {e}")
        websocket_manager.disconnect_signals(websocket)

# Background task for market monitoring
@app.on_event("startup")
async def startup_event():
    """Initialize background tasks on startup"""
    print("🚀 ROBX Trading Bot API starting up...")
    
    # Start market monitoring background task
    asyncio.create_task(market_monitoring_task())

async def market_monitoring_task():
    """Background task to monitor markets and generate signals"""
    print("📊 Starting market monitoring task...")
    
    # Popular B3 stocks to monitor
    symbols = ["PETR4.SA", "VALE3.SA", "ITUB4.SA", "BBDC4.SA", "ABEV3.SA", 
               "MGLU3.SA", "WEGE3.SA", "RENT3.SA", "LREN3.SA", "JBSS3.SA"]
    
    while True:
        try:
            for symbol in symbols:
                # Analyze each symbol
                analysis = await analysis_service.analyze_symbol(symbol)
                
                # Check for trading signals
                if analysis and analysis.get("signal") != "HOLD":
                    print(f"🔔 Signal for {symbol}: {analysis['signal']}")
                    
                    # Send signal via WebSocket
                    await websocket_manager.send_signals({
                        "type": "new_signal",
                        "symbol": symbol,
                        "signal": analysis["signal"],
                        "price": analysis.get("current_price"),
                        "indicators": analysis.get("indicators"),
                        "timestamp": asyncio.get_event_loop().time()
                    })
                
                # Small delay between symbols
                await asyncio.sleep(2)
            
            # Wait 5 minutes before next full scan
            await asyncio.sleep(300)
            
        except Exception as e:
            print(f"❌ Error in market monitoring: {e}")
            await asyncio.sleep(60)  # Wait 1 minute on error

if __name__ == "__main__":
    # Run the application
    uvicorn.run(
        "main:app",
        host=os.getenv("API_HOST", "0.0.0.0"),
        port=int(os.getenv("API_PORT", 8000)),
        reload=os.getenv("DEBUG", "False").lower() == "true",
        log_level="info"
    )
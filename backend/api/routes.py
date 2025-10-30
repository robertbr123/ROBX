"""
API Routes Aggregator
Centraliza todas as rotas da API
"""

import sys
import os

# Add backend directory to path
backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, backend_dir)

# Import routers with error handling
try:
    from api.market_data import router as market_data
    from api.analysis import router as analysis  
    from api.recommendations import router as recommendations
except ImportError as e:
    print(f"Erro ao importar routers: {e}")
    # Create dummy routers to prevent crashes
    from fastapi import APIRouter
    market_data = APIRouter()
    analysis = APIRouter()
    recommendations = APIRouter()
    
    @market_data.get("/status")
    async def market_status():
        return {"status": "Market data service not available"}
    
    @analysis.get("/status") 
    async def analysis_status():
        return {"status": "Analysis service not available"}
    
    @recommendations.get("/status")
    async def recommendations_status():
        return {"status": "Recommendations service not available"}

__all__ = ["market_data", "analysis", "recommendations"]
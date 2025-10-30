"""
API Routes Module Initializer
"""

from .market_data import router as market_router
from .analysis import router as analysis_router  
from .recommendations import router as recommendations_router

__all__ = ["market_router", "analysis_router", "recommendations_router"]
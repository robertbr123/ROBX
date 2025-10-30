"""
API Routes Module Initializer
"""

try:
    # Try relative imports first (when run as package)
    from .market_data import router as market_router
    from .analysis import router as analysis_router  
    from .recommendations import router as recommendations_router
except ImportError:
    # Fall back to absolute imports (when run directly)
    from api.market_data import router as market_router
    from api.analysis import router as analysis_router  
    from api.recommendations import router as recommendations_router

__all__ = ["market_router", "analysis_router", "recommendations_router"]
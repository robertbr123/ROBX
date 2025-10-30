#!/usr/bin/env python3
"""
Teste rápido dos imports do ROBX
"""

import sys
import os
from pathlib import Path

# Setup paths
current_dir = Path(__file__).parent.absolute()
project_root = current_dir.parent
sys.path.insert(0, str(current_dir))
sys.path.insert(0, str(project_root))

def test_imports():
    """Testar todos os imports do projeto"""
    print("🔧 Testando imports do ROBX...")
    
    errors = []
    
    # Test basic FastAPI
    try:
        from fastapi import FastAPI
        print("✅ FastAPI")
    except Exception as e:
        errors.append(f"FastAPI: {e}")
        print(f"❌ FastAPI: {e}")
    
    # Test uvicorn
    try:
        import uvicorn
        print("✅ uvicorn")
    except Exception as e:
        errors.append(f"uvicorn: {e}")
        print(f"❌ uvicorn: {e}")
    
    # Test API routes import method from routes.py
    try:
        from api.routes import market_data, analysis, recommendations
        print("✅ API routes (via routes.py)")
        print(f"   market_data type: {type(market_data)}")
        print(f"   analysis type: {type(analysis)}")
        print(f"   recommendations type: {type(recommendations)}")
    except Exception as e:
        errors.append(f"API routes: {e}")
        print(f"❌ API routes: {e}")
    
    # Test direct API imports
    try:
        from api.market_data import router as market_router
        from api.analysis import router as analysis_router
        from api.recommendations import router as recommendations_router
        print("✅ API routers (diretamente)")
    except Exception as e:
        errors.append(f"API routers diretos: {e}")
        print(f"❌ API routers diretos: {e}")
    
    # Test services
    try:
        from services.market_service import MarketDataService
        from services.analysis_service import TechnicalAnalysisService
        from services.websocket_manager import WebSocketManager
        print("✅ Services")
    except Exception as e:
        errors.append(f"Services: {e}")
        print(f"❌ Services: {e}")
    
    # Test main app
    try:
        from main import app
        print("✅ Main app")
        print(f"   App type: {type(app)}")
    except Exception as e:
        errors.append(f"Main app: {e}")
        print(f"❌ Main app: {e}")
    
    print("\n" + "="*50)
    if errors:
        print(f"❌ {len(errors)} erro(s) encontrado(s):")
        for error in errors:
            print(f"   - {error}")
        return False
    else:
        print("✅ Todos os imports funcionando!")
        return True

if __name__ == "__main__":
    success = test_imports()
    
    if success:
        print("\n🚀 Pronto para executar!")
        print("Execute: python3 debug.py")
    else:
        print("\n💡 Corrija os erros acima antes de executar")
    
    exit(0 if success else 1)
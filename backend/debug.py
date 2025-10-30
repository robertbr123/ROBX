#!/usr/bin/env python3
"""
ROBX Trading Bot - Debug Version
Versão simplificada para debugging de imports
"""

import sys
import os
from pathlib import Path

# Setup paths
current_dir = Path(__file__).parent.absolute()
project_root = current_dir.parent
sys.path.insert(0, str(current_dir))
sys.path.insert(0, str(project_root))

print(f"🔧 Debug Info:")
print(f"   Current dir: {current_dir}")
print(f"   Project root: {project_root}")
print(f"   Python path: {sys.path[:3]}")

def create_minimal_app():
    """Criar aplicação mínima para testar"""
    try:
        from fastapi import FastAPI, HTTPException
        from fastapi.middleware.cors import CORSMiddleware
        
        app = FastAPI(
            title="ROBX Trading Bot",
            description="Sistema de Trading para B3",
            version="1.0.0"
        )
        
        # CORS
        app.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )
        
        @app.get("/")
        async def root():
            return {"message": "ROBX Trading Bot está funcionando!"}
        
        @app.get("/health")
        async def health():
            return {"status": "healthy", "service": "robx-backend"}
        
        @app.get("/test")
        async def test():
            """Endpoint de teste para verificar funcionalidades"""
            try:
                # Testar imports
                import pandas as pd
                import requests
                
                return {
                    "status": "ok",
                    "imports": {
                        "pandas": str(pd.__version__),
                        "requests": str(requests.__version__)
                    },
                    "message": "Todos os imports básicos funcionando"
                }
            except Exception as e:
                return {
                    "status": "error",
                    "error": str(e),
                    "message": "Alguns imports falharam"
                }
        
        # Tentar importar e adicionar rotas da API
        try:
            # Market data routes
            try:
                from api.market_data import router as market_router
                app.include_router(market_router, prefix="/api/market", tags=["market"])
                print("✅ Market data routes carregadas")
            except Exception as e:
                print(f"⚠️  Market data routes falharam: {e}")
            
            # Analysis routes  
            try:
                from api.analysis import router as analysis_router
                app.include_router(analysis_router, prefix="/api/analysis", tags=["analysis"])
                print("✅ Analysis routes carregadas")
            except Exception as e:
                print(f"⚠️  Analysis routes falharam: {e}")
            
            # Recommendations routes
            try:
                from api.recommendations import router as recommendations_router
                app.include_router(recommendations_router, prefix="/api/recommendations", tags=["recommendations"])
                print("✅ Recommendations routes carregadas")
            except Exception as e:
                print(f"⚠️  Recommendations routes falharam: {e}")
                
        except Exception as e:
            print(f"⚠️  Erro ao carregar rotas da API: {e}")
        
        return app
        
    except ImportError as e:
        print(f"❌ Erro crítico ao importar FastAPI: {e}")
        raise

if __name__ == "__main__":
    try:
        import uvicorn
        
        print("🚀 Criando aplicação...")
        app = create_minimal_app()
        
        print("🌐 Iniciando servidor...")
        print("📊 Acesse: http://localhost:8000")
        print("📚 Docs: http://localhost:8000/docs") 
        print("🧪 Teste: http://localhost:8000/test")
        print("⏹️  Ctrl+C para parar\n")
        
        uvicorn.run(
            app,
            host="0.0.0.0",
            port=8000,
            reload=False
        )
        
    except ImportError as e:
        print(f"❌ uvicorn não encontrado: {e}")
        print("💡 Instale com: pip install uvicorn")
    except Exception as e:
        print(f"❌ Erro: {e}")
#!/usr/bin/env python3
"""
ROBX Trading Bot - Run Script
Script de inicialização que resolve problemas de imports
"""

import sys
import os

# Add the backend directory to Python path
backend_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.dirname(backend_dir)
sys.path.insert(0, backend_dir)
sys.path.insert(0, project_root)

if __name__ == "__main__":
    # Set PYTHONPATH environment variable
    os.environ['PYTHONPATH'] = f"{backend_dir}:{project_root}"
    
    # Now run the main application
    from main import app
    import uvicorn
    
    print("🚀 Iniciando ROBX Trading Bot Backend...")
    print("📊 Acesse: http://localhost:8000")
    print("📚 Documentação API: http://localhost:8000/docs")
    
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
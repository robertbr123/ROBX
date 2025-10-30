#!/usr/bin/env python3
"""
ROBX Trading Bot - Executar diretamente
Script simplificado para executar o backend
"""

import sys
import os
from pathlib import Path

# Configurar paths
script_dir = Path(__file__).parent
backend_dir = script_dir
project_root = script_dir.parent

# Adicionar ao Python path
sys.path.insert(0, str(backend_dir))
sys.path.insert(0, str(project_root))

# Configurar variáveis de ambiente
os.environ['PYTHONPATH'] = f"{backend_dir}:{project_root}"

def main():
    """Função principal para executar o servidor"""
    try:
        print("🚀 Iniciando ROBX Trading Bot...")
        print(f"📁 Diretório: {backend_dir}")
        print(f"🐍 Python: {sys.version}")
        
        # Verificar dependências básicas
        try:
            import fastapi
            import uvicorn
            print("✅ FastAPI e Uvicorn encontrados")
        except ImportError as e:
            print(f"❌ Erro ao importar dependências: {e}")
            print("💡 Execute: pip install fastapi uvicorn")
            return 1
        
        # Carregar variáveis de ambiente
        try:
            from dotenv import load_dotenv
            env_path = project_root / '.env'
            load_dotenv(dotenv_path=env_path)
            print("✅ Variáveis de ambiente carregadas")
        except ImportError:
            print("⚠️  python-dotenv não encontrado, continuando sem .env")
        except Exception as e:
            print(f"⚠️  Erro ao carregar .env: {e}")
        
        # Importar aplicação
        try:
            from main import app
            print("✅ Aplicação carregada com sucesso")
        except ImportError as e:
            print(f"❌ Erro ao importar aplicação: {e}")
            print("💡 Verifique se todos os arquivos estão presentes")
            return 1
        
        # Executar servidor
        print("\n🌐 Iniciando servidor...")
        print("📊 Interface: http://localhost:8000")
        print("📚 Docs: http://localhost:8000/docs")
        print("🔗 WebSocket: ws://localhost:8000/ws")
        print("\n⏹️  Pressione Ctrl+C para parar\n")
        
        uvicorn.run(
            app,
            host="0.0.0.0",
            port=8000,
            reload=False,  # Desabilitar reload para evitar problemas de import
            log_level="info"
        )
        
    except KeyboardInterrupt:
        print("\n🛑 Servidor interrompido pelo usuário")
        return 0
    except Exception as e:
        print(f"❌ Erro fatal: {e}")
        return 1

if __name__ == "__main__":
    exit(main())
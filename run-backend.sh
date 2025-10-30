#!/bin/bash

echo "🔧 Iniciando Backend ROBX..."
echo

# Verificar se está no diretório correto
if [ ! -f "backend/main.py" ]; then
    echo "❌ Arquivo main.py não encontrado. Execute a partir do diretório raiz do projeto."
    exit 1
fi

# Verificar se o ambiente virtual existe
if [ ! -d "venv" ]; then
    echo "❌ Ambiente virtual não encontrado. Execute ./setup.sh primeiro."
    exit 1
fi

# Ativar ambiente virtual
echo "🔧 Ativando ambiente virtual..."
source venv/bin/activate

# Verificar se as dependências estão instaladas
python3 -c "import fastapi" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "❌ FastAPI não encontrado. Execute ./setup.sh primeiro."
    exit 1
fi

echo "✅ Dependências verificadas"
echo

# Navegar para o diretório backend
cd backend

echo "🚀 Iniciando servidor FastAPI na porta 8000..."
echo "📊 API Docs: http://localhost:8000/docs"
echo "🔗 WebSocket: ws://localhost:8000/ws"
echo "🔄 Health Check: http://localhost:8000/health"
echo
echo "Pressione Ctrl+C para parar o servidor"
echo

# Executar o servidor
python3 main.py
#!/bin/bash

echo "🔧 Iniciando Backend ROBX..."
echo

# Verificar se está no diretório correto
if [ ! -f "backend/main.py" ]; then
    echo "❌ Arquivo main.py não encontrado. Execute a partir do diretório raiz do projeto."
    exit 1
fi

# Ativar ambiente virtual se existir
if [ -f "venv/bin/activate" ]; then
    echo "🔧 Ativando ambiente virtual..."
    source venv/bin/activate
else
    echo "⚠️  Ambiente virtual não encontrado, usando Python global"
fi

# Verificar se as dependências estão instaladas
python3 -c "import fastapi" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "❌ FastAPI não encontrado. Execute ./setup.sh primeiro."
    exit 1
fi

echo "✅ Dependências verificadas"
echo

# Definir PYTHONPATH para resolver imports
export PYTHONPATH="${PWD}/backend:${PWD}:${PYTHONPATH}"

echo "🚀 Iniciando servidor FastAPI na porta 8000..."
echo "📊 API Docs: http://localhost:8000/docs"
echo "🔗 WebSocket: ws://localhost:8000/ws"
echo "🔄 Health Check: http://localhost:8000/health"
echo
echo "Pressione Ctrl+C para parar o servidor"
echo

# Tentar diferentes métodos de execução
cd backend

echo "🔧 Testando imports primeiro..."
if python3 test_imports.py; then
    echo "✅ Imports OK, iniciando servidor..."
else
    echo "⚠️  Alguns imports com problemas, mas tentando mesmo assim..."
fi

echo "🔧 Tentando método 1: start.py..."
if python3 start.py; then
    echo "✅ Servidor executado com sucesso"
else
    echo "⚠️  Método 1 falhou, tentando método 2: debug.py..."
    if python3 debug.py; then
        echo "✅ Servidor executado com sucesso"
    else
        echo "⚠️  Método 2 falhou, tentando método 3: main.py direto..."
        python3 -c "
import sys
import os
sys.path.insert(0, '.')
sys.path.insert(0, '..')
os.environ['PYTHONPATH'] = '.:..:'
try:
    from main import app
    import uvicorn
    print('✅ Imports funcionando, iniciando servidor...')
    uvicorn.run(app, host='0.0.0.0', port=8000)
except Exception as e:
    print(f'❌ Erro: {e}')
    print('💡 Execute ./troubleshoot.sh para diagnóstico')
"
    fi
fi
#!/bin/bash

echo "🎨 Iniciando Frontend ROBX..."
echo

# Verificar se está no diretório correto
if [ ! -f "frontend/package.json" ]; then
    echo "❌ package.json não encontrado. Execute a partir do diretório raiz do projeto."
    exit 1
fi

# Verificar se as dependências estão instaladas
if [ ! -d "frontend/node_modules" ]; then
    echo "❌ Dependências não instaladas. Execute ./setup.sh primeiro."
    exit 1
fi

echo "✅ Dependências verificadas"
echo

# Navegar para o diretório frontend
cd frontend

echo "🚀 Iniciando servidor React na porta 3000..."
echo "🌐 Interface: http://localhost:3000"
echo "🔗 Conecta ao backend: http://localhost:8000"
echo
echo "⏳ PRIMEIRA EXECUÇÃO PODE DEMORAR 2-5 MINUTOS"
echo "📊 Status: 'Starting the development server...' é NORMAL"
echo "💡 Para monitorar: ../monitor-frontend.sh (em outro terminal)"
echo
echo "Pressione Ctrl+C para parar o servidor"
echo

# Definir variáveis de ambiente para desenvolvimento
export REACT_APP_API_URL=http://localhost:8000
export REACT_APP_WS_URL=ws://localhost:8000
export DANGEROUSLY_DISABLE_HOST_CHECK=true
export WDS_SOCKET_HOST=localhost
export WDS_SOCKET_PORT=3000
export SKIP_PREFLIGHT_CHECK=true

echo "🔧 Tentando múltiplos métodos de inicialização..."

# Método 1: CRACO (preferido)
echo "📦 Método 1: Usando CRACO..."
if npm run start 2>/dev/null; then
    echo "✅ Frontend iniciado com CRACO"
elif npm run start:legacy 2>/dev/null; then
    echo "✅ Frontend iniciado com método legacy"
else
    echo "⚠️  CRACO falhou, tentando react-scripts direto..."
    
    # Método 2: React Scripts com variáveis de ambiente
    DANGEROUSLY_DISABLE_HOST_CHECK=true \
    WDS_SOCKET_HOST=localhost \
    WDS_SOCKET_PORT=3000 \
    npm run start:safe
fi
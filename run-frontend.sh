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

# Suprimir warnings de depreciação do Node.js/Webpack
export NODE_OPTIONS="--no-deprecation"
export NODE_NO_WARNINGS=1
export GENERATE_SOURCEMAP=false

echo "🔧 Verificando configuração do projeto..."

# Verificar se CRACO está instalado
if [ -f "node_modules/.bin/craco" ] || npm list @craco/craco > /dev/null 2>&1; then
    echo "✅ CRACO encontrado"
    USE_CRACO=true
else
    echo "⚠️  CRACO não encontrado, usando react-scripts"
    USE_CRACO=false
fi

echo "🔧 Tentando múltiplos métodos de inicialização..."

# Método 1: CRACO (se disponível)
if [ "$USE_CRACO" = true ]; then
    echo "📦 Método 1: Usando CRACO..."
    if NODE_OPTIONS="--no-deprecation" NODE_NO_WARNINGS=1 timeout 10s npm run start --silent 2>/dev/null; then
        echo "✅ Frontend iniciado com CRACO"
        exit 0
    else
        echo "⚠️  CRACO falhou ou timeout, tentando react-scripts..."
    fi
fi

# Método 2: React Scripts Legacy
echo "📦 Método 2: React Scripts com configurações legacy..."
if NODE_OPTIONS="--no-deprecation" NODE_NO_WARNINGS=1 npm run start:legacy --silent 2>/dev/null; then
    echo "✅ Frontend iniciado com método legacy"
elif NODE_OPTIONS="--no-deprecation" NODE_NO_WARNINGS=1 npm run start:safe --silent 2>/dev/null; then
    echo "✅ Frontend iniciado com react-scripts seguro"
else
    echo "⚠️  Métodos configurados falharam, tentando react-scripts direto..."
    
    # Método 3: React Scripts puro com variáveis de ambiente
    echo "📦 Método 3: React Scripts direto..."
    NODE_OPTIONS="--no-deprecation" \
    NODE_NO_WARNINGS=1 \
    DANGEROUSLY_DISABLE_HOST_CHECK=true \
    WDS_SOCKET_HOST=localhost \
    WDS_SOCKET_PORT=3000 \
    SKIP_PREFLIGHT_CHECK=true \
    npx react-scripts start
fi
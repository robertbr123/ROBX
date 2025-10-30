#!/bin/bash

echo "🎨 Frontend ROBX - Sem Warnings de Depreciação"
echo "=============================================="
echo

cd frontend

# Configurar variáveis para suprimir warnings
export NODE_OPTIONS="--no-deprecation"
export NODE_NO_WARNINGS=1
export GENERATE_SOURCEMAP=false

# Configurações do React
export REACT_APP_API_URL=http://localhost:8000
export REACT_APP_WS_URL=ws://localhost:8000
export DANGEROUSLY_DISABLE_HOST_CHECK=true
export WDS_SOCKET_HOST=localhost
export WDS_SOCKET_PORT=3000
export SKIP_PREFLIGHT_CHECK=true

echo "🔧 Iniciando frontend sem warnings de depreciação..."
echo "⚡ Variáveis configuradas:"
echo "   NODE_OPTIONS=--no-deprecation"
echo "   NODE_NO_WARNINGS=1"
echo

echo "🚀 Executando npm start..."
npm start
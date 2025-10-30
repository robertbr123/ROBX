#!/bin/bash

echo "🎨 Frontend ROBX - Sem CRACO (React Scripts Puro)"
echo "================================================="
echo

cd frontend

# Configurar variáveis de ambiente
export REACT_APP_API_URL=http://localhost:8000
export REACT_APP_WS_URL=ws://localhost:8000
export DANGEROUSLY_DISABLE_HOST_CHECK=true
export WDS_SOCKET_HOST=localhost
export WDS_SOCKET_PORT=3000
export SKIP_PREFLIGHT_CHECK=true
export NODE_OPTIONS="--no-deprecation"
export NODE_NO_WARNINGS=1
export GENERATE_SOURCEMAP=false

echo "⚡ Usando React Scripts diretamente (sem CRACO)"
echo "🔧 Variáveis configuradas:"
echo "   DANGEROUSLY_DISABLE_HOST_CHECK=true"
echo "   NODE_OPTIONS=--no-deprecation"
echo "   SKIP_PREFLIGHT_CHECK=true"
echo

echo "🚀 Iniciando servidor..."

# Usar react-scripts diretamente
DANGEROUSLY_DISABLE_HOST_CHECK=true \
NODE_OPTIONS="--no-deprecation" \
NODE_NO_WARNINGS=1 \
WDS_SOCKET_HOST=localhost \
WDS_SOCKET_PORT=3000 \
SKIP_PREFLIGHT_CHECK=true \
GENERATE_SOURCEMAP=false \
npx react-scripts start
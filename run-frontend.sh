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
echo "Pressione Ctrl+C para parar o servidor"
echo

# Definir variáveis de ambiente para desenvolvimento
export REACT_APP_API_URL=http://localhost:8000
export REACT_APP_WS_URL=ws://localhost:8000

# Executar o servidor de desenvolvimento
npm start
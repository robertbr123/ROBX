#!/bin/bash

echo "🚀 Iniciando ROBX Trading Bot..."
echo

# Verificar se Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 não encontrado. Por favor, instale Python 3.8+"
    exit 1
fi

# Verificar se Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js não encontrado. Por favor, instale Node.js 16+"
    exit 1
fi

echo "✅ Python e Node.js encontrados"

# Configurar ambiente Python
echo
echo "📦 Configurando ambiente Python..."
cd backend
pip3 install -r ../requirements.txt
if [ $? -ne 0 ]; then
    echo "❌ Erro ao instalar dependências Python"
    exit 1
fi

echo "✅ Dependências Python instaladas"

# Configurar ambiente Node.js
echo
echo "📦 Configurando ambiente React..."
cd ../frontend
npm install
if [ $? -ne 0 ]; then
    echo "❌ Erro ao instalar dependências Node.js"
    exit 1
fi

echo "✅ Dependências React instaladas"

# Criar arquivo .env se não existir
cd ..
if [ ! -f ".env" ]; then
    echo "📝 Criando arquivo .env..."
    cp .env.example .env
fi

echo
echo "🎉 Setup concluído com sucesso!"
echo
echo "Para executar o ROBX Trading Bot:"
echo "1. Backend: ./run-backend.sh"
echo "2. Frontend: ./run-frontend.sh"
echo
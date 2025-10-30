#!/bin/bash

echo "🔧 Corrigindo Frontend ROBX..."
echo

cd frontend

echo "🧹 Limpando instalação anterior..."
rm -rf node_modules package-lock.json

echo "📦 Instalando CRACO para resolver problemas de configuração..."
npm install @craco/craco --save-dev

echo "📦 Reinstalando dependências..."
if npm install; then
    echo "✅ Dependências instaladas com sucesso"
else
    echo "⚠️  Instalação padrão falhou, tentando com --legacy-peer-deps..."
    npm install --legacy-peer-deps
fi

echo "🔍 Verificando estrutura..."
if [ -f "craco.config.js" ]; then
    echo "✅ Configuração CRACO encontrada"
else
    echo "❌ Configuração CRACO ausente"
fi

if [ -f ".env" ]; then
    echo "✅ Arquivo .env encontrado"
else
    echo "❌ Arquivo .env ausente"
fi

echo
echo "🎉 Frontend corrigido!"
echo "💡 Para testar: ./run-frontend.sh"
echo
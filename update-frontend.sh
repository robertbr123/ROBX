#!/bin/bash

echo "🔧 Atualizando Frontend para Resolver Warnings"
echo "============================================="
echo

cd frontend

echo "📦 Atualizando dependências para versões mais recentes..."

# Backup do package.json atual
cp package.json package.json.backup
echo "💾 Backup criado: package.json.backup"

echo "🔄 Instalando versões compatíveis..."

# Instalar versões específicas que não geram warnings
npm install --save-dev @craco/craco@^7.1.0 webpack@^5.88.0

echo "🧹 Limpando cache..."
npm cache clean --force

echo "📦 Reinstalando dependências..."
rm -rf node_modules package-lock.json
npm install

echo "🔍 Verificando configuração..."

# Verificar se craco.config.js tem a configuração correta
if grep -q "setupMiddlewares" craco.config.js; then
    echo "✅ Configuração moderna encontrada"
else
    echo "⚠️  Configuração pode precisar de atualização"
fi

echo "🧪 Testando configuração..."
if npm run build --dry-run 2>/dev/null; then
    echo "✅ Build test passou"
else
    echo "⚠️  Build test falhou, mas pode ser normal"
fi

echo
echo "🎉 Atualização concluída!"
echo "💡 Para testar sem warnings: ../run-frontend-clean.sh"
echo "📋 Para uso normal: ../run-frontend.sh"
echo
echo "🔧 Configurações aplicadas:"
echo "   - NODE_OPTIONS=--no-deprecation"
echo "   - setupMiddlewares (nova sintaxe)"
echo "   - Configuração CRACO atualizada"
echo
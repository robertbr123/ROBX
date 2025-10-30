#!/bin/bash

echo "🔧 Reinstalando CRACO para Frontend ROBX"
echo "======================================="
echo

cd frontend

echo "🔍 Verificando problema atual..."

# Verificar se CRACO está instalado
if npm list @craco/craco > /dev/null 2>&1; then
    echo "📦 CRACO está listado no package.json"
else
    echo "❌ CRACO não está instalado"
fi

# Verificar se o executável existe
if [ -f "node_modules/.bin/craco" ]; then
    echo "✅ Executável CRACO encontrado"
else
    echo "❌ Executável CRACO não encontrado"
fi

# Verificar configuração
if [ -f "craco.config.js" ]; then
    echo "✅ Arquivo de configuração existe"
else
    echo "❌ Arquivo de configuração ausente"
fi

echo
echo "🔧 Corrigindo instalação..."

# Remover CRACO atual
echo "🗑️  Removendo CRACO atual..."
npm uninstall @craco/craco 2>/dev/null || true

# Limpar cache
echo "🧹 Limpando cache..."
npm cache clean --force

# Reinstalar CRACO
echo "📦 Reinstalando CRACO..."
if npm install @craco/craco@^7.1.0 --save-dev; then
    echo "✅ CRACO instalado com sucesso"
else
    echo "❌ Falha ao instalar CRACO, tentando versão alternativa..."
    npm install @craco/craco@latest --save-dev
fi

# Verificar instalação
echo
echo "🔍 Verificando instalação..."

if [ -f "node_modules/.bin/craco" ]; then
    echo "✅ Executável CRACO disponível"
    
    # Testar CRACO
    echo "🧪 Testando CRACO..."
    if npx craco --version > /dev/null 2>&1; then
        echo "✅ CRACO funcional"
    else
        echo "⚠️  CRACO instalado mas com problemas"
    fi
else
    echo "❌ Executável CRACO ainda não disponível"
    
    # Tentar instalação global como último recurso
    echo "🔄 Tentando instalação global..."
    npm install -g @craco/craco 2>/dev/null || echo "Instalação global falhou"
fi

echo
echo "🎯 Resultado da correção:"
echo "========================"

if [ -f "node_modules/.bin/craco" ] && npx craco --version > /dev/null 2>&1; then
    echo "✅ CRACO corrigido com sucesso!"
    echo "💡 Use: npm run start"
else
    echo "⚠️  CRACO ainda com problemas"
    echo "💡 Use métodos alternativos:"
    echo "   npm run start:safe    # React Scripts puro"
    echo "   npm run start:direct  # npx react-scripts"
    echo "   npm run start:force   # Com SKIP_PREFLIGHT_CHECK"
fi

echo
echo "📋 Scripts disponíveis:"
npm run | grep start
#!/bin/bash

echo "🔍 Diagnóstico do Frontend ROBX"
echo "==============================="
echo

cd frontend

echo "📋 Verificando configuração atual..."

# Verificar package.json
if [ -f "package.json" ]; then
    echo "✅ package.json existe"
    
    # Verificar se CRACO está instalado
    if grep -q "@craco/craco" package.json; then
        echo "✅ CRACO encontrado no package.json"
    else
        echo "❌ CRACO não encontrado - isso pode causar o erro allowedHosts"
    fi
    
    # Verificar scripts
    if grep -q "craco start" package.json; then
        echo "✅ Script start configurado para CRACO"
    else
        echo "❌ Script start não usa CRACO"
    fi
else
    echo "❌ package.json não encontrado"
fi

# Verificar craco.config.js
if [ -f "craco.config.js" ]; then
    echo "✅ craco.config.js existe"
    
    if grep -q "allowedHosts: 'all'" craco.config.js; then
        echo "✅ Configuração allowedHosts corrigida"
    else
        echo "❌ Configuração allowedHosts pode estar incorreta"
    fi
else
    echo "❌ craco.config.js ausente - CRACO não funcionará"
fi

# Verificar .env
if [ -f ".env" ]; then
    echo "✅ .env existe"
    
    if grep -q "DANGEROUSLY_DISABLE_HOST_CHECK=true" .env; then
        echo "✅ HOST_CHECK desabilitado"
    else
        echo "❌ HOST_CHECK não desabilitado"
    fi
else
    echo "❌ .env ausente"
fi

# Verificar node_modules
if [ -d "node_modules" ]; then
    echo "✅ node_modules existe"
    
    if [ -d "node_modules/@craco" ]; then
        echo "✅ CRACO instalado"
    else
        echo "❌ CRACO não instalado"
    fi
    
    if [ -d "node_modules/react-scripts" ]; then
        echo "✅ react-scripts instalado"
    else
        echo "❌ react-scripts não instalado"
    fi
else
    echo "❌ node_modules não existe"
fi

echo
echo "🔧 Soluções para erro 'allowedHosts should be a non-empty string':"
echo "================================================================="
echo

if [ ! -f "craco.config.js" ] || ! grep -q "allowedHosts: 'all'" craco.config.js; then
    echo "1. ❌ Executar correção automática:"
    echo "   ../fix-frontend.sh"
    echo
fi

if [ ! -d "node_modules/@craco" ]; then
    echo "2. ❌ Instalar CRACO manualmente:"
    echo "   npm install @craco/craco --save-dev"
    echo
fi

if ! grep -q "craco start" package.json 2>/dev/null; then
    echo "3. ❌ Atualizar script start no package.json:"
    echo '   "start": "craco start",'
    echo
fi

echo "4. ✅ Métodos alternativos (se CRACO não funcionar):"
echo "   npm run start:legacy  # Usa método legacy"
echo "   npm run start:safe    # Usa react-scripts puro"
echo

echo "5. 🔄 Reinstalação completa (último recurso):"
echo "   rm -rf node_modules package-lock.json"
echo "   npm install"
echo

echo "💡 Após corrigir, teste com: ../run-frontend.sh"
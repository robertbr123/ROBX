#!/bin/bash

echo "🔍 ROBX Trading Bot - Diagnóstico de Problemas"
echo "=============================================="
echo

# Função para verificar comando
check_command() {
    if command -v $1 &> /dev/null; then
        echo "✅ $1 está instalado: $($1 --version 2>/dev/null | head -1)"
    else
        echo "❌ $1 NÃO está instalado"
        return 1
    fi
}

# Função para verificar arquivo
check_file() {
    if [ -f "$1" ]; then
        echo "✅ $1 existe"
    else
        echo "❌ $1 NÃO existe"
        return 1
    fi
}

# Função para verificar diretório
check_dir() {
    if [ -d "$1" ]; then
        echo "✅ $1 existe"
    else
        echo "❌ $1 NÃO existe"
        return 1
    fi
}

echo "🔧 Verificando dependências do sistema..."
echo "----------------------------------------"
check_command python3
check_command pip3
check_command node
check_command npm
check_command git

echo
echo "📁 Verificando estrutura do projeto..."
echo "------------------------------------"
check_file "requirements.txt"
check_file ".env.example"
check_file "backend/main.py"
check_file "frontend/package.json"
check_dir "backend"
check_dir "frontend"

echo
echo "🐍 Verificando ambiente Python..."
echo "--------------------------------"
if [ -d "venv" ]; then
    echo "✅ Ambiente virtual existe"
    source venv/bin/activate
    
    # Verificar se consegue importar módulos essenciais
    python3 -c "import fastapi" 2>/dev/null && echo "✅ FastAPI instalado" || echo "❌ FastAPI não encontrado"
    python3 -c "import pandas" 2>/dev/null && echo "✅ Pandas instalado" || echo "❌ Pandas não encontrado"
    python3 -c "import yfinance" 2>/dev/null && echo "✅ yfinance instalado" || echo "❌ yfinance não encontrado"
    python3 -c "import talib" 2>/dev/null && echo "✅ TA-Lib instalado" || echo "⚠️  TA-Lib não encontrado (usará implementações próprias)"
    
    deactivate
else
    echo "❌ Ambiente virtual não existe - execute ./setup.sh"
fi

echo
echo "📦 Verificando ambiente Node.js..."
echo "---------------------------------"
if [ -d "frontend/node_modules" ]; then
    echo "✅ Dependências Node.js instaladas"
    
    cd frontend
    if npm list react &>/dev/null; then
        echo "✅ React instalado"
    else
        echo "❌ React não encontrado"
    fi
    
    if npm list @mui/material &>/dev/null; then
        echo "✅ Material-UI instalado"
    else
        echo "❌ Material-UI não encontrado"
    fi
    cd ..
else
    echo "❌ Dependências Node.js não instaladas - execute ./setup.sh"
fi

echo
echo "🌐 Verificando conectividade..."
echo "-----------------------------"
if ping -c 1 google.com &>/dev/null; then
    echo "✅ Conexão com internet OK"
else
    echo "❌ Sem conexão com internet"
fi

if curl -s --connect-timeout 5 https://pypi.org &>/dev/null; then
    echo "✅ PyPI acessível"
else
    echo "❌ PyPI não acessível"
fi

if curl -s --connect-timeout 5 https://registry.npmjs.org &>/dev/null; then
    echo "✅ NPM Registry acessível"
else
    echo "❌ NPM Registry não acessível"
fi

echo
echo "🔍 Verificando portas..."
echo "----------------------"
if lsof -i :8000 &>/dev/null; then
    echo "⚠️  Porta 8000 em uso (backend)"
    lsof -i :8000
else
    echo "✅ Porta 8000 disponível"
fi

if lsof -i :3000 &>/dev/null; then
    echo "⚠️  Porta 3000 em uso (frontend)"
    lsof -i :3000
else
    echo "✅ Porta 3000 disponível"
fi

echo
echo "💾 Informações do sistema..."
echo "-------------------------"
echo "SO: $(uname -a)"
echo "Usuário: $(whoami)"
echo "Diretório atual: $(pwd)"
echo "Espaço em disco:"
df -h . | tail -1

echo
echo "🔧 Soluções para problemas comuns:"
echo "================================="
echo

echo "❌ Problema: 'pip command not found'"
echo "💡 Solução: sudo apt install python3-pip (Ubuntu/Debian)"
echo

echo "❌ Problema: 'node command not found'"
echo "💡 Solução: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt install nodejs"
echo

echo "❌ Problema: 'TA-Lib installation failed'"
echo "💡 Solução: sudo apt install libta-lib-dev (Ubuntu/Debian)"
echo "💡 Alternativa: Use requirements-simple.txt (sem TA-Lib)"
echo

echo "❌ Problema: 'Permission denied'"
echo "💡 Solução: chmod +x *.sh"
echo

echo "❌ Problema: 'Port already in use'"
echo "💡 Solução: sudo lsof -i :8000 && sudo kill -9 <PID>"
echo

echo "❌ Problema: 'Module not found'"
echo "💡 Solução: source venv/bin/activate && pip install -r requirements.txt"
echo

echo "📞 Se o problema persistir:"
echo "- Verifique os logs em detalhes"
echo "- Execute ./setup.sh novamente"
echo "- Use requirements-simple.txt para instalação básica"
echo
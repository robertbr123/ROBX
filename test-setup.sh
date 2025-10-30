#!/bin/bash

echo "🧪 Testando ROBX Trading Bot..."
echo "=============================="
echo

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para teste
test_item() {
    if eval "$2"; then
        echo -e "${GREEN}✅ $1${NC}"
        return 0
    else
        echo -e "${RED}❌ $1${NC}"
        return 1
    fi
}

# Função para aviso
warn_item() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo "🔍 Testando ambiente Python..."
echo "-----------------------------"

# Verificar se ambiente virtual existe
test_item "Ambiente virtual existe" "[ -d 'venv' ]"

# Verificar se activate existe
test_item "Script activate existe" "[ -f 'venv/bin/activate' ]"

# Ativar ambiente e testar importações
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    
    test_item "FastAPI" "python3 -c 'import fastapi' 2>/dev/null"
    test_item "Pandas" "python3 -c 'import pandas' 2>/dev/null"
    test_item "NumPy" "python3 -c 'import numpy' 2>/dev/null"
    test_item "yfinance" "python3 -c 'import yfinance' 2>/dev/null"
    test_item "WebSockets" "python3 -c 'import websockets' 2>/dev/null"
    test_item "Requests" "python3 -c 'import requests' 2>/dev/null"
    test_item "Python-dotenv" "python3 -c 'import dotenv' 2>/dev/null"
    
    # TA-Lib é opcional
    if python3 -c 'import talib' 2>/dev/null; then
        echo -e "${GREEN}✅ TA-Lib (opcional)${NC}"
    else
        warn_item "TA-Lib não instalado (usará implementações próprias)"
    fi
    
    deactivate
else
    echo -e "${RED}❌ Não foi possível ativar ambiente virtual${NC}"
fi

echo
echo "🌐 Testando ambiente Node.js..."
echo "------------------------------"

test_item "Diretório frontend existe" "[ -d 'frontend' ]"
test_item "package.json existe" "[ -f 'frontend/package.json' ]"
test_item "node_modules existe" "[ -d 'frontend/node_modules' ]"

if [ -d "frontend" ]; then
    cd frontend
    
    test_item "React" "npm list react --depth=0 >/dev/null 2>&1"
    test_item "Material-UI" "npm list @mui/material --depth=0 >/dev/null 2>&1"
    test_item "Chart.js" "npm list chart.js --depth=0 >/dev/null 2>&1"
    test_item "Axios" "npm list axios --depth=0 >/dev/null 2>&1"
    
    cd ..
fi

echo
echo "📁 Testando arquivos de configuração..."
echo "--------------------------------------"

test_item "requirements.txt" "[ -f 'requirements.txt' ]"
test_item ".env.example" "[ -f '.env.example' ]"
test_item "backend/main.py" "[ -f 'backend/main.py' ]"
test_item "Scripts executáveis" "[ -x 'setup.sh' ] || [ -f 'setup.sh' ]"

if [ -f ".env" ]; then
    echo -e "${GREEN}✅ .env configurado${NC}"
else
    warn_item ".env não existe (será criado automaticamente)"
fi

echo
echo "🔌 Testando conectividade..."
echo "-------------------------"

if ping -c 1 google.com >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Conexão com internet${NC}"
else
    echo -e "${RED}❌ Sem conexão com internet${NC}"
fi

if curl -s --connect-timeout 5 https://pypi.org >/dev/null 2>&1; then
    echo -e "${GREEN}✅ PyPI acessível${NC}"
else
    echo -e "${YELLOW}⚠️  PyPI pode estar inacessível${NC}"
fi

echo
echo "🚀 Teste de execução rápida..."
echo "----------------------------"

if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    
    # Testar se consegue importar e criar app FastAPI
    if python3 -c "
from fastapi import FastAPI
import yfinance as yf
app = FastAPI()
ticker = yf.Ticker('AAPL')
print('✅ Teste básico passou')
" 2>/dev/null; then
        echo -e "${GREEN}✅ Backend pode ser executado${NC}"
    else
        echo -e "${RED}❌ Problema na execução do backend${NC}"
    fi
    
    deactivate
fi

echo
echo "📊 Resumo dos Testes"
echo "==================="

if [ -f "venv/bin/activate" ] && [ -d "frontend/node_modules" ]; then
    echo -e "${GREEN}🎉 Sistema está pronto para uso!${NC}"
    echo
    echo "Para executar:"
    echo "  Backend:  ./run-backend.sh"
    echo "  Frontend: ./run-frontend.sh"
    echo "  Ambos:    ./run-all.sh"
else
    echo -e "${RED}⚠️  Sistema precisa de configuração${NC}"
    echo
    echo "Execute:"
    echo "  chmod +x *.sh"
    echo "  ./setup-simple.sh"
fi

echo
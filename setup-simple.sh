#!/bin/bash

echo "🚀 ROBX Trading Bot - Setup Simplificado"
echo "========================================"
echo

# Função para verificar e exibir status
check_status() {
    if [ $? -eq 0 ]; then
        echo "✅ $1"
    else
        echo "❌ $1"
        exit 1
    fi
}

# Verificações básicas
echo "🔍 Verificando pré-requisitos..."

python3 --version
check_status "Python3 disponível"

node --version
check_status "Node.js disponível"

npm --version
check_status "npm disponível"

echo
echo "📁 Verificando estrutura do projeto..."

if [ ! -f "requirements.txt" ]; then
    echo "❌ requirements.txt não encontrado"
    exit 1
fi

if [ ! -f "frontend/package.json" ]; then
    echo "❌ frontend/package.json não encontrado"
    exit 1
fi

echo "✅ Estrutura do projeto OK"

# Remover ambiente virtual existente se corrompido
if [ -d "venv" ] && [ ! -f "venv/bin/activate" ]; then
    echo "🗑️  Removendo ambiente virtual corrompido..."
    rm -rf venv
fi

# Criar ambiente virtual
echo
echo "📦 Configurando ambiente Python..."

if [ ! -d "venv" ]; then
    echo "Criando ambiente virtual..."
    python3 -m venv venv
    check_status "Ambiente virtual criado"
fi

# Verificar se activate existe
if [ ! -f "venv/bin/activate" ]; then
    echo "❌ venv/bin/activate não existe!"
    echo "💡 Tentando recriar ambiente virtual..."
    rm -rf venv
    python3 -m venv venv
    
    if [ ! -f "venv/bin/activate" ]; then
        echo "❌ Falha crítica - não consegue criar ambiente virtual"
        echo "💡 Verifique se python3-venv está instalado:"
        echo "   Ubuntu/Debian: sudo apt install python3-venv"
        echo "   CentOS/RHEL: sudo yum install python3-venv"
        exit 1
    fi
fi

# Ativar ambiente virtual
echo "Ativando ambiente virtual..."
source venv/bin/activate
check_status "Ambiente virtual ativado"

# Verificar ativação
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ VIRTUAL_ENV não definido - ambiente não foi ativado"
    exit 1
fi

echo "✅ Usando: $VIRTUAL_ENV"

# Atualizar pip
echo
echo "📦 Atualizando pip..."
pip install --upgrade pip
check_status "pip atualizado"

# Instalar dependências Python básicas primeiro
echo
echo "📦 Instalando dependências básicas..."
pip install fastapi uvicorn pandas numpy requests python-dotenv
check_status "Dependências básicas instaladas"

# Tentar instalar yfinance
echo "📈 Instalando yfinance..."
pip install yfinance
check_status "yfinance instalado"

# Tentar instalar outras dependências
echo "📊 Instalando dependências adicionais..."
pip install websockets aiohttp loguru
check_status "Dependências adicionais instaladas"

echo
echo "📦 Configurando frontend..."
cd frontend

# Limpar cache npm
npm cache clean --force 2>/dev/null || true

# Instalar dependências
npm install
check_status "Dependências Node.js instaladas"

cd ..

# Criar arquivo .env
if [ ! -f ".env" ]; then
    echo
    echo "📝 Criando arquivo .env..."
    cp .env.example .env
    check_status "Arquivo .env criado"
fi

# Teste final
echo
echo "🧪 Testando instalação..."

# Testar importações Python
source venv/bin/activate
python3 -c "
import fastapi
import pandas
import yfinance
print('✅ Módulos Python OK')
"
check_status "Módulos Python funcionando"

# Testar se React está instalado
cd frontend
npm list react --depth=0 >/dev/null 2>&1
check_status "React instalado"
cd ..

echo
echo "🎉 Setup simplificado concluído com sucesso!"
echo
echo "📋 Para executar:"
echo "Backend:  source venv/bin/activate && cd backend && python3 main.py"
echo "Frontend: cd frontend && npm start"
echo
echo "📋 Ou use os scripts:"
echo "./run-backend.sh"
echo "./run-frontend.sh"
echo
#!/bin/bash

echo "🛠️  ROBX Trading Bot - Setup Robusto"
echo "===================================="
echo

# Função para verificar comandos
check_command() {
    if command -v $1 &> /dev/null; then
        echo "✅ $1 disponível"
        return 0
    else
        echo "❌ $1 não encontrado"
        return 1
    fi
}

# Função para verificar e criar diretório
ensure_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "📁 Criado diretório: $1"
    fi
}

echo "🔍 Verificando sistema..."

# Verificar comandos essenciais
check_command python3 || {
    echo "💡 Instale Python3:"
    echo "   Ubuntu/Debian: sudo apt install python3 python3-pip python3-venv"
    echo "   CentOS/RHEL: sudo yum install python3 python3-pip"
    echo "   macOS: brew install python3"
    exit 1
}

check_command node || {
    echo "💡 Instale Node.js:"
    echo "   Ubuntu/Debian: sudo apt install nodejs npm"
    echo "   CentOS/RHEL: sudo yum install nodejs npm"
    echo "   macOS: brew install node"
    exit 1
}

check_command npm || {
    echo "💡 npm não encontrado - geralmente vem com Node.js"
    exit 1
}

echo
echo "📦 Configuração Python..."

# Remover ambiente virtual corrompido
if [ -d "venv" ] && [ ! -f "venv/bin/activate" ]; then
    echo "🗑️  Removendo venv corrompido..."
    rm -rf venv
fi

# Criar ambiente virtual com diferentes métodos
if [ ! -d "venv" ]; then
    echo "Tentando criar ambiente virtual..."
    
    # Método 1: python3 -m venv
    if python3 -m venv venv 2>/dev/null; then
        echo "✅ Ambiente virtual criado com 'python3 -m venv'"
    else
        echo "⚠️  python3 -m venv falhou, tentando virtualenv..."
        
        # Instalar virtualenv se não existir
        if ! command -v virtualenv &> /dev/null; then
            echo "Instalando virtualenv..."
            python3 -m pip install --user virtualenv || pip3 install --user virtualenv
        fi
        
        # Método 2: virtualenv
        if virtualenv venv 2>/dev/null; then
            echo "✅ Ambiente virtual criado com 'virtualenv'"
        else
            echo "❌ Todos os métodos falharam!"
            echo "💡 Soluções:"
            echo "   1. Instale python3-venv: sudo apt install python3-venv"
            echo "   2. Ou use sem ambiente virtual (não recomendado)"
            echo "   3. Instale virtualenv: pip3 install --user virtualenv"
            exit 1
        fi
    fi
fi

# Verificar se o ambiente foi criado
if [ ! -f "venv/bin/activate" ]; then
    echo "❌ Ambiente virtual não foi criado corretamente"
    echo "💡 Verificando estrutura..."
    ls -la venv/ 2>/dev/null || echo "Diretório venv vazio"
    exit 1
fi

echo "✅ Ambiente virtual OK"

# Ativar ambiente virtual
echo "🔧 Ativando ambiente virtual..."
source venv/bin/activate

# Verificar ativação
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Ambiente virtual não foi ativado"
    echo "💡 Tentando ativação manual..."
    export VIRTUAL_ENV="$(pwd)/venv"
    export PATH="$VIRTUAL_ENV/bin:$PATH"
fi

echo "✅ Ambiente ativo: ${VIRTUAL_ENV:-$(pwd)/venv}"

# Atualizar pip
echo "📦 Atualizando pip..."
python -m pip install --upgrade pip 2>/dev/null || pip install --upgrade pip

# Instalar dependências uma por uma para melhor controle
echo "📦 Instalando dependências essenciais..."

# Lista de pacotes essenciais
essential_packages=(
    "fastapi==0.104.1"
    "uvicorn[standard]==0.24.0"
    "pandas==2.1.4"
    "numpy==1.25.2"
    "requests==2.31.0"
    "python-dotenv==1.0.0"
)

for package in "${essential_packages[@]}"; do
    echo "Instalando $package..."
    if pip install "$package"; then
        echo "✅ $package instalado"
    else
        echo "⚠️  Falha em $package, continuando..."
    fi
done

# Tentar instalar yfinance
echo "📈 Instalando yfinance..."
if pip install yfinance==0.2.22; then
    echo "✅ yfinance instalado"
else
    echo "⚠️  yfinance falhou, tentando versão mais recente..."
    pip install yfinance
fi

# Pacotes opcionais
optional_packages=(
    "websockets==12.0"
    "aiohttp==3.9.1"
    "loguru==0.7.2"
    "scikit-learn==1.3.2"
)

echo "📦 Instalando dependências opcionais..."
for package in "${optional_packages[@]}"; do
    echo "Instalando $package..."
    pip install "$package" 2>/dev/null && echo "✅ $package" || echo "⚠️  $package falhou"
done

echo
echo "🌐 Configurando frontend..."

cd frontend || {
    echo "❌ Diretório frontend não encontrado"
    exit 1
}

# Verificar package.json
if [ ! -f "package.json" ]; then
    echo "❌ package.json não encontrado"
    exit 1
fi

# Limpar cache npm
echo "🧹 Limpando cache npm..."
npm cache clean --force 2>/dev/null || true

# Instalar dependências com diferentes estratégias
echo "📦 Instalando dependências React..."

if npm install; then
    echo "✅ npm install sucesso"
elif npm install --legacy-peer-deps; then
    echo "✅ npm install com --legacy-peer-deps"
elif npm install --force; then
    echo "✅ npm install com --force"
else
    echo "❌ Todas as tentativas de npm install falharam"
    exit 1
fi

cd ..

# Configurar .env
echo "📝 Configurando .env..."
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "✅ .env criado a partir de .env.example"
    else
        cat > .env << EOF
API_HOST=0.0.0.0
API_PORT=8000
DEBUG=True
CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
EOF
        echo "✅ .env criado com configurações básicas"
    fi
fi

# Teste final
echo
echo "🧪 Teste final..."
source venv/bin/activate
if python -c "import fastapi, pandas, yfinance; print('✅ Módulos principais OK')" 2>/dev/null; then
    echo "✅ Backend pronto"
else
    echo "⚠️  Alguns módulos podem ter problemas"
fi

echo
echo "🎉 Setup robusto concluído!"
echo
echo "📋 Para executar:"
echo "Backend:  source venv/bin/activate && cd backend && python main.py"
echo "Frontend: cd frontend && npm start"
echo
echo "📋 Ou use os scripts (se executáveis):"
echo "./run-backend.sh"
echo "./run-frontend.sh"
echo
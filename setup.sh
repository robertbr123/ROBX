#!/bin/bash

echo "🚀 Iniciando ROBX Trading Bot..."
echo

# Verificar se estamos no diretório correto
if [ ! -f "requirements.txt" ]; then
    echo "❌ Arquivo requirements.txt não encontrado. Execute o script a partir do diretório raiz do projeto."
    exit 1
fi

# Verificar se Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 não encontrado. Por favor, instale Python 3.8+"
    echo "Ubuntu/Debian: sudo apt update && sudo apt install python3 python3-pip python3-venv"
    echo "CentOS/RHEL: sudo yum install python3 python3-pip"
    echo "Arch: sudo pacman -S python python-pip"
    exit 1
fi

# Verificar se pip está instalado
if ! command -v pip3 &> /dev/null; then
    echo "⚠️  pip3 não encontrado. Tentando instalar..."
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install python3-pip -y
    elif command -v yum &> /dev/null; then
        sudo yum install python3-pip -y
    else
        echo "💡 Instale pip3 manualmente para sua distribuição"
    fi
fi

# Verificar se Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js não encontrado. Por favor, instale Node.js 16+"
    echo "Ubuntu/Debian: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt install nodejs"
    echo "Ou use: sudo apt install nodejs npm"
    exit 1
fi

# Verificar se npm está instalado
if ! command -v npm &> /dev/null; then
    echo "⚠️  npm não encontrado. Tentando instalar..."
    if command -v apt &> /dev/null; then
        sudo apt install npm -y
    elif command -v yum &> /dev/null; then
        sudo yum install npm -y
    else
        echo "💡 Instale npm manualmente para sua distribuição"
    fi
fi

echo "✅ Python $(python3 --version) e Node.js $(node --version) encontrados"

# Criar ambiente virtual Python
echo
echo "📦 Criando ambiente virtual Python..."

# Remover ambiente virtual corrompido se existir
if [ -d "venv" ] && [ ! -f "venv/bin/activate" ]; then
    echo "🗑️  Removendo ambiente virtual corrompido..."
    rm -rf venv
fi

if [ ! -d "venv" ]; then
    echo "Tentando criar ambiente virtual..."
    
    # Método 1: Verificar se python3-venv está instalado
    if ! python3 -c "import venv" 2>/dev/null; then
        echo "⚠️  Módulo venv não encontrado. Instalando python3-venv..."
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install python3-venv -y
        elif command -v yum &> /dev/null; then
            sudo yum install python3-venv -y || sudo yum install python36-devel -y
        elif command -v dnf &> /dev/null; then
            sudo dnf install python3-venv -y
        elif command -v pacman &> /dev/null; then
            sudo pacman -S python-virtualenv --noconfirm
        fi
    fi
    
    # Método 2: Tentar criar com python3 -m venv
    echo "Criando com 'python3 -m venv venv'..."
    if python3 -m venv venv 2>/dev/null; then
        echo "✅ Ambiente virtual criado com venv"
    else
        echo "⚠️  python3 -m venv falhou. Tentando virtualenv..."
        
        # Método 3: Instalar e usar virtualenv
        if ! command -v virtualenv &> /dev/null; then
            echo "Instalando virtualenv..."
            python3 -m pip install --user virtualenv 2>/dev/null || pip3 install --user virtualenv
        fi
        
        if command -v virtualenv &> /dev/null; then
            echo "Criando com 'virtualenv venv'..."
            if virtualenv venv 2>/dev/null; then
                echo "✅ Ambiente virtual criado com virtualenv"
            else
                echo "⚠️  virtualenv também falhou. Tentando virtualenv-3..."
                virtualenv-3 venv 2>/dev/null && echo "✅ Ambiente virtual criado com virtualenv-3"
            fi
        fi
    fi
    
    # Verificação final
    if [ ! -f "venv/bin/activate" ]; then
        echo "❌ Não foi possível criar ambiente virtual com nenhum método!"
        echo "💡 Soluções:"
        echo "   Ubuntu/Debian: sudo apt install python3-venv python3-dev"
        echo "   CentOS/RHEL 7: sudo yum install python36-devel python36-virtualenv"  
        echo "   CentOS/RHEL 8+: sudo dnf install python3-venv python3-devel"
        echo "   Fedora: sudo dnf install python3-virtualenv python3-devel"
        echo "   Arch: sudo pacman -S python-virtualenv"
        echo ""
        echo "⚠️  Continuando sem ambiente virtual (não recomendado)..."
        export SKIP_VENV=1
    else
        echo "✅ Ambiente virtual criado com sucesso"
    fi
else
    echo "✅ Ambiente virtual já existe"
fi

# Ativar ambiente virtual se disponível
echo
if [ "$SKIP_VENV" != "1" ] && [ -f "venv/bin/activate" ]; then
    echo "🔧 Ativando ambiente virtual..."
    source venv/bin/activate
    
    # Verificar se a ativação funcionou
    if [ -n "$VIRTUAL_ENV" ]; then
        echo "✅ Ambiente virtual ativado: $VIRTUAL_ENV"
        
        # Atualizar pip
        echo "📦 Atualizando pip..."
        python -m pip install --upgrade pip 2>/dev/null || pip install --upgrade pip
    else
        echo "⚠️  Ambiente virtual não foi ativado corretamente, continuando sem..."
        export SKIP_VENV=1
    fi
else
    echo "⚠️  Pulando ambiente virtual - instalando globalmente (não recomendado)"
    export SKIP_VENV=1
fi

# Instalar dependências Python
echo
echo "📦 Instalando dependências Python..."

# Escolher comando pip correto
if [ "$SKIP_VENV" = "1" ]; then
    PIP_CMD="pip3"
    echo "⚠️  Instalando globalmente com pip3"
else
    PIP_CMD="pip"
    echo "✅ Instalando no ambiente virtual com pip"
fi

# Tentar instalar dependências básicas primeiro
echo "📦 Instalando dependências essenciais..."
essential_deps="fastapi uvicorn pandas numpy requests python-dotenv"

for dep in $essential_deps; do
    echo "Instalando $dep..."
    if $PIP_CMD install "$dep" 2>/dev/null; then
        echo "✅ $dep instalado"
    else
        echo "⚠️  Falha em $dep, continuando..."
    fi
done

# Tentar yfinance separadamente (pode ser problemático)
echo "📈 Instalando yfinance..."
if $PIP_CMD install yfinance 2>/dev/null; then
    echo "✅ yfinance instalado"
else
    echo "⚠️  yfinance falhou, mas continuando..."
fi

# Tentar instalar outras dependências do requirements.txt
echo "📦 Tentando instalar dependências do requirements.txt..."
if $PIP_CMD install -r requirements.txt 2>/dev/null; then
    echo "✅ Dependências principais instaladas"
else
    echo "⚠️  Algumas dependências do requirements.txt falharam"
    
    # Tentar requirements-simple.txt se existir
    if [ -f "requirements-simple.txt" ]; then
        echo "📦 Tentando requirements-simple.txt..."
        if $PIP_CMD install -r requirements-simple.txt 2>/dev/null; then
            echo "✅ Dependências simplificadas instaladas"
        else
            echo "⚠️  requirements-simple.txt também falhou"
        fi
    fi
fi

echo "✅ Instalação de dependências Python concluída"

# Configurar ambiente Node.js
echo
echo "📦 Configurando ambiente React..."

if [ ! -d "frontend" ]; then
    echo "❌ Diretório frontend não encontrado!"
    exit 1
fi

cd frontend

# Verificar package.json
if [ ! -f "package.json" ]; then
    echo "❌ package.json não encontrado!"
    exit 1
fi

# Limpar cache do npm se necessário
echo "🧹 Limpando cache npm..."
npm cache clean --force 2>/dev/null || true

# Remover node_modules se corrompido
if [ -d "node_modules" ] && [ ! -f "node_modules/.package-lock.json" ]; then
    echo "🗑️  Removendo node_modules corrompido..."
    rm -rf node_modules package-lock.json
fi

# Instalar dependências com múltiplas estratégias
echo "📦 Instalando dependências React..."

if npm install 2>/dev/null; then
    echo "✅ npm install bem-sucedido"
elif npm install --legacy-peer-deps 2>/dev/null; then
    echo "✅ npm install com --legacy-peer-deps bem-sucedido"
elif npm install --force 2>/dev/null; then
    echo "✅ npm install com --force bem-sucedido"
else
    echo "⚠️  npm install falhou com todas as estratégias"
    echo "💡 Tentando instalar dependências essenciais individualmente..."
    
    # Instalar dependências essenciais uma por uma
    essential_npm_deps="react react-dom react-scripts react-router-dom"
    for dep in $essential_npm_deps; do
        echo "Instalando $dep..."
        npm install "$dep" 2>/dev/null && echo "✅ $dep" || echo "⚠️  $dep falhou"
    done
fi

# Verificar se React foi instalado
if [ -d "node_modules/react" ]; then
    echo "✅ React está instalado"
else
    echo "⚠️  React pode não estar instalado corretamente"
fi

echo "✅ Configuração do frontend concluída"

# Voltar ao diretório raiz
cd ..

# Criar arquivo .env se não existir
if [ ! -f ".env" ]; then
    echo "📝 Criando arquivo .env..."
    cp .env.example .env
    echo "✅ Arquivo .env criado"
else
    echo "✅ Arquivo .env já existe"
fi

# Verificar se TA-Lib está instalado (dependência comum que pode causar problemas)
echo
echo "🔍 Verificando módulos Python..."

if [ "$SKIP_VENV" != "1" ] && [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
fi

# Verificar módulos essenciais
python3 -c "import fastapi" 2>/dev/null && echo "✅ FastAPI funcionando" || echo "⚠️  FastAPI pode ter problemas"
python3 -c "import pandas" 2>/dev/null && echo "✅ Pandas funcionando" || echo "⚠️  Pandas pode ter problemas"  
python3 -c "import yfinance" 2>/dev/null && echo "✅ yfinance funcionando" || echo "⚠️  yfinance pode ter problemas"
python3 -c "import talib" 2>/dev/null && echo "✅ TA-Lib funcionando" || echo "⚠️  TA-Lib não disponível (sistema usará implementações próprias)"

echo
echo "🎉 Setup concluído!"
echo
echo "Para executar o ROBX Trading Bot:"
echo "1. Backend: ./run-backend.sh"
echo "2. Frontend: ./run-frontend.sh"  
echo "3. Ou ambos: ./run-all.sh"
echo
echo "📝 Notas importantes:"
if [ "$SKIP_VENV" != "1" ]; then
    echo "- O ambiente virtual Python foi criado em 'venv/'"
    echo "- Para ativar manualmente: source venv/bin/activate"
else
    echo "- ⚠️  Executando sem ambiente virtual (dependências instaladas globalmente)"
    echo "- Para criar ambiente virtual: sudo apt install python3-venv"
fi
echo "- Para instalar TA-Lib no Ubuntu: sudo apt install libta-lib-dev"
echo "- Em caso de problemas, execute: ./troubleshoot.sh"
echo
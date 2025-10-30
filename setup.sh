#!/bin/bash

set -e  # Exit on any error

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
    echo "❌ pip3 não encontrado. Instalando..."
    sudo apt update && sudo apt install python3-pip -y
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
    echo "❌ npm não encontrado. Instalando..."
    sudo apt install npm -y
fi

echo "✅ Python $(python3 --version) e Node.js $(node --version) encontrados"

# Criar ambiente virtual Python
echo
echo "📦 Criando ambiente virtual Python..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "✅ Ambiente virtual criado"
else
    echo "✅ Ambiente virtual já existe"
fi

# Ativar ambiente virtual
echo "🔧 Ativando ambiente virtual..."
source venv/bin/activate

# Atualizar pip
echo "📦 Atualizando pip..."
pip install --upgrade pip

# Instalar dependências Python
echo "📦 Instalando dependências Python..."
pip install -r requirements.txt

echo "✅ Dependências Python instaladas no ambiente virtual"

# Configurar ambiente Node.js
echo
echo "📦 Configurando ambiente React..."
cd frontend

# Limpar cache do npm se necessário
npm cache clean --force 2>/dev/null || true

# Instalar dependências
npm install

if [ $? -ne 0 ]; then
    echo "❌ Erro ao instalar dependências Node.js. Tentando com --legacy-peer-deps..."
    npm install --legacy-peer-deps
fi

echo "✅ Dependências React instaladas"

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
echo "🔍 Verificando TA-Lib..."
source venv/bin/activate
python3 -c "import talib" 2>/dev/null && echo "✅ TA-Lib está funcionando" || echo "⚠️  TA-Lib pode não estar funcionando (o sistema usará implementações próprias)"

echo
echo "🎉 Setup concluído com sucesso!"
echo
echo "Para executar o ROBX Trading Bot:"
echo "1. Backend: ./run-backend.sh"
echo "2. Frontend: ./run-frontend.sh"
echo "3. Ou ambos: ./run-all.sh"
echo
echo "📝 Notas importantes:"
echo "- O ambiente virtual Python foi criado em 'venv/'"
echo "- Para ativar manualmente: source venv/bin/activate"
echo "- Para instalar TA-Lib no Ubuntu: sudo apt install libta-lib-dev"
echo
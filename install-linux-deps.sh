#!/bin/bash

echo "🔧 Instalando dependências do sistema para ROBX Trading Bot..."
echo

# Detectar distribuição Linux
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
fi

echo "🐧 Sistema detectado: $OS"
echo

# Função para Ubuntu/Debian
install_ubuntu_deps() {
    echo "📦 Instalando dependências para Ubuntu/Debian..."
    
    # Atualizar repositórios
    sudo apt update
    
    # Instalar Python e pip
    sudo apt install -y python3 python3-pip python3-venv python3-dev
    
    # Instalar Node.js e npm
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
    
    # Instalar dependências para TA-Lib
    sudo apt install -y build-essential wget
    
    # Instalar TA-Lib
    echo "📈 Instalando TA-Lib..."
    cd /tmp
    wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
    tar -xzf ta-lib-0.4.0-src.tar.gz
    cd ta-lib/
    ./configure --prefix=/usr
    make
    sudo make install
    sudo ldconfig
    cd -
    
    echo "✅ Dependências Ubuntu/Debian instaladas"
}

# Função para CentOS/RHEL/Fedora
install_redhat_deps() {
    echo "📦 Instalando dependências para Red Hat/CentOS/Fedora..."
    
    # Instalar EPEL (para CentOS/RHEL)
    if command -v yum &> /dev/null; then
        sudo yum install -y epel-release
        sudo yum install -y python3 python3-pip python3-devel gcc gcc-c++ make wget
    else
        sudo dnf install -y python3 python3-pip python3-devel gcc gcc-c++ make wget
    fi
    
    # Instalar Node.js
    curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
    if command -v yum &> /dev/null; then
        sudo yum install -y nodejs
    else
        sudo dnf install -y nodejs
    fi
    
    # Instalar TA-Lib
    echo "📈 Instalando TA-Lib..."
    cd /tmp
    wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
    tar -xzf ta-lib-0.4.0-src.tar.gz
    cd ta-lib/
    ./configure --prefix=/usr
    make
    sudo make install
    sudo ldconfig
    cd -
    
    echo "✅ Dependências Red Hat/CentOS/Fedora instaladas"
}

# Função para Arch Linux
install_arch_deps() {
    echo "📦 Instalando dependências para Arch Linux..."
    
    # Atualizar sistema
    sudo pacman -Syu --noconfirm
    
    # Instalar dependências
    sudo pacman -S --noconfirm python python-pip nodejs npm base-devel wget
    
    # Instalar TA-Lib
    echo "📈 Instalando TA-Lib..."
    cd /tmp
    wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
    tar -xzf ta-lib-0.4.0-src.tar.gz
    cd ta-lib/
    ./configure --prefix=/usr
    make
    sudo make install
    sudo ldconfig
    cd -
    
    echo "✅ Dependências Arch Linux instaladas"
}

# Detectar e instalar dependências
case "$OS" in
    *"Ubuntu"*|*"Debian"*)
        install_ubuntu_deps
        ;;
    *"CentOS"*|*"Red Hat"*|*"Fedora"*)
        install_redhat_deps
        ;;
    *"Arch"*)
        install_arch_deps
        ;;
    *)
        echo "⚠️  Distribuição não reconhecida: $OS"
        echo "Por favor, instale manualmente:"
        echo "- Python 3.8+"
        echo "- Node.js 16+"
        echo "- TA-Lib"
        echo "- Ferramentas de desenvolvimento (gcc, make, etc.)"
        ;;
esac

echo
echo "🎉 Instalação de dependências do sistema concluída!"
echo "📋 Próximos passos:"
echo "1. Execute: ./setup.sh"
echo "2. Execute: ./run-all.sh"
echo
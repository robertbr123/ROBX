# ROBX Trading Bot

Sistema de trading automatizado para análise e recomendações de compra/venda de ativos da B3 com interface web moderna.

## 🚀 Funcionalidades

- **Análise Técnica Avançada**: RSI, MACD, Bollinger Bands, Médias Móveis
- **Dados em Tempo Real**: Conexão com APIs da B3 via Yahoo Finance e outras fontes
- **Interface Web Moderna**: Dashboard interativo com gráficos em tempo real
- **Sistema de Recomendações**: Algoritmos para sinais de compra/venda
- **Alertas Inteligentes**: Notificações em tempo real de oportunidades
- **Day Trading Otimizado**: Focado em operações intraday

## 🏗️ Arquitetura

```
ROBX/
├── backend/           # API Python (FastAPI)
│   ├── api/          # Endpoints da API
│   ├── services/     # Lógica de negócio
│   ├── models/       # Modelos de dados
│   └── utils/        # Utilitários
├── frontend/         # Interface React
└── docs/            # Documentação
```

## 🛠️ Tecnologias

### Backend
- **FastAPI**: API REST moderna e rápida
- **WebSockets**: Comunicação em tempo real
- **Pandas + TA-Lib**: Análise técnica
- **SQLAlchemy**: ORM para banco de dados
- **Celery + Redis**: Tarefas assíncronas

### Frontend
- **React**: Interface de usuário
- **Chart.js**: Gráficos interativos
- **Material-UI**: Componentes modernos
- **Socket.io**: Tempo real

### APIs de Dados
- **Yahoo Finance**: Dados históricos e tempo real
- **Alpha Vantage**: Dados financeiros
- **Binance API**: Criptomoedas (opcional)

## 🚀 Instalação

### Opção 1: Instalação Automática (Linux)

#### 1. Clone o repositório
```bash
git clone https://github.com/robertbr123/ROBX.git
cd ROBX
```

#### 2. Instale dependências do sistema (apenas primeira vez)
```bash
chmod +x *.sh
sudo ./install-linux-deps.sh
```

#### 3. Configure o projeto
```bash
./setup.sh
```

#### 4. Execute o sistema
```bash
./run-all.sh  # Inicia backend e frontend juntos
# OU
./run-backend.sh  # Apenas backend
./run-frontend.sh  # Apenas frontend (em outro terminal)
```

### Opção 2: Instalação Manual

#### 1. Dependências do Sistema
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3 python3-pip python3-venv nodejs npm build-essential

# CentOS/RHEL/Fedora
sudo yum install python3 python3-pip nodejs npm gcc gcc-c++ make
# ou para versões mais novas: sudo dnf install python3 python3-pip nodejs npm gcc gcc-c++ make

# Arch Linux
sudo pacman -S python python-pip nodejs npm base-devel
```

#### 2. Backend Setup
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cd backend
python3 main.py
```

#### 3. Frontend Setup (novo terminal)
```bash
cd frontend
npm install
npm start
```

### Opção 3: Windows
```bash
# Execute os arquivos .bat
setup.bat
run-backend.bat  # Terminal 1
run-frontend.bat  # Terminal 2
```

## 📊 Indicadores Técnicos

- **RSI (Relative Strength Index)**: Identificação de sobrecompra/sobrevenda
- **MACD**: Convergência/divergência de médias móveis
- **Bollinger Bands**: Volatilidade e pontos de entrada
- **Médias Móveis**: Tendências de curto e longo prazo
- **Volume**: Confirmação de movimentos

## 🎯 Sistema de Sinais

### Sinais de Compra
- RSI < 30 (sobrevenda)
- MACD cruza acima da linha de sinal
- Preço toca banda inferior de Bollinger
- Volume acima da média

### Sinais de Venda
- RSI > 70 (sobrecompra)
- MACD cruza abaixo da linha de sinal
- Preço toca banda superior de Bollinger
- Divergência bearish

## ⚡ Uso

1. **Acesse o Dashboard**: http://localhost:3000
2. **Selecione Ativos**: Escolha as ações da B3
3. **Configure Parâmetros**: Ajuste indicadores
4. **Monitore Sinais**: Acompanhe recomendações
5. **Execute Operações**: Day trading otimizado

## 📈 Dashboard

- **Gráficos em Tempo Real**: Candlesticks com indicadores
- **Lista de Ativos**: Watchlist personalizada
- **Sinais Ativos**: Oportunidades em destaque
- **Performance**: Histórico de sinais
- **Configurações**: Personalização de estratégias

## ⚠️ Disclaimer

Este sistema é apenas para fins educacionais e de análise. Não constitui aconselhamento financeiro. O usuário é responsável por suas decisões de investimento.

## 📝 Licença

MIT License - Veja [LICENSE](LICENSE) para detalhes.

---

**Desenvolvido para Day Traders da B3** 🇧🇷📈
# 🤖 ROBX Trading Bot

Sistema completo de trading para análise da B3 com interface web moderna e API robusta.

## 🚀 Início Rápido

### 1. Setup Inicial
```bash
# Clone o repositório e entre no diretório
cd ROBX

# Execute o setup (instala todas as dependências)
./setup.sh
```

### 2. Executar o Sistema

#### Opção A: Menu Interativo (Recomendado)
```bash
./menu.sh
```

#### Opção B: Scripts Diretos
```bash
# Iniciar ambos (backend + frontend) - Versão completa
./run-all.sh

# Iniciar ambos - Versão rápida  
./quick-start.sh

# Ou separadamente:
./run-backend.sh    # Apenas backend
./run-frontend.sh   # Apenas frontend
```

#### Opção C: Parar Serviços
```bash
./stop-all.sh
```

## 📊 Endpoints Disponíveis

### Frontend
- 🌐 **Interface Web**: http://localhost:3000
- 📈 **Dashboard**: Trading em tempo real
- 📊 **Gráficos**: Análise técnica interativa

### Backend API
- 📊 **API Base**: http://localhost:8000
- 📚 **Documentação**: http://localhost:8000/docs
- 🔄 **Health Check**: http://localhost:8000/health
- 📈 **Market Data**: http://localhost:8000/api/v1/market/
- 🔍 **Análise Técnica**: http://localhost:8000/api/v1/analysis/
- 💡 **Recomendações**: http://localhost:8000/api/v1/recommendations/
- 🔗 **WebSocket**: ws://localhost:8000/ws

## 🛠️ Scripts Disponíveis

| Script | Descrição |
|--------|-----------|
| `./menu.sh` | Menu interativo principal |
| `./setup.sh` | Instalação completa de dependências |
| `./run-all.sh` | Executa backend + frontend (completo) |
| `./quick-start.sh` | Início rápido dos serviços |
| `./run-backend.sh` | Apenas backend |
| `./run-frontend.sh` | Apenas frontend |
| `./stop-all.sh` | Para todos os serviços |
| `./troubleshoot.sh` | Diagnóstico de problemas |

## 🔧 Funcionalidades

### Backend (Python/FastAPI)
- ✅ API RESTful completa
- ✅ WebSocket para dados em tempo real
- ✅ Integração com Yahoo Finance (dados B3)
- ✅ Análise técnica (RSI, MACD, Bollinger Bands)
- ✅ Sistema de recomendações
- ✅ Documentação automática (Swagger)

### Frontend (React)
- ✅ Dashboard responsivo
- ✅ Gráficos interativos (Chart.js)
- ✅ Tema escuro moderno (Material-UI)
- ✅ Dados em tempo real via WebSocket
- ✅ Interface otimizada para trading

### Análise Técnica
- 📈 **RSI** (Relative Strength Index)
- 📊 **MACD** (Moving Average Convergence Divergence)
- 📉 **Bollinger Bands**
- 📈 **Médias Móveis** (SMA, EMA)
- 📊 **Volume** e indicadores de momentum

## 🐛 Solução de Problemas

### Erro de Imports Python
```bash
cd backend
python3 test_imports.py  # Diagnosticar imports
python3 debug.py        # Versão mínima
```

### Problemas de Dependências
```bash
./troubleshoot.sh       # Diagnóstico completo
rm -rf venv frontend/node_modules
./setup.sh             # Reinstalar tudo
```

### Portas Ocupadas
```bash
./stop-all.sh          # Para todos os processos
pkill -f uvicorn        # Para backend
pkill -f react-scripts  # Para frontend
```

## 📋 Requisitos

### Sistema
- **SO**: Linux/Ubuntu (testado), macOS, Windows WSL
- **Python**: 3.8+
- **Node.js**: 16+
- **npm**: 8+

### Dependências Python
- FastAPI
- Uvicorn
- Pandas
- yfinance
- WebSockets
- python-dotenv

### Dependências React
- React 18
- Material-UI
- Chart.js
- Axios
- React Router

## 🔒 Configuração

### Variáveis de Ambiente (.env)
```bash
# API Keys (opcional)
ALPHA_VANTAGE_API_KEY=your_key_here
FINNHUB_API_KEY=your_key_here

# Configurações
DEBUG=true
CORS_ORIGINS=http://localhost:3000
```

## 📈 Uso

1. **Executar Setup**: `./setup.sh`
2. **Iniciar Sistema**: `./run-all.sh`
3. **Acessar Frontend**: http://localhost:3000
4. **Explorar API**: http://localhost:8000/docs
5. **Parar Sistema**: Ctrl+C ou `./stop-all.sh`

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob a licença MIT.

---

**⚡ Para usar rapidamente: `./menu.sh`**
#!/bin/bash

echo "🚀 Iniciando ROBX Trading Bot Completo..."
echo "========================================"
echo

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verificar se está no diretório correto
if [ ! -f "backend/main.py" ] || [ ! -f "frontend/package.json" ]; then
    echo -e "${RED}❌ Arquivos do projeto não encontrados. Execute a partir do diretório raiz do projeto.${NC}"
    exit 1
fi

# Verificar se o setup foi executado
echo "🔍 Verificando dependências..."
missing_deps=0

if [ ! -f "venv/bin/activate" ] && [ ! -f "requirements.txt" ]; then
    echo -e "${YELLOW}⚠️  Ambiente virtual Python não encontrado${NC}"
    missing_deps=1
fi

if [ ! -d "frontend/node_modules" ]; then
    echo -e "${YELLOW}⚠️  Dependências React não encontradas${NC}"
    missing_deps=1
fi

if [ $missing_deps -eq 1 ]; then
    echo -e "${RED}❌ Dependências incompletas. Execute ./setup.sh primeiro.${NC}"
    echo -e "${BLUE}💡 Comando: ./setup.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Verificações concluídas${NC}"
echo

# Função para parar processos em background
cleanup() {
    echo
    echo -e "${YELLOW}🛑 Parando servidores...${NC}"
    
    # Parar backend
    if [ ! -z "$BACKEND_PID" ] && kill -0 $BACKEND_PID 2>/dev/null; then
        echo "🔧 Parando backend (PID: $BACKEND_PID)..."
        kill -TERM $BACKEND_PID 2>/dev/null
        sleep 2
        kill -KILL $BACKEND_PID 2>/dev/null
    fi
    
    # Parar frontend
    if [ ! -z "$FRONTEND_PID" ] && kill -0 $FRONTEND_PID 2>/dev/null; then
        echo "🎨 Parando frontend (PID: $FRONTEND_PID)..."
        kill -TERM $FRONTEND_PID 2>/dev/null
        sleep 2
        kill -KILL $FRONTEND_PID 2>/dev/null
    fi
    
    # Parar processos na porta 8000 e 3000 se existirem
    pkill -f "uvicorn.*8000" 2>/dev/null || true
    pkill -f "npm.*start" 2>/dev/null || true
    pkill -f "react-scripts.*start" 2>/dev/null || true
    
    echo -e "${GREEN}✅ Servidores parados${NC}"
    exit 0
}

# Configurar trap para cleanup
trap cleanup SIGINT SIGTERM

# Verificar se as portas estão disponíveis
echo "🌐 Verificando portas..."
if command -v netstat &> /dev/null; then
    if netstat -tuln 2>/dev/null | grep -q ":8000"; then
        echo -e "${YELLOW}⚠️  Porta 8000 já está em uso (Backend)${NC}"
        echo "💡 Para liberar: pkill -f uvicorn"
    fi
    
    if netstat -tuln 2>/dev/null | grep -q ":3000"; then
        echo -e "${YELLOW}⚠️  Porta 3000 já está em uso (Frontend)${NC}"
        echo "💡 Para liberar: pkill -f react-scripts"
    fi
fi

# Iniciar Backend em background
echo -e "${BLUE}🔧 Iniciando Backend...${NC}"
./run-backend.sh > backend.log 2>&1 &
BACKEND_PID=$!

# Aguardar alguns segundos para o backend inicializar
echo "⏳ Aguardando backend inicializar..."
sleep 8

# Verificar se o backend está rodando
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo -e "${RED}❌ Falha ao iniciar o backend${NC}"
    echo -e "${BLUE}💡 Verifique o log: tail backend.log${NC}"
    exit 1
fi

# Verificar se o backend responde
echo "🔍 Testando conexão com backend..."
for i in {1..10}; do
    if curl -s http://localhost:8000/health &>/dev/null; then
        echo -e "${GREEN}✅ Backend respondendo${NC}"
        break
    elif [ $i -eq 10 ]; then
        echo -e "${RED}❌ Backend não responde após 10 tentativas${NC}"
        echo -e "${BLUE}💡 Verifique o log: tail backend.log${NC}"
        kill $BACKEND_PID 2>/dev/null
        exit 1
    else
        echo "⏳ Tentativa $i/10..."
        sleep 2
    fi
done

echo -e "${GREEN}✅ Backend iniciado (PID: $BACKEND_PID)${NC}"

# Iniciar Frontend em background
echo -e "${BLUE}🎨 Iniciando Frontend...${NC}"
echo "⏳ ATENÇÃO: Frontend pode demorar 2-5 minutos na primeira execução"
echo "📊 'Starting the development server...' é NORMAL"
./run-frontend.sh > frontend.log 2>&1 &
FRONTEND_PID=$!

# Aguardar alguns segundos para o frontend inicializar
echo "⏳ Aguardando frontend inicializar..."
echo "💡 Para monitorar progresso: tail -f frontend.log (outro terminal)"
sleep 15

# Verificar se o frontend está rodando
if ! kill -0 $FRONTEND_PID 2>/dev/null; then
    echo -e "${RED}❌ Falha ao iniciar o frontend${NC}"
    echo -e "${BLUE}💡 Verifique o log: tail frontend.log${NC}"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

# Verificar se o frontend responde (mais tempo para primeira execução)
echo "🔍 Testando conexão com frontend (pode demorar)..."
for i in {1..30}; do
    if curl -s --connect-timeout 2 http://localhost:3000 &>/dev/null; then
        echo -e "${GREEN}✅ Frontend respondendo${NC}"
        break
    elif [ $i -eq 30 ]; then
        echo -e "${YELLOW}⚠️  Frontend ainda carregando, mas processo ativo${NC}"
        echo -e "${BLUE}💡 Continue aguardando ou verifique: tail -f frontend.log${NC}"
        break
    else
        if [ $((i % 5)) -eq 0 ]; then
            echo "⏳ Ainda carregando... ($i/30) - Primeira execução demora mais"
        fi
        sleep 4
    fi
done

echo -e "${GREEN}✅ Frontend iniciado (PID: $FRONTEND_PID)${NC}"
echo
echo -e "${GREEN}🎉 ROBX Trading Bot está rodando!${NC}"
echo "========================================"
echo -e "${BLUE}📊 Backend API:${NC} http://localhost:8000"
echo -e "${BLUE}🌐 Frontend Web:${NC} http://localhost:3000"  
echo -e "${BLUE}📚 API Docs:${NC} http://localhost:8000/docs"
echo -e "${BLUE}🔄 WebSocket:${NC} ws://localhost:8000/ws"
echo -e "${BLUE}💾 Logs:${NC} tail -f backend.log frontend.log"
echo
echo -e "${YELLOW}⏹️  Pressione Ctrl+C para parar todos os serviços${NC}"
echo

# Aguardar indefinidamente até receber sinal de parada
wait
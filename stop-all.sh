#!/bin/bash

echo "🛑 Parando ROBX Trading Bot..."
echo "=============================="
echo

# Função para parar processo por PID
stop_process() {
    local pid=$1
    local name=$2
    
    if [ ! -z "$pid" ] && kill -0 $pid 2>/dev/null; then
        echo "🔄 Parando $name (PID: $pid)..."
        kill -TERM $pid 2>/dev/null
        sleep 3
        
        if kill -0 $pid 2>/dev/null; then
            echo "💀 Forçando parada de $name..."
            kill -KILL $pid 2>/dev/null
        fi
        
        echo "✅ $name parado"
    else
        echo "ℹ️  $name não está rodando"
    fi
}

# Parar por processo específico
echo "🔍 Procurando processos ROBX..."

# Parar backend (uvicorn/FastAPI)
BACKEND_PIDS=$(pgrep -f "uvicorn.*8000" 2>/dev/null)
if [ ! -z "$BACKEND_PIDS" ]; then
    for pid in $BACKEND_PIDS; do
        stop_process $pid "Backend"
    done
else
    echo "ℹ️  Backend não encontrado na porta 8000"
fi

# Parar processos Python debug
DEBUG_PIDS=$(pgrep -f "python.*debug.py" 2>/dev/null)
if [ ! -z "$DEBUG_PIDS" ]; then
    for pid in $DEBUG_PIDS; do
        stop_process $pid "Debug Backend"
    done
fi

# Parar frontend (npm/react-scripts)
FRONTEND_PIDS=$(pgrep -f "npm.*start\|react-scripts.*start" 2>/dev/null)
if [ ! -z "$FRONTEND_PIDS" ]; then
    for pid in $FRONTEND_PIDS; do
        stop_process $pid "Frontend"
    done
else
    echo "ℹ️  Frontend não encontrado"
fi

# Parar processos Node.js na porta 3000
NODE_PIDS=$(lsof -ti:3000 2>/dev/null)
if [ ! -z "$NODE_PIDS" ]; then
    for pid in $NODE_PIDS; do
        stop_process $pid "Node.js (porta 3000)"
    done
fi

# Parar processos Python na porta 8000
PYTHON_PIDS=$(lsof -ti:8000 2>/dev/null)
if [ ! -z "$PYTHON_PIDS" ]; then
    for pid in $PYTHON_PIDS; do
        stop_process $pid "Python (porta 8000)"
    done
fi

echo
echo "🧹 Limpando arquivos temporários..."

# Remover logs se existirem
[ -f "backend.log" ] && rm backend.log && echo "🗑️  backend.log removido"
[ -f "frontend.log" ] && rm frontend.log && echo "🗑️  frontend.log removido"

# Verificar se as portas estão livres
echo
echo "🔍 Verificando portas..."
if command -v netstat &> /dev/null; then
    if netstat -tuln 2>/dev/null | grep -q ":8000"; then
        echo "⚠️  Porta 8000 ainda ocupada"
    else
        echo "✅ Porta 8000 livre"
    fi
    
    if netstat -tuln 2>/dev/null | grep -q ":3000"; then
        echo "⚠️  Porta 3000 ainda ocupada"
    else
        echo "✅ Porta 3000 livre"
    fi
else
    echo "ℹ️  netstat não disponível para verificar portas"
fi

echo
echo "✅ ROBX Trading Bot parado!"
echo
echo "💡 Para reiniciar:"
echo "   ./run-all.sh      (completo)"
echo "   ./quick-start.sh  (rápido)"
echo
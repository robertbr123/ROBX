#!/bin/bash

echo "⚡ ROBX Trading Bot - Início Rápido"
echo "=================================="
echo

# Verificar se curl está disponível para testes
if ! command -v curl &> /dev/null; then
    echo "📦 Instalando curl para testes de conectividade..."
    if command -v apt &> /dev/null; then
        sudo apt install curl -y
    elif command -v yum &> /dev/null; then
        sudo yum install curl -y
    fi
fi

# Iniciar backend em background
echo "🔧 Iniciando Backend..."
cd backend
python3 debug.py > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..

# Aguardar backend estar pronto
echo "⏳ Aguardando backend..."
sleep 5

# Verificar se backend está funcionando
if curl -s http://localhost:8000/health &>/dev/null; then
    echo "✅ Backend funcionando"
else
    echo "⚠️  Backend ainda carregando..."
fi

# Iniciar frontend em background
echo "🎨 Iniciando Frontend..."
cd frontend
npm start > ../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..

# Aguardar frontend estar pronto
echo "⏳ Aguardando frontend..."
sleep 8

echo
echo "🚀 ROBX Trading Bot Iniciado!"
echo "=============================="
echo "🌐 Frontend: http://localhost:3000"
echo "📊 Backend: http://localhost:8000"
echo "📚 API Docs: http://localhost:8000/docs"
echo
echo "📋 PIDs dos processos:"
echo "   Backend: $BACKEND_PID"
echo "   Frontend: $FRONTEND_PID"
echo
echo "🛑 Para parar:"
echo "   kill $BACKEND_PID $FRONTEND_PID"
echo "   ou use: ./stop-all.sh"
echo
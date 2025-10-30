#!/bin/bash

echo "🚀 Iniciando ROBX Trading Bot Completo..."
echo

# Verificar se está no diretório correto
if [ ! -f "backend/main.py" ] || [ ! -f "frontend/package.json" ]; then
    echo "❌ Arquivos do projeto não encontrados. Execute a partir do diretório raiz do projeto."
    exit 1
fi

# Verificar se o setup foi executado
if [ ! -d "venv" ] || [ ! -d "frontend/node_modules" ]; then
    echo "❌ Dependências não instaladas. Execute ./setup.sh primeiro."
    exit 1
fi

echo "✅ Verificações concluídas"
echo

# Função para parar processos em background
cleanup() {
    echo
    echo "🛑 Parando servidores..."
    kill $BACKEND_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    echo "✅ Servidores parados"
    exit 0
}

# Configurar trap para cleanup
trap cleanup SIGINT SIGTERM

# Iniciar Backend em background
echo "🔧 Iniciando Backend..."
./run-backend.sh &
BACKEND_PID=$!

# Aguardar alguns segundos para o backend inicializar
sleep 5

# Verificar se o backend está rodando
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo "❌ Falha ao iniciar o backend"
    exit 1
fi

echo "✅ Backend iniciado (PID: $BACKEND_PID)"

# Iniciar Frontend em background
echo "🎨 Iniciando Frontend..."
./run-frontend.sh &
FRONTEND_PID=$!

# Aguardar alguns segundos para o frontend inicializar
sleep 5

# Verificar se o frontend está rodando
if ! kill -0 $FRONTEND_PID 2>/dev/null; then
    echo "❌ Falha ao iniciar o frontend"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

echo "✅ Frontend iniciado (PID: $FRONTEND_PID)"
echo
echo "🎉 ROBX Trading Bot está rodando!"
echo "📊 Backend API: http://localhost:8000"
echo "🌐 Frontend Web: http://localhost:3000"
echo "📚 API Docs: http://localhost:8000/docs"
echo
echo "Pressione Ctrl+C para parar todos os serviços"
echo

# Aguardar indefinidamente até receber sinal de parada
wait
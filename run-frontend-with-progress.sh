#!/bin/bash

echo "🎨 Frontend ROBX com Monitor de Progresso"
echo "========================================"
echo

# Verificar se está no diretório correto
if [ ! -f "frontend/package.json" ]; then
    echo "❌ Execute a partir do diretório raiz do projeto."
    exit 1
fi

# Definir arquivo de log
LOG_FILE="frontend-progress.log"
rm -f $LOG_FILE

echo "📋 Informações importantes:"
echo "=========================="
echo "⏳ Primeira execução: 2-5 minutos é normal"
echo "📊 'Starting the development server...' = carregando dependências"
echo "🔄 'Compiling...' = compilando código React"
echo "✅ 'Compiled successfully!' = pronto para uso"
echo

# Navegar para o diretório frontend
cd frontend

# Configurar variáveis de ambiente
export REACT_APP_API_URL=http://localhost:8000
export REACT_APP_WS_URL=ws://localhost:8000
export DANGEROUSLY_DISABLE_HOST_CHECK=true
export WDS_SOCKET_HOST=localhost
export WDS_SOCKET_PORT=3000
export SKIP_PREFLIGHT_CHECK=true

echo "🚀 Iniciando servidor React..."
echo "📝 Log: ../$LOG_FILE"
echo

# Função para monitorar progresso
monitor_progress() {
    sleep 5
    local last_line=""
    
    while true; do
        if [ -f "../$LOG_FILE" ]; then
            # Pegar última linha do log
            current_line=$(tail -n 1 "../$LOG_FILE" 2>/dev/null)
            
            if [ "$current_line" != "$last_line" ] && [ ! -z "$current_line" ]; then
                echo "📊 Status: $current_line"
                last_line="$current_line"
                
                # Verificar se compilou com sucesso
                if echo "$current_line" | grep -q "Compiled successfully"; then
                    echo "🎉 Frontend carregado com sucesso!"
                    echo "🌐 Acesse: http://localhost:3000"
                    break
                fi
                
                # Verificar se há erro
                if echo "$current_line" | grep -qi "failed\|error"; then
                    echo "❌ Erro detectado: $current_line"
                fi
            fi
        fi
        
        sleep 3
    done
}

# Iniciar monitor em background
monitor_progress &
MONITOR_PID=$!

# Cleanup function
cleanup() {
    echo
    echo "🛑 Parando frontend..."
    kill $MONITOR_PID 2>/dev/null
    exit 0
}

trap cleanup SIGINT SIGTERM

# Executar frontend com log
echo "🔧 Método 1: Usando CRACO..."
if npm run start > "../$LOG_FILE" 2>&1; then
    echo "✅ Frontend executado com sucesso"
else
    echo "⚠️  CRACO falhou, verificando log..."
    echo "📋 Últimas linhas do log:"
    tail -n 5 "../$LOG_FILE"
fi

# Aguardar
wait
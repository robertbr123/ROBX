#!/bin/bash

echo "🎨 Monitor do Frontend ROBX"
echo "=========================="
echo

cd frontend

echo "🔍 Status atual:"
echo "==============="

# Verificar se o processo está rodando
if pgrep -f "react-scripts\|craco" > /dev/null; then
    echo "✅ Processo frontend detectado"
else
    echo "❌ Nenhum processo frontend detectado"
fi

# Verificar se a porta 3000 está ocupada
if command -v netstat &> /dev/null; then
    if netstat -tuln 2>/dev/null | grep -q ":3000"; then
        echo "✅ Porta 3000 está ocupada (servidor rodando)"
    else
        echo "⏳ Porta 3000 livre (ainda carregando)"
    fi
else
    echo "ℹ️  netstat não disponível"
fi

echo
echo "⏳ Testando conectividade com o frontend..."
echo "=========================================="

# Função para testar conectividade
test_frontend() {
    local attempt=1
    local max_attempts=30
    local wait_time=2
    
    while [ $attempt -le $max_attempts ]; do
        echo "🔄 Tentativa $attempt/$max_attempts..."
        
        if curl -s --connect-timeout 3 http://localhost:3000 >/dev/null 2>&1; then
            echo "🎉 Frontend respondendo!"
            echo "🌐 Acesse: http://localhost:3000"
            return 0
        elif [ $attempt -eq $max_attempts ]; then
            echo "⏰ Timeout após $max_attempts tentativas"
            return 1
        else
            echo "⏳ Aguardando ${wait_time}s..."
            sleep $wait_time
            
            # Aumentar tempo de espera gradualmente
            if [ $attempt -gt 10 ]; then
                wait_time=5
            fi
        fi
        
        attempt=$((attempt + 1))
    done
}

# Executar teste
if test_frontend; then
    echo
    echo "✅ Frontend carregado com sucesso!"
    echo "📊 Status completo:"
    echo "   - Backend: http://localhost:8000"
    echo "   - Frontend: http://localhost:3000"
    echo "   - API Docs: http://localhost:8000/docs"
else
    echo
    echo "⚠️  Frontend ainda carregando ou com problemas"
    echo
    echo "💡 Possíveis causas:"
    echo "   1. Primeira execução (pode demorar 2-5 minutos)"
    echo "   2. Dependências sendo compiladas"
    echo "   3. Problemas de configuração"
    echo
    echo "🔧 Comandos úteis:"
    echo "   tail -f ../frontend.log    # Ver logs detalhados"
    echo "   ../stop-all.sh            # Parar e reiniciar"
    echo "   ../fix-frontend.sh        # Corrigir problemas"
fi

echo
echo "📝 Para monitorar continuamente:"
echo "   watch -n 2 'curl -s http://localhost:3000 >/dev/null && echo \"✅ OK\" || echo \"⏳ Carregando\"'"
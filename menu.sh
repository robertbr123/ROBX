#!/bin/bash

echo "🤖 ROBX Trading Bot - Menu Principal"
echo "===================================="
echo

# Verificar se está no diretório correto
if [ ! -f "backend/main.py" ] || [ ! -f "frontend/package.json" ]; then
    echo "❌ Execute este script a partir do diretório raiz do projeto ROBX"
    exit 1
fi

# Função para mostrar status dos serviços
show_status() {
    echo "📊 Status dos Serviços:"
    echo "======================"
    
    # Verificar backend
    if curl -s http://localhost:8000/health &>/dev/null; then
        echo "✅ Backend: Rodando (http://localhost:8000)"
    else
        echo "❌ Backend: Parado"
    fi
    
    # Verificar frontend
    if curl -s http://localhost:3000 &>/dev/null; then
        echo "✅ Frontend: Rodando (http://localhost:3000)"
    else
        echo "❌ Frontend: Parado"
    fi
    
    echo
}

# Mostrar status atual
show_status

# Menu de opções
while true; do
    echo "Escolha uma opção:"
    echo "1) 🚀 Executar Setup Completo (./setup.sh)"
    echo "2) 🔧 Iniciar Backend (./run-backend.sh)"
    echo "3) 🎨 Iniciar Frontend (./run-frontend.sh)"
    echo "4) 🎨 Iniciar Frontend com Progresso (./run-frontend-with-progress.sh)"
    echo "5) 🎨 Iniciar Frontend Sem Warnings (./run-frontend-clean.sh)"
    echo "6) 🚀 Iniciar Ambos - Completo (./run-all.sh)"
    echo "7) ⚡ Iniciar Ambos - Rápido (./quick-start.sh)"
    echo "8) 🛑 Parar Todos os Serviços (./stop-all.sh)"
    echo "9) 🔍 Diagnóstico (./troubleshoot.sh)"
    echo "c) 🎨 Corrigir Frontend (./fix-frontend.sh)"
    echo "s) 📊 Mostrar Status"
    echo "m) 📈 Monitorar Frontend"
    echo "d) 📚 Abrir Documentação da API"
    echo "f) 🔍 Diagnóstico Frontend"
    echo "0) ❌ Sair"
    echo
    
    read -p "Digite sua escolha (0-9, c, s, m, d, f): " choice
    
    case $choice in
        1)
            echo "🔧 Executando setup..."
            ./setup.sh
            ;;
        2)
            echo "🔧 Iniciando backend..."
            ./run-backend.sh
            ;;
        3)
            echo "🎨 Iniciando frontend..."
            ./run-frontend.sh
            ;;
        4)
            echo "🎨 Iniciando frontend com monitor de progresso..."
            ./run-frontend-with-progress.sh
            ;;
        5)
            echo "🎨 Iniciando frontend sem warnings..."
            ./run-frontend-clean.sh
            ;;
        6)
            echo "🚀 Iniciando sistema completo..."
            ./run-all.sh
            ;;
        7)
            echo "⚡ Início rápido..."
            ./quick-start.sh
            ;;
        8)
            echo "🛑 Parando serviços..."
            ./stop-all.sh
            ;;
        9)
            echo "🔍 Executando diagnóstico..."
            ./troubleshoot.sh
            ;;
        c|C)
            echo "🎨 Corrigindo frontend..."
            ./fix-frontend.sh
            ;;
        s|S)
            show_status
            ;;
        m|M)
            echo "📈 Monitorando frontend..."
            ./monitor-frontend.sh
            ;;
        d|D)
            echo "📚 Abrindo documentação..."
            echo "🌐 Acesse: http://localhost:8000/docs"
            if command -v xdg-open &> /dev/null; then
                xdg-open http://localhost:8000/docs &
            elif command -v open &> /dev/null; then
                open http://localhost:8000/docs &
            else
                echo "💡 Abra manualmente no navegador: http://localhost:8000/docs"
            fi
            ;;
        f|F)
            echo "🔍 Diagnóstico do frontend..."
            ./frontend-diagnosis.sh
            ;;
        0)
            echo "👋 Saindo..."
            exit 0
            ;;
        *)
            echo "❌ Opção inválida. Use: 0-9, c (corrigir), s (status), m (monitor), d (docs), f (diagnóstico)"
            ;;
    esac
    
    echo
    echo "Pressione Enter para continuar..."
    read
    echo
done
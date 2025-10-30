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
    echo "4) 🚀 Iniciar Ambos - Completo (./run-all.sh)"
    echo "5) ⚡ Iniciar Ambos - Rápido (./quick-start.sh)"
    echo "6) 🛑 Parar Todos os Serviços (./stop-all.sh)"
    echo "7) 🔍 Diagnóstico (./troubleshoot.sh)"
    echo "8) 🎨 Corrigir Frontend (./fix-frontend.sh)"
    echo "9) 📊 Mostrar Status"
    echo "d) 📚 Abrir Documentação da API"
    echo "f) 🔍 Diagnóstico Frontend"
    echo "0) ❌ Sair"
    echo
    
    read -p "Digite sua escolha (0-9, d, f): " choice
    
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
            echo "🚀 Iniciando sistema completo..."
            ./run-all.sh
            ;;
        5)
            echo "⚡ Início rápido..."
            ./quick-start.sh
            ;;
        6)
            echo "🛑 Parando serviços..."
            ./stop-all.sh
            ;;
        7)
            echo "🔍 Executando diagnóstico..."
            ./troubleshoot.sh
            ;;
        8)
            echo "🎨 Corrigindo frontend..."
            ./fix-frontend.sh
            ;;
        9)
            show_status
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
            echo "❌ Opção inválida. Digite um número de 0 a 9, ou 'd' para docs, 'f' para diagnóstico frontend."
            ;;
    esac
    
    echo
    echo "Pressione Enter para continuar..."
    read
    echo
done
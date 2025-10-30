#!/bin/bash

echo "🗑️  APAGANDO TUDO - Recomeçando do Zero"
echo "======================================"
echo

# Confirmar antes de apagar
read -p "🚨 ATENÇÃO: Isso vai apagar TUDO. Tem certeza? (digite 'SIM' para confirmar): " confirm

if [ "$confirm" != "SIM" ]; then
    echo "❌ Operação cancelada"
    exit 1
fi

echo "🗑️  Removendo frontend problemático..."
rm -rf frontend/

echo "🗑️  Removendo backend complexo..."
rm -rf backend/

echo "🗑️  Removendo scripts complicados..."
rm -f *.sh
rm -f *.md

echo "🗑️  Removendo dependências..."
rm -rf venv/
rm -f requirements.txt

echo "✅ Sistema antigo removido!"
echo
echo "🚀 Agora vou criar algo SIMPLES que funciona!"
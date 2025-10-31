#!/usr/bin/env bash
set -euo pipefail

# Bootstrap: cria venv (se não existir) e instala dependências
# Uso: ./scripts/bootstrap.sh [python_bin]
# Ex.: ./scripts/bootstrap.sh python3.12

# Descobre o diretório do projeto (raiz)
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$PROJECT_ROOT"

PY_BIN="${1:-python3}"

if [ ! -d ".venv" ]; then
  echo "[robx] criando .venv com ${PY_BIN}..."
  "${PY_BIN}" -m venv .venv
fi

# shellcheck disable=SC1091
source .venv/bin/activate

# Garante que o Python enxergue o pacote 'robx' da raiz do projeto
export PYTHONPATH="${PROJECT_ROOT}${PYTHONPATH:+:${PYTHONPATH}}"

python -m pip install --upgrade pip
pip install -r requirements.txt

echo "[robx] ambiente pronto. ative com: source .venv/bin/activate"

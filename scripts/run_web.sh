#!/usr/bin/env bash
set -euo pipefail

# Inicia o servidor web do ROBX
# Uso: ./scripts/run_web.sh [--config config.yaml] [--host 0.0.0.0] [--port 8000] [-v|-vv]

# Descobre o diretório do projeto (raiz) e garante execução dali
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$PROJECT_ROOT"

# Ativa venv se existir
if [ -d ".venv" ]; then
  # shellcheck disable=SC1091
  source .venv/bin/activate
fi

# Garante que o Python enxergue o pacote 'robx'
export PYTHONPATH="${PROJECT_ROOT}${PYTHONPATH:+:${PYTHONPATH}}"

exec python -m robx.web_server "$@"

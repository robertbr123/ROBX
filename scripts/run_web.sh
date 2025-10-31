#!/usr/bin/env bash
set -euo pipefail

# Inicia o servidor web do ROBX
# Uso: ./scripts/run_web.sh [--config config.yaml] [--host 0.0.0.0] [--port 8000] [-v|-vv]

# Ativa venv se existir
if [ -d ".venv" ]; then
  # shellcheck disable=SC1091
  source .venv/bin/activate
fi

exec python -m robx.web_server "$@"

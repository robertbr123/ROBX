#!/usr/bin/env bash
set -euo pipefail

# Executa o engine uma vez pela CLI
# Uso: ./scripts/run_cli.sh [--config config.yaml] [--once] [-v|-vv]

if [ -d ".venv" ]; then
  # shellcheck disable=SC1091
  source .venv/bin/activate
fi

exec python -m robx.cli "$@"

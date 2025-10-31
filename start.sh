#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
FRONTEND_DIR="$ROOT_DIR/frontend"
BACKEND_VENV="$BACKEND_DIR/.venv"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

log() {
  printf "[ROBX] %s\n" "$1"
}

ensure_python() {
  if command_exists python3; then
    echo "python3"
  elif command_exists python; then
    echo "python"
  else
    log "Python 3 não encontrado. Instale e tente novamente."
    exit 1
  fi
}

setup_backend() {
  local python_bin
  python_bin="$(ensure_python)"

  if [ ! -d "$BACKEND_VENV" ]; then
    log "Criando ambiente virtual do backend..."
    "$python_bin" -m venv "$BACKEND_VENV"
  fi

  log "Instalando dependências do backend..."
  "$BACKEND_VENV/bin/pip" install --upgrade pip >/dev/null
  (cd "$BACKEND_DIR" && "$BACKEND_VENV/bin/pip" install ".[all]")

  if [ ! -f "$BACKEND_DIR/.env" ]; then
    log "Arquivo backend/.env não encontrado. Copiando .env.example..."
    cp "$BACKEND_DIR/.env.example" "$BACKEND_DIR/.env"
    log "Atualize backend/.env com suas credenciais antes de iniciar em produção."
  fi
}

setup_frontend() {
  if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
    log "Instalando dependências do frontend..."
    (cd "$FRONTEND_DIR" && npm install)
  fi
}

start_backend() {
  log "Iniciando backend em http://localhost:8000 ..."
  (
    cd "$BACKEND_DIR"
    source "$BACKEND_VENV/bin/activate"
    uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
  ) &
  BACKEND_PID=$!
}

start_frontend() {
  log "Iniciando frontend em http://localhost:5173 ..."
  (
    cd "$FRONTEND_DIR"
    npm run dev -- --host 0.0.0.0 --port 5173
  ) &
  FRONTEND_PID=$!
}

shutdown() {
  log "Encerrando serviços..."
  kill "$BACKEND_PID" "$FRONTEND_PID" 2>/dev/null || true
  wait "$BACKEND_PID" "$FRONTEND_PID" 2>/dev/null || true
  log "Finalizado."
}

main() {
  setup_backend
  setup_frontend

  start_backend
  start_frontend

  trap shutdown INT TERM
  log "Serviços em execução. Pressione Ctrl+C para parar."
  wait "$BACKEND_PID" "$FRONTEND_PID"
}

main "$@"

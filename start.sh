#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
FRONTEND_DIR="$ROOT_DIR/frontend"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

log() {
  printf "[ROBX] %s\n" "$1"
}

ensure_go() {
  if ! command_exists go; then
    log "Go não encontrado. Instale Go 1.22+ e tente novamente."
    exit 1
  fi
}

ensure_node() {
  if ! command_exists npm; then
    log "npm não encontrado. Instale Node.js 18+ e tente novamente."
    exit 1
  fi
}

setup_backend() {
  ensure_go

  log "Baixando dependências do backend (Go modules)..."
  (cd "$BACKEND_DIR" && go mod download >/dev/null)

  if [ ! -f "$BACKEND_DIR/.env" ]; then
    log "Arquivo backend/.env não encontrado. Copiando .env.example..."
    cp "$BACKEND_DIR/.env.example" "$BACKEND_DIR/.env"
    log "Atualize backend/.env com suas credenciais antes de iniciar em produção."
  fi
}

setup_frontend() {
  ensure_node
  if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
    log "Instalando dependências do frontend..."
    (cd "$FRONTEND_DIR" && npm install)
  fi
}

start_backend() {
  log "Iniciando backend Go..."
  (
    cd "$BACKEND_DIR"
    go run ./main.go
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

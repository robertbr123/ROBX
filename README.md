# ROBX Signals Platform

Plataforma completa para geração e acompanhamento de sinais de negociação voltados para ativos da B3, mini índice e mini dólar. Inclui backend em FastAPI e frontend em React (Vite) com foco principal em execução Linux, mas compatível com Windows.

## Visão geral

- **Backend FastAPI** com autenticação JWT, geração dinâmica de sinais e histórico.
- **Frontend React + Mantine** com painel responsivo, login e visualização dos indicadores.
- **Motor de sinais** baseado em indicadores técnicos (médias móveis, RSI, volume e volatilidade) com pontuação de confiança.
- **Integração com dados de mercado** via Yahoo Finance (`yfinance`).

## Estrutura

```
backend/   # API FastAPI
frontend/  # Aplicação React (Vite)
```

## Pré-requisitos

- Python 3.10+
- Node.js 18+

## Configuração rápida

### Backend

```bash
cd backend
python -m venv .venv
# Linux/macOS
source .venv/bin/activate
# Windows PowerShell
.\.venv\Scripts\Activate.ps1
pip install .[all]
cp .env.example .env
# Defina ROBX_SECRET_KEY, ROBX_ADMIN_EMAIL e ROBX_ADMIN_PASSWORD na sua .env
uvicorn app.main:app --reload
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```

O frontend espera que a API esteja disponível em `http://localhost:8000`. Ajuste `VITE_API_URL` criando um arquivo `.env` na pasta `frontend` se necessário.

### Docker (opcional)

```bash
docker compose up --build
```

O serviço `frontend` ficará em `http://localhost:5173` e a API em `http://localhost:8000`.

## Scripts úteis

- `npm run build` (frontend): build produção.
- `npm run lint` (frontend): lint do código React.
- `pytest` (backend): suite de testes.

## Deploy

- **Linux**: recomendável usar `uvicorn` ou `gunicorn` com `systemd` para o backend e `npm run build` + `serve`/Nginx para o frontend.
- **Windows**: utilize `pip install .[all]` e `uvicorn`, e `npm run dev`/`npm run build` para o frontend.

## Observações

- O motor de sinal utiliza heurísticas simplificadas e pode ser aprimorado com indicadores adicionais.
- Configurações de ativos e credenciais padrão (admin) podem ser definidas via `.env` (veja `backend/.env.example`).

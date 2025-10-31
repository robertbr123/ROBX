# ROBX

Painel Administrativo de Sinais com opção de dados reais via API local.

## Estrutura

- `painel.html` — Dashboard com gráfico (Chart.js), sinal COMPRA/VENDA e histórico.
- `server/` — API Node.js que fornece preços e séries (Yahoo Finance e HG Brasil opcional).

## Rodando a API (Windows / PowerShell)

1. Abra o terminal na pasta `server` e instale as dependências:

```powershell
cd .\server
npm install
```

2. (Opcional) Configure a chave do HG Brasil (se for usar):

```powershell
Copy-Item .env.example .env
# edite .env e coloque sua HG_KEY
```

3. Inicie a API:

```powershell
npm run start
```

Você deverá ver:

```
ROBX API running on http://localhost:3000
```

## Usando o painel

1. Abra `painel.html` no navegador (duplo clique ou:

```powershell
start ..\painel.html
```

2. No topo, selecione:
   - Intervalo: 1m, 5m, 15m
   - Provedor: **Servidor** (recomendado) ou Simulado / HG Brasil / Yahoo
   - Símbolo: ex. `AAPL` (EUA) ou `PETR4` (Brasil)

3. Clique em "Aplicar".

- Para símbolos da B3, a API adiciona automaticamente `.SA` (por ex. `PETR4` -> `PETR4.SA`).
- Se a API não responder, o painel mantém dados simulados como fallback.

## Endpoints

- `GET /api/health` — status da API
- `GET /api/quote?symbol=AAPL` — último preço (Yahoo)
- `GET /api/series?symbol=AAPL&interval=1m&range=1d` — série intraday (Yahoo)
- `GET /api/hg/quote?symbol=PETR4` — preço via HG Brasil (requer HG_KEY)

## Observações

- Yahoo Finance pode rate‑limitar. Em caso de falhas, o painel volta para simulado.
- Para produção, considere cache/limites e segurança (ocultar chaves, rate limit, logs).

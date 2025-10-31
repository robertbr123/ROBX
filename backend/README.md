# ROBX Backend

API de sinais de negociação construída com FastAPI.

## Requisitos

- Python 3.10+
- Dependências listadas em `pyproject.toml`

## Configuração rápida

```bash
python -m venv .venv
source .venv/bin/activate
pip install .[all]
cp .env.example .env
uvicorn app.main:app --reload
```

No Windows PowerShell substitua `source .venv/bin/activate` por `.\.venv\Scripts\Activate.ps1`.

## Variáveis de ambiente

| Nome | Descrição | Valor padrão |
| --- | --- | --- |
| `ROBX_DB_URL` | Caminho do banco de dados | `sqlite:///./robx.db` |
| `ROBX_SECRET_KEY` | Chave para geração de tokens JWT | obrigatório |
| `ROBX_ACCESS_TOKEN_EXPIRE_MINUTES` | Expiração do token em minutos | `60` |
| `ROBX_DEFAULT_ASSETS` | Lista separada por vírgula de ativos padrão | `PETR4.SA,VALE3.SA,BBDC4.SA` |

## Testes

```bash
pytest
```

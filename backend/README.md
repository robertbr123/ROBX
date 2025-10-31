# ROBX Backend

API de sinais construída em Go para geração de recomendações de negociação.

## Requisitos

- Go 1.19
- SQLite (utilizamos arquivo local, nenhuma configuração adicional é necessária)

## Configuração rápida

```bash
cd backend
cp .env.example .env
go mod tidy
go run ./main.go
```

> Caso utilize o script `../start.sh`, garanta que o Go 1.19 esteja instalado e no `PATH`.

## Variáveis de ambiente

| Nome | Descrição | Valor padrão |
| --- | --- | --- |
| `ROBX_DB_URL` | Caminho do banco de dados | `sqlite:///./robx.db` |
| `ROBX_SECRET_KEY` | Chave para geração de tokens JWT | obrigatório |
| `ROBX_ACCESS_TOKEN_EXPIRE_MINUTES` | Expiração do token em minutos | `120` |
| `ROBX_DEFAULT_ASSETS` | Lista separada por vírgula de ativos padrão | `PETR4.SA,VALE3.SA,BBDC4.SA` |
| `ROBX_DEFAULT_MINI_INDICE` | Código do mini índice padrão | `WIN=F` |
| `ROBX_DEFAULT_MINI_DOLAR` | Código do mini dólar padrão | `WDO=F` |
| `ROBX_ADMIN_EMAIL` | E-mail do usuário administrador inicial | `admin@robx.local` |
| `ROBX_ADMIN_PASSWORD` | Senha do usuário administrador inicial | `robx12345` |
| `ROBX_ADMIN_FULL_NAME` | Nome completo do administrador | `Administrador ROBX` |
| `ROBX_SERVER_PORT` | Porta HTTP exposta pelo servidor | `8000` |

## Testes

```bash
go test ./...
```

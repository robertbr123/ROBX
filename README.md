# ROBX - Sistema de Sinais (Ações BR, WIN, WDO)

Um sistema modular de geração de sinais de compra/venda para ativos brasileiros (ações B3) e mini-índice (WIN) e mini-dólar (WDO), com provedores de dados intercambiáveis e estratégias configuráveis.

## Recursos

- Provedores de dados:
  - Yahoo Finance (histórico OHLC e cotações)
  - HG Brasil (cotações em tempo real; histórico não suportado)
- Estratégias incluídas:
  - Cruzamento de Médias (SMA crossover)
  - RSI (sobrecompra/sobrevenda)
- Configuração via YAML (ativos, timeframe, lookback, parâmetros de estratégia)
- Projeto em Python, fácil de estender (adicione provedores e estratégias)

## Instalação

Pré-requisitos:
- Python 3.10+

Crie um ambiente virtual (opcional) e instale dependências:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

## Configuração

1. Copie `config.example.yaml` para `config.yaml` e ajuste:
   - Lista de `assets` (ex.: PETR4.SA, VALE3.SA).
   - Timeframes (ex.: 1d, 15m) e `lookback`.
   - Estratégias e parâmetros.
2. Para HG Brasil, defina a variável de ambiente com sua key:

```powershell
$env:HG_API_KEY = "SUA_CHAVE"
```

Observações:
- Ações B3 no Yahoo usam sufixo `.SA`.
- Futuros WIN/WDO mudam por vencimento (ex.: `WINZ25`), e a cobertura pelo Yahoo pode variar. Ajuste conforme necessário.

## Uso

Execute a CLI para gerar sinais uma única vez com o arquivo de exemplo:

```powershell
python -m robx.cli --config config.example.yaml --once -v
```

### Terminal web (interface web)

Você também pode iniciar um servidor web simples para executar o engine e visualizar os sinais no navegador:

```powershell
python -m robx.web_server --config config.example.yaml --host 127.0.0.1 --port 8000 -v
```

Depois, abra no navegador: http://127.0.0.1:8000

Na página, clique em "Executar agora" para gerar os sinais e ver a tabela atualizada.

Saída típica:

```
SINAIS GERADOS:
PETR4.SA   1d   sma_crossover -> BUY  conf=0.27 preço=38.12 extras={'fast': 37.80, 'slow': 36.50}
PETR4.SA   1d   rsi           -> HOLD conf=0.00 preço=38.12 extras={'rsi': 56.3}
...
```

## Estrutura do projeto

- `robx/providers/*`: provedores de dados (Yahoo, HG Brasil)
- `robx/indicators/*`: indicadores técnicos (SMA, RSI)
- `robx/signals/*`: estratégias de sinal
- `robx/engine.py`: orquestra dados + estratégias
- `robx/cli.py`: ponto de entrada por linha de comando

## Extensão

- Para adicionar um provedor, implemente `BaseProvider` e registre em `PROVIDER_FACTORY`.
- Para adicionar uma estratégia, implemente `Strategy` e registre em `STRATEGY_FACTORY`.

## Avisos Importantes

- Este projeto é educacional. Não constitui recomendação de investimento. Use por sua conta e risco.
- Exatidão e disponibilidade dos dados dependem dos provedores (Yahoo, HG Brasil). Verifique limites de API e termos de uso.

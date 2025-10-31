import os
from typing import Dict, Optional

import requests
import pandas as pd

from .base import BaseProvider, ProviderError


class HGBrasilProvider(BaseProvider):
    name = "hg_brasil"

    def __init__(self, config: Optional[Dict[str, str]] = None):
        super().__init__(config)
        # API key from config or env
        self.api_key = self.config.get("api_key") or os.getenv("HG_API_KEY", "")
        self.base_url = self.config.get("base_url", "https://api.hgbrasil.com")
        if not self.api_key:
            # We allow quote() to still try public limits; but warn via exception on history
            pass

    def get_history(self, symbol: str, interval: str = "1d", lookback: int = 200) -> pd.DataFrame:
        # HG Brasil Finance API typically provides snapshots/quotes, not full OHLC history.
        # We raise a clear error so the engine can fallback to another provider.
        raise ProviderError("HG Brasil não fornece histórico OHLC adequado. Use outro provedor (ex.: yahoo).")

    def get_quote(self, symbol: str) -> Dict[str, float]:
        # HG Brasil usa tickers B3 sem sufixo .SA (ex.: PETR4, VALE3). Para futuros WIN/WDO, cobertura pode variar.
        url = f"{self.base_url}/finance/stock_price"
        params = {"symbol": symbol, "key": self.api_key}
        try:
            r = requests.get(url, params=params, timeout=10)
            r.raise_for_status()
            data = r.json()
            results = data.get("results", {})
            quote = results.get(symbol) or next(iter(results.values()), {})
            if not quote:
                raise ProviderError(f"Sem dados para {symbol} em HG Brasil.")
            price = float(quote.get("price")) if quote.get("price") is not None else None
            if price is None:
                raise ProviderError(f"Preço ausente para {symbol} em HG Brasil.")
            out = {
                "price": price,
                "change": float(quote.get("change", 0) or 0),
                "pct_change": float(quote.get("change_percent", 0) or 0),
            }
            return out
        except requests.RequestException as e:
            raise ProviderError(f"Erro de rede HG Brasil: {e}")
        except Exception as e:
            raise ProviderError(str(e))

from typing import Dict, Optional

import pandas as pd
import yfinance as yf

from .base import BaseProvider, ProviderError


class YahooProvider(BaseProvider):
    name = "yahoo"

    _INTERVAL_MAP = {
        "1m": "1m",
        "2m": "2m",
        "5m": "5m",
        "15m": "15m",
        "30m": "30m",
        "60m": "60m",
        "90m": "90m",
        "1h": "60m",
        "1d": "1d",
        "1wk": "1wk",
        "1mo": "1mo",
    }

    def get_history(self, symbol: str, interval: str = "1d", lookback: int = 200) -> pd.DataFrame:
        yf_interval = self._INTERVAL_MAP.get(interval, "1d")
        try:
            t = yf.Ticker(symbol)
            df = t.history(period="max", interval=yf_interval)
            if df.empty:
                raise ProviderError(f"Histórico vazio para {symbol} no Yahoo.")
            # Keep last lookback rows
            if lookback and lookback > 0:
                df = df.tail(lookback)
            # Normalize columns
            df = df.rename(columns={
                "Open": "open",
                "High": "high",
                "Low": "low",
                "Close": "close",
                "Volume": "volume",
            })[["open", "high", "low", "close", "volume"]]
            return df
        except Exception as e:
            raise ProviderError(str(e))

    def get_quote(self, symbol: str) -> Dict[str, float]:
        try:
            t = yf.Ticker(symbol)
            info = getattr(t, "fast_info", None)
            if info:
                price = float(info.last_price)
                return {"price": price}
            # fallback
            hist = t.history(period="1d")
            if hist.empty:
                raise ProviderError(f"Sem cotação para {symbol} no Yahoo.")
            price = float(hist["Close"].iloc[-1])
            return {"price": price}
        except Exception as e:
            raise ProviderError(str(e))

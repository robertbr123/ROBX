from __future__ import annotations

from dataclasses import dataclass

import pandas as pd
import yfinance as yf


TIMEFRAME_CONFIG: dict[str, tuple[str, str]] = {
    "1m": ("5d", "1m"),
    "5m": ("1mo", "5m"),
    "15m": ("2mo", "15m"),
    "1h": ("6mo", "1h"),
    "1d": ("1y", "1d"),
    "1wk": ("5y", "1wk"),
    "1mo": ("10y", "1mo"),
}


@dataclass
class MarketSeries:
    symbol: str
    timeframe: str
    data: pd.DataFrame


def fetch_market_series(symbol: str, timeframe: str) -> MarketSeries:
    if timeframe not in TIMEFRAME_CONFIG:
        raise ValueError(f"Timeframe não suportado: {timeframe}")
    period, interval = TIMEFRAME_CONFIG[timeframe]
    history = yf.download(
        symbol,
        period=period,
        interval=interval,
        progress=False,
        auto_adjust=True,
        threads=False,
    )
    if history.empty:
        raise ValueError(f"Sem dados para {symbol}")
    history = history.rename(
        columns={
            "Open": "open",
            "High": "high",
            "Low": "low",
            "Close": "close",
            "Adj Close": "close",
            "Volume": "volume",
        }
    )
    history.index.name = "timestamp"
    cleaned = history[["open", "high", "low", "close", "volume"]].dropna()
    if cleaned.empty:
        raise ValueError(f"Dados insuficientes para {symbol}")
    return MarketSeries(symbol=symbol, timeframe=timeframe, data=cleaned)

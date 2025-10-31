from dataclasses import dataclass
from typing import Dict, List

import pandas as pd

from robx.indicators.indicators import sma, rsi


@dataclass
class Signal:
    symbol: str
    timeframe: str
    strategy: str
    action: str  # "buy" | "sell" | "hold"
    confidence: float
    price: float
    extras: Dict[str, float]


class Strategy:
    name: str = "base"

    def generate(self, symbol: str, timeframe: str, df: pd.DataFrame) -> Signal:
        raise NotImplementedError


class SMACrossover(Strategy):
    name = "sma_crossover"

    def __init__(self, fast: int = 9, slow: int = 21):
        self.fast = fast
        self.slow = slow

    def generate(self, symbol: str, timeframe: str, df: pd.DataFrame) -> Signal:
        closes = df["close"]
        fast_ma = sma(closes, self.fast)
        slow_ma = sma(closes, self.slow)
        action = "hold"
        confidence = 0.0
        if len(df) >= 2 and not (fast_ma.isna().iloc[-2] or slow_ma.isna().iloc[-2]):
            prev_cross = fast_ma.iloc[-2] - slow_ma.iloc[-2]
            curr_cross = fast_ma.iloc[-1] - slow_ma.iloc[-1]
            if prev_cross <= 0 and curr_cross > 0:
                action = "buy"
                confidence = min(1.0, abs(curr_cross) / max(1e-6, slow_ma.iloc[-1]))
            elif prev_cross >= 0 and curr_cross < 0:
                action = "sell"
                confidence = min(1.0, abs(curr_cross) / max(1e-6, slow_ma.iloc[-1]))
        return Signal(
            symbol=symbol,
            timeframe=timeframe,
            strategy=self.name,
            action=action,
            confidence=confidence,
            price=float(closes.iloc[-1]),
            extras={"fast": float(fast_ma.iloc[-1] if not pd.isna(fast_ma.iloc[-1]) else 0),
                    "slow": float(slow_ma.iloc[-1] if not pd.isna(slow_ma.iloc[-1]) else 0)},
        )


class RSIThreshold(Strategy):
    name = "rsi"

    def __init__(self, period: int = 14, oversold: float = 30.0, overbought: float = 70.0):
        self.period = period
        self.oversold = oversold
        self.overbought = overbought

    def generate(self, symbol: str, timeframe: str, df: pd.DataFrame) -> Signal:
        closes = df["close"]
        r = rsi(closes, self.period)
        last = r.iloc[-1]
        action = "hold"
        confidence = 0.0
        if last <= self.oversold:
            action = "buy"
            confidence = min(1.0, (self.oversold - last) / self.oversold)
        elif last >= self.overbought:
            action = "sell"
            confidence = min(1.0, (last - self.overbought) / (100 - self.overbought))
        return Signal(
            symbol=symbol,
            timeframe=timeframe,
            strategy=self.name,
            action=action,
            confidence=confidence,
            price=float(closes.iloc[-1]),
            extras={"rsi": float(last)},
        )

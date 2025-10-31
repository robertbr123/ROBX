from __future__ import annotations

import math

import pandas as pd

from ..models import Recommendation
from ..schemas import SignalParameters
from .market_data import MarketSeries


def compute_rsi(series: pd.Series, period: int) -> pd.Series:
    delta = series.diff()
    gains = delta.clip(lower=0)
    losses = -delta.clip(upper=0)
    avg_gain = gains.ewm(alpha=1 / period, min_periods=period).mean()
    avg_loss = losses.ewm(alpha=1 / period, min_periods=period).mean()
    rs = avg_gain / avg_loss.replace(0, math.nan)
    rsi = 100 - (100 / (1 + rs))
    return rsi.fillna(50)


class SignalEngine:
    def evaluate(self, market: MarketSeries, params: SignalParameters) -> tuple[Recommendation, float, str, dict[str, float]]:
        df = market.data.copy()
        df["sma_short"] = df["close"].rolling(window=params.short_window).mean()
        df["sma_long"] = df["close"].rolling(window=params.long_window).mean()
        df["rsi"] = compute_rsi(df["close"], params.rsi_period)
        df["volume_ma"] = df["volume"].rolling(window=params.volume_window).mean()
        returns = df["close"].pct_change()
        df["volatility"] = (
            returns.rolling(window=params.volatility_window).std() * math.sqrt(params.volatility_window)
        )
        latest = df.dropna().iloc[-1]
        score = 50.0

        bullish_trend = latest["sma_short"] > latest["sma_long"] and latest["close"] > latest["sma_short"]
        bearish_trend = latest["sma_short"] < latest["sma_long"] and latest["close"] < latest["sma_short"]
        if bullish_trend:
            score += 20
        elif bearish_trend:
            score -= 20

        if latest["rsi"] <= params.rsi_oversold:
            score += 15
        elif latest["rsi"] >= params.rsi_overbought:
            score -= 15

        raw_volume_ma = float(latest["volume_ma"])
        if not math.isfinite(raw_volume_ma) or raw_volume_ma <= 0:
            raw_volume_ma = float(latest["volume"])
        volume_ma = raw_volume_ma if raw_volume_ma > 0 else 1.0
        volume_ratio = float(latest["volume"]) / volume_ma
        if volume_ratio > 1.2:
            score += 5
        elif volume_ratio < 0.8:
            score -= 5

        volatility_value = float(latest["volatility"])
        if math.isfinite(volatility_value) and volatility_value > 0:
            if volatility_value < 0.02:
                score += 5
            elif volatility_value > 0.06:
                score -= 5
        else:
            volatility_value = 0.0

        score = max(0.0, min(100.0, score))
        if score >= 60:
            recommendation = Recommendation.BUY
        elif score <= 40:
            recommendation = Recommendation.SELL
        else:
            recommendation = Recommendation.HOLD

        confidence = round(score / 100, 2)
        summary_parts = []
        if recommendation == Recommendation.BUY:
            summary_parts.append("Força compradora dominando")
        elif recommendation == Recommendation.SELL:
            summary_parts.append("Pressão vendedora dominante")
        else:
            summary_parts.append("Cenário neutro, aguarde confirmação")
        summary_parts.append(f"RSI em {latest['rsi']:.1f}")
        summary_parts.append(f"Médias {int(params.short_window)}/{int(params.long_window)} alinhadas")
        summary = "; ".join(summary_parts)

        indicators = {
            "close": round(float(latest["close"]), 4),
            "sma_short": round(float(latest["sma_short"]), 4),
            "sma_long": round(float(latest["sma_long"]), 4),
            "rsi": round(float(latest["rsi"]), 2),
            "volume": round(float(latest["volume"]), 2),
            "volume_ma": round(float(volume_ma), 2),
            "volume_ratio": round(float(volume_ratio), 2),
            "volatility": round(volatility_value, 4),
        }
        return recommendation, confidence, summary, indicators

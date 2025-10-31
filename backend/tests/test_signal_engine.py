import pandas as pd

from app.schemas import SignalParameters
from app.services.market_data import MarketSeries
from app.services.signal_engine import SignalEngine


def test_signal_engine_returns_recommendation():
    dates = pd.date_range(end="2024-01-01", periods=120, freq="D")
    prices = pd.Series([100 + i * 0.5 for i in range(120)], index=dates)
    highs = prices * 1.01
    lows = prices * 0.99
    volumes = pd.Series([1_000_000 + i * 1_000 for i in range(120)], index=dates)
    df = pd.DataFrame({
        "open": prices.values,
        "high": highs.values,
        "low": lows.values,
        "close": prices.values,
        "volume": volumes.values,
    }, index=dates)
    market = MarketSeries(symbol="TEST", timeframe="1d", data=df)
    engine = SignalEngine()
    params = SignalParameters()
    recommendation, confidence, summary, indicators = engine.evaluate(market, params)
    assert recommendation.value in {"buy", "sell", "hold"}
    assert 0 <= confidence <= 1
    assert summary
    assert "close" in indicators

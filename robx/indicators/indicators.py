import numpy as np
import pandas as pd


def sma(series: pd.Series, period: int) -> pd.Series:
    return series.rolling(window=period, min_periods=period).mean()


def rsi(series: pd.Series, period: int = 14) -> pd.Series:
    delta = series.diff()
    up = np.where(delta > 0, delta, 0.0)
    down = np.where(delta < 0, -delta, 0.0)

    roll_up = pd.Series(up, index=series.index).rolling(period).mean()
    roll_down = pd.Series(down, index=series.index).rolling(period).mean()

    rs = roll_up / (roll_down.replace(0, np.nan))
    rsi_val = 100.0 - (100.0 / (1.0 + rs))
    return rsi_val.fillna(50.0)

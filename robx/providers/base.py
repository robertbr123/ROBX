from abc import ABC, abstractmethod
from typing import Optional, Dict
import pandas as pd


class ProviderError(Exception):
    pass


class BaseProvider(ABC):
    name: str = "base"

    def __init__(self, config: Optional[Dict[str, str]] = None):
        self.config = config or {}

    @abstractmethod
    def get_history(self, symbol: str, interval: str = "1d", lookback: int = 200) -> pd.DataFrame:
        """
        Returns OHLCV history as a DataFrame with index as datetime and columns:
        [open, high, low, close, volume]. Raises ProviderError on failure.
        """
        raise NotImplementedError

    def get_quote(self, symbol: str) -> Dict[str, float]:
        """
        Returns a dict with at least {"price": float}. Optional fields: bid, ask, change, pct_change.
        Raise ProviderError on failure.
        """
        raise NotImplementedError

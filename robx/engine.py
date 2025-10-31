import logging
from typing import Dict, List, Optional, Tuple

import pandas as pd

from robx.config import AppConfig, Asset, StrategyConfig
from robx.providers.base import BaseProvider, ProviderError
from robx.providers.yahoo import YahooProvider
from robx.providers.hg_brasil import HGBrasilProvider
from robx.signals.strategies import Strategy, SMACrossover, RSIThreshold, Signal


log = logging.getLogger(__name__)


PROVIDER_FACTORY = {
    "yahoo": YahooProvider,
    "hg_brasil": HGBrasilProvider,
}

STRATEGY_FACTORY = {
    "sma_crossover": SMACrossover,
    "rsi": RSIThreshold,
}


def build_provider(name: Optional[str], cfg: Dict[str, Dict[str, str]]) -> BaseProvider:
    name = name or "yahoo"
    prov_cls = PROVIDER_FACTORY.get(name)
    if not prov_cls:
        raise ValueError(f"Provedor desconhecido: {name}")
    return prov_cls(cfg.get(name, {}))


def build_strategy(scfg: StrategyConfig) -> Strategy:
    strat_cls = STRATEGY_FACTORY.get(scfg.name)
    if not strat_cls:
        raise ValueError(f"Estratégia desconhecida: {scfg.name}")
    return strat_cls(**(scfg.params or {}))


class Engine:
    def __init__(self, app_config: AppConfig):
        self.cfg = app_config
        self.providers_cache: Dict[str, BaseProvider] = {}
        self.strategies: List[Strategy] = [build_strategy(s) for s in self.cfg.strategies]

    def _get_provider(self, preferred: Optional[str]) -> Tuple[str, BaseProvider, Optional[BaseProvider]]:
        # Load preferred provider and also a fallback (Yahoo default)
        primary_name = preferred or "yahoo"
        if primary_name not in self.providers_cache:
            self.providers_cache[primary_name] = build_provider(primary_name, self.cfg.providers)
        primary = self.providers_cache[primary_name]

        fallback_name = "yahoo" if primary_name != "yahoo" else None
        fallback = None
        if fallback_name:
            if fallback_name not in self.providers_cache:
                self.providers_cache[fallback_name] = build_provider(fallback_name, self.cfg.providers)
            fallback = self.providers_cache[fallback_name]
        return primary_name, primary, fallback

    def fetch_history(self, asset: Asset) -> Optional[pd.DataFrame]:
        _, primary, fallback = self._get_provider(asset.provider)
        try:
            return primary.get_history(asset.symbol, asset.timeframe, asset.lookback)
        except ProviderError as e:
            log.warning(f"Falha histórico {asset.symbol} via {primary.name}: {e}")
            if fallback:
                try:
                    return fallback.get_history(asset.symbol, asset.timeframe, asset.lookback)
                except ProviderError as e2:
                    log.error(f"Fallback histórico {asset.symbol} via {fallback.name} também falhou: {e2}")
                    return None
            return None

    def fetch_quote(self, asset: Asset) -> Optional[Dict[str, float]]:
        _, primary, fallback = self._get_provider(asset.provider)
        try:
            return primary.get_quote(asset.symbol)
        except ProviderError as e:
            log.warning(f"Falha cotação {asset.symbol} via {primary.name}: {e}")
            if fallback:
                try:
                    return fallback.get_quote(asset.symbol)
                except ProviderError as e2:
                    log.error(f"Fallback cotação {asset.symbol} via {fallback.name} também falhou: {e2}")
                    return None
            return None

    def run_once(self) -> List[Signal]:
        signals: List[Signal] = []
        for a in self.cfg.assets:
            df = self.fetch_history(a)
            if df is None or df.empty:
                log.error(f"Sem dados históricos para {a.symbol} ({a.timeframe}). Pulando…")
                continue
            for strat in self.strategies:
                try:
                    sig = strat.generate(a.symbol, a.timeframe, df)
                    signals.append(sig)
                except Exception as e:
                    log.exception(f"Erro gerando sinal {strat.name} para {a.symbol}: {e}")
        return signals

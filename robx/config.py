import os
from dataclasses import dataclass, field
from typing import List, Dict, Optional

import yaml


@dataclass
class Asset:
    symbol: str
    provider: Optional[str] = None  # e.g., "yahoo" or "hg_brasil"
    timeframe: str = "1d"  # e.g., "1d", "1h", "15m"
    lookback: int = 200  # number of periods to load


@dataclass
class StrategyConfig:
    name: str  # e.g., "sma_crossover" or "rsi"
    params: Dict[str, float] = field(default_factory=dict)


@dataclass
class AppConfig:
    assets: List[Asset]
    strategies: List[StrategyConfig]
    scheduler: Dict[str, str] = field(default_factory=lambda: {"cron": "*/5 * * * *"})
    providers: Dict[str, Dict[str, str]] = field(default_factory=dict)

    @staticmethod
    def from_yaml(path: str) -> "AppConfig":
        with open(path, "r", encoding="utf-8") as f:
            cfg = yaml.safe_load(f) or {}

        assets = [Asset(**a) for a in cfg.get("assets", [])]
        strategies = [StrategyConfig(**s) for s in cfg.get("strategies", [])]
        providers = cfg.get("providers", {})

        # Allow env var interpolation like ${HG_API_KEY}
        def interpolate_env(d: Dict[str, str]) -> Dict[str, str]:
            out = {}
            for k, v in d.items():
                if isinstance(v, str) and v.startswith("${") and v.endswith("}"):
                    out[k] = os.getenv(v[2:-1], "")
                else:
                    out[k] = v
            return out

        for name, prov_cfg in list(providers.items()):
            providers[name] = interpolate_env(prov_cfg)

        return AppConfig(
            assets=assets,
            strategies=strategies,
            scheduler=cfg.get("scheduler", {"cron": "*/5 * * * *"}),
            providers=providers,
        )

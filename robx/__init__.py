"""
ROBX - Sistema de Sinais para Ações Brasileiras, Mini-Índice (WIN) e Mini-Dólar (WDO).

Arquitetura modular com provedores de dados, indicadores, estratégias e um engine para
orquestração. Veja README para detalhes.
"""
from importlib.metadata import version, PackageNotFoundError

__all__ = [
    "__version__",
]

try:
    __version__ = version("robx")
except PackageNotFoundError:
    __version__ = "0.1.0"

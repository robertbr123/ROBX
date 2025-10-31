import argparse
import logging
import os
import sys
from typing import Optional
import time

from robx.config import AppConfig
from robx.engine import Engine


def configure_logging(verbosity: int) -> None:
    level = logging.WARNING
    if verbosity == 1:
        level = logging.INFO
    elif verbosity >= 2:
        level = logging.DEBUG
    logging.basicConfig(
        level=level,
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    )


def main(argv: Optional[list] = None) -> int:
    parser = argparse.ArgumentParser(description="ROBX - Sistema de Sinais (BR Ações/WIN/WDO)")
    parser.add_argument("--config", "-c", default="config.example.yaml", help="Caminho do arquivo de configuração")
    parser.add_argument("--once", action="store_true", help="Executa uma única vez e sai")
    parser.add_argument("--interval", type=int, default=300, help="Intervalo em segundos no modo contínuo (default: 300)")
    parser.add_argument("-v", action="count", default=0, help="Aumenta verbosidade (-v, -vv)")
    args = parser.parse_args(argv)

    configure_logging(args.v)

    if not os.path.exists(args.config):
        logging.error(f"Arquivo de configuração não encontrado: {args.config}")
        return 1

    app_cfg = AppConfig.from_yaml(args.config)
    engine = Engine(app_cfg)

    def run_and_print() -> None:
        signals = engine.run_once()
        if not signals:
            print("Nenhum sinal gerado.")
            return
        print("SINAIS GERADOS:")
        for s in signals:
            print(
                f"{s.symbol:<10} {s.timeframe:<4} {s.strategy:<13} -> {s.action.upper():<4} "
                f"conf={s.confidence:.2f} preço={s.price:.2f} extras={s.extras}"
            )

    if args.once:
        run_and_print()
        return 0
    else:
        print(f"Executando continuamente a cada {args.interval} segundos. Pressione Ctrl+C para parar.")
        try:
            while True:
                run_and_print()
                time.sleep(max(5, args.interval))
        except KeyboardInterrupt:
            print("Encerrado pelo usuário.")
            return 0


if __name__ == "__main__":
    raise SystemExit(main())

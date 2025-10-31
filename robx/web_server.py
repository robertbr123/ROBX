import argparse
import logging
import uvicorn

from robx.web.app import create_app


def main():
    parser = argparse.ArgumentParser(description="ROBX Web Server")
    parser.add_argument("--config", "-c", default="config.example.yaml", help="Caminho do arquivo de configuração")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8000)
    parser.add_argument("-v", action="count", default=0)
    args = parser.parse_args()

    level = logging.WARNING if args.v == 0 else (logging.INFO if args.v == 1 else logging.DEBUG)
    logging.basicConfig(level=level, format="%(asctime)s %(levelname)s %(name)s: %(message)s")

    app = create_app(config_path=args.config)
    uvicorn.run(app, host=args.host, port=args.port, log_level="info")


if __name__ == "__main__":
    main()

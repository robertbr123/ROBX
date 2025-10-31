from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel
from typing import List, Optional
import logging
from pathlib import Path

from robx.config import AppConfig
from robx.engine import Engine
from robx.signals.strategies import Signal

log = logging.getLogger(__name__)

templates_dir = Path(__file__).resolve().parent / "templates"
templates = Jinja2Templates(directory=str(templates_dir))


class RunResponse(BaseModel):
    count: int


def create_app(config_path: str = "config.example.yaml") -> FastAPI:
    app = FastAPI(title="ROBX Web", version="0.1.0")

    app.state.config_path = config_path
    # notas: evite anotação inline em atribuições para compatibilidade de análise
    app.state.engine = None
    app.state.last_signals = []

    @app.on_event("startup")
    async def _startup():
        try:
            cfg = AppConfig.from_yaml(app.state.config_path)
            app.state.engine = Engine(cfg)
            log.info("Engine inicializado com %d ativos e %d estratégias", len(cfg.assets), len(cfg.strategies))
        except Exception as e:
            log.exception("Falha ao iniciar Engine: %s", e)

    @app.get("/", response_class=HTMLResponse)
    async def index(request: Request):
        return templates.TemplateResponse("index.html", {"request": request})

    @app.get("/api/signals")
    async def get_signals():
        signals = app.state.last_signals or []
        return JSONResponse([
            {
                "symbol": s.symbol,
                "timeframe": s.timeframe,
                "strategy": s.strategy,
                "action": s.action,
                "confidence": s.confidence,
                "price": s.price,
                "extras": s.extras,
            }
            for s in signals
        ])

    @app.post("/api/run", response_model=RunResponse)
    async def run_once():
        if not app.state.engine:
            return JSONResponse({"count": 0})
        signals = app.state.engine.run_once()
        app.state.last_signals = signals
        return RunResponse(count=len(signals))

    return app

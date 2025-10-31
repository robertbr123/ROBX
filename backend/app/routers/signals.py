from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import desc, select
from sqlalchemy.orm import Session

from .. import models
from ..config import get_settings
from ..database import get_db
from ..dependencies import get_current_user
from ..schemas import (
    SignalHistoryResponse,
    SignalParameters,
    SignalRequest,
    SignalResponse,
    SignalSummary,
)
from ..services.market_data import fetch_market_series
from ..services.signal_engine import SignalEngine

router = APIRouter(prefix="/signals", tags=["signals"])
settings = get_settings()
engine = SignalEngine()


def resolve_symbol(request: SignalRequest) -> str:
    if request.symbol:
        return request.symbol
    if request.instrument_type == models.InstrumentType.MINI_INDICE:
        return settings.default_mini_indice
    if request.instrument_type == models.InstrumentType.MINI_DOLAR:
        return settings.default_mini_dolar
    return settings.default_assets[0]


@router.post("", response_model=SignalResponse)
def generate_signal(
    request: SignalRequest,
    _: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SignalResponse:
    params = request.parameters or SignalParameters()
    symbol = resolve_symbol(request)
    try:
        market_series = fetch_market_series(symbol=symbol, timeframe=request.timeframe)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc
    recommendation, confidence, summary, indicators = engine.evaluate(market_series, params)
    snapshot = models.SignalSnapshot(
        symbol=symbol,
        instrument_type=request.instrument_type,
        timeframe=request.timeframe,
        recommendation=recommendation,
        confidence=confidence,
        summary=summary,
        parameters=params.model_dump(),
        created_at=datetime.utcnow(),
    )
    db.add(snapshot)
    db.commit()
    db.refresh(snapshot)
    return SignalResponse(
        recommendation=recommendation,
        confidence=confidence,
        summary=summary,
        symbol=symbol,
        instrument_type=request.instrument_type,
        timeframe=request.timeframe,
        parameters=params,
        created_at=snapshot.created_at,
        indicators=indicators,
    )


@router.get("/history", response_model=SignalHistoryResponse)
def signal_history(
    limit: int = Query(default=20, ge=1, le=100),
    instrument: models.InstrumentType | None = None,
    _: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SignalHistoryResponse:
    stmt = select(models.SignalSnapshot).order_by(desc(models.SignalSnapshot.created_at)).limit(limit)
    if instrument:
        stmt = stmt.where(models.SignalSnapshot.instrument_type == instrument)
    snapshots = db.execute(stmt).scalars().all()
    items = [
        SignalSummary(
            recommendation=snapshot.recommendation,
            confidence=snapshot.confidence,
            summary=snapshot.summary,
            symbol=snapshot.symbol,
            instrument_type=snapshot.instrument_type,
            timeframe=snapshot.timeframe,
            parameters=SignalParameters(**snapshot.parameters),
            created_at=snapshot.created_at,
        )
        for snapshot in snapshots
    ]
    return SignalHistoryResponse(items=items)

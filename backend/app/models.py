from datetime import datetime
from enum import Enum

from sqlalchemy import Column, DateTime, Enum as SqlEnum, Float, Integer, JSON, String
from sqlalchemy.orm import Mapped, mapped_column

from .database import Base


class InstrumentType(str, Enum):
    EQUITY = "equity"
    MINI_INDICE = "mini_indice"
    MINI_DOLAR = "mini_dolar"


class Recommendation(str, Enum):
    BUY = "buy"
    SELL = "sell"
    HOLD = "hold"


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    full_name: Mapped[str] = mapped_column(String(255), nullable=False)
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)


class SignalSnapshot(Base):
    __tablename__ = "signal_snapshots"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    symbol: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    instrument_type: Mapped[InstrumentType] = mapped_column(
        SqlEnum(InstrumentType), nullable=False, index=True
    )
    timeframe: Mapped[str] = mapped_column(String(20), nullable=False)
    recommendation: Mapped[Recommendation] = mapped_column(
        SqlEnum(Recommendation), nullable=False
    )
    confidence: Mapped[float] = mapped_column(Float, nullable=False)
    summary: Mapped[str] = mapped_column(String(500), nullable=False)
    parameters: Mapped[dict] = mapped_column(JSON, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

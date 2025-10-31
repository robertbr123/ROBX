from datetime import datetime
from typing import Any

from pydantic import BaseModel, EmailStr, Field

from .models import InstrumentType, Recommendation


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class TokenPayload(BaseModel):
    sub: str
    exp: int


class UserBase(BaseModel):
    email: EmailStr
    full_name: str = Field(min_length=1, max_length=255)


class UserCreate(UserBase):
    password: str = Field(min_length=8, max_length=128)


class UserRead(UserBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class SignalParameters(BaseModel):
    short_window: int = Field(14, ge=3, le=120)
    long_window: int = Field(50, ge=10, le=240)
    rsi_period: int = Field(14, ge=2, le=60)
    rsi_overbought: int = Field(70, ge=50, le=90)
    rsi_oversold: int = Field(30, ge=10, le=50)
    volume_window: int = Field(20, ge=5, le=120)
    volatility_window: int = Field(20, ge=5, le=120)


class SignalRequest(BaseModel):
    instrument_type: InstrumentType
    symbol: str | None = None
    timeframe: str = Field(default="1d", pattern=r"^(1m|5m|15m|1h|1d|1wk|1mo)$")
    parameters: SignalParameters | None = None


class SignalSummary(BaseModel):
    recommendation: Recommendation
    confidence: float
    summary: str
    symbol: str
    instrument_type: InstrumentType
    timeframe: str
    parameters: SignalParameters
    created_at: datetime


class SignalResponse(SignalSummary):
    indicators: dict[str, Any]


class SignalHistoryResponse(BaseModel):
    items: list[SignalSummary]

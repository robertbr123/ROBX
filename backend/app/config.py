from functools import lru_cache
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "ROBX Signals API"
    secret_key: str
    access_token_expire_minutes: int = 120
    db_url: str = "sqlite:///./robx.db"
    default_assets: list[str] = Field(
        default_factory=lambda: ["PETR4.SA", "VALE3.SA", "BBDC4.SA"]
    )
    default_mini_indice: str = "WIN=F"
    default_mini_dolar: str = "WDO=F"

    model_config = SettingsConfigDict(env_file=".env", env_prefix="ROBX_")


@lru_cache
def get_settings() -> Settings:
    return Settings()

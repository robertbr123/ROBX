from functools import lru_cache

from pydantic import AliasChoices, Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "ROBX Signals API"
    secret_key: str
    access_token_expire_minutes: int = 120
    db_url: str = "sqlite:///./robx.db"
    default_assets_raw: str = Field(
        default="PETR4.SA,VALE3.SA,BBDC4.SA",
        validation_alias=AliasChoices("DEFAULT_ASSETS", "DEFAULT_ASSETS_RAW"),
    )
    default_mini_indice: str = "WIN=F"
    default_mini_dolar: str = "WDO=F"
    admin_email: str | None = None
    admin_password: str | None = None
    admin_full_name: str = "Administrador ROBX"

    model_config = SettingsConfigDict(
        env_file=".env",
        env_prefix="ROBX_",
        populate_by_name=True,
    )

    @property
    def default_assets(self) -> list[str]:
        values = [item.strip() for item in self.default_assets_raw.split(",") if item.strip()]
        return values or ["PETR4.SA", "VALE3.SA", "BBDC4.SA"]


@lru_cache
def get_settings() -> Settings:
    return Settings()

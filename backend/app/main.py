from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import models  # noqa: F401
from .config import get_settings
from .core import auth
from .database import Base, SessionLocal, engine
from .routers import auth as auth_router
from .routers import signals
from .schemas import UserCreate

settings = get_settings()
Base.metadata.create_all(bind=engine)

app = FastAPI(title=settings.app_name, version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def read_root() -> dict[str, str]:
    return {"message": "ROBX Signals API operacional"}


@app.on_event("startup")
def ensure_default_user() -> None:
    if not settings.admin_email or not settings.admin_password:
        return
    db = SessionLocal()
    try:
        user = auth.get_user_by_email(db, settings.admin_email)
        if not user:
            auth.create_user(
                db,
                UserCreate(
                    email=settings.admin_email,
                    full_name=settings.admin_full_name,
                    password=settings.admin_password,
                ),
            )
    except ValueError:
        pass
    finally:
        db.close()


app.include_router(auth_router.router)
app.include_router(signals.router)

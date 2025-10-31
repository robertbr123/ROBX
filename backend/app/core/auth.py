from sqlalchemy import select
from sqlalchemy.orm import Session

from .. import models
from ..schemas import UserCreate
from .security import get_password_hash


def get_user_by_email(db: Session, email: str) -> models.User | None:
    stmt = select(models.User).where(models.User.email == email)
    return db.execute(stmt).scalar_one_or_none()


def create_user(db: Session, user_in: UserCreate) -> models.User:
    existing = get_user_by_email(db, user_in.email)
    if existing:
        raise ValueError("Email em uso")
    user = models.User(
        email=user_in.email,
        full_name=user_in.full_name,
        hashed_password=get_password_hash(user_in.password),
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

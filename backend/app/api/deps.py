from typing import Generator, Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import User, UserRole
from app.models.artisan import ArtisanProfile
from app.services.auth_service import decode_access_token

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


def get_current_user(
    db: Session = Depends(get_db),
    token: str = Depends(oauth2_scheme)
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    payload = decode_access_token(token)
    if payload is None:
        raise credentials_exception
    user_id_str: str = payload.get("sub")
    if user_id_str is None:
        raise credentials_exception
    try:
        user_id = int(user_id_str)
    except ValueError:
        raise credentials_exception

    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise credentials_exception
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user account")
    return user


def get_current_artisan_user(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
) -> tuple[User, ArtisanProfile]:
    if current_user.role != UserRole.ARTISAN and current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Operation restricted to registered artisans"
        )
    artisan = db.query(ArtisanProfile).filter(ArtisanProfile.user_id == current_user.id).first()
    if not artisan and current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Artisan profile not found for this user account"
        )
    return current_user, artisan


def get_current_buyer_user(
    current_user: User = Depends(get_current_user)
) -> User:
    if current_user.role not in [UserRole.BUYER, UserRole.ADMIN]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Operation restricted to buyers"
        )
    return current_user


def get_current_admin_user(
    current_user: User = Depends(get_current_user)
) -> User:
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Operation requires administrator privileges"
        )
    return current_user

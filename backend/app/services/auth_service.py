import os
import hmac
import hashlib
from datetime import datetime, timedelta
from typing import Optional, Any, Union
from jose import jwt, JWTError
from app.config import settings


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifies a password against a salt$hash string or legacy hash."""
    try:
        if "$" in hashed_password:
            salt, stored_hash = hashed_password.split("$", 1)
            calculated_hash = hashlib.pbkdf2_hmac(
                "sha256",
                plain_password.encode("utf-8"),
                salt.encode("utf-8"),
                100000
            ).hex()
            return hmac.compare_digest(calculated_hash, stored_hash)
        else:
            # Fallback direct comparison for mock/testing
            return hmac.compare_digest(plain_password, hashed_password)
    except Exception:
        return False


def get_password_hash(password: str) -> str:
    """Generates a secure PBKDF2-HMAC-SHA256 password hash with random salt."""
    salt = os.urandom(16).hex()
    hashed = hashlib.pbkdf2_hmac(
        "sha256",
        password.encode("utf-8"),
        salt.encode("utf-8"),
        100000
    ).hex()
    return f"{salt}${hashed}"


def create_access_token(subject: Union[str, Any], role: str, expires_delta: Optional[timedelta] = None) -> str:
    """Creates a signed JWT access token."""
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode = {
        "exp": expire,
        "sub": str(subject),
        "role": role,
        "iat": datetime.utcnow()
    }
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


def decode_access_token(token: str) -> Optional[dict]:
    """Decodes and validates a JWT token."""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        return None

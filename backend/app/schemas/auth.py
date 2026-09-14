from typing import Optional
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field
from app.models.user import UserRole


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: int
    email: str
    role: UserRole
    full_name: str
    artisan_profile_id: Optional[int] = None


class TokenPayload(BaseModel):
    sub: Optional[str] = None
    role: Optional[str] = None


class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)
    full_name: str = Field(..., min_length=2)
    phone: Optional[str] = None
    role: UserRole = UserRole.BUYER

    # Optional fields for direct artisan registration
    craft_type: Optional[str] = None
    region: Optional[str] = None
    community_cooperative: Optional[str] = None
    heritage_story: Optional[str] = None
    bio: Optional[str] = None
    years_of_experience: Optional[int] = 1


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    id: int
    email: EmailStr
    full_name: str
    phone: Optional[str] = None
    role: UserRole
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

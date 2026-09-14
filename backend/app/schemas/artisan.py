from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field


class ArtisanProfileBase(BaseModel):
    craft_type: str = Field(..., example="Handloom Weaving")
    heritage_story: Optional[str] = Field(None, example="Generational handloom weaver preserving Khadi and Ikat techniques.")
    bio: Optional[str] = Field(None, example="Creating organic dye cotton dupattas and sarees.")
    region: str = Field(..., example="Maheshwar, Madhya Pradesh")
    community_cooperative: Optional[str] = Field(None, example="Nimar Weavers Guild")
    years_of_experience: int = Field(1, ge=0)
    avatar_url: Optional[str] = None


class ArtisanProfileCreate(ArtisanProfileBase):
    pass


class ArtisanProfileUpdate(BaseModel):
    craft_type: Optional[str] = None
    heritage_story: Optional[str] = None
    bio: Optional[str] = None
    region: Optional[str] = None
    community_cooperative: Optional[str] = None
    years_of_experience: Optional[int] = None
    avatar_url: Optional[str] = None


class ArtisanProfileResponse(ArtisanProfileBase):
    id: int
    user_id: int
    is_verified: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class ArtisanDetailResponse(ArtisanProfileResponse):
    artisan_name: str
    artisan_email: str
    artisan_phone: Optional[str] = None
    total_products: int = 0

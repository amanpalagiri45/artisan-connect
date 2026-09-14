from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field
from app.models.linkage import LinkageStatus


class LinkageCreate(BaseModel):
    artisan_id: int
    product_id: Optional[int] = None
    quantity: int = Field(1, ge=1)
    proposed_unit_price: Optional[float] = Field(None, gt=0)
    buyer_notes: str = Field(..., min_length=5, example="We run a sustainable boutique in Austin and would love to procure 25 units.")
    target_delivery_date: Optional[str] = None


class LinkageStatusUpdate(BaseModel):
    status: LinkageStatus
    artisan_notes: Optional[str] = None


class LinkageResponse(BaseModel):
    id: int
    buyer_id: int
    artisan_id: int
    product_id: Optional[int] = None
    status: LinkageStatus
    quantity: int
    proposed_unit_price: Optional[float] = None
    buyer_notes: str
    artisan_notes: Optional[str] = None
    match_score: float
    target_delivery_date: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    # Display enrichments
    buyer_name: Optional[str] = None
    buyer_email: Optional[str] = None
    artisan_name: Optional[str] = None
    artisan_craft: Optional[str] = None
    product_title: Optional[str] = None

    class Config:
        from_attributes = True


class MatchRequest(BaseModel):
    craft_type: str = Field(..., example="Handloom")
    materials_needed: Optional[str] = Field(None, example="Organic Cotton, Natural Indigo")
    max_budget_per_unit: Optional[float] = Field(None, example=60.0)
    preferred_region: Optional[str] = Field(None, example="Rajasthan")
    order_quantity: int = Field(10, ge=1)


class MatchedArtisanResult(BaseModel):
    artisan_id: int
    artisan_name: str
    craft_type: str
    region: str
    community_cooperative: Optional[str]
    match_score: float  # e.g., 94.5%
    match_reasons: List[str]
    sample_product_id: Optional[int] = None
    sample_product_title: Optional[str] = None
    sample_product_price: Optional[float] = None

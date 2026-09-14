from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field


class ProductBase(BaseModel):
    title: str = Field(..., min_length=2, example="Hand-painted Blue Pottery Vase")
    description: str = Field(..., min_length=5, example="Authentic Jaipur quartz-clay blue pottery vase hand-decorated with cobalt cobalt oxide floral motifs.")
    price: float = Field(..., gt=0, example=45.0)
    craft_type: str = Field(..., example="Blue Pottery")
    materials: Optional[str] = Field(None, example="Quartz powder, glass, natural dye")
    dimensions: Optional[str] = Field(None, example="15x15x25 cm")
    weight_grams: Optional[float] = Field(None, example=650.0)
    production_time_days: int = Field(3, ge=1, example=5)
    stock_quantity: int = Field(1, ge=0, example=8)
    image_url: Optional[str] = Field(None, example="https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=600&q=80")
    ai_tags: Optional[str] = Field(None, example="pottery, eco-friendly, handmade, glazed, floral")


class ProductCreate(ProductBase):
    ai_suggested_price: Optional[float] = None


class ProductUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    craft_type: Optional[str] = None
    materials: Optional[str] = None
    dimensions: Optional[str] = None
    weight_grams: Optional[float] = None
    production_time_days: Optional[int] = None
    stock_quantity: Optional[int] = None
    image_url: Optional[str] = None
    ai_tags: Optional[str] = None
    is_available: Optional[bool] = None


class ProductResponse(ProductBase):
    id: int
    artisan_id: int
    ai_suggested_price: Optional[float] = None
    is_available: bool
    views_count: int
    created_at: datetime
    updated_at: datetime

    # Additional metadata for convenience
    artisan_name: Optional[str] = None
    artisan_region: Optional[str] = None
    artisan_cooperative: Optional[str] = None

    class Config:
        from_attributes = True


class SmartCatalogSuggestRequest(BaseModel):
    craft_type: str = Field(..., example="Terracotta Pottery")
    raw_description: str = Field(..., example="Earthen water bottle made from river clay baked in wood fire")
    estimated_hours: Optional[float] = Field(None, example=6.0)
    material_cost: Optional[float] = Field(None, example=12.0)


class SmartCatalogSuggestResponse(BaseModel):
    suggested_title: str
    enhanced_description: str
    suggested_price_min: float
    suggested_price_max: float
    recommended_price: float
    suggested_tags: List[str]
    detected_materials: List[str]
    craft_category: str
    fair_trade_margin_percent: float

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.product import Product
from app.models.artisan import ArtisanProfile
from app.models.user import User
from app.schemas.product import (
    ProductCreate,
    ProductUpdate,
    ProductResponse,
    SmartCatalogSuggestRequest,
    SmartCatalogSuggestResponse
)
from app.services.catalog_ai_service import CatalogAIService
from app.services.search_service import ProductSearchService
from app.api.deps import get_current_artisan_user, get_current_buyer_user

router = APIRouter(prefix="/products", tags=["Products & Catalog"])


def _enrich_product_response(product: Product, db: Session) -> ProductResponse:
    artisan = db.query(ArtisanProfile).filter(ArtisanProfile.id == product.artisan_id).first()
    artisan_name = None
    region = None
    coop = None
    if artisan:
        region = artisan.region
        coop = artisan.community_cooperative
        user = db.query(User).filter(User.id == artisan.user_id).first()
        if user:
            artisan_name = user.full_name

    return ProductResponse(
        id=product.id,
        artisan_id=product.artisan_id,
        title=product.title,
        description=product.description,
        price=product.price,
        craft_type=product.craft_type,
        materials=product.materials,
        dimensions=product.dimensions,
        weight_grams=product.weight_grams,
        production_time_days=product.production_time_days,
        stock_quantity=product.stock_quantity,
        image_url=product.image_url,
        ai_tags=product.ai_tags,
        ai_suggested_price=product.ai_suggested_price,
        is_available=product.is_available,
        views_count=product.views_count,
        created_at=product.created_at,
        updated_at=product.updated_at,
        artisan_name=artisan_name,
        artisan_region=region,
        artisan_cooperative=coop
    )


@router.post("/smart-suggest", response_model=SmartCatalogSuggestResponse)
def get_smart_catalog_suggestion(request: SmartCatalogSuggestRequest):
    """Generate a market-ready product listing suggestion."""
    return CatalogAIService.analyze_and_suggest(
        craft_type=request.craft_type,
        raw_description=request.raw_description,
        estimated_hours=request.estimated_hours or 4.0,
        material_cost=request.material_cost or 10.0
    )


@router.get("/", response_model=List[ProductResponse])
def browse_catalog(
    q: Optional[str] = Query(None, description="Fuzzy search query across titles, materials, tags, makers"),
    craft_type: Optional[str] = Query(None, description="Filter by craft category"),
    min_price: Optional[float] = Query(None, ge=0),
    max_price: Optional[float] = Query(None, ge=0),
    region: Optional[str] = Query(None, description="Filter by artisan geographic cluster"),
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """Browse the artisan product catalog."""
    products = ProductSearchService.search_and_filter(
        db=db, query_str=q, craft_type=craft_type, min_price=min_price,
        max_price=max_price, region=region, limit=limit
    )
    return [_enrich_product_response(p, db) for p in products]


@router.get("/my/listings", response_model=List[ProductResponse])
def get_my_products(
    artisan_tuple=Depends(get_current_artisan_user),
    db: Session = Depends(get_db)
):
    """Return listings belonging to the authenticated artisan."""
    _, artisan = artisan_tuple
    products = db.query(Product).filter(Product.artisan_id == artisan.id).order_by(Product.created_at.desc()).all()
    return [_enrich_product_response(p, db) for p in products]


@router.post("/{product_id}/buy")
def buy_product(
    product_id: int,
    quantity: int = Query(1, ge=1, le=1000),
    buyer: User = Depends(get_current_buyer_user),
    db: Session = Depends(get_db)
):
    """Reserve/buy stock for an authenticated buyer and reduce inventory."""
    product = db.query(Product).filter(Product.id == product_id).with_for_update().first()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")
    if not product.is_available or product.stock_quantity < quantity:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Not enough stock available")

    product.stock_quantity -= quantity
    if product.stock_quantity == 0:
        product.is_available = False

    db.commit()
    return {
        "message": "Purchase reserved successfully",
        "buyer_id": buyer.id,
        "product_id": product.id,
        "quantity": quantity,
        "unit_price": product.price,
        "total_price": round(product.price * quantity, 2),
        "remaining_stock": product.stock_quantity,
        "payment_required": True,
    }


@router.get("/{product_id}", response_model=ProductResponse)
def get_product_details(product_id: int, db: Session = Depends(get_db)):
    """Retrieve full product details and increment its view counter."""
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")
    product.views_count = (product.views_count or 0) + 1
    db.commit()
    db.refresh(product)
    return _enrich_product_response(product, db)


@router.post("/", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
def create_product(
    product_in: ProductCreate,
    artisan_tuple=Depends(get_current_artisan_user),
    db: Session = Depends(get_db)
):
    """Publish a new handcrafted product listing for the logged-in artisan."""
    _, artisan = artisan_tuple
    new_product = Product(
        artisan_id=artisan.id,
        title=product_in.title,
        description=product_in.description,
        price=product_in.price,
        craft_type=product_in.craft_type,
        materials=product_in.materials,
        dimensions=product_in.dimensions,
        weight_grams=product_in.weight_grams,
        production_time_days=product_in.production_time_days,
        stock_quantity=product_in.stock_quantity,
        image_url=product_in.image_url,
        ai_tags=product_in.ai_tags,
        ai_suggested_price=product_in.ai_suggested_price,
        is_available=product_in.stock_quantity > 0,
        views_count=0
    )
    db.add(new_product)
    db.commit()
    db.refresh(new_product)
    return _enrich_product_response(new_product, db)


@router.put("/{product_id}", response_model=ProductResponse)
def update_product(
    product_id: int,
    product_in: ProductUpdate,
    artisan_tuple=Depends(get_current_artisan_user),
    db: Session = Depends(get_db)
):
    """Update a product listing. Only the artisan owner can update it."""
    _, artisan = artisan_tuple
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")
    if product.artisan_id != artisan.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to edit this listing")
    update_data = product_in.model_dump(exclude_unset=True)
    for key, val in update_data.items():
        setattr(product, key, val)
    if "stock_quantity" in update_data and product.stock_quantity == 0:
        product.is_available = False
    db.commit()
    db.refresh(product)
    return _enrich_product_response(product, db)


@router.delete("/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_product(
    product_id: int,
    artisan_tuple=Depends(get_current_artisan_user),
    db: Session = Depends(get_db)
):
    """Delete a product listing."""
    _, artisan = artisan_tuple
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")
    if product.artisan_id != artisan.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to delete this listing")
    db.delete(product)
    db.commit()
    return None

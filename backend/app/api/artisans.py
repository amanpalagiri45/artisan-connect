from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.artisan import ArtisanProfile
from app.models.user import User
from app.models.product import Product
from app.schemas.artisan import (
    ArtisanProfileResponse,
    ArtisanProfileUpdate,
    ArtisanDetailResponse
)
from app.schemas.product import ProductResponse
from app.api.deps import get_current_artisan_user

router = APIRouter(prefix="/artisans", tags=["Artisans"])


@router.get("/", response_model=List[ArtisanDetailResponse])
def list_artisans(
    craft_type: Optional[str] = None,
    region: Optional[str] = None,
    verified_only: bool = False,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """
    Public directory of registered artisan cooperatives and makers.
    """
    query = db.query(ArtisanProfile)
    if craft_type:
        query = query.filter(ArtisanProfile.craft_type.ilike(f"%{craft_type}%"))
    if region:
        query = query.filter(ArtisanProfile.region.ilike(f"%{region}%"))
    if verified_only:
        query = query.filter(ArtisanProfile.is_verified == True)

    artisans = query.offset(skip).limit(limit).all()
    results = []
    for art in artisans:
        user = db.query(User).filter(User.id == art.user_id).first()
        prod_count = db.query(Product).filter(Product.artisan_id == art.id).count()
        results.append(
            ArtisanDetailResponse(
                id=art.id,
                user_id=art.user_id,
                craft_type=art.craft_type,
                heritage_story=art.heritage_story,
                bio=art.bio,
                region=art.region,
                community_cooperative=art.community_cooperative,
                years_of_experience=art.years_of_experience,
                is_verified=art.is_verified,
                avatar_url=art.avatar_url,
                created_at=art.created_at,
                updated_at=art.updated_at,
                artisan_name=user.full_name if user else "Artisan",
                artisan_email=user.email if user else "",
                artisan_phone=user.phone if user else None,
                total_products=prod_count
            )
        )
    return results


@router.get("/me/profile", response_model=ArtisanDetailResponse)
def get_my_artisan_profile(
    artisan_tuple=Depends(get_current_artisan_user),
    db: Session = Depends(get_db)
):
    """Fetches the active artisan's profile."""
    current_user, artisan = artisan_tuple
    prod_count = db.query(Product).filter(Product.artisan_id == artisan.id).count()
    return ArtisanDetailResponse(
        id=artisan.id,
        user_id=artisan.user_id,
        craft_type=artisan.craft_type,
        heritage_story=artisan.heritage_story,
        bio=artisan.bio,
        region=artisan.region,
        community_cooperative=artisan.community_cooperative,
        years_of_experience=artisan.years_of_experience,
        is_verified=artisan.is_verified,
        avatar_url=artisan.avatar_url,
        created_at=artisan.created_at,
        updated_at=artisan.updated_at,
        artisan_name=current_user.full_name,
        artisan_email=current_user.email,
        artisan_phone=current_user.phone,
        total_products=prod_count
    )


@router.put("/me/profile", response_model=ArtisanProfileResponse)
def update_my_artisan_profile(
    profile_in: ArtisanProfileUpdate,
    artisan_tuple=Depends(get_current_artisan_user),
    db: Session = Depends(get_db)
):
    """Updates the logged-in artisan's profile data."""
    _, artisan = artisan_tuple
    update_data = profile_in.model_dump(exclude_unset=True)
    for field, val in update_data.items():
        setattr(artisan, field, val)
    db.commit()
    db.refresh(artisan)
    return artisan


@router.get("/{artisan_id}", response_model=ArtisanDetailResponse)
def get_artisan_by_id(artisan_id: int, db: Session = Depends(get_db)):
    """Fetches public profile for an artisan by ID."""
    artisan = db.query(ArtisanProfile).filter(ArtisanProfile.id == artisan_id).first()
    if not artisan:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Artisan profile not found")
    user = db.query(User).filter(User.id == artisan.user_id).first()
    prod_count = db.query(Product).filter(Product.artisan_id == artisan.id).count()
    return ArtisanDetailResponse(
        id=artisan.id,
        user_id=artisan.user_id,
        craft_type=artisan.craft_type,
        heritage_story=artisan.heritage_story,
        bio=artisan.bio,
        region=artisan.region,
        community_cooperative=artisan.community_cooperative,
        years_of_experience=artisan.years_of_experience,
        is_verified=artisan.is_verified,
        avatar_url=artisan.avatar_url,
        created_at=artisan.created_at,
        updated_at=artisan.updated_at,
        artisan_name=user.full_name if user else "Artisan",
        artisan_email=user.email if user else "",
        artisan_phone=user.phone if user else None,
        total_products=prod_count
    )


@router.get("/{artisan_id}/products", response_model=List[ProductResponse])
def get_artisan_products(artisan_id: int, db: Session = Depends(get_db)):
    """Fetches all public listings by a specific artisan."""
    products = db.query(Product).filter(
        Product.artisan_id == artisan_id,
        Product.is_available == True
    ).all()
    return products

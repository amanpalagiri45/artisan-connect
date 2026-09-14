from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.linkage import MarketLinkage, LinkageStatus
from app.models.artisan import ArtisanProfile
from app.models.product import Product
from app.models.user import User, UserRole
from app.models.notification import Notification, NotificationType
from app.schemas.linkage import (
    LinkageCreate,
    LinkageStatusUpdate,
    LinkageResponse,
    MatchRequest,
    MatchedArtisanResult
)
from app.services.matching_engine import MarketLinkageMatcher
from app.api.deps import get_current_user, get_current_artisan_user, get_current_buyer_user

router = APIRouter(prefix="/linkages", tags=["Market Linkages & Inquiries"])


def _enrich_linkage(linkage: MarketLinkage, db: Session) -> LinkageResponse:
    buyer = db.query(User).filter(User.id == linkage.buyer_id).first()
    artisan = db.query(ArtisanProfile).filter(ArtisanProfile.id == linkage.artisan_id).first()
    artisan_user = db.query(User).filter(User.id == artisan.user_id).first() if artisan else None
    product = db.query(Product).filter(Product.id == linkage.product_id).first() if linkage.product_id else None

    return LinkageResponse(
        id=linkage.id,
        buyer_id=linkage.buyer_id,
        artisan_id=linkage.artisan_id,
        product_id=linkage.product_id,
        status=linkage.status,
        quantity=linkage.quantity,
        proposed_unit_price=linkage.proposed_unit_price,
        buyer_notes=linkage.buyer_notes,
        artisan_notes=linkage.artisan_notes,
        match_score=linkage.match_score,
        target_delivery_date=linkage.target_delivery_date,
        created_at=linkage.created_at,
        updated_at=linkage.updated_at,
        buyer_name=buyer.full_name if buyer else "Buyer",
        buyer_email=buyer.email if buyer else "",
        artisan_name=artisan_user.full_name if artisan_user else "Artisan",
        artisan_craft=artisan.craft_type if artisan else "",
        product_title=product.title if product else "Custom Craft Inquiry"
    )


@router.post("/inquire", response_model=LinkageResponse, status_code=status.HTTP_201_CREATED)
def create_market_inquiry(
    inquiry_in: LinkageCreate,
    current_buyer: User = Depends(get_current_buyer_user),
    db: Session = Depends(get_db)
):
    """
    Buyer initiates a market linkage or product purchase inquiry with an artisan.
    Automatically computes a match score and generates a notification for the artisan.
    """
    artisan = db.query(ArtisanProfile).filter(ArtisanProfile.id == inquiry_in.artisan_id).first()
    if not artisan:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Target artisan not found")

    product = None
    if inquiry_in.product_id:
        product = db.query(Product).filter(Product.id == inquiry_in.product_id).first()

    # Calculate match affinity score
    calc_req = MatchRequest(
        craft_type=product.craft_type if product else artisan.craft_type,
        materials_needed=product.materials if product else None,
        max_budget_per_unit=inquiry_in.proposed_unit_price or (product.price if product else 50.0),
        preferred_region=artisan.region,
        order_quantity=inquiry_in.quantity
    )
    score, _ = MarketLinkageMatcher.calculate_match_score(artisan, calc_req, product)

    new_linkage = MarketLinkage(
        buyer_id=current_buyer.id,
        artisan_id=artisan.id,
        product_id=product.id if product else None,
        status=LinkageStatus.PENDING,
        quantity=inquiry_in.quantity,
        proposed_unit_price=inquiry_in.proposed_unit_price or (product.price if product else None),
        buyer_notes=inquiry_in.buyer_notes,
        match_score=score,
        target_delivery_date=inquiry_in.target_delivery_date
    )
    db.add(new_linkage)
    db.commit()
    db.refresh(new_linkage)

    # Dispatch notification to artisan user
    product_name = product.title if product else artisan.craft_type
    notif = Notification(
        user_id=artisan.user_id,
        title=f"New Buyer Inquiry ({score:.0f}% Match)",
        message=f"{current_buyer.full_name} inquired about {inquiry_in.quantity}x '{product_name}'. Notes: \"{inquiry_in.buyer_notes[:80]}...\"",
        notification_type=NotificationType.NEW_INQUIRY,
        reference_id=new_linkage.id,
        is_read=False
    )
    db.add(notif)
    db.commit()

    return _enrich_linkage(new_linkage, db)


@router.post("/match", response_model=List[MatchedArtisanResult])
def match_market_demand(
    criteria: MatchRequest,
    db: Session = Depends(get_db)
):
    """
    AI Market Linkage Matcher: Ranks artisan producers based on craft taxonomy,
    sustainable materials, price constraints, and geographic provenance.
    """
    return MarketLinkageMatcher.find_matches(db=db, request=criteria, limit=10)


@router.get("/artisan", response_model=List[LinkageResponse])
def get_artisan_linkages(
    status_filter: Optional[LinkageStatus] = None,
    artisan_tuple=Depends(get_current_artisan_user),
    db: Session = Depends(get_db)
):
    """Returns all buyer inquiries and market linkages received by the artisan."""
    _, artisan = artisan_tuple
    query = db.query(MarketLinkage).filter(MarketLinkage.artisan_id == artisan.id)
    if status_filter:
        query = query.filter(MarketLinkage.status == status_filter)
    linkages = query.order_by(MarketLinkage.created_at.desc()).all()
    return [_enrich_linkage(l, db) for l in linkages]


@router.get("/buyer", response_model=List[LinkageResponse])
def get_buyer_linkages(
    current_buyer: User = Depends(get_current_buyer_user),
    db: Session = Depends(get_db)
):
    """Returns all market inquiries submitted by the buyer."""
    linkages = db.query(MarketLinkage).filter(
        MarketLinkage.buyer_id == current_buyer.id
    ).order_by(MarketLinkage.created_at.desc()).all()
    return [_enrich_linkage(l, db) for l in linkages]


@router.put("/{linkage_id}/status", response_model=LinkageResponse)
def update_linkage_status(
    linkage_id: int,
    status_in: LinkageStatusUpdate,
    artisan_tuple=Depends(get_current_artisan_user),
    db: Session = Depends(get_db)
):
    """
    Artisans accept, decline, or mark linkages as completed.
    Dispatches a real-time status notification back to the buyer.
    """
    current_user, artisan = artisan_tuple
    linkage = db.query(MarketLinkage).filter(MarketLinkage.id == linkage_id).first()
    if not linkage:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Linkage not found")
    if linkage.artisan_id != artisan.id and current_user.role != UserRole.ADMIN:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to update this linkage")

    linkage.status = status_in.status
    if status_in.artisan_notes:
        linkage.artisan_notes = status_in.artisan_notes

    db.commit()
    db.refresh(linkage)

    # Dispatch notification to buyer
    notif = Notification(
        user_id=linkage.buyer_id,
        title=f"Inquiry Update: {status_in.status.value.upper()}",
        message=f"Artisan {current_user.full_name} updated your inquiry status to '{status_in.status.value}'.",
        notification_type=NotificationType.STATUS_CHANGED,
        reference_id=linkage.id,
        is_read=False
    )
    db.add(notif)
    db.commit()

    return _enrich_linkage(linkage, db)

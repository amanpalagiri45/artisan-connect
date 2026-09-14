from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.artisan import ArtisanProfile
from app.models.product import Product
from app.models.linkage import MarketLinkage, LinkageStatus
from app.models.user import User
from app.schemas.analytics import ArtisanDashboardMetrics
from app.api.deps import get_current_artisan_user

router = APIRouter(prefix="/analytics", tags=["Analytics & Dashboard"])


@router.get("/artisan/dashboard", response_model=ArtisanDashboardMetrics)
def get_artisan_dashboard(
    artisan_tuple=Depends(get_current_artisan_user),
    db: Session = Depends(get_db)
):
    """
    Computes key performance metrics, inquiry conversion rates, and revenue pipeline
    for the authenticated artisan's mobile dashboard.
    """
    current_user, artisan = artisan_tuple

    # Products count & total views
    products = db.query(Product).filter(Product.artisan_id == artisan.id).all()
    total_products = len(products)
    total_views = sum(p.views_count or 0 for p in products)

    # Inquiries & Linkages
    linkages = db.query(MarketLinkage).filter(MarketLinkage.artisan_id == artisan.id).all()
    total_inquiries = len(linkages)
    pending_inquiries = sum(1 for l in linkages if l.status == LinkageStatus.PENDING)
    accepted_linkages = sum(1 for l in linkages if l.status in [LinkageStatus.ACCEPTED, LinkageStatus.IN_PROGRESS])
    completed_linkages = sum(1 for l in linkages if l.status == LinkageStatus.COMPLETED)

    # Potential Revenue calculation: quantity * proposed_unit_price for pending, accepted, in_progress, completed
    total_potential_revenue = 0.0
    for l in linkages:
        if l.status != LinkageStatus.DECLINED:
            unit_p = l.proposed_unit_price or 0.0
            total_potential_revenue += (unit_p * (l.quantity or 1))

    # Conversion Rate
    conversion_rate = 0.0
    if total_views > 0:
        conversion_rate = round((total_inquiries / total_views) * 100, 1)

    # Recent inquiries summary
    recent_inquiries = []
    for l in sorted(linkages, key=lambda x: x.created_at, reverse=True)[:5]:
        buyer = db.query(User).filter(User.id == l.buyer_id).first()
        prod = db.query(Product).filter(Product.id == l.product_id).first() if l.product_id else None
        recent_inquiries.append({
            "id": l.id,
            "buyer_name": buyer.full_name if buyer else "Buyer",
            "product_title": prod.title if prod else "Custom Inquiry",
            "quantity": l.quantity,
            "status": l.status.value,
            "match_score": l.match_score,
            "created_at": l.created_at.isoformat()
        })

    # Top products by views
    top_products = []
    for p in sorted(products, key=lambda x: x.views_count, reverse=True)[:4]:
        top_products.append({
            "id": p.id,
            "title": p.title,
            "price": p.price,
            "views": p.views_count,
            "craft_type": p.craft_type,
            "image_url": p.image_url
        })

    return ArtisanDashboardMetrics(
        artisan_id=artisan.id,
        artisan_name=current_user.full_name,
        craft_type=artisan.craft_type,
        total_products=total_products,
        total_inquiries=total_inquiries,
        pending_inquiries=pending_inquiries,
        accepted_linkages=accepted_linkages,
        completed_linkages=completed_linkages,
        total_potential_revenue=round(total_potential_revenue, 2),
        total_views=total_views,
        conversion_rate_percent=conversion_rate,
        recent_inquiries=recent_inquiries,
        top_performing_products=top_products
    )

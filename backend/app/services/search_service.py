from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.product import Product
from app.models.artisan import ArtisanProfile
from app.models.user import User

try:
    from thefuzz import fuzz
    HAS_THEFUZZ = True
except ImportError:
    HAS_THEFUZZ = False


def pure_python_similarity(s1: str, s2: str) -> int:
    """Pure Python token similarity score between 0 and 100 as fallback."""
    s1_tokens = set(s1.lower().split())
    s2_tokens = set(s2.lower().split())
    if not s1_tokens or not s2_tokens:
        return 0
    intersection = s1_tokens.intersection(s2_tokens)
    union = s1_tokens.union(s2_tokens)
    return int((len(intersection) / len(union)) * 100)


def calculate_similarity(s1: str, s2: str) -> int:
    """Computes string similarity score using thefuzz or pure python fallback."""
    if HAS_THEFUZZ:
        return fuzz.token_set_ratio(s1, s2)
    return pure_python_similarity(s1, s2)


class ProductSearchService:
    """
    Search and filter service offering fuzzy matching on title, description,
    craft type, tags, and artisan origin.
    """

    @classmethod
    def search_and_filter(
        cls,
        db: Session,
        query_str: Optional[str] = None,
        craft_type: Optional[str] = None,
        min_price: Optional[float] = None,
        max_price: Optional[float] = None,
        region: Optional[str] = None,
        limit: int = 50
    ) -> List[Product]:
        """
        Executes query filtering and applies fuzzy matching ranking if query_str is provided.
        """
        base_query = db.query(Product).filter(Product.is_available == True)

        if craft_type:
            base_query = base_query.filter(Product.craft_type.ilike(f"%{craft_type}%"))
        
        if min_price is not None:
            base_query = base_query.filter(Product.price >= min_price)
            
        if max_price is not None:
            base_query = base_query.filter(Product.price <= max_price)

        if region:
            base_query = base_query.join(ArtisanProfile).filter(ArtisanProfile.region.ilike(f"%{region}%"))

        products = base_query.all()

        if not query_str or not query_str.strip():
            return products[:limit]

        q = query_str.strip().lower()
        scored_products = []

        for p in products:
            # Composite text representation of product
            artisan = db.query(ArtisanProfile).filter(ArtisanProfile.id == p.artisan_id).first()
            artisan_user = db.query(User).filter(User.id == artisan.user_id).first() if artisan else None
            artisan_name = artisan_user.full_name if artisan_user else ""

            target_corpus = f"{p.title} {p.description} {p.craft_type} {p.materials or ''} {p.ai_tags or ''} {artisan_name}"
            score = calculate_similarity(q, target_corpus)

            # Direct substring check gives high priority
            if q in target_corpus.lower():
                score = max(score, 85)

            if score >= 35:
                scored_products.append((p, score))

        # Sort descending by match score
        scored_products.sort(key=lambda x: x[1], reverse=True)
        return [p for p, _ in scored_products[:limit]]

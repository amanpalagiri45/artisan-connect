from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.artisan import ArtisanProfile
from app.models.product import Product
from app.models.user import User
from app.schemas.linkage import MatchRequest, MatchedArtisanResult


class MarketLinkageMatcher:
    """
    Market Linkage Matching Engine that connects commercial, boutique,
    and conscious buyers directly with relevant marginalized artisans.
    """

    @staticmethod
    def calculate_match_score(
        artisan: ArtisanProfile,
        request: MatchRequest,
        sample_product: Optional[Product] = None
    ) -> tuple[float, List[str]]:
        score = 0.0
        reasons = []

        req_craft = request.craft_type.strip().lower()
        art_craft = artisan.craft_type.strip().lower()

        # 1. Craft Type Match (40% weight)
        if req_craft in art_craft or art_craft in req_craft:
            score += 0.40
            reasons.append(f"Specialized in requested craft: {artisan.craft_type}")
        else:
            # Partial overlap in common terms
            common_words = set(req_craft.split()) & set(art_craft.split())
            if common_words:
                score += 0.25
                reasons.append(f"Related craft technique match: {artisan.craft_type}")

        # 2. Material & Tag Match (25% weight)
        if request.materials_needed:
            needed_mats = [m.strip().lower() for m in request.materials_needed.split(",") if m.strip()]
            matched_mat_count = 0
            if sample_product:
                prod_materials = (sample_product.materials or "").lower()
                prod_tags = (sample_product.ai_tags or "").lower()
                for mat in needed_mats:
                    if mat in prod_materials or mat in prod_tags:
                        matched_mat_count += 1

            if matched_mat_count > 0:
                mat_score = min(0.25, 0.15 + (0.05 * matched_mat_count))
                score += mat_score
                reasons.append("Craft uses requested sustainable materials & tags")
            else:
                score += 0.10
        else:
            score += 0.20

        # 3. Budget Fit (20% weight)
        if request.max_budget_per_unit and sample_product:
            if sample_product.price <= request.max_budget_per_unit:
                score += 0.20
                reasons.append(f"Product price (${sample_product.price:.2f}) fits within budget (${request.max_budget_per_unit:.2f})")
            elif sample_product.price <= request.max_budget_per_unit * 1.25:
                score += 0.10
                reasons.append("Slightly above target budget; negotiable for wholesale volumes")
        else:
            score += 0.15

        # 4. Regional / Cooperative Affinity (15% weight)
        if request.preferred_region:
            pref_reg = request.preferred_region.strip().lower()
            art_reg = (artisan.region or "").lower()
            if pref_reg in art_reg:
                score += 0.15
                reasons.append(f"Located in target sourcing cluster: {artisan.region}")
            else:
                score += 0.05
        else:
            score += 0.10

        # Bonus: Verified artisan cooperative
        if artisan.is_verified:
            score = min(1.0, score + 0.05)
            reasons.append("Verified indigenous cooperative status")

        return round(min(score, 1.0) * 100, 1), reasons

    @classmethod
    def find_matches(
        cls,
        db: Session,
        request: MatchRequest,
        limit: int = 10
    ) -> List[MatchedArtisanResult]:
        """
        Scans registered artisans and their product catalogs to find top matching artisans for buyers.
        """
        artisans = db.query(ArtisanProfile).all()
        results: List[MatchedArtisanResult] = []

        for artisan in artisans:
            user = db.query(User).filter(User.id == artisan.user_id).first()
            artisan_name = user.full_name if user else "Artisan"

            # Find best representative product
            sample_product = (
                db.query(Product)
                .filter(Product.artisan_id == artisan.id)
                .first()
            )

            score, reasons = cls.calculate_match_score(artisan, request, sample_product)

            # Filter candidates with meaningful match (> 30%)
            if score >= 30.0:
                results.append(
                    MatchedArtisanResult(
                        artisan_id=artisan.id,
                        artisan_name=artisan_name,
                        craft_type=artisan.craft_type,
                        region=artisan.region,
                        community_cooperative=artisan.community_cooperative,
                        match_score=score,
                        match_reasons=reasons,
                        sample_product_id=sample_product.id if sample_product else None,
                        sample_product_title=sample_product.title if sample_product else None,
                        sample_product_price=sample_product.price if sample_product else None
                    )
                )

        # Sort descending by match score
        results.sort(key=lambda x: x.match_score, reverse=True)
        return results[:limit]

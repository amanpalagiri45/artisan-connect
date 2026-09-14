import re
from typing import List, Dict, Tuple
from app.schemas.product import SmartCatalogSuggestResponse


class CatalogAIService:
    """
    AI-driven smart cataloging service that transforms basic artisan inputs into
    comprehensive, market-ready listings with automated tagging, storytelling enhancements,
    and fair-trade pricing recommendations.
    """

    CRAFT_TAXONOMY = {
        "pottery": {
            "tags": ["terracotta", "earthenware", "hand-thrown", "traditional-kiln", "sustainable-home", "organic-clay"],
            "materials": ["natural clay", "mineral glaze", "quartz sand", "river silt"],
            "hourly_artisan_rate": 8.50,
            "overhead_multiplier": 1.35
        },
        "handloom": {
            "tags": ["handwoven", "slow-fashion", "organic-cotton", "natural-indigo", "artisan-apparel", "heritage-weave"],
            "materials": ["mulberry silk", "organic cotton", "khadi", "linen", "vegetable dye"],
            "hourly_artisan_rate": 10.00,
            "overhead_multiplier": 1.40
        },
        "woodwork": {
            "tags": ["reclaimed-wood", "hand-carved", "solid-wood", "artisan-joinery", "sustainable-decor", "rustic"],
            "materials": ["sheesham wood", "teak", "natural beeswax polish", "brass inlay"],
            "hourly_artisan_rate": 12.00,
            "overhead_multiplier": 1.30
        },
        "metalcraft": {
            "tags": ["dhokra", "lost-wax-casting", "hand-beaten", "brass-decor", "tribal-art", "antique-finish"],
            "materials": ["bell metal", "recycled brass", "bronze", "natural beeswax mold"],
            "hourly_artisan_rate": 11.00,
            "overhead_multiplier": 1.45
        },
        "embroidery": {
            "tags": ["chikankari", "kantha", "needlework", "intricate-stitching", "ethical-luxury", "artisan-textile"],
            "materials": ["georgette", "silk thread", "muslin", "cotton floss"],
            "hourly_artisan_rate": 9.50,
            "overhead_multiplier": 1.30
        }
    }

    MATERIAL_KEYWORDS = [
        "clay", "terracotta", "cotton", "silk", "wool", "brass", "bronze", "wood", 
        "teak", "sheesham", "indigo", "vegetable dye", "jute", "bamboo", "glass", "quartz"
    ]

    @classmethod
    def analyze_and_suggest(
        cls,
        craft_type: str,
        raw_description: str,
        estimated_hours: float = 4.0,
        material_cost: float = 10.0
    ) -> SmartCatalogSuggestResponse:
        """
        Parses artisan inputs, runs keyword heuristics, and synthesizes an AI catalog profile.
        """
        craft_lower = craft_type.lower()
        desc_lower = raw_description.lower()

        # Identify primary category
        matched_category = "handloom"
        for key in cls.CRAFT_TAXONOMY:
            if key in craft_lower or key in desc_lower:
                matched_category = key
                break

        category_profile = cls.CRAFT_TAXONOMY.get(matched_category, cls.CRAFT_TAXONOMY["handloom"])

        # Detect materials from description
        detected_materials = []
        for mat in cls.MATERIAL_KEYWORDS:
            if mat in desc_lower or mat in craft_lower:
                detected_materials.append(mat.capitalize())
        
        if not detected_materials:
            detected_materials = [m.capitalize() for m in category_profile["materials"][:2]]

        # Suggested title synthesis
        clean_desc_snippet = re.sub(r'[^a-zA-Z0-9\s]', '', raw_description).strip().title()
        words = clean_desc_snippet.split()
        short_title = " ".join(words[:4]) if len(words) >= 4 else clean_desc_snippet
        suggested_title = f"Handcrafted {craft_type.title()} - {short_title}"

        # Enhanced Storytelling description
        enhanced_description = (
            f"{raw_description.strip()}. "
            f"Lovingly crafted by master artisans using time-honored {craft_type} traditions. "
            f"Made with authentic {', '.join(detected_materials)}, each piece carries the unique "
            f"heritage, cultural lineage, and tactile soul of marginalized maker communities. "
            f"Supports fair wages, sustainable indigenous livelihoods, and slow craftsmanship."
        )

        # Smart Tags
        base_tags = list(category_profile["tags"])
        custom_tags = [craft_type.lower().replace(" ", "-"), "fair-trade", "ethical-craft"]
        suggested_tags = list(dict.fromkeys(custom_tags + base_tags))

        # Fair-trade pricing algorithm:
        # Base Labor = hours * fair hourly rate
        # Total Cost = material_cost + Base Labor
        # Fair Trade Price = Total Cost * overhead_multiplier
        hours = max(1.0, float(estimated_hours or 3.0))
        mat_cost = max(5.0, float(material_cost or 8.0))
        labor_cost = hours * category_profile["hourly_artisan_rate"]
        baseline_cost = mat_cost + labor_cost

        recommended_price = round(baseline_cost * category_profile["overhead_multiplier"], 2)
        price_min = round(recommended_price * 0.85, 2)
        price_max = round(recommended_price * 1.30, 2)

        return SmartCatalogSuggestResponse(
            suggested_title=suggested_title,
            enhanced_description=enhanced_description,
            suggested_price_min=price_min,
            suggested_price_max=price_max,
            recommended_price=recommended_price,
            suggested_tags=suggested_tags[:8],
            detected_materials=detected_materials,
            craft_category=matched_category.title(),
            fair_trade_margin_percent=35.0
        )

from typing import List, Dict, Any, Optional
from pydantic import BaseModel


class ArtisanDashboardMetrics(BaseModel):
    artisan_id: int
    artisan_name: str
    craft_type: str
    total_products: int
    total_inquiries: int
    pending_inquiries: int
    accepted_linkages: int
    completed_linkages: int
    total_potential_revenue: float
    total_views: int
    conversion_rate_percent: float
    recent_inquiries: List[Dict[str, Any]]
    top_performing_products: List[Dict[str, Any]]

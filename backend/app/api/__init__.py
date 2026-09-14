from fastapi import APIRouter
from app.api.auth import router as auth_router
from app.api.artisans import router as artisans_router
from app.api.products import router as products_router
from app.api.linkages import router as linkages_router
from app.api.notifications import router as notifications_router
from app.api.analytics import router as analytics_router

api_router = APIRouter()
api_router.include_router(auth_router)
api_router.include_router(artisans_router)
api_router.include_router(products_router)
api_router.include_router(linkages_router)
api_router.include_router(notifications_router)
api_router.include_router(analytics_router)

__all__ = ["api_router"]

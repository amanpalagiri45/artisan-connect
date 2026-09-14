from typing import Optional
from datetime import datetime
from pydantic import BaseModel
from app.models.notification import NotificationType


class NotificationResponse(BaseModel):
    id: int
    user_id: int
    title: str
    message: str
    notification_type: NotificationType
    reference_id: Optional[int] = None
    is_read: bool
    created_at: datetime

    class Config:
        from_attributes = True


class NotificationUnreadCount(BaseModel):
    unread_count: int

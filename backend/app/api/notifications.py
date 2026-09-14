from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.notification import Notification
from app.models.user import User
from app.schemas.notification import NotificationResponse, NotificationUnreadCount
from app.api.deps import get_current_user

router = APIRouter(prefix="/notifications", tags=["Notifications"])


@router.get("/", response_model=List[NotificationResponse])
def get_my_notifications(
    limit: int = 50,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Fetches user notifications sorted from newest to oldest."""
    notifications = (
        db.query(Notification)
        .filter(Notification.user_id == current_user.id)
        .order_by(Notification.created_at.desc())
        .limit(limit)
        .all()
    )
    return notifications


@router.get("/unread-count", response_model=NotificationUnreadCount)
def get_unread_count(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Returns the count of unread notifications for badge display."""
    count = (
        db.query(Notification)
        .filter(Notification.user_id == current_user.id, Notification.is_read == False)
        .count()
    )
    return NotificationUnreadCount(unread_count=count)


@router.put("/{notification_id}/read", response_model=NotificationResponse)
def mark_notification_read(
    notification_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Marks a single notification as read."""
    notif = db.query(Notification).filter(Notification.id == notification_id).first()
    if not notif:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Notification not found")
    if notif.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

    notif.is_read = True
    db.commit()
    db.refresh(notif)
    return notif


@router.put("/mark-all-read", status_code=status.HTTP_200_OK)
def mark_all_read(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Marks all user notifications as read."""
    db.query(Notification).filter(
        Notification.user_id == current_user.id,
        Notification.is_read == False
    ).update({"is_read": True})
    db.commit()
    return {"message": "All notifications marked as read"}

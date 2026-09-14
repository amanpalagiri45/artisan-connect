import enum
from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, ForeignKey, Enum
from sqlalchemy.orm import relationship
from app.database import Base


class NotificationType(str, enum.Enum):
    NEW_INQUIRY = "new_inquiry"
    LINKAGE_MATCHED = "linkage_matched"
    STATUS_CHANGED = "status_changed"
    SYSTEM = "system"


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    title = Column(String, nullable=False)
    message = Column(Text, nullable=False)
    notification_type = Column(Enum(NotificationType), default=NotificationType.NEW_INQUIRY, nullable=False)
    reference_id = Column(Integer, nullable=True)  # E.g. linkage_id or product_id
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    user = relationship("User", back_populates="notifications")

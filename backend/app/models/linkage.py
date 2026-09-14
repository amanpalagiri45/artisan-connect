import enum
from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, Float, DateTime, ForeignKey, Enum
from sqlalchemy.orm import relationship
from app.database import Base


class LinkageStatus(str, enum.Enum):
    PENDING = "pending"
    ACCEPTED = "accepted"
    DECLINED = "declined"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"


class MarketLinkage(Base):
    __tablename__ = "market_linkages"

    id = Column(Integer, primary_key=True, index=True)
    buyer_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    artisan_id = Column(Integer, ForeignKey("artisan_profiles.id"), nullable=False, index=True)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=True, index=True)

    status = Column(Enum(LinkageStatus), default=LinkageStatus.PENDING, nullable=False)
    quantity = Column(Integer, default=1)
    proposed_unit_price = Column(Float, nullable=True)
    buyer_notes = Column(Text, nullable=False)
    artisan_notes = Column(Text, nullable=True)
    match_score = Column(Float, default=0.0)  # AI Match Score 0.0 - 1.0

    target_delivery_date = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    buyer = relationship("User", foreign_keys=[buyer_id], back_populates="linkages_as_buyer")
    artisan = relationship("ArtisanProfile", foreign_keys=[artisan_id], back_populates="linkages")
    product = relationship("Product", back_populates="linkages")

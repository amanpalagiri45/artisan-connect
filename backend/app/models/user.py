import enum
from datetime import datetime
from sqlalchemy import Column, Integer, String, Boolean, DateTime, Enum
from sqlalchemy.orm import relationship
from app.database import Base


class UserRole(str, enum.Enum):
    ARTISAN = "artisan"
    BUYER = "buyer"
    ADMIN = "admin"


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    full_name = Column(String, nullable=False)
    phone = Column(String, nullable=True)
    role = Column(Enum(UserRole), default=UserRole.BUYER, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    artisan_profile = relationship("ArtisanProfile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    linkages_as_buyer = relationship("MarketLinkage", foreign_keys="MarketLinkage.buyer_id", back_populates="buyer")
    notifications = relationship("Notification", back_populates="user", cascade="all, delete-orphan")

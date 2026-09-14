from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base


class ArtisanProfile(Base):
    __tablename__ = "artisan_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    craft_type = Column(String, index=True, nullable=False)  # e.g., Pottery, Handloom, Woodwork, Metalcraft
    heritage_story = Column(Text, nullable=True)  # Cultural origin & artisan story
    bio = Column(Text, nullable=True)
    region = Column(String, index=True, nullable=False)  # Village/District/State
    community_cooperative = Column(String, nullable=True)  # e.g. "Weavers Collective of Varanasi"
    years_of_experience = Column(Integer, default=1)
    is_verified = Column(Boolean, default=False)
    avatar_url = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user = relationship("User", back_populates="artisan_profile")
    products = relationship("Product", back_populates="artisan", cascade="all, delete-orphan")
    linkages = relationship("MarketLinkage", foreign_keys="MarketLinkage.artisan_id", back_populates="artisan")

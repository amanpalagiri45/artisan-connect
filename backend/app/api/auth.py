from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import User, UserRole
from app.models.artisan import ArtisanProfile
from app.schemas.auth import Token, UserCreate, UserLogin, UserResponse
from app.services.auth_service import verify_password, get_password_hash, create_access_token
from app.api.deps import get_current_user

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=Token, status_code=status.HTTP_201_CREATED)
def register_user(user_in: UserCreate, db: Session = Depends(get_db)):
    """
    Registers a new user (artisan or buyer). If registering as an artisan,
    their artisan profile is created automatically.
    """
    existing_user = db.query(User).filter(User.email == user_in.email.lower()).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user with this email address already exists."
        )

    # Create User
    new_user = User(
        email=user_in.email.lower(),
        hashed_password=get_password_hash(user_in.password),
        full_name=user_in.full_name,
        phone=user_in.phone,
        role=user_in.role,
        is_active=True
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    artisan_profile_id = None
    if new_user.role == UserRole.ARTISAN:
        profile = ArtisanProfile(
            user_id=new_user.id,
            craft_type=user_in.craft_type or "Traditional Craftsmanship",
            region=user_in.region or "Regional Cluster",
            community_cooperative=user_in.community_cooperative,
            heritage_story=user_in.heritage_story,
            bio=user_in.bio,
            years_of_experience=user_in.years_of_experience or 1,
            is_verified=False
        )
        db.add(profile)
        db.commit()
        db.refresh(profile)
        artisan_profile_id = profile.id

    access_token = create_access_token(subject=new_user.id, role=new_user.role.value)
    return Token(
        access_token=access_token,
        token_type="bearer",
        user_id=new_user.id,
        email=new_user.email,
        role=new_user.role,
        full_name=new_user.full_name,
        artisan_profile_id=artisan_profile_id
    )


@router.post("/login", response_model=Token)
def login(login_data: UserLogin, db: Session = Depends(get_db)):
    """
    Authenticates user using JSON credentials and returns JWT bearer token.
    """
    user = db.query(User).filter(User.email == login_data.email.lower()).first()
    if not user or not verify_password(login_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive account")

    artisan_profile_id = None
    if user.artisan_profile:
        artisan_profile_id = user.artisan_profile.id

    access_token = create_access_token(subject=user.id, role=user.role.value)
    return Token(
        access_token=access_token,
        token_type="bearer",
        user_id=user.id,
        email=user.email,
        role=user.role,
        full_name=user.full_name,
        artisan_profile_id=artisan_profile_id
    )


@router.post("/token", response_model=Token)
def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    """
    OAuth2 compatible token login endpoint for Swagger UI & API docs.
    """
    user = db.query(User).filter(User.email == form_data.username.lower()).first()
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    artisan_profile_id = user.artisan_profile.id if user.artisan_profile else None
    access_token = create_access_token(subject=user.id, role=user.role.value)
    return Token(
        access_token=access_token,
        token_type="bearer",
        user_id=user.id,
        email=user.email,
        role=user.role,
        full_name=user.full_name,
        artisan_profile_id=artisan_profile_id
    )


@router.get("/me", response_model=UserResponse)
def get_current_user_profile(current_user: User = Depends(get_current_user)):
    """Returns the authenticated user's account details."""
    return current_user

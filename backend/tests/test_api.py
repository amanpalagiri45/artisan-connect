import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.main import app
from app.database import Base, get_db
from app.models.user import User, UserRole

from sqlalchemy.pool import StaticPool

# Use an in-memory SQLite database for isolated tests with StaticPool
SQLALCHEMY_TEST_DATABASE_URL = "sqlite:///:memory:"

test_engine = create_engine(
    SQLALCHEMY_TEST_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db

# Create all tables in test database
Base.metadata.create_all(bind=test_engine)

client = TestClient(app)


@pytest.fixture(scope="module", autouse=True)
def setup_db():
    Base.metadata.create_all(bind=test_engine)
    yield
    Base.metadata.drop_all(bind=test_engine)


def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_register_artisan_and_buyer():
    # 1. Register Artisan
    artisan_payload = {
        "email": "test.artisan@artisanconnect.org",
        "password": "artisanpassword123",
        "full_name": "Devi Bai",
        "phone": "+91-99887-11223",
        "role": "artisan",
        "craft_type": "Terracotta Pottery",
        "region": "Molela, Rajasthan",
        "community_cooperative": "Molela Clay Guild",
        "years_of_experience": 14
    }
    artisan_res = client.post("/api/v1/auth/register", json=artisan_payload)
    assert artisan_res.status_code == 201
    artisan_data = artisan_res.json()
    assert artisan_data["role"] == "artisan"
    assert "access_token" in artisan_data
    assert artisan_data["artisan_profile_id"] is not None

    # 2. Register Buyer
    buyer_payload = {
        "email": "test.buyer@fairtrade.org",
        "password": "buyerpassword123",
        "full_name": "Global Living Co.",
        "phone": "+1-212-555-0100",
        "role": "buyer"
    }
    buyer_res = client.post("/api/v1/auth/register", json=buyer_payload)
    assert buyer_res.status_code == 201
    buyer_data = buyer_res.json()
    assert buyer_data["role"] == "buyer"
    assert "access_token" in buyer_data


def test_login_and_me():
    login_res = client.post("/api/v1/auth/login", json={
        "email": "test.artisan@artisanconnect.org",
        "password": "artisanpassword123"
    })
    assert login_res.status_code == 200
    token = login_res.json()["access_token"]

    me_res = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert me_res.status_code == 200
    assert me_res.json()["email"] == "test.artisan@artisanconnect.org"
    assert me_res.json()["role"] == "artisan"


def test_smart_catalog_suggestion():
    req_body = {
        "craft_type": "Terracotta Pottery",
        "raw_description": "Hand-formed earthenware water jug made with organic alluvial clay and terracotta slip",
        "estimated_hours": 5.0,
        "material_cost": 12.0
    }
    res = client.post("/api/v1/products/smart-suggest", json=req_body)
    assert res.status_code == 200
    data = res.json()
    assert "suggested_title" in data
    assert "enhanced_description" in data
    assert len(data["suggested_tags"]) > 0
    assert data["recommended_price"] > 0
    assert data["fair_trade_margin_percent"] > 0


def test_product_crud_and_fuzzy_search():
    # Login as artisan
    login_res = client.post("/api/v1/auth/login", json={
        "email": "test.artisan@artisanconnect.org",
        "password": "artisanpassword123"
    })
    artisan_token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {artisan_token}"}

    # Create product
    prod_payload = {
        "title": "Molela Terracotta Ritual Wall Plaque",
        "description": "Traditional hollow relief plaque of folk guardian deity hand-modeled by traditional potter.",
        "price": 48.0,
        "craft_type": "Terracotta Pottery",
        "materials": "Clay, straw, natural red slip",
        "dimensions": "25 x 35 cm",
        "production_time_days": 4,
        "stock_quantity": 10,
        "ai_tags": "terracotta, molela, wall-art, spiritual, sustainable, organic-clay"
    }
    create_res = client.post("/api/v1/products/", json=prod_payload, headers=headers)
    assert create_res.status_code == 201
    prod_id = create_res.json()["id"]

    # Fuzzy search for "molela clay wall"
    search_res = client.get("/api/v1/products/?q=molela+clay")
    assert search_res.status_code == 200
    search_results = search_res.json()
    assert len(search_results) >= 1
    assert any(p["id"] == prod_id for p in search_results)


def test_market_linkage_and_notifications():
    # 1. Login buyer
    buyer_login = client.post("/api/v1/auth/login", json={
        "email": "test.buyer@fairtrade.org",
        "password": "buyerpassword123"
    })
    buyer_token = buyer_login.json()["access_token"]
    buyer_headers = {"Authorization": f"Bearer {buyer_token}"}

    # 2. Login artisan to get profile ID
    artisan_login = client.post("/api/v1/auth/login", json={
        "email": "test.artisan@artisanconnect.org",
        "password": "artisanpassword123"
    })
    artisan_token = artisan_login.json()["access_token"]
    artisan_profile_id = artisan_login.json()["artisan_profile_id"]
    artisan_headers = {"Authorization": f"Bearer {artisan_token}"}

    # 3. Buyer submits inquiry
    inquiry_payload = {
        "artisan_id": artisan_profile_id,
        "quantity": 12,
        "proposed_unit_price": 45.0,
        "buyer_notes": "We would like to order 12 wall plaques for our spring gallery exhibition in New York."
    }
    inquire_res = client.post("/api/v1/linkages/inquire", json=inquiry_payload, headers=buyer_headers)
    assert inquire_res.status_code == 201
    linkage_id = inquire_res.json()["id"]
    assert inquire_res.json()["status"] == "pending"
    assert inquire_res.json()["match_score"] > 0

    # 4. Verify artisan received notification
    notif_res = client.get("/api/v1/notifications/", headers=artisan_headers)
    assert notif_res.status_code == 200
    notifications = notif_res.json()
    assert len(notifications) >= 1
    assert any("Inquiry" in n["title"] for n in notifications)

    # 5. Artisan accepts inquiry
    update_res = client.put(
        f"/api/v1/linkages/{linkage_id}/status",
        json={"status": "accepted", "artisan_notes": "Honored to craft these. Production will begin Monday."},
        headers=artisan_headers
    )
    assert update_res.status_code == 200
    assert update_res.json()["status"] == "accepted"

    # 6. Check artisan analytics dashboard
    dash_res = client.get("/api/v1/analytics/artisan/dashboard", headers=artisan_headers)
    assert dash_res.status_code == 200
    metrics = dash_res.json()
    assert metrics["total_inquiries"] >= 1
    assert metrics["accepted_linkages"] >= 1
    assert metrics["total_potential_revenue"] > 0

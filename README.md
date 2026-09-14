# ARTISAN CONNECT 🎨🤝

**AI-Driven Market Linkage & Smart Cataloging Platform for Marginalized Artisans**

ARTISAN CONNECT is an MVP platform designed to empower traditional, rural, and indigenous craftspeople by bridging the digital divide. It provides smart AI cataloging assistance, direct buyer market linkage matching without predatory intermediaries, real-time inquiry notifications, and sales performance analytics.

---

## 🏗️ Architecture & Tech Stack

```
                                  ┌────────────────────────────────────────┐
                                  │      Flutter Mobile Frontend           │
                                  │  - Artisan Profile & Registration      │
                                  │  - Smart Catalog with Fuzzy Search     │
                                  │  - Artisan KPI Metrics Dashboard       │
                                  │  - Buyer Direct Inquiries & Alerts     │
                                  └───────────────────┬────────────────────┘
                                                      │ REST / JSON (JWT Auth)
                                                      ▼
                                  ┌────────────────────────────────────────┐
                                  │      FastAPI Backend Engine            │
                                  │  ├── Authentication & RBAC (JWT)       │
                                  │  ├── Smart Cataloging AI Engine        │
                                  │  ├── Fuzzy Search & Match Filtering    │
                                  │  ├── Market Linkage Matching Logic     │
                                  │  ├── Notification Dispatcher           │
                                  │  └── Artisan Analytics Aggregator      │
                                  └───────────────────┬────────────────────┘
                                                      │ SQLAlchemy ORM
                                                      ▼
                                  ┌────────────────────────────────────────┐
                                  │     SQLite Database (Zero-Config)      │
                                  │  Users, Artisans, Products, Linkages,  │
                                  │  Inquiries, Notifications              │
                                  └────────────────────────────────────────┘
```

- **Frontend:** Flutter (Mobile Android/iOS, Web, Desktop) with Provider state management & Craft-Earth palette.
- **Backend:** Python 3.10+ / FastAPI with SQLAlchemy, Pydantic v2 schemas, JWT Bearer RBAC, and SQLite.
- **Fuzzy Search:** Token sort ratio matching across craft titles, descriptions, materials, and artisan regions.
- **AI Smart Cataloging:** Generates storytelling descriptions, SEO discovery tags, and fair-trade pricing bounds.

---

## 📁 Project Structure

```
artisan_connect/
├── backend/
│   ├── app/
│   │   ├── api/             # REST endpoints (auth, artisans, products, linkages, notifications, analytics)
│   │   ├── models/          # SQLAlchemy database models (User, ArtisanProfile, Product, MarketLinkage, Notification)
│   │   ├── schemas/         # Pydantic v2 request/response schemas
│   │   ├── services/        # AI Cataloging, Matching Engine, Fuzzy Search, Auth Security
│   │   ├── config.py        # Environment settings
│   │   ├── database.py      # SQLAlchemy session and engine setup
│   │   └── main.py          # FastAPI application entrypoint
│   ├── tests/
│   │   └── test_api.py      # Automated integration & endpoint test suite
│   ├── .env.example         # Sample environment variables
│   ├── requirements.txt     # Python backend dependencies
│   ├── seed.py              # Realistic sample data seeder
│   └── run.py               # Uvicorn server execution script
│
├── frontend/
│   ├── lib/
│   │   ├── config/          # API URLs, Earthy Craft Palette theme
│   │   ├── models/          # User, Artisan, Product, Linkage, Notification models
│   │   ├── services/        # HTTP API client, LocalStorage
│   │   ├── state/           # Auth, Product, Artisan, and Notification providers
│   │   ├── screens/         # Login, Register, Catalog, Product Detail, Add Listing, Dashboard, Notifications
│   │   ├── widgets/         # ArtisanBadge, MetricCard, ProductCard, SearchBarWidget
│   │   └── main.dart        # Flutter entry point
│   ├── pubspec.yaml         # Flutter dependencies
│   └── web/index.html       # Web runner support
│
└── README.md
```

---

## 🚀 Quick Start Guide (Run Locally)

### 1. Backend Setup (FastAPI)

#### Prerequisites:
- Python 3.10 or newer (`python --version`)

#### Step 1: Open terminal in backend directory
```bash
cd backend
```

#### Step 2: Create and activate virtual environment
- **On Windows (PowerShell):**
  ```powershell
  python -m venv venv
  .\venv\Scripts\Activate.ps1
  ```
- **On macOS / Linux:**
  ```bash
  python3 -m venv venv
  source venv/bin/activate
  ```

#### Step 3: Install dependencies
```bash
pip install -r requirements.txt
```

#### Step 4: Configure environment
Copy `.env.example` to `.env` (pre-configured with sensible defaults):
```bash
# On Windows
copy .env.example .env

# On Linux/macOS
cp .env.example .env
```

#### Step 5: Seed the database with realistic sample data
Populates authentic artisan makers (Jaipur Blue Pottery, Mithila Handloom, Swamimalai Bronze, Lucknow Chikankari), sample products, buyer linkages, and notifications:
```bash
python seed.py
```

#### Step 6: Start the FastAPI Server
```bash
python run.py
```
- Server URL: **`http://localhost:8000`**
- Interactive Swagger API Docs: **`http://localhost:8000/docs`**
- Alternative ReDoc: **`http://localhost:8000/redoc`**

---

### 2. Running Automated Tests

Run the backend integration test suite using `pytest`:
```bash
cd backend
pytest -v tests/test_api.py
```

The test suite validates:
1. Health check endpoint
2. Artisan and Buyer registration with role-based attributes
3. JWT Authentication & `/auth/me`
4. Smart Cataloging AI suggestion service (`/products/smart-suggest`)
5. Product CRUD and multi-field fuzzy search
6. Buyer inquiry creation & automatic match score computation
7. Artisan notification dispatch
8. Linkage acceptance and artisan dashboard KPI analytics aggregation

---

### 3. Frontend Setup (Flutter)

#### Non-Localhost Connectivity (Physical Mobile Devices & Cloud):
1. **In-App Configuration (Easiest):**
   Tap the **Server/Network icon (`DNS`)** on the top-right of the Sign In screen to enter your backend URL:
   - **Wi-Fi LAN (for physical phone):** `http://192.168.55.103:8000/api/v1`
   - **Cloud Deployment:** `https://artisan-connect-api.onrender.com/api/v1`
   *(Changes are automatically persisted to device storage)*.

2. **Compile-Time Cloud URL:**
   ```bash
   flutter run --dart-define=API_BASE_URL=https://your-cloud-api.com/api/v1
   ```

3. **Instant Free Public HTTPS Tunnel (Zero Deployment):**
   Expose your backend to any phone in the world with one command:
   ```bash
   # Using localtunnel:
   npx localtunnel --port 8000

   # Or using ngrok:
   ngrok http 8000
   ```
   Copy the generated `https://...` URL into the Flutter app or pass via `--dart-define`.

---

## ☁️ Cloud & Docker Deployment

### Deploy via Docker
```bash
cd backend
docker build -t artisan-connect-backend .
docker run -p 8000:8000 artisan-connect-backend
```

### Deploy to Render / Railway / Cloud Run
The repository includes a ready-to-deploy [`render.yaml`](../render.yaml) and [`backend/Dockerfile`](backend/Dockerfile):
1. Push this repository to GitHub.
2. Connect to [Render.com](https://render.com) or [Railway.app](https://railway.app).
3. Select "Web Service" -> it automatically detects Python, installs dependencies, runs `seed.py`, and exposes a public HTTPS endpoint.
4. Paste the public URL into your Flutter mobile app.

---

## 🔑 Demo User Credentials (Pre-seeded)

All seeded accounts use password: `password123`

| Role | Email | Name | Craft Specialty / Focus |
| :--- | :--- | :--- | :--- |
| **Artisan** | `ramlal.pottery@artisanconnect.org` | Ramlal Meena | Jaipur Blue Pottery & Terracotta (Rajasthan) |
| **Artisan** | `shanti.devi@artisanconnect.org` | Shanti Devi | Handloom & Mithila Folk Textiles (Bihar) |
| **Artisan** | `kavi.murugan@artisanconnect.org` | Kavi Murugan | Lost-Wax Bronze & Bell Metal (Tamil Nadu) |
| **Artisan** | `fatimah.begum@artisanconnect.org` | Fatimah Begum | Chikankari & Shadow Embroidery (Uttar Pradesh) |
| **Buyer** | `sarah.jenkins@ethicalliving.com` | Sarah Jenkins | Ethical Living Boutique (Austin, TX) |
| **Buyer** | `marco.rossi@heritageimports.eu` | Marco Rossi | Heritage Home Imports (Milan, Italy) |
| **Admin** | `admin@artisanconnect.org` | Artisan Connect Admin | System Administration |

*(Note: The Flutter login screen features convenient "Artisan Demo" and "Buyer Demo" autofill buttons for rapid testing).*

---

## 🔄 Core User Journey Walkthrough

### 1. Artisan Lists Product with AI Assistance:
1. Sign in as Artisan (`ramlal.pottery@artisanconnect.org`).
2. Tap **"New Listing"** or Floating Action Button in Catalog.
3. Enter Craft Type (e.g. `Terracotta Pottery`) and short description (e.g. `River clay water cooling pitcher hand-shaped on traditional wheel`).
4. Tap **"Auto-Enhance with AI"** (`POST /api/v1/products/smart-suggest`).
5. The system generates an enhanced title, cultural heritage narrative, recommended fair-trade price, detected materials, and SEO discovery tags.
6. Tap **"Publish Craft to Marketplace"**.

### 2. Buyer Discovers & Searches Crafts:
1. Browse the **Catalog** tab.
2. Type queries like `"blue pottery"`, `"handloom"`, `"clay planter"`, or select category chips.
3. The backend fuzzy search engine ranks items based on title, description, materials, and tags.
4. Tap on any craft card to view the heritage narrative and pricing transparency.

### 3. Market Linkage & Direct Inquiry:
1. On the product detail page, tap **"Direct Connect"**.
2. Specify procurement quantity (e.g., `25` units), proposed unit price, and delivery requirements.
3. Tap **"Send Market Linkage Inquiry"** (`POST /api/v1/linkages/inquire`).
4. The backend calculates a **Match Score (0-100%)** based on craft type, materials, budget, and geographic cluster.
5. A real-time **Notification** is dispatched to the artisan.

### 4. Artisan Receives Notification & Reviews Dashboard:
1. Switch to the artisan account.
2. The **Alerts** tab shows a badge and inquiry details.
3. The **Artisan Dashboard** updates:
   - **Pipeline Revenue** increases reflecting the order value.
   - **Buyer Inquiries** count updates with pending badge.
   - Artisan can tap **"Accept"** or **"Decline"** directly from the dashboard.
4. When accepted, an automated notification is dispatched back to the buyer!

---

## 📡 API Endpoints Overview

### Authentication (`/api/v1/auth`)
- `POST /register`: Register user (buyer or artisan with profile details).
- `POST /login`: JSON credentials login returning JWT bearer token.
- `POST /token`: OAuth2 form login for Swagger docs.
- `GET /me`: Authenticated user profile.

### Artisans (`/api/v1/artisans`)
- `GET /`: Directory of registered artisans with craft & region filters.
- `GET /{id}`: Public artisan profile with products.
- `GET /me/profile`: Authenticated artisan's own profile.
- `PUT /me/profile`: Update artisan craft, story, and bio.

### Products (`/api/v1/products`)
- `GET /`: Fuzzy search and filtered product catalog.
- `GET /{id}`: Product details with view counter increment.
- `POST /`: Create handcrafted listing (Artisan only).
- `POST /smart-suggest`: AI Smart Cataloging assistant (storytelling, tags, fair pricing).
- `GET /my/listings`: Artisan's own catalog listings.

### Market Linkages (`/api/v1/linkages`)
- `POST /inquire`: Buyer initiates sourcing inquiry with match scoring & notification.
- `POST /match`: Buyer runs AI matching engine against all artisans.
- `GET /artisan`: Artisan views incoming inquiries.
- `GET /buyer`: Buyer views outgoing procurement requests.
- `PUT /{id}/status`: Artisan accepts, declines, or updates linkage status.

### Notifications (`/api/v1/notifications`)
- `GET /`: List notifications for current user.
- `GET /unread-count`: Badge count of unread notifications.
- `PUT /{id}/read`: Mark notification as read.
- `PUT /mark-all-read`: Mark all notifications as read.

### Analytics (`/api/v1/analytics`)
- `GET /artisan/dashboard`: Aggregated artisan KPI metrics (potential revenue, conversion rate, views, inquiries, top crafts).

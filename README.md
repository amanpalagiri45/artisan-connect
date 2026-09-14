# ARTISAN CONNECT 🎨🤝

**AI-Driven Market Linkage & Smart Cataloging Platform for Marginalized Artisans**

ARTISAN CONNECT is an MVP platform designed to empower traditional, rural, and indigenous craftspeople by bridging the digital divide. It provides smart AI cataloging assistance, direct buyer market linkage matching without predatory intermediaries, real-time inquiry notifications, and sales performance analytics.

---

## 🏗️ Architecture & Tech Stack

```
                                  ┌────────────────────────────────────────┐
                                  │        React + Vite Frontend           │
                                  │  - Public Artisan Product Catalog      │
                                  │  - Product Search & Detail Views       │
                                  │  - Responsive Web Experience           │
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

- **Frontend:** React with Vite, Lucide icons, and responsive CSS for the public web catalog.
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
│   ├── src/
│   │   ├── api.js           # Public REST client
│   │   ├── App.jsx          # Guest catalog and product detail views
│   │   ├── main.jsx         # React entry point
│   │   └── styles.css       # Responsive web application styling
│   ├── package.json         # React and Vite dependencies
│   └── vite.config.js       # Vite configuration
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

### 3. Frontend Setup (React + Vite)

The web frontend lives in `frontend/` and uses React, Vite, and the existing FastAPI REST API.

```bash
cd frontend
npm install
npm run dev
```

### Google Sign-In Setup

The frontend uses the backend's server-side Google OAuth 2.0 / OpenID Connect flow. Google tokens are exchanged on the backend and the signed session is stored in an HTTP-only cookie; the browser does not store Google tokens.

1. In Google Cloud Console, create an OAuth client with application type **Web application**.
2. Add `http://localhost:8000/api/v1/auth/google/callback` as an authorized redirect URI.
3. Copy `backend/.env.example` to `backend/.env` and replace `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`.
4. Keep `FRONTEND_URL=http://localhost:5173` for local development.
5. Start the backend, then start the frontend and open `http://localhost:5173`.

For deployment, use HTTPS and set `GOOGLE_REDIRECT_URI` to the public backend callback URL, `FRONTEND_URL` to the public frontend URL, and `DEBUG=false`. Add the production callback URL to the Google Cloud OAuth credential.

### Deploy Publicly on Render

The root `render.yaml` defines both public services:

- `artisan-connect-api`: FastAPI backend
- `artisan-connect-web`: React static website

1. Push the repository to GitHub and create a Render Blueprint from the repository.
2. In the backend service environment, set `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`.
3. In Google Cloud Console, add this authorized redirect URI:
  `https://artisan-connect-api.onrender.com/api/v1/auth/google/callback`
4. Open the public website at:
  `https://artisan-connect-web.onrender.com`

If Render assigns different service URLs, update `FRONTEND_URL`, `GOOGLE_REDIRECT_URI`, and `VITE_API_BASE_URL` in the Blueprint or service settings to match them.

Open `http://localhost:5173`. To point the app at another API server:

```bash
npm run dev -- --host 0.0.0.0
# or set VITE_API_BASE_URL before building
```

Example production build configuration:

```powershell
$env:VITE_API_BASE_URL="https://your-api.example.com/api/v1"
npm run build
```

### 4. Frontend API Connectivity

Set `VITE_API_BASE_URL` when the backend is not running on localhost:

```powershell
$env:VITE_API_BASE_URL="https://your-cloud-api.com/api/v1"
npm run build
```

For local device or cloud testing, expose the backend with a tunnel:

```bash
   Expose your backend to any phone in the world with one command:
   ```bash
   # Using localtunnel:
   npx localtunnel --port 8000

   # Or using ngrok:
   ngrok http 8000
   ```
   Set the generated `https://...` URL in `VITE_API_BASE_URL` before building.

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
4. Set the public URL in `VITE_API_BASE_URL` before building the web frontend.

---

---

## 🔄 Core User Journey Walkthrough

### 1. Visitor Discovers & Searches Crafts:
1. Browse the **Catalog** tab.
2. Type queries like `"blue pottery"`, `"handloom"`, `"clay planter"`, or select category chips.
3. The backend fuzzy search engine ranks items based on title, description, materials, and tags.
4. Tap on any craft card to view the heritage narrative and pricing transparency.

### 2. Future Market Linkage:
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

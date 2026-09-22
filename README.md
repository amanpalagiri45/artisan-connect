# ARTISAN CONNECT 🎨🤝

**AI-Driven Market Linkage & Smart Cataloging Platform for Marginalized Artisans**

ARTISAN CONNECT is an MVP platform designed to empower traditional, rural, and indigenous craftspeople by bridging the digital divide. It provides smart AI cataloging assistance, direct buyer market linkage, product selling, and buyer discovery.

---

## 🛒 Selling and Buying Products

ARTISAN CONNECT supports a direct artisan-to-buyer marketplace.

### Artisans can sell products

1. Register or sign in with an **artisan** account.
2. Create a product listing with:
   - Product name and description
   - Craft type and materials
   - Price and available stock
   - Product dimensions and weight
   - Product image
3. Use the AI cataloging assistant to generate:
   - A market-ready product title
   - An enhanced product description
   - Search and SEO tags
   - Fair-trade price recommendations
4. Upload or take a product photo. The image-enhancement service improves brightness, color, contrast, sharpness, and image size while preserving the original photo.
5. Publish the product to the public catalog.
6. Manage, update, or remove listings from the artisan dashboard.

### Buyers can discover and buy products

1. Browse the public product catalog without signing in.
2. Search products by name, craft, material, artisan, or region.
3. Open a product to view its description, artisan story, price, and availability.
4. Send a direct inquiry to the artisan for a custom or wholesale order.
5. Authenticated buyers can purchase available stock through the product purchase endpoint.
6. The purchase flow checks stock, calculates the total price, reduces inventory, and marks the product unavailable when the remaining stock reaches zero.
7. Buyers can view their submitted inquiries and receive status notifications when an artisan accepts or declines an inquiry.

### Buyer and artisan matching

The market-linkage matching engine ranks suitable artisan-product matches using:

- Craft type and technique
- Materials and AI-generated tags
- Buyer budget and product price
- Preferred region
- Order quantity
- Verified cooperative status

Each match includes a score from 0 to 100 and an explanation of why the match was recommended. Buyers can use `POST /api/v1/linkages/match` to find suitable artisans, while artisans receive notifications when buyers submit inquiries.

### Important purchase note

The current purchase endpoint reserves stock and records the purchase calculation, but it does not process real payments. A payment provider such as Stripe, Razorpay, or PayPal must be integrated before accepting live payments.

---

## 🎙️ Voice Product Descriptions and Photo Enhancement

Artisans can speak their product description using browser speech recognition. The spoken words are converted into editable text in the product form. Artisans can also take or upload a product photo, which is processed by the backend image-enhancement service before it is attached to a listing.

Voice input works best in Chrome or Edge and requires microphone permission. Camera access requires a secure HTTPS deployment or localhost and requires camera permission.

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
                                  │  ├── Product Buying & Stock Management │
                                  │  ├── Product Photo Enhancement         │
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
- **Photo Enhancement:** Pillow-based processing improves uploaded artisan product photos.

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
│   ├── uploads/             # Enhanced product images
│   ├── tests/
│   │   └── test_api.py      # Automated integration & endpoint test suite
│   ├── .env.example         # Sample environment variables
│   ├── requirements.txt     # Python backend dependencies
│   ├── seed.py              # Realistic sample data seeder
│   └── run.py               # Uvicorn server execution script
│
├── frontend/
│   ├── src/
│   │   ├── api.js           # Public REST client and photo-upload client
│   │   ├── App.jsx          # Guest catalog and product detail views
│   │   ├── CameraCapture.jsx # Mobile camera capture component
│   │   ├── main.jsx         # React entry point
│   │   └── styles.css       # Responsive web application styling
│   ├── package.json         # React and Vite dependencies
│   └── vite.config.js       # Vite configuration
│
├── images/
│   ├── front/               # Homepage category cover images
│   ├── harvesting/          # Raw forest harvest images
│   ├── kondapalli/          # Kondapalli Bommalu images
│   ├── sarees/              # Kalamkari saree images
│   └── Sikki Grass/         # Sikki grass product images
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

```bash
cd frontend
npm install
npm run dev
```

For mobile camera testing on a local network:

```bash
npm run dev -- --host 0.0.0.0
```

Camera and microphone features require permission. For phone testing, use HTTPS or a secure tunnel such as localtunnel/ngrok.

---

## 📡 API Endpoints Overview

### Authentication (`/api/v1/auth`)
- `POST /register`: Register a buyer or artisan.
- `POST /login`: Log in and receive a JWT bearer token.
- `GET /me`: Get the authenticated user profile.

### Products (`/api/v1/products`)
- `GET /`: Browse and search products.
- `GET /{id}`: View product details.
- `POST /`: Create a product listing as an artisan.
- `POST /{id}/buy`: Reserve/buy available stock as an authenticated buyer.
- `POST /smart-suggest`: Generate AI catalog title, description, tags, and pricing suggestions.
- `GET /my/listings`: View the artisan's listings.

### AI Product Tools (`/api/v1/ai`)
- `POST /enhance-product-photo`: Upload a JPG, PNG, or WebP product image and receive an enhanced image URL.

### Market Linkages (`/api/v1/linkages`)
- `POST /inquire`: Buyer submits a sourcing or product inquiry.
- `POST /match`: Match buyer requirements with suitable artisans and products.
- `GET /artisan`: Artisan views incoming buyer inquiries.
- `GET /buyer`: Buyer views submitted inquiries.
- `PUT /{id}/status`: Artisan accepts, declines, or updates an inquiry.

---

## 🔄 Core User Journeys

### Artisan selling journey
1. Register as an artisan.
2. Speak the product description or type it manually.
3. Take or upload a product photo.
4. Enhance the photo and preview it.
5. Use AI catalog suggestions to improve the title, description, tags, and price.
6. Add stock quantity and publish the listing.
7. Receive buyer inquiries and match notifications.

### Buyer purchasing journey
1. Browse or search the catalog.
2. Open a product listing.
3. Review the artisan story, image, price, and stock.
4. Sign in as a buyer.
5. Purchase available stock or send a direct inquiry.
6. Receive notifications about the inquiry or order status.

---

## ⚠️ Production Notes

- The purchase endpoint currently manages stock and returns the total price; integrate Stripe, Razorpay, or another payment provider before accepting real payments.
- Store uploaded images in object storage such as S3 or Cloudinary for production deployments instead of local disk.
- Use HTTPS for camera and microphone access.
- Set a strong production `SECRET_KEY` in the environment.

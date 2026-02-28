# Material Map - FastAPI Backend Setup Guide

## 🚀 Quick Start

### Prerequisites
- Python 3.10+
- Flutter 3.0+
- pip (Python package manager)

## 🏗️ Backend Setup

### Step 1: Navigate to Backend Directory
```bash
cd backend
```

### Step 2: Create Virtual Environment
```bash
# macOS/Linux
python -m venv venv
source venv/bin/activate

# Windows
python -m venv venv
venv\Scripts\activate
```

### Step 3: Install Dependencies
```bash
pip install -r requirements.txt
```

### Step 4: Configure Environment
```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your configuration
nano .env  # or use your preferred editor
```

**Important settings to update in `.env`:**
```env
# JWT Secret (change this!)
SECRET_KEY=your-super-secret-key-with-at-least-32-characters

# If using Supabase for image storage
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your_supabase_anon_key
SUPABASE_BUCKET=material-map

# Database (SQLite by default)
DATABASE_URL=sqlite:///./material_map.db

# Server Configuration
DEBUG=False
HOST=0.0.0.0
PORT=8000
```

### Step 5: Run the Backend Server
```bash
python main.py
```

You should see:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
```

**API Documentation will be available at:**
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## 📱 Flutter App Setup

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Update API URL
**File:** `lib/core/constants/api_config.dart`

Update the `API_URL` based on your environment:

```dart
// For local development on your machine
static const String API_URL = 'http://localhost:8000/api';

// For Android Emulator
static const String API_URL = 'http://10.0.2.2:8000/api';

// For iOS Simulator
static const String API_URL = 'http://127.0.0.1:8000/api';

// For Physical Device (replace with your machine IP)
static const String API_URL = 'http://192.168.1.100:8000/api';  // Replace with your IP
```

### Step 3: Get Your Machine IP Address

If using a physical device or Android emulator, you need your machine's IP:

**macOS/Linux:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Windows:**
```bash
ipconfig
```

### Step 4: Run the Flutter App
```bash
flutter run
```

## 🗂️ Project Structure

```
material_map/
├── backend/                          # FastAPI Backend
│   ├── main.py                      # Application entry point
│   ├── config.py                    # Configuration management
│   ├── database.py                  # Database models
│   ├── schemas.py                   # API request/response schemas
│   ├── auth.py                      # Authentication utilities
│   ├── storage.py                   # Supabase integration
│   ├── seed.py                      # Database seeding
│   ├── routes/                      # API route handlers
│   │   ├── auth.py                 # Authentication endpoints
│   │   ├── products.py             # Product endpoints
│   │   ├── stores.py               # Store endpoints
│   │   └── inventory.py            # Inventory endpoints
│   ├── requirements.txt             # Python dependencies
│   ├── .env.example                 # Environment template
│   └── README.md                    # Backend documentation
│
├── lib/                             # Flutter App
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_config.dart      # API configuration
│   │   │   └── app_constants.dart
│   │   ├── services/
│   │   │   └── api_client.dart      # HTTP client service
│   │   └── theme/
│   ├── data/
│   │   ├── models/                  # Data models (JSON serializable)
│   │   └── repositories/            # Data repositories (API calls)
│   ├── logic/
│   │   └── providers/               # State management providers
│   └── presentation/
│       └── screens/                 # UI screens
│
├── pubspec.yaml                     # Flutter dependencies (Firebase removed)
└── FIREBASE_MIGRATION.md            # Migration guide
```

## 🔐 Database Seeding

The database is automatically populated with sample data on the first run. To manually reset:

```bash
cd backend
python seed.py
```

**Sample data includes:**
- 5 stores with locations
- 30 products across 6 categories
- Inventory items with varying prices

## 🖼️ Image Storage with Supabase

### Setup Supabase
1. Go to https://supabase.com and create an account
2. Create a new project
3. Create a storage bucket named `material-map`
4. Configure bucket to allow public read access
5. Get your project URL and API key from settings

### Configure in Backend
Update `.env`:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your_anon_api_key
SUPABASE_BUCKET=material-map
```

## 🧪 Testing

### Backend Health Check
```bash
curl http://localhost:8000/health
```

### Test Authentication
```bash
# Register
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Login
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Access API Docs
- Visit http://localhost:8000/docs in your browser
- Try out API endpoints interactively

## 🐛 Troubleshooting

### Backend Issues

**Port Already in Use:**
```bash
# Change port in .env
PORT=8001

# Or stop the process using port 8000
lsof -ti:8000 | xargs kill
```

**Database Locked:**
- Stop the backend
- Delete `material_map.db`
- Restart backend

**Supabase Connection Failed:**
- Verify SUPABASE_URL and SUPABASE_KEY in `.env`
- Check that project is active on Supabase dashboard
- Ensure storage bucket exists

### Flutter Issues

**"Connection Refused" Errors:**
1. Verify backend is running: `python main.py`
2. Check API URL in `api_config.dart`
3. For emulator, use `http://10.0.2.2:8000/api`
4. For physical device, get your machine IP: `ifconfig`

**"Invalid Token" Errors:**
- Clear app data: `flutter clean`
- Restart app
- Re-login with credentials

**Build Errors After Removing Firebase:**
1. Run: `flutter pub get`
2. Run: `flutter clean`
3. Run: `flutter pub get` again
4. Run: `flutter run`

## 📦 Production Deployment

### Backend (FastAPI)

1. **Database:** Use PostgreSQL instead of SQLite
```bash
DATABASE_URL=postgresql://user:password@localhost/material_map
```

2. **Deploy with Gunicorn:**
```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:8000 main:app
```

3. **Use HTTPS:** Set up Nginx reverse proxy
4. **Update CORS:** Change `allow_origins` in `main.py` to specific domain
5. **Change SECRET_KEY:** Use a cryptographically secure key

### Flutter App

1. Build for release:
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

2. Update API URL to production endpoint
3. Sign and publish app

## 📚 Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Flutter Provider Package](https://pub.dev/packages/provider)
- [Supabase Documentation](https://supabase.com/docs)
- [SQLAlchemy ORM](https://docs.sqlalchemy.org/)

## ✅ Verification Checklist

- [ ] Backend is running (`python main.py`)
- [ ] API docs accessible at `http://localhost:8000/docs`
- [ ] `.env` file configured with SECRET_KEY
- [ ] API URL updated in `api_config.dart`
- [ ] `flutter pub get` executed successfully
- [ ] No Firebase references in build errors
- [ ] App runs without build errors
- [ ] Can register/login with new backend
- [ ] Search functionality works
- [ ] Product details load correctly

## 🎉 You're Ready!

Your Material Map app is now running with FastAPI backend and Supabase storage!

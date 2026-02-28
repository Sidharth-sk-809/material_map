# Material Map - Store Inventory & Price Comparison App

A full-stack Flutter application for comparing product prices across multiple stores. Built with a **Flutter frontend** + **Flask backend** + **SQLite database**.

> **New here?** Follow the [Quick Setup](#quick-setup) section below!

---

## 📱 What is Material Map?

Material Map helps users:
- 🔍 Find products across multiple stores
- 💰 Compare prices to find the best deals
- 📍 Locate stores near them
- 🛒 Browse by category (Grocery, Stationery, Household, Plumbing, Electronics)

---

## 🚀 Quick Setup

### Prerequisites

Before you start, ensure you have installed:

1. **Flutter** (v3.0.0+)
   ```bash
   flutter --version
   ```
   [Install Flutter](https://flutter.dev/docs/get-started/install)

2. **Python** (v3.8+)
   ```bash
   python --version
   ```
   [Install Python](https://www.python.org/downloads/)

3. **Git** (optional, for cloning)
   ```bash
   git --version
   ```

---

## 📋 Project Structure

```
material_map/
├── backend/              # Flask REST API
│   ├── main.py          # Entry point
│   ├── requirements.txt  # Python dependencies
│   ├── routes/          # API endpoints
│   ├── database.py      # Database config
│   └── seed.py          # Demo data
├── lib/                 # Flutter app code
│   ├── main.dart        # App entry
│   ├── presentation/    # UI screens
│   ├── logic/          # Business logic
│   └── data/           # API & models
├── pubspec.yaml        # Flutter dependencies
└── README.md           # This file
```

---

## ⚙️ Setup Instructions

### Step 1: Set Up the Backend

#### 1a. Create Python Virtual Environment
```bash
cd material_map
python -m venv .venv
```

#### 1b. Activate Virtual Environment

**On macOS/Linux:**
```bash
source .venv/bin/activate
```

**On Windows:**
```bash
.venv\Scripts\activate
```

#### 1c. Install Python Dependencies
```bash
pip install -r backend/requirements.txt
```

#### 1d. Configuration
The app uses **SQLite database** by default (no setup needed!).

To use **Supabase PostgreSQL** instead:
1. Create a [Supabase](https://supabase.com) project
2. Update `.env` file:
   ```env
   DATABASE_URL=postgresql://user:password@host:port/database
   ```

#### 1e. Start the Backend Server

**On macOS/Linux:**
```bash
python backend/main.py
```

**On Windows:**
```bash
python backend\main.py
```

✅ You should see:
```
Starting Flask server on 0.0.0.0:9000
 * Serving Flask app 'main'
 * Debug mode: off
```

**Keep this terminal open!** The backend must stay running while you use the app.

---

### Step 2: Run the Flutter App

**In a new terminal window** (keep the backend running in the first one):

#### 2a. Get Flutter Dependencies
```bash
flutter pub get
```

#### 2b. Run on Android Emulator

**Option A: Using Android Studio Emulator**
```bash
flutter run
```

**Option B: Specify Device**
```bash
flutter run -d emulator-5554
```

**Option C: Using Chrome (Web Preview)**
```bash
flutter run -d chrome
```

#### 2c. Run on Physical Device
```bash
flutter run
```
*(Make sure USB debugging is enabled)*

---

## 🎯 Testing the App

### Verify Backend is Running
```bash
curl http://localhost:9000/api/health
```

Expected response:
```json
{
  "message": "Material Map API is running",
  "status": "healthy",
  "database": "sqlite",
  "timestamp": "2026-02-28T..."
}
```

### Test API Endpoints
```bash
# Get all products
curl http://localhost:9000/api/products

# Get products by category
curl http://localhost:9000/api/products/category/grocery

# Get all stores
curl http://localhost:9000/api/stores
```

### Test the App
1. Launch the Flutter app
2. You should see a **splash screen**
3. Tap **Grocery** category
4. See all products with 3 cheapest store prices
5. Tap a product to see full inventory

---

## 📊 Database

### Default: SQLite (Recommended)
- **File:** `material_map.db`
- **Auto-seeded:** 13 stores + 36 products + 38 inventory items
- **No setup needed!** Database creates and seeds automatically on first run

### Optional: Supabase PostgreSQL
- Update `.env` with your database credentials
- Supported for cloud deployment

---

## 🛠️ Troubleshooting

### Backend Won't Start

**Error:** `Port 9000 is in use`
```bash
# Kill process using port 9000
lsof -i :9000 | grep LISTEN | awk '{print $2}' | xargs kill -9

# Then restart
python backend/main.py
```

**Error:** `ModuleNotFoundError: No module named 'flask'`
```bash
# Make sure virtual environment is activated
source .venv/bin/activate
pip install -r backend/requirements.txt
```

### Flutter App Says "No Data"

1. ✅ Make sure backend is running: `curl http://localhost:9000/api/health`
2. ✅ Check Flask terminal for errors
3. ✅ Try hot reload: Press `R` in Flutter terminal
4. ✅ Restart app completely: Press `q` then `flutter run`

### Database Issues

**To reset database:**
```bash
rm material_map.db
python backend/main.py  # Will recreate with seed data
```

---

## 📚 API Documentation

Full API docs available in [backend/README.md](backend/README.md)

### Key Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/health` | GET | Server health check |
| `/api/products` | GET | All products |
| `/api/products/category/{cat}` | GET | Products by category |
| `/api/stores` | GET | All stores |
| `/api/stores/category/{cat}` | GET | Stores by category |
| `/api/inventory` | GET | All inventory items |

---

## 🔄 Development Workflow

### Hot Reload (Faster Development)
While app is running, press `R` in Flutter terminal to reload without restart.

### Full Restart
```bash
# In Flutter terminal, press:
q    # Quit
flutter run  # Restart
```

### Code Changes

**Backend changes:**
1. Edit `backend/main.py` or routes
2. Backend restarts automatically (if using debug mode)

**Frontend changes:**
1. Edit Flutter files in `lib/`
2. Press `R` for hot reload

---

## 📦 Building for Release

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-app.apk`

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

---

## 🔐 Environment Variables

Create `.env` file in project root:

```env
# Backend
SECRET_KEY=your-secret-key-here
DEBUG=False
ENVIRONMENT=development

# Database (Optional - SQLite is default)
DATABASE_URL=sqlite:///material_map.db

# Supabase (Optional - for cloud database)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-key
```

---

## 📱 Features

✅ **Product Browsing** - Browse by 6 categories
✅ **Price Comparison** - See same product across stores
✅ **Store Locator** - Distance-based store sorting
✅ **Search** - Search products by name/brand
✅ **Deals** - Filter products with discounts
✅ **Responsive Design** - Works on phones & tablets
✅ **Real-time Data** - Flask backend with SQLite/Supabase

---

## 🤝 Contributing

Want to improve Material Map?

1. **Found a bug?** Check existing [issues](../../issues)
2. **Have a feature idea?** Open a [discussion](../../discussions)
3. **Want to code?** Fork and submit a pull request

---

## 📄 License

This project is licensed under the MIT License.

---

## 📞 Support

- **Backend Issues?** Check [backend/README.md](backend/README.md)
- **Flutter Issues?** Check [Flutter docs](https://flutter.dev)
- **Database Issues?** Check [SQLite docs](https://www.sqlite.org/docs.html)

---

## 🎉 You're All Set!

You now have a fully functional store inventory app with:
- ✅ Flutter Frontend
- ✅ Flask Backend
- ✅ SQLite Database
- ✅ 13 Stores + 36 Products + 38 Inventory Items

**Start exploring!** 🚀

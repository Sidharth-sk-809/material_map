# Quick Start - FastAPI Backend for Material Map

## 🚀 Start Backend in 3 Commands

```bash
cd backend
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt && cp .env.example .env
python main.py
```

Backend will run on: **http://localhost:8000**
API Docs: **http://localhost:8000/docs**

## 📱 Start Flutter App in 3 Commands

```bash
# Make sure backend is running!
flutter clean
flutter pub get
flutter run
```

## 🔑 Test Login

**Auto-seeded credentials:**
- Email: `test@example.com`
- Password: `password123`

(Or register a new account)

## 📝 Required Configuration

### 1. Backend `.env` file

Create `/backend/.env`:
```
SECRET_KEY=your-very-long-secret-key-at-least-32-chars
DATABASE_URL=sqlite:///./material_map.db
DEBUG=False
HOST=0.0.0.0
PORT=8000
```

### 2. Flutter API URL

Edit `lib/core/constants/api_config.dart`:
```dart
// For local machine/testing:
static const String API_URL = 'http://localhost:8000/api';

// For Android emulator:
static const String API_URL = 'http://10.0.2.2:8000/api';

// For physical device (replace IP):
static const String API_URL = 'http://192.168.1.100:8000/api';
```

## ✨ What's Included

✅ Complete FastAPI backend with all endpoints
✅ SQLite database with auto-seeding
✅ JWT authentication with token persistence
✅ 30 products across 6 categories
✅ 5 stores with geolocation
✅ Pricing comparison
✅ Search functionality
✅ User registration & login
✅ Supabase integration (optional for images)

## 📚 Documentation Files

- `FASTAPI_SETUP.md` - Complete setup guide
- `FIREBASE_MIGRATION.md` - What changed from Firebase
- `MIGRATION_COMPLETE.md` - Full feature summary
- `MIGRATION_CHECKLIST.md` - Verification checklist
- `/backend/README.md` - Backend API docs

## 🆘 Troubleshooting

**Backend won't start?**
```bash
# Make sure you're in the backend directory
cd backend
# Make sure venv is activated (you should see (venv) in prompt)
source venv/bin/activate
# Try again
python main.py
```

**Flutter connection errors?**
- Verify backend is running
- Check API URL matches your setup
- Use `http://10.0.2.2:8000/api` for Android emulator
- Use your machine IP for physical device

**Login fails?**
- Verify backend completed seeding (check console)
- Use `test@example.com` / `password123`
- Check backend logs for errors

## 🎯 Next Steps

1. ✅ Start backend: `python main.py`
2. ✅ Test API: Visit http://localhost:8000/docs
3. ✅ Update API URL in Flutter app
4. ✅ Run app: `flutter run`
5. ✅ Test login with credentials above

**That's it! You're ready to go! 🎉**

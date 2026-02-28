# Firebase to FastAPI Migration Guide

## Overview

This document outlines the complete migration from Firebase to FastAPI backend with Supabase storage.

## Changes Made

### Backend
- ✅ Created FastAPI backend in `/backend` directory
- ✅ Implemented all API endpoints (auth, products, stores, inventory)
- ✅ Set up SQLite database (can be migrated to PostgreSQL)
- ✅ Integrated Supabase for image storage
- ✅ Created database seeding with sample data

### Flutter App
- ✅ Removed Firebase dependencies from `pubspec.yaml`
- ✅ Added `dio` and `http` packages for API communication
- ✅ Created `ApiClient` service for HTTP requests
- ✅ Created `ApiConfig` for API endpoints
- ✅ Updated all models to use JSON serialization
- ✅ Updated repositories to use HTTP API calls
- ✅ Updated providers to work with new authentication
- ✅ Removed Firebase initialization from `main.dart`
- ✅ Updated `AuthProvider` to use token-based authentication

## API Endpoints

### Base URL
```
http://localhost:8000/api
```

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `GET /auth/me?token=TOKEN` - Get current user
- `POST /auth/logout` - Logout

### Products
- `GET /products` - Get all products
- `GET /products/category/{category}` - Get products by category
- `GET /products/search?q=query` - Search products
- `GET /products/{id}` - Get product by ID

### Stores
- `GET /stores` - Get all stores
- `GET /stores/nearby?latitude=x&longitude=y&radius=10` - Get nearby stores
- `GET /stores/{id}` - Get store by ID

### Inventory
- `GET /inventory` - Get all inventory
- `GET /inventory/product/{product_id}` - Get product inventory
- `GET /inventory/store/{store_id}` - Get store inventory
- `GET /inventory/{id}` - Get inventory item

## Setting Up the Backend

### 1. Install Dependencies
```bash
cd backend
pip install -r requirements.txt
```

### 2. Configure Environment
```bash
cp .env.example .env
```

Edit `.env` and add:
- Supabase URL and key
- Secret key for JWT
- Database URL (defaults to SQLite)

### 3. Run the Backend
```bash
python main.py
```

The API will be available at `http://localhost:8000`

## Setting Up Supabase

1. Create a Supabase project at https://supabase.com
2. Create a storage bucket named `material-map`
3. Get your project URL and API key
4. Add to `.env`:
```env
SUPABASE_URL=your_url
SUPABASE_KEY=your_key
SUPABASE_BUCKET=material-map
```

## Flutter Configuration

### Update API URL
In `lib/core/constants/api_config.dart`, update `API_URL`:

```dart
// For local machine
static const String API_URL = 'http://localhost:8000/api';

// For Android emulator
static const String API_URL = 'http://10.0.2.2:8000/api';

// For physical device  
static const String API_URL = 'http://YOUR_MACHINE_IP:8000/api';
```

### Run Flutter App
```bash
flutter pub get
flutter run
```

## Token Storage

Tokens are automatically stored in SharedPreferences:
- Key: `access_token`
- Retrieved on app startup for persistent login

## Authentication Flow

```
User Input (email, password)
    ↓
AuthProvider.signIn() / register()
    ↓
AuthRepository → API /auth/login or /auth/register
    ↓
Save token to SharedPreferences
    ↓
API Client includes token in headers automatically
```

## Removed Firebase Components

### From `pubspec.yaml`
- firebase_core
- firebase_auth
- cloud_firestore
- firebase_storage

### From `lib/data/repositories/`
- Firebase constructors and methods
- Firestore-specific queries
- Firebase error handling

### From `lib/main.dart`
- Firebase.initializeApp()
- kFirebaseReady constant

### From Android
- google-services.json integration (still present but not used)

### Files to Delete (if not needed)
- `android/app/google-services.json` (optional, can keep for reference)
- Firebase configuration files in iOS (if present)

## Database Seeding

Sample data is automatically loaded on first start:
- 5 stores with locations
- 30 products across 6 categories
- Inventory items with varying prices

To manually reseed:
```bash
python seed.py
```

## Features Maintained

✅ User authentication (registration, login)
✅ Product search
✅ Product browsing by category
✅ Price comparison across stores
✅ Store locations with coordinates
✅ Inventory management
✅ Location-based store finding
✅ Image loading (via Supabase or fallback URLs)

## Breaking Changes

- Token-based authentication instead of Firebase Auth
- No real-time database (Firestore) - use REST API instead
- No automatic user presence tracking
- Manual token refresh needed (currently not implemented)

## Future Enhancements

1. Add JWT token refresh logic
2. Implement real-time updates with WebSockets
3. Add image upload functionality
4. Set up admin dashboard
5. Implement analytics
6. Add caching strategies

## Troubleshooting

### Connection Refused
- Ensure backend is running: `python main.py`
- Check API URL in `api_config.dart`
- For emulator, use `http://10.0.2.2:8000/api`

### 401 Unauthorized
- Token might be expired (need refresh logic)
- Clear app data and re-login
- Check SharedPreferences for stored token

### CORS Issues
- Backend allows all origins by default
- For production, update CORS in `main.py`

### Database Errors
- Ensure backend directory is writable
- SQLite file: `backend/material_map.db`

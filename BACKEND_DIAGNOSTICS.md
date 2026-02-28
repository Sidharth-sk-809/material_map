# Backend Diagnostics & Deployment Guide

## Issues Fixed

### 1. **CORS Configuration Enhanced**
   - Updated CORS to be more explicit with proper headers
   - Added support for OPTIONS requests
   - Configured credentials and max-age

### 2. **Error Handling Added**
   - All major routes now have try-catch blocks
   - Returns proper error messages with status codes
   - Database connection errors are handled gracefully

### 3. **New Diagnostic Endpoints**
   - `/api/status` - Comprehensive status check with data counts
   - `/api/seed` - Initialize database with demo data if empty

### 4. **Procfile Created**
   - Configured for Render deployment with gunicorn

### 5. **Database Initialization**
   - Backend now auto-creates tables on startup
   - Checks database connectivity

---

## Testing the Backend Locally

### 1. Start the Backend
```bash
cd /Users/sidharth_sk/Desktop/mini/prj/material_map
source .venv/bin/activate
python backend/main.py
```

You should see:
```
Starting Flask server on 0.0.0.0:9000
```

### 2. Test Health Endpoint
```bash
curl http://localhost:9000/health
```

Expected response:
```json
{"status": "healthy"}
```

### 3. Test Status Endpoint
```bash
curl http://localhost:9000/api/status
```

Expected response includes database connection status and data counts.

### 4. Seed Database (if needed)
```bash
curl -X POST http://localhost:9000/api/seed
```

### 5. Test Product Endpoint
```bash
curl http://localhost:9000/api/products
```

---

## Deployment Issues on Render

### **Issue 1: Frontend Can't Connect**

**Symptoms:**
- Frontend shows "Connection timeout" or no data appears
- Console shows CORS errors

**Solutions:**

1. **Verify Render Environment Variables:**
   - Go to Render Dashboard → Material Map Service → Environment
   - Ensure these are set:
     ```
     DATABASE_URL=<your-supabase-connection-string>
     SECRET_KEY=<your-secret-key>
     HOST=0.0.0.0
     PORT=10000
     ```

2. **Check Database Connection:**
   ```bash
   # In Render dashboard, open Shell and run:
   curl https://material-map.onrender.com/api/status
   ```

3. **If Database is Empty:**
   ```bash
   # Seed the database
   curl -X POST https://material-map.onrender.com/api/seed
   ```

### **Issue 2: Port Not Matching**
- Frontend expects: `https://material-map.onrender.com`
- Render automatically assigns port (shown in logs)
- Procfile correctly uses environment PORT variable

### **Issue 3: Database Connection String Format**
- Ensure DATABASE_URL uses correct format:
  ```
  postgresql+psycopg://user:password@host:5432/database
  ```
- Backend automatically converts from `postgresql://` format

---

## Frontend Configuration

The frontend is correctly configured in:
- **File:** `lib/core/constants/api_config.dart`
- **API_URL:** `https://material-map.onrender.com/api`

### If You Need to Change Backend URL:
```dart
// lib/core/constants/api_config.dart
static const String API_URL = 'https://your-new-url.onrender.com/api';
```

---

## Key Improvements Made

1. ✅ **Better Error Messages** - All endpoints now return meaningful errors
2. ✅ **Database Auto-Init** - Tables are created automatically on startup
3. ✅ **CORS Fixed** - Comprehensive CORS configuration for all methods
4. ✅ **Status Monitoring** - New endpoints to check system health
5. ✅ **Graceful Degradation** - API continues running even if database operations fail

---

## Render Deployment Checklist

- [ ] Environment variables set in Render dashboard
- [ ] DATABASE_URL correctly formatted
- [ ] Procfile is in root directory
- [ ] Backend code is committed to git
- [ ] Database connection tested with `/api/status`
- [ ] Demo data seeded with `/api/seed`
- [ ] Frontend URL in `api_config.dart` matches Render URL

---

## Database Seeding

The backend includes comprehensive demo data with:
- 13 stores (organized by category: grocery, stationery, household, plumbing, electronics)
- 40+ products with brand and size information
- 300+ inventory items with varied pricing and discounts

To seed: Call `POST /api/seed` endpoint

---

## Debugging Tips

1. **Check Render Logs:**
   - Render Dashboard → Service → Logs tab
   - Look for "Starting Flask server" message

2. **Test Each Endpoint:**
   ```bash
   curl https://material-map.onrender.com/health
   curl https://material-map.onrender.com/api/health
   curl https://material-map.onrender.com/api/status
   curl https://material-map.onrender.com/api/products
   ```

3. **Test with Frontend:**
   - Open Flutter app
   - Check Device Logs (Android Studio)
   - Look for actual error messages

4. **Common Issues:**
   - 502 Bad Gateway = Backend not running
   - 503 Service Unavailable = Database connection error
   - 500 Internal Server Error = Check Render logs for details

# 🚨 Render Backend Not Responding - Complete Fix Guide

## The Problem
Your Flutter app shows "No products found" because:
1. **Render backend is either not running or failing to start**
2. **Database connection is not configured**

---

## ✅ Solution: 3-Step Fix

### Step 1: Verify Render Service Status

1. **Go to Render Dashboard:** https://dashboard.render.com
2. **Find your service:** "material-map"
3. **Check the status indicator:**
   - 🟢 **Green** = Running (should be this)
   - 🔴 **Red/Gray** = Failed or Stopped
4. **Click on the service** to open detailed view
5. **Go to Logs tab** at the top
6. **Look for error messages**, especially:
   - `gunicorn: command not found`
   - `ModuleNotFoundError`
   - `connection refused` (database)
   - `Exit code 1` or `Exit code 127`

---

### Step 2: Set Required Environment Variables

**If the service is stopped/failed, it's likely because DATABASE_URL is missing.**

In Render Dashboard:
1. **Click on material-map service**
2. **Click Environment tab**
3. **Add these variables:**

```
DATABASE_URL = postgresql+psycopg://postgres:YOUR_PASSWORD@db.tqdrxzmjjgbhbbvqyfmn.supabase.co:5432/postgres

SECRET_KEY = Material-Map-Secret-Key-2026

ENVIRONMENT = production

DEBUG = False
```

**Where to get DATABASE_URL:**
- Go to: https://app.supabase.com
- Select your project
- Settings → Database → Connection string → Copy "URI"
- Replace `postgresql://` with `postgresql+psycopg://`
- The password is in the connection string

**Important:** Make sure **Sync is OFF** for DATABASE_URL (it's confidential)

---

### Step 3: Redeploy

1. **In Render Dashboard**, on the material-map service page:
2. **Click "Manual Deploy"** button (top right)
3. **Wait 2-3 minutes** for deployment
4. **Go to Logs tab** and look for:
   - `gunicorn workers starting`
   - `✅ Database tables initialized`
   - If you see errors, read the error message carefully

---

## 🔍 Verify It's Working

### Quick Test
```bash
curl https://material-map.onrender.com/health
```

Should return instantly:
```json
{"status": "healthy"}
```

### Full Status Check
```bash
curl https://material-map.onrender.com/api/status
```

Should show:
```json
{
  "status": "healthy",
  "database_connected": true,
  "database_type": "PostgreSQL",
  "environment": "production"
}
```

### Get Products
```bash
curl https://material-map.onrender.com/api/products | jq '.[0]'
```

Should return a product object.

---

## 📊 If Database is Empty

After confirming the backend is running and PostgreSQL is connected:

```bash
curl -X POST https://material-map.onrender.com/api/seed
```

This will:
- Create database tables
- Add 13 stores
- Add 40+ products
- Add 300+ inventory items

---

## 🐛 Troubleshooting Each Step

### "Backend Not Responding" / "Connection Timeout"
- Check Render service status (should be green)
- Check for errors in Render Logs tab
- If offline: click "Restart" button in Render
- Redeploy: click "Manual Deploy"

### "Database Connection Failed"
- Check DATABASE_URL is set in Render Environment
- Verify password is correct in connection string
- Ensure format matches: `postgresql+psycopg://...@...`
- Try testing the Supabase connection directly

### "ModuleNotFoundError"
- Missing imports in main.py
- Click "Manual Deploy" to force reinstall dependencies
- Check requirements.txt has all needed packages

### "gunicorn: command not found"
- Render didn't install dependencies
- Check requirements.txt exists in root
- requirements.txt must be in `/backend/requirements.txt`
- Ensure Procfile is in project root

---

## 🔧 Complete Checklist

### Code Side
- [ ] `backend/main.py` exists and imports successfully
- [ ] `requirements.txt` exists in `/backend/`
- [ ] `Procfile` exists in project root with:
  ```
  web: gunicorn --chdir backend --bind 0.0.0.0:$PORT --workers 4 --timeout 60 --access-logfile - --error-logfile - main:app
  ```
- [ ] All changes committed to git

### Render Configuration
- [ ] Service name: "material-map"
- [ ] Build command: (default is fine)
- [ ] Start command: (using Procfile)
- [ ] Environment variables set:
  - [ ] `DATABASE_URL` (from Supabase)
  - [ ] `SECRET_KEY` (any string)
  - [ ] `ENVIRONMENT=production`
  - [ ] `DEBUG=False`

### Database
- [ ] Supabase project exists
- [ ] Can access https://app.supabase.com
- [ ] Connection string obtained
- [ ] DATABASE_URL added to Render env vars

### Testing
- [ ] `curl https://material-map.onrender.com/health` returns 200
- [ ] `curl https://material-map.onrender.com/api/status` shows `database_connected: true`
- [ ] Backend shows `PostgreSQL` not `SQLite`
- [ ] `/api/seed` returns success
- [ ] Flutter app shows products

---

## 📝 If You're Stuck

1. **Share Render Logs:**
   - Go to Render → material-map → Logs
   - Copy any error messages
   - These will tell us exactly what's wrong

2. **Test Supabase Connection Locally:**
   ```bash
   cd backend
   python3 << 'EOF'
   import os
   from dotenv import load_dotenv
   load_dotenv()
   
   db_url = os.getenv('DATABASE_URL')
   if db_url and 'postgresql' in db_url:
       print("✅ DATABASE_URL configured for PostgreSQL")
       print(f"   Connection string starts with: {db_url[:50]}...")
   else:
       print("❌ DATABASE_URL not set or not PostgreSQL")
       print(f"   Current: {db_url}")
   EOF
   ```

3. **Test Flask App Locally:**
   ```bash
   cd backend
   python3 << 'EOF'
   from main import app, db
   with app.app_context():
       print(f"✅ App created successfully")
       try:
           count = db.session.execute("SELECT 1")
           print("✅ Database connection works")
       except Exception as e:
           print(f"❌ Database error: {e}")
   EOF
   ```

---

## 🎯 Expected Flow

```
Flutter App
    ↓
https://material-map.onrender.com/api/products
    ↓
Render Service (gunicorn)
    ↓
PostgreSQL (Supabase)
    ↓
← Returns product data
← Displays in app ✅
```

If any link in this chain breaks, you get "No products found".

---

## Next Steps

1. Check Render Logs for specific errors
2. Set DATABASE_URL in Render environment
3. Click "Manual Deploy"
4. Test with curl commands
5. Seed database if needed
6. Rebuild Flutter app

Your app should work once all pieces are connected!

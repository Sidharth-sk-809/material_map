# 🚀 Quick Setup: Connect Render to Your Supabase

## Your Supabase Project Details
- **Project URL:** https://tqdrxzmjjgbhbbvqyfmn.supabase.co
- **Project ID:** `tqdrxzmjjgbhbbvqyfmn`

## Step 1: Get Your Database Connection String

### Method A: From Supabase Dashboard (Recommended)
1. Go to: https://app.supabase.com
2. Select your project
3. Click **Settings** (bottom left) → **Database**
4. Under "Connection string" section, select **"URI"** tab
5. Copy the string (looks like):
```
postgresql://postgres:[PASSWORD]@db.tqdrxzmjjgbhbbvqyfmn.supabase.co:5432/postgres
```

### Method B: Build It Manually
If you know your database password:
```
postgresql+psycopg://postgres:[YOUR_PASSWORD]@db.tqdrxzmjjgbhbbvqyfmn.supabase.co:5432/postgres
```

## Step 2: Set DATABASE_URL in Render

1. **Log in to Render:** https://dashboard.render.com
2. **Find your service:** "material-map"  
3. **Click on service** to open settings
4. **Environment tab** → **Add Environment Variable**
5. **Key:** `DATABASE_URL`
6. **Value:** Paste the connection string from Step 1
7. **Click:** Save changes
8. **Back on main page:** Click **Manual Deploy**

Wait 2-3 minutes for deployment...

## Step 3: Verify Connection

### Test 1: Check Backend Status
```bash
curl https://material-map.onrender.com/api/status
```

Expected response (after seeding):
```json
{
  "status": "healthy",
  "database_type": "PostgreSQL",
  "data_stats": {
    "products": 40,
    "stores": 13,
    "inventory_items": 300
  }
}
```

### Test 2: Get Products
```bash
curl https://material-map.onrender.com/api/products | jq '.[0:2]'
```

Should return product data.

## Step 4: Seed Database (If Empty)

If you see `"products": 0`, seed the database:
```bash
curl -X POST https://material-map.onrender.com/api/seed
```

Response:
```json
{
  "message": "Database seeded successfully",
  "status": "success"
}
```

## Step 5: Test in Your Flutter App

1. **Rebuild the app:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Your app should now show:**
   - ✅ Products list populated
   - ✅ Store categories available
   - ✅ No "No products found" message

---

## 🔍 Troubleshooting

### Issue: Still showing "No products found"

**Check 1:** Is backend running?
```bash
curl https://material-map.onrender.com/health
```
Should return: `{"status": "healthy"}`

**Check 2:** Is database connected?
```bash
curl https://material-map.onrender.com/api/status
```
Look for: `"database_connected": true`

**Check 3:** Has data been seeded?
```bash
curl https://material-map.onrender.com/api/products | jq '. | length'
```
Should return a number > 0

**Check 4:** Check Render Logs
- Go to Render Dashboard → material-map service → Logs tab
- Look for error messages starting with "Error:", "Connection", "404", etc.

### Issue: "Cannot connect to database"

**Cause:** DATABASE_URL not set in Render or incorrect

**Fix:**
1. Check Render environment variables are saved (close and reopen)
2. Verify password in connection string is correct
3. Try simplified URL: `postgresql://postgres:[PASS]@db.tqdrxzmjjgbhbbvqyfmn.supabase.co:5432/postgres`
4. Make sure you're using `postgresql+psycopg://` not `postgresql://`

### Issue: Render keeps saying "Deploy Failed"

**Check:**
- Is your git pushed?
- Do Procfile and requirements.txt exist in root?
- Any Python syntax errors?

**Test locally:**
```bash
python3 -c "from backend.main import app; print('✅ OK')"
```

---

## 📋 Checklist

- [ ] Got DATABASE_URL from Supabase
- [ ] Added DATABASE_URL to Render environment variables
- [ ] Redeployed on Render
- [ ] Tested `/api/status` endpoint
- [ ] Seeds database with `POST /api/seed`
- [ ] Flutter app shows products
- [ ] No location errors in app

---

## 📱 If Location Still Shows "Unavailable"

This is separate from the database issue. The location needs Android permissions.

In your app, check **AndroidManifest.xml** has:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

And request permissions at runtime in the app code.

---

## Questions?

Check:
- `GET_SUPABASE_URL.md` - Detailed Supabase setup
- `BACKEND_DIAGNOSTICS.md` - Backend troubleshooting
- `RENDER_DEPLOYMENT_FIX.md` - Render-specific issues

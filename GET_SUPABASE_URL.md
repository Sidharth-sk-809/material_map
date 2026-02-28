# 🔧 Getting Supabase Database URL for Render

## The Problem
- Your local `.env` uses SQLite: `sqlite:///material_map.db`
- When deployed to Render, this SQLite database doesn't exist
- Render needs a **PostgreSQL connection string** to your Supabase database

## Solution: Get Your Supabase Connection String

### Step 1: Go to Supabase Dashboard
1. Visit: https://app.supabase.com
2. Select your project: `tqdrxzmjjgbhbbvqyfmn` (from your SUPABASE_URL)
3. Go to **Settings → Database → Connection string**

### Step 2: Copy the Connection String
You'll see something like:
```
postgresql://postgres:[YOUR-PASSWORD]@db.tqdrxzmjjgbhbbvqyfmn.supabase.co:5432/postgres
```

### Step 3: Convert to psycopg Format
Replace `postgresql://` with `postgresql+psycopg://`:
```
postgresql+psycopg://postgres:[YOUR-PASSWORD]@db.tqdrxzmjjgbhbbvqyfmn.supabase.co:5432/postgres
```

### Step 4: Add to Render Environment
1. Go to: Render Dashboard → Material Map service
2. Click **Environment** tab
3. Find `DATABASE_URL` or add it:
   - **Key:** `DATABASE_URL`
   - **Value:** The connection string from Step 3 (with your actual password)
   - Make sure **Sync** is OFF (confidential)
4. Click **Save**

### Step 5: Redeploy
- Click **Manual Deploy** on the main service page
- Wait 2-3 minutes for deployment

### Step 6: Seed the Database
Once deployed:
```bash
curl -X POST https://material-map.onrender.com/api/seed
```

---

## ✅ Expected Result
After seeding, your app should show:
- Products list populated
- Stores by category
- Inventory with prices

---

## 🔍 Verification Steps

### Check if Render can connect to database:
```bash
curl https://material-map.onrender.com/api/status
```

Expected response includes database stats:
```json
{
  "status": "healthy",
  "database_connected": true,
  "data_stats": {
    "users": 0,
    "products": 40,
    "stores": 13,
    "inventory_items": 300
  }
}
```

### Check if products endpoint returns data:
```bash
curl https://material-map.onrender.com/api/products | jq '.[0:2]'
```

Should return product objects with name, brand, category, etc.

---

## ⚠️ Important Notes

1. **Password Security:**
   - Never commit DATABASE_URL to git
   - Always set it in Render dashboard environment variables
   - The password in local `.env` is fine for development

2. **Connection Pool Settings:**
   - Supabase Free tier has 20 concurrent connections
   - Render app uses a max connection pool auto-configured by Flask

3. **Testing Locally:**
   - You can also test locally by creating a `.env.prod` with the PostgreSQL URL
   - Then run: `DATABASE_URL=postgresql+psycopg://... python backend/main.py`

---

## If You Don't Have Supabase Password

1. Go to Supabase dashboard
2. Click **Settings → Database**
3. Look for "Connection pooling" or "Direct connection"
4. Copy the full connection string (Supabase shows it)
5. Use that URL with password already included

---

## Common Issues

### "Connection refused" Error
- Database URL is incorrect
- Check host, port, username, password
- Verify Supabase project is running

### "No products found" 
- Database connected but no data
- Run seeding: `curl -X POST https://material-map.onrender.com/api/seed`

### "Database connection failed"
- DATABASE_URL not set in Render
- Password is wrong in the connection string
- Firewall blocking connection to Supabase

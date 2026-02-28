# Supabase Migration Setup Checklist

## Pre-Setup (5 minutes)

### 1. Create Supabase Project
- [ ] Go to [supabase.com](https://supabase.com)
- [ ] Sign up or log in
- [ ] Click "New Project"
- [ ] Name it `material-map`
- [ ] Choose region closest to your users
- [ ] Wait for initialization (2-3 minutes)

### 2. Get Credentials
- [ ] Go to Dashboard → Settings → API
- [ ] Copy `SUPABASE_URL` (looks like: `https://xxx.supabase.co`)
- [ ] Copy `SUPABASE_KEY` (anon/public key)
- [ ] Copy `SUPABASE_SERVICE_ROLE_KEY`
- [ ] Go to Database → Connection string (URL) → Copy with password

### 3. Save Credentials
- [ ] Open `.env` in project root
- [ ] Add all copied values to `.env`

---

## Installation Phase (10 minutes)

### 4. Update Dependencies
```bash
cd /Users/sidharth_sk/Desktop/mini/prj/material_map

# Update requirements.txt
pip install psycopg2-binary==2.9.9
pip install supabase==2.0.1
pip install python-multipart==0.0.6

# Or use the prepared requirements file
pip install -r backend/requirements_supabase.txt
```

Checklist:
- [ ] psycopg2-binary installed
- [ ] supabase package installed
- [ ] python-multipart installed

### 5. Verify Configuration
- [ ] SUPABASE_URL set in .env
- [ ] SUPABASE_KEY set in .env
- [ ] DATABASE_URL set in .env
- [ ] DATABASE_URL format is correct (postgresql+psycopg2://...)

### 6. Test Connection
```bash
python backend/test_supabase_connection.py
```

Expected output:
```
✅ Connection successful!
✅ SQLAlchemy can reach Supabase PostgreSQL
📊 Found 0 table(s) in database:
```

Checklist:
- [ ] Connection test passed
- [ ] No errors in output

---

## Database Setup Phase (5 minutes)

### 7. Create Tables
```bash
python backend/create_tables.py
```

Expected output:
```
✅ Tables created successfully!
📊 Created 4 table(s):
  ✅ inventory_item
  ✅ products
  ✅ stores
  ✅ users
```

Checklist:
- [ ] All 4 tables created
- [ ] No error messages

### 8. (Optional) Create Storage Bucket
- [ ] Go to Supabase Dashboard → Storage
- [ ] Click "New bucket"
- [ ] Name: `material-map`
- [ ] Make public or private (your choice)
- [ ] Create

Checklist:
- [ ] Storage bucket created
- [ ] Can see it in Storage section

---

## Testing Phase (10 minutes)

### 9. Start Backend Server
```bash
# Activate venv if not already
source /Users/sidharth_sk/Desktop/mini/prj/material_map/.venv/bin/activate

# Start server
python backend/main.py
```

Expected output:
```
Starting Flask server on 0.0.0.0:9000
✅ Database initialized!
```

Checklist:
- [ ] Server starts without errors
- [ ] Listening on port 9000

### 10. Test APIs

In a new terminal:
```bash
# Test get all products
curl http://localhost:9000/api/products

# Should return: []

# Test get stores
curl http://localhost:9000/api/stores

# Should return: []
```

Checklist:
- [ ] `/api/products` returns 200 OK
- [ ] `/api/stores` returns 200 OK
- [ ] `/api/inventory` returns 200 OK
- [ ] No database errors

### 11. (Optional) Seed Demo Data
If you have a seed script:
```bash
python backend/seed.py
```

Then verify:
```bash
curl http://localhost:9000/api/products
# Should return array with products
```

Checklist:
- [ ] Demo data loaded successfully
- [ ] Can see products in API response

---

## Configuration Phase (5 minutes)

### 12. Update Config Files

#### Update `config.py`
- [ ] Verify SUPABASE_URL is set
- [ ] Verify DATABASE_URL is postgresql format

#### Update `main.py` 
- [ ] Update database connection with pool settings
- [ ] Add: `postgresql+psycopg2://` prefix conversion

---

## Documentation Phase (5 minutes)

### 13. Update Project Documentation
- [ ] Update README.md with new setup instructions
- [ ] Link to SUPABASE_MIGRATION.md
- [ ] Link to SUPABASE_QUICK_START.md
- [ ] Document API endpoints (already done in BACKEND_API_DOCS.md)

Checklist:
- [ ] README updated
- [ ] All docs linked

---

## Post-Migration (Optional)

### 14. Production Considerations
- [ ] Enable Row Level Security (RLS) for production
- [ ] Set up automated backups in Supabase
- [ ] Configure firewall/IP whitelist if needed
- [ ] Set up monitoring/alerts
- [ ] Document database schema
- [ ] Create database user with limited permissions

### 15. Flutter App Updates
- [ ] Update API base URL if hosting backend remotely
- [ ] Update any hardcoded localhost references
- [ ] Test API calls from mobile app
- [ ] Verify authentication still works

### 16. Deployment
- [ ] Choose hosting platform (Heroku, Railway, Render, etc.)
- [ ] Set up environment variables on hosting platform
- [ ] Deploy backend
- [ ] Test all endpoints on production
- [ ] Update Flutter app API URL to production backend

---

## Troubleshooting Support

### Common Issues

**"psycopg2 not found"**
```bash
pip install psycopg2-binary
```

**"Connection refused"**
- Check SUPABASE_URL in .env
- Verify internet connection
- Test with: `python backend/test_supabase_connection.py`

**"authentication failed"**
- Verify password in DATABASE_URL
- Reset database password in Supabase Settings
- Check character encoding (no special chars need escaping)

**"relation does not exist"**
- Run: `python backend/create_tables.py`
- Verify tables in Supabase SQL Editor

**"query timeout"**
- Increase pool_recycle in main.py
- Check Supabase project is active (not paused)
- Look at query performance in Supabase Dashboard

---

## Files Created/Modified

### New Files Created:
- ✅ `SUPABASE_MIGRATION.md` - Detailed migration guide
- ✅ `SUPABASE_QUICK_START.md` - Quick setup guide
- ✅ `backend/test_supabase_connection.py` - Connection tester
- ✅ `backend/create_tables.py` - Table creator
- ✅ `backend/supabase_storage.py` - File upload handler
- ✅ `backend/requirements_supabase.txt` - Updated dependencies
- ✅ `SUPABASE_SETUP_CHECKLIST.md` - This file

### Files to Modify:
- `backend/main.py` - Update database connection
- `backend/config.py` - Already prepared ✅
- `.env` - Add Supabase credentials
- `requirements.txt` - Update dependencies

---

## Estimated Timeline

| Phase | Time |
|-------|------|
| Pre-Setup (Create Supabase) | 5 min |
| Installation | 10 min |
| Database Setup | 5 min |
| Testing | 10 min |
| Configuration | 5 min |
| Documentation | 5 min |
| **Total** | **40 min** |

---

## Success Criteria

You'll know everything is working when:

✅ Connection test passes
✅ Tables are created in Supabase
✅ Server starts without errors
✅ API endpoints return 200 OK
✅ Flutter app connects to new backend

---

## Need Help?

1. Check SUPABASE_MIGRATION.md for detailed explanations
2. See SUPABASE_QUICK_START.md for common setup steps
3. Review error messages carefully - they usually indicate the issue
4. Check Supabase Dashboard for database status
5. Review logs: `python backend/test_supabase_connection.py`

---

**Last Updated:** February 28, 2026
**Estimated Setup Time:** 40 minutes

# Material Map Backend - Supabase Setup Quick Start

## 🚀 Quick Setup (5 minutes)

### 1. Create Supabase Project
```bash
# Go to https://supabase.com
# Click "New Project" and wait for it to initialize
```

### 2. Get Credentials
From Supabase Dashboard → Settings → API:
- `tqdrxzmjjgbhbbvqyfmn` - Your project URL
- `sb_publishable_4bFekLsFsRl_yAbeWA2W-A_ot_Btenu` - anon/public key
- `postgresql://postgres:[YOUR-PASSWORD]@db.tqdrxzmjjgbhbbvqyfmn.supabase.co:5432/postgres` - From Database settings

### 3. Update .env File
```bash
cd /Users/sidharth_sk/Desktop/mini/prj/material_map
```

Create/update `.env`:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
DATABASE_URL=postgresql://postgres:your-password@db.your-project.supabase.co:5432/postgres
SECRET_KEY=your-secret-key-change-in-production
DEBUG=False
HOST=0.0.0.0
PORT=9000
```

### 4. Install Dependencies
```bash
pip install -r requirements.txt
```

**Updated requirements.txt:**
```
flask==3.0.0
flask-cors==4.0.0
flask-sqlalchemy==3.1.1
psycopg2-binary==2.9.9
python-dotenv==1.0.0
PyJWT==2.8.0
passlib==1.7.4
bcrypt==4.0.1
email-validator==1.3.1
python-jose==3.3.0
pytest==7.4.3
supabase==2.0.1
python-multipart==0.0.6
```

### 5. Test Connection
```bash
python backend/test_supabase_connection.py
```

Expected output:
```
✅ Connection successful!
✅ SQLAlchemy can reach Supabase PostgreSQL
```

### 6. Create Tables
```bash
python backend/create_tables.py
```

### 7. Run Server
```bash
python backend/main.py
```

---

## 📋 Files to Update

| File | Change |
|------|--------|
| `.env` | Add Supabase credentials |
| `requirements.txt` | Add psycopg2-binary, supabase |
| `backend/config.py` | Already prepared for Supabase ✅ |
| `backend/main.py` | Update DATABASE_URL connection string |

---

## 🔧 Configuration Details

### Database URL Format

**Get from Supabase Dashboard:**
```
Settings → Database → Connection string (URI)
Display mode: URI
```

**Format:**
```
postgresql://postgres:[PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres
```

**For SQLAlchemy:**
```
postgresql+psycopg2://postgres:[PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres
```

### Update main.py

Find this section in `backend/main.py`:
```python
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///material_map.db')
```

Replace with:
```python
from config import DATABASE_URL
import os

# Convert postgresql:// to postgresql+psycopg2://
database_url = DATABASE_URL
if database_url and not database_url.startswith('postgresql+psycopg2://'):
    database_url = database_url.replace('postgresql://', 'postgresql+psycopg2://')

app.config['SQLALCHEMY_DATABASE_URI'] = database_url
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    'pool_size': 10,
    'pool_recycle': 3600,
    'pool_pre_ping': True,
}
```

---

## ✅ Verification Checklist

```bash
# 1. Test connection
python backend/test_supabase_connection.py
# ✅ Should show "Connection successful!"

# 2. Create tables
python backend/create_tables.py
# ✅ Should show "Tables created successfully!"

# 3. Start server
python backend/main.py
# ✅ Should show "Starting Flask server on 0.0.0.0:9000"

# 4. Test API endpoint
curl http://localhost:9000/api/products
# ✅ Should return JSON array (empty if no data)
```

---

## 🐛 Troubleshooting

| Error | Solution |
|-------|----------|
| `No module named 'psycopg2'` | `pip install psycopg2-binary` |
| `could not connect` | Check DATABASE_URL in .env |
| `relation does not exist` | Run `python backend/create_tables.py` |
| `password authentication failed` | Verify database password in Supabase |

---

## 📊 What Gets Created

Running the setup creates:
- ✅ `users` table - For authentication
- ✅ `products` table - Product catalog
- ✅ `stores` table - Store locations
- ✅ `inventory_item` table - Product inventory per store
- ✅ Indexes - For performance
- ✅ Foreign keys - Data integrity

---

## 🔐 Security Notes

1. **Never commit .env file** - Add to .gitignore
2. **Rotate API keys regularly** - In Supabase Settings
3. **Use environment variables** - Don't hardcode secrets
4. **Enable Row Level Security** (optional for production)

---

## 📚 Next Steps

After setup:
1. Test all endpoints in Postman or curl
2. Deploy to production (Heroku, Railway, Render, etc.)
3. Update Flutter app API base URL if hosting remotely
4. Set up CI/CD for automatic deployments
5. Monitor database performance in Supabase Dashboard

---

## 💡 Tips

- **Local Development:** Can use local PostgreSQL instead of Supabase
- **Backups:** Enable automatic backups in Supabase Settings
- **Monitoring:** Check Supabase Dashboard for query performance
- **Scaling:** Can upgrade Supabase plan anytime for more connections

---

For detailed information, see: [SUPABASE_MIGRATION.md](./SUPABASE_MIGRATION.md)

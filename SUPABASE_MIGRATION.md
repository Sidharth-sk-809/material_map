# Supabase Migration Guide

## Overview
This guide explains how to migrate your Material Map backend from Flask with SQLite to Supabase (PostgreSQL-based backend-as-a-service).

**Current Stack:** Flask + SQLAlchemy + SQLite  
**Target Stack:** Flask + SQLAlchemy + Supabase (PostgreSQL)

---

## ✅ Benefits of Supabase

- **PostgreSQL Database** - More powerful than SQLite, production-ready
- **Built-in Authentication** - Optional JWT-based auth with email/password
- **Storage API** - File uploads for product/store images
- **Real-time Features** - WebSocket support for live data
- **Backups & Scalability** - Automatic backups, easy scaling
- **Admin Dashboard** - Built-in UI for data management

---

## 📋 What Needs to Change

| Component | Current | Supabase |
|-----------|---------|----------|
| Database | SQLite (file-based) | PostgreSQL |
| Connection | Local file URI | Remote connection string |
| Authentication | Custom JWT | Can use Supabase Auth (optional) |
| File Storage | Filesystem | Supabase Storage buckets |
| Environment Vars | Minimal | Need Supabase URL & API keys |

---

## 🚀 Step-by-Step Migration Guide

### Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign up/Login and create a new project
3. Choose region (preferably closest to your users)
4. Wait for project initialization (2-3 minutes)
5. Get your credentials from **Settings > API**:
   - `Project URL` → `SUPABASE_URL`
   - `anon public` key → `SUPABASE_KEY`
   - `service_role` key → `SUPABASE_SERVICE_ROLE_KEY`

### Step 2: Update Requirements.txt

```txt
flask==3.0.0
flask-cors==4.0.0
flask-sqlalchemy==3.1.1
psycopg2-binary==2.9.9          # PostgreSQL adapter (Required!)
python-dotenv==1.0.0
PyJWT==2.8.0
passlib==1.7.4
bcrypt==4.0.1
email-validator==1.3.1
python-jose==3.3.0
pytest==7.4.3
supabase==2.0.1                 # Optional: For Storage/Auth APIs
python-multipart==0.0.6         # For file uploads
```

**Install:**
```bash
pip install -r requirements.txt
```

### Step 3: Update .env File

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Database (PostgreSQL via Supabase)
DATABASE_URL=postgresql://postgres:your-password@db.your-project.supabase.co:5432/postgres

# Existing configs
SECRET_KEY=your-secret-key-change-in-production
DEBUG=False
HOST=0.0.0.0
PORT=9000
```

**How to get DATABASE_URL:**
1. In Supabase Dashboard → Settings → Database
2. Connection string (URI mode):
   ```
   postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres
   ```

### Step 4: Update config.py

```python
from dotenv import load_dotenv
import os

load_dotenv()

# Supabase Configuration
SUPABASE_URL = os.getenv("SUPABASE_URL", "")
SUPABASE_KEY = os.getenv("SUPABASE_KEY", "")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")
SUPABASE_BUCKET = os.getenv("SUPABASE_BUCKET", "material-map")

# JWT Configuration
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-change-in-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# Database Configuration - PostgreSQL
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:password@localhost:5432/material_map"
)

# Important: SQLAlchemy requires psycopg2 for PostgreSQL
# Connection string format: postgresql+psycopg2://user:password@host:port/database

# Server Configuration
DEBUG = os.getenv("DEBUG", "False").lower() == "true"
HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", 9000))
```

### Step 5: Update main.py Database Connection

**Current (SQLite):**
```python
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///material_map.db')
```

**Updated (PostgreSQL/Supabase):**
```python
import os
from config import DATABASE_URL

# Ensure PostgreSQL driver is used
database_url = DATABASE_URL
if database_url and not database_url.startswith('postgresql+psycopg2://'):
    # Convert postgresql:// to postgresql+psycopg2://
    database_url = database_url.replace('postgresql://', 'postgresql+psycopg2://')

app.config['SQLALCHEMY_DATABASE_URI'] = database_url
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    'pool_size': 10,
    'pool_recycle': 3600,
    'pool_pre_ping': True,
}
```

### Step 6: Create Tables in Supabase

#### Option A: Using SQL Editor (Recommended)

1. Go to Supabase Dashboard → SQL Editor
2. Click "New Query"
3. Run this SQL:

```sql
-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(120) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    brand VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    image_url VARCHAR(500),
    description TEXT,
    unit VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_brand ON products(brand);

-- Create stores table
CREATE TABLE IF NOT EXISTS stores (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL DEFAULT 'other',
    address VARCHAR(500) NOT NULL,
    latitude FLOAT,
    longitude FLOAT,
    phone VARCHAR(20),
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stores_category ON stores(category);

-- Create inventory_item table
CREATE TABLE IF NOT EXISTS inventory_item (
    id VARCHAR(36) PRIMARY KEY,
    product_id VARCHAR(36) NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    store_id VARCHAR(36) NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    price FLOAT NOT NULL,
    quantity INTEGER NOT NULL,
    original_price FLOAT,
    discount_percentage FLOAT DEFAULT 0,
    offer_valid_until TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_inventory_product ON inventory_item(product_id);
CREATE INDEX idx_inventory_store ON inventory_item(store_id);
```

#### Option B: Using Python Script

In your backend, create `create_tables.py`:

```python
from main import app, db

def init_db():
    with app.app_context():
        print("Creating tables in Supabase PostgreSQL...")
        db.create_all()
        print("✅ Tables created successfully!")

if __name__ == '__main__':
    init_db()
```

Run:
```bash
python create_tables.py
```

### Step 7: Update Image Storage (Optional but Recommended)

**Create storage.py** for Supabase file uploads:

```python
from supabase import create_client
from config import SUPABASE_URL, SUPABASE_KEY, SUPABASE_BUCKET
import os

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def upload_product_image(file, product_id):
    """Upload product image to Supabase Storage"""
    try:
        file_path = f"products/{product_id}"
        supabase.storage.from_(SUPABASE_BUCKET).upload(
            path=file_path,
            file=file
        )
        # Return public URL
        return f"{SUPABASE_URL}/storage/v1/object/public/{SUPABASE_BUCKET}/{file_path}"
    except Exception as e:
        print(f"Error uploading image: {e}")
        return None

def upload_store_image(file, store_id):
    """Upload store image to Supabase Storage"""
    try:
        file_path = f"stores/{store_id}"
        supabase.storage.from_(SUPABASE_BUCKET).upload(
            path=file_path,
            file=file
        )
        return f"{SUPABASE_URL}/storage/v1/object/public/{SUPABASE_BUCKET}/{file_path}"
    except Exception as e:
        print(f"Error uploading image: {e}")
        return None

def delete_image(file_path):
    """Delete image from Supabase Storage"""
    try:
        supabase.storage.from_(SUPABASE_BUCKET).remove([file_path])
        return True
    except Exception as e:
        print(f"Error deleting image: {e}")
        return False
```

### Step 8: Test Connection

Create `test_connection.py`:

```python
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from config import DATABASE_URL
import os

# Convert to psycopg2 format
db_url = DATABASE_URL
if db_url and not db_url.startswith('postgresql+psycopg2://'):
    db_url = db_url.replace('postgresql://', 'postgresql+psycopg2://')

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = db_url
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

if __name__ == '__main__':
    with app.app_context():
        try:
            # Test connection
            connection = db.engine.connect()
            connection.close()
            print("✅ Successfully connected to Supabase PostgreSQL!")
        except Exception as e:
            print(f"❌ Connection failed: {e}")
```

Run:
```bash
python test_connection.py
```

---

## 🔧 Additional Configuration

### Create Supabase Storage Bucket

1. Go to Supabase Dashboard → Storage
2. Click "New bucket"
3. Name it `material-map`
4. Uncheck "Public bucket" (or make it public if needed)
5. Save

### Enable Row Level Security (Optional)

For production, enable RLS for security:

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_item ENABLE ROW LEVEL SECURITY;
```

### Set Firewall Rules (if needed)

In Supabase Dashboard → Settings → Database → Firewall IP Whitelist

---

## 📊 Migration Checklist

- [ ] Create Supabase project
- [ ] Get SUPABASE_URL, SUPABASE_KEY, DATABASE_URL
- [ ] Update .env file with credentials
- [ ] Update requirements.txt (add psycopg2-binary, supabase)
- [ ] Run `pip install -r requirements.txt`
- [ ] Update config.py with new environment variables
- [ ] Update main.py database connection string
- [ ] Create tables using SQL or Python script
- [ ] Test database connection
- [ ] Seed initial data if needed
- [ ] Test all API endpoints
- [ ] (Optional) Set up Storage for images
- [ ] Update Flutter app to use new API endpoint
- [ ] Deploy to production

---

## ⚠️ Important Notes

### Database URL Format
```
# SQLite (Old)
sqlite:///./material_map.db

# PostgreSQL (New)
postgresql://user:password@host:port/database

# For SQLAlchemy with psycopg2
postgresql+psycopg2://user:password@host:port/database
```

### Connection Pool Settings
```python
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    'pool_size': 10,           # Number of DB connections to maintain
    'pool_recycle': 3600,      # Recycle connections after 1 hour
    'pool_pre_ping': True,     # Test connection before using
}
```

### Performance Optimization
- Supabase has connection limits - use connection pooling
- PgBouncer is included with Supabase (recommended for serverless)
- Use indexes on frequently queried columns (already done)

### Local Development (Optional)
You can run Supabase locally using Docker:
```bash
docker run -d \
  --name supabase \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=postgres \
  postgres:latest
```

---

## 🐛 Troubleshooting

### Error: "psycopg2 not found"
```bash
pip install psycopg2-binary
```

### Error: "could not translate host name to address"
- Check SUPABASE_URL format
- Ensure internet connection
- Verify firewall rules in Supabase

### Error: "password authentication failed"
- Verify DATABASE_URL credentials
- Reset database password in Supabase Settings

### Error: "relation does not exist"
- Run table creation script
- Check Supabase SQL Editor for errors

### Slow queries
- Add indexes
- Use connection pooling
- Check query performance in Supabase CLI

---

## 📚 Resources

- [Supabase Documentation](https://supabase.com/docs)
- [SQLAlchemy with PostgreSQL](https://docs.sqlalchemy.org/en/20/dialects/postgresql.html)
- [Supabase Python Client](https://github.com/supabase-community/supabase-py)
- [PostgreSQL Best Practices](https://wiki.postgresql.org/wiki/Performance_Optimization)

---

## 🎯 Next Steps After Migration

1. **Update Flutter App** - Change API endpoint if hosted remotely
2. **Set up Backups** - Enable automated backups in Supabase
3. **Monitor Performance** - Use Supabase Dashboard analytics
4. **Configure Auth** - Optionally migrate to Supabase Auth
5. **Deploy** - Push to production with new connection strings

---

**Last Updated:** February 28, 2026

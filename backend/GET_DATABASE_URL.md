# How to Get Supabase DATABASE_URL

## 🎯 Quick Reference

**DATABASE_URL** connects your Python backend to your Supabase PostgreSQL database.

**Final format:**
```
postgresql://postgres:YOUR_PASSWORD@db.YOUR_PROJECT_ID.supabase.co:5432/postgres
```

---

## 📋 Step-by-Step Instructions

### Step 1: Open Supabase Dashboard
1. Go to https://supabase.com/dashboard
2. Log in to your account
3. Select your Material Map project

### Step 2: Navigate to Database Settings
1. Click **⚙️ Settings** (bottom left sidebar)
2. Click **Database**
3. You should see a blue section called "Connection string"

### Step 3: Choose Connection String Format
1. Look for the **Connection string** section
2. Click the dropdown that says "URI"
3. You'll see three options:
   - `postgresql` ← Select this
   - `psycopg2` (alternative, also works)
   - `jdbc`

### Step 4: Copy the Connection String
1. Select **postgresql** mode
2. You'll see the complete URL:
   ```
   postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres
   ```

3. Click the **Copy** button (📋 icon)

### Step 5: Get Your Database Password
If you don't have your database password:
1. In the same Settings → Database section
2. Look for **"Database password"** field
3. Click **"Reset"** if needed
4. Note down the password shown

### Step 6: Complete Your DATABASE_URL

**Replace the placeholder:**
```
# Template:
postgresql://postgres:[PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres

# Example (with fake values):
postgresql://postgres:VerySecurePassword123@db.tqdrxzmjjgbhbbvq.supabase.co:5432/postgres
```

---

## 📸 Visual Guide

### In Supabase Dashboard:
```
Dashboard Home
    ↓
⚙️ Settings (left sidebar, near bottom)
    ↓
Database (top menu in settings)
    ↓
"Connection string" section
    ↓
Dropdown: Choose "postgresql"
    ↓
Copy the URL
```

### URL Components Explained:
```
postgresql://postgres:PASSWORD@db.PROJECT-ID.supabase.co:5432/postgres
│            │        │        │  │  │         │          │    │        
Protocol     User     Password │  │  │         Hostname    │    Database
             default           db  │  Project ID           Port  default
                                   │
                              Your Supabase domain
```

---

## ✅ Verification Checklist

Before using your DATABASE_URL:

- [ ] URL starts with `postgresql://`
- [ ] Contains `postgres:` (the default user)
- [ ] Has a password after the colon
- [ ] Contains `@db.` (database server)
- [ ] Ends with `:5432/postgres` (port and database name)
- [ ] No brackets `[` `]` remaining (replace with actual values)
- [ ] Password contains no special characters that need escaping

### Example of VALID DATABASE_URL:
```
postgresql://postgres:mySecurePassword123@db.tqdrxzmjjgbhbbvqyfmn.supabase.co:5432/postgres
```

### Example of INVALID DATABASE_URL:
```
postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres
❌ Still has placeholders instead of actual values
```

---

## 🔐 Security Best Practices

1. **Never share your DATABASE_URL** - It contains your password!
2. **Never commit to git** - Add `.env` to `.gitignore`
3. **Use strong database passwords** - At least 16 characters
4. **Rotate passwords regularly** - In Settings → Database → Reset password

---

## 🐛 Troubleshooting

### "Connection string section not visible"
- Make sure you're in Settings → Database
- Scroll down if needed
- Refresh the page

### "Can't find PROJECT-ID"
- Look at your project URL: `https://YOUR-PROJECT-ID.supabase.co`
- The PROJECT-ID is the alphanumeric string before `.supabase.co`

### "Password shows as [YOUR-PASSWORD]"
- Go to Settings → Database
- Find "Database password" field
- If you don't see it, reset it with the Reset button
- New password will be displayed

### "Connection string has angle brackets < >"
- Remove them and replace with actual values
- Example: `<PASSWORD>` → `actualPassword123`

---

## 📝 Add to .env File

Once you have your DATABASE_URL, add it to `.env`:

```env
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@db.YOUR_PROJECT_ID.supabase.co:5432/postgres
```

Then in Python code:
```python
from dotenv import load_dotenv
import os

load_dotenv()
database_url = os.getenv('DATABASE_URL')
# Now you can use it with SQLAlchemy
```

---

## 💡 For SQLAlchemy Connection

When using SQLAlchemy, you may need to add the psycopg2 driver:

```python
# Option 1: Use as-is (if psycopg is auto-detected)
DATABASE_URL = "postgresql://postgres:password@db.xxx.supabase.co:5432/postgres"

# Option 2: Explicit psycopg2 (recommended for clarity)
DATABASE_URL = "postgresql+psycopg2://postgres:password@db.xxx.supabase.co:5432/postgres"
```

Add to your Flask app:
```python
app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URL
```

---

## 🎯 Quick Summary

| Step | Action |
|------|--------|
| 1 | Open Supabase Dashboard |
| 2 | Go to Settings → Database |
| 3 | Find "Connection string" section |
| 4 | Select "postgresql" mode |
| 5 | Copy the connection string |
| 6 | Add to .env file |
| 7 | Use in Flask app config |

---

## 📚 Related Resources

- [Supabase Docs - Connection Strings](https://supabase.com/docs/guides/database/connecting-to-postgres)
- [PostgreSQL Connection String Format](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING)
- [SQLAlchemy PostgreSQL](https://docs.sqlalchemy.org/en/20/dialects/postgresql.html)

---

**Last Updated:** February 28, 2026

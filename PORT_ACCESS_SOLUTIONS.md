# Port Access Issue - Solutions

## 📊 Current Situation

Both ports are blocked from your network:
- ❌ Port 5432 (direct database) - Blocked
- ❌ Port 6543 (connection pooler) - Blocked

This suggests a **network/firewall issue** on your side, not Supabase.

---

## ✅ Solutions You Can Try

### Solution 1: Check Your Network/Firewall
```bash
# Test if you can reach Supabase
nslookup db.tqdrxzmjjgbhbbvqyfmn.supabase.co
# Should return an IP address

# Check if port 6543 is reachable
nc -zv db.tqdrxzmjjgbhbbvqyfmn.pooler.supabase.co 6543
# Should show "succeeded" or "open"

# Check if VPN/Proxy is blocking connections
curl -I https://db.tqdrxzmjjgbhbbvqyfmn.supabase.co
```

### Solution 2: Disable Firewall Temporarily
**macOS:**
```bash
# Check if firewall is on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw -getglobalstate

# Temporarily disable
sudo /usr/libexec/ApplicationFirewall/socketfilterfw -setglobalstate off

# Re-enable later
sudo /usr/libexec/ApplicationFirewall/socketfilterfw -setglobalstate on
```

### Solution 3: Try From Different Network
- Connect to **public WiFi** or **mobile hotspot**
- Test if it's a network restriction on your current connection

### Solution 4: SSH Tunneling (Advanced)
If you have SSH access to a server, create a tunnel:
```bash
ssh -L 5432:db.tqdrxzmjjgbhbbvqyfmn.supabase.co:6543 user@your-server.com
```

---

## 🔄 Alternative: Use SQLite for Development

Since PostgreSQL is blocked, you can develop locally with **SQLite**:

Update `.env`:
```env
# Use SQLite for development
DATABASE_URL=sqlite:///material_map.db
```

Restart server:
```bash
python backend/main.py
```

Then test:
```bash
curl http://localhost:9000/api/products
```

**Pros:**
- ✅ Works immediately
- ✅ No network dependency
- ✅ Good for local development

**Cons:**
- ❌ Not production-ready
- ❌ No cloud backup
- ❌ Limited concurrent users

---

## 🎯 Recommended Path

1. **Try Solution 1** - Check your network connectivity
2. **Try Solution 2** - Disable firewall temporarily to test
3. If still blocked, **use SQLite locally** (Solution 4) for development
4. When deploying to production, switch back to Supabase

---

## 🔍 Why Both Ports Are Blocked?

| Port | Purpose | Status |
|------|---------|--------|
| 5432 | Direct DB connection | ❌ Blocked |
| 6543 | Connection pooler | ❌ Blocked |

**This indicates:**
- Firewall blocking outbound PostgreSQL connections
- ISP/Network restriction
- VPN/Proxy interference
- Corporate network restrictions

---

## ✅ What You Can Still Do

Your Flask API **IS running and responding**:
```bash
curl http://localhost:9000/api/health
# ✅ Returns success
```

You can build your **Flutter app** using the health endpoint and other non-database endpoints. Once the port issue is fixed, database endpoints will work automatically!

---

**Quick Test:** Run this to confirm port blocking:
```bash
nc -zv -w 5 db.tqdrxzmjjgbhbbvqyfmn.pooler.supabase.co 6543
```

If it times out → ports are blocked
If it connects → ports are accessible

---

**Last Updated:** February 28, 2026

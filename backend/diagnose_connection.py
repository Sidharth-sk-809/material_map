#!/usr/bin/env python3
"""
Diagnostic script to check Supabase connection issues
"""
import socket
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv('DATABASE_URL', '')
SUPABASE_URL = os.getenv('SUPABASE_URL', '')

print("=" * 60)
print("Supabase Connection Diagnostics")
print("=" * 60)

# 1. Check environment variables
print("\n1️⃣  Checking Environment Variables...")
if SUPABASE_URL:
    print(f"   ✅ SUPABASE_URL: {SUPABASE_URL}")
else:
    print("   ❌ SUPABASE_URL not set")

if DATABASE_URL:
    # Extract host without showing full password
    if '@' in DATABASE_URL:
        host_part = DATABASE_URL.split('@')[1]
        print(f"   ✅ DATABASE_URL configured: ...@{host_part}")
    else:
        print(f"   ✅ DATABASE_URL: {DATABASE_URL[:30]}...")
else:
    print("   ❌ DATABASE_URL not set")

# 2. Test DNS resolution
print("\n2️⃣  Testing DNS Resolution...")
try:
    host = "db.tqdrxzmjjgbhbbvqyfmn.supabase.co"
    ip = socket.gethostbyname(host)
    print(f"   ✅ DNS resolved: {host} -> {ip}")
except socket.gaierror as e:
    print(f"   ❌ DNS resolution failed: {e}")
    print("   ℹ️  This might indicate:")
    print("      - No internet connection")
    print("      - VPN/Firewall blocking DNS")
    print("      - Incorrect host address")

# 3. Check if port is accessible
print("\n3️⃣  Testing Port Connectivity...")
try:
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(5)  # 5 second timeout
    result = sock.connect_ex(("db.tqdrxzmjjgbhbbvqyfmn.supabase.co", 5432))
    sock.close()
    
    if result == 0:
        print("   ✅ Port 5432 is accessible")
    else:
        print(f"   ❌ Port 5432 connection failed (error code: {result})")
        print("   ℹ️  This might indicate:")
        print("      - Firewall blocking port 5432")
        print("      - Supabase server not running")
        print("      - Network connectivity issue")
except Exception as e:
    print(f"   ❌ Error testing port: {e}")

# 4. Check credentials format
print("\n4️⃣  Checking Credentials Format...")
if DATABASE_URL:
    required_parts = ['postgresql://', 'postgres:', '@', 'supabase.co', ':5432']
    all_valid = all(part in DATABASE_URL for part in required_parts)
    
    if all_valid:
        print("   ✅ DATABASE_URL format looks correct")
    else:
        missing = [p for p in required_parts if p not in DATABASE_URL]
        print(f"   ❌ DATABASE_URL format issue. Missing: {missing}")

# 5. Quick Supabase status
print("\n5️⃣  Summary & Next Steps...")
print("\n   If all checks passed:")
print("   → Try running: python backend/create_tables.py")
print("\n   If DNS fails:")
print("   → Check internet connection")
print("   → Check VPN/firewall settings")
print("\n   If Port fails:")
print("   → Verify credentials in Supabase dashboard")
print("   → Check if Supabase project is paused")
print("   → Try connecting from Supabase SQL editor first")
print("\n" + "=" * 60)

"""
Test Supabase PostgreSQL Connection
Run this to verify your Supabase database connection is working
"""

from flask import Flask
from flask_sqlalchemy import SQLAlchemy
import os
from dotenv import load_dotenv

load_dotenv()

# Get database URL and convert to psycopg format
db_url = os.getenv('DATABASE_URL', '')

if not db_url:
    print("❌ ERROR: DATABASE_URL not set in .env file")
    exit(1)

# Convert postgresql:// to postgresql+psycopg:// for SQLAlchemy (psycopg v3)
if db_url.startswith('postgresql://'):
    db_url = db_url.replace('postgresql://', 'postgresql+psycopg://', 1)

print(f"🔍 Testing connection to: {db_url.split('@')[1] if '@' in db_url else 'Supabase'}")

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = db_url
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    'pool_size': 5,
    'pool_recycle': 3600,
    'pool_pre_ping': True,
}

db = SQLAlchemy(app)

def test_connection():
    """Test database connection"""
    with app.app_context():
        try:
            # Attempt to connect
            with db.engine.connect() as connection:
                result = connection.execute(db.text("SELECT 1"))
                result.close()
            
            print("✅ Connection successful!")
            print("✅ SQLAlchemy can reach Supabase PostgreSQL")
            return True
            
        except Exception as e:
            print(f"❌ Connection failed: {type(e).__name__}")
            print(f"❌ Error: {str(e)}")
            print("\n🔧 Troubleshooting:")
            print("1. Check DATABASE_URL format in .env")
            print("2. Verify Supabase project is running")
            print("3. Check firewall/network connectivity")
            print("4. Ensure psycopg2-binary is installed: pip install psycopg2-binary")
            return False

def check_tables():
    """Check if tables exist in database"""
    with app.app_context():
        try:
            result = db.session.execute(db.text("""
                SELECT table_name FROM information_schema.tables 
                WHERE table_schema = 'public'
            """))
            
            tables = [row[0] for row in result]
            
            if tables:
                print(f"\n📊 Found {len(tables)} table(s) in database:")
                for table in sorted(tables):
                    print(f"  ✅ {table}")
            else:
                print("\n📊 No tables found - run create_tables.py to initialize")
                
        except Exception as e:
            print(f"❌ Error checking tables: {e}")

if __name__ == '__main__':
    print("=" * 50)
    print("Supabase Connection Test")
    print("=" * 50)
    
    if test_connection():
        check_tables()
        print("\n" + "=" * 50)
        print("✅ All checks passed! Ready to proceed.")
        print("=" * 50)
    else:
        print("\n" + "=" * 50)
        print("❌ Connection test failed. Please check configuration.")
        print("=" * 50)
        exit(1)

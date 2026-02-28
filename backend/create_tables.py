"""
Create tables in Supabase PostgreSQL database
Run this AFTER updating config files and before running main.py
"""

from flask import Flask
from flask_sqlalchemy import SQLAlchemy
import os
from dotenv import load_dotenv
from datetime import datetime

load_dotenv()

# Initialize Flask app
app = Flask(__name__)

# Get database URL
db_url = os.getenv('DATABASE_URL', '')
if not db_url:
    print("❌ ERROR: DATABASE_URL not set in .env file")
    exit(1)

# Convert to psycopg format
if db_url.startswith('postgresql://'):
    db_url = db_url.replace('postgresql://', 'postgresql+psycopg://', 1)

app.config['SQLALCHEMY_DATABASE_URI'] = db_url
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    'pool_size': 10,
    'pool_recycle': 3600,
    'pool_pre_ping': True,
}

db = SQLAlchemy(app)

# ============ DATABASE MODELS ============

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.String(36), primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    hashed_password = db.Column(db.String(255), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Product(db.Model):
    __tablename__ = 'products'
    id = db.Column(db.String(36), primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    brand = db.Column(db.String(255), nullable=False)
    category = db.Column(db.String(100), nullable=False, index=True)
    image_url = db.Column(db.String(500))
    description = db.Column(db.Text)
    unit = db.Column(db.String(100))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Store(db.Model):
    __tablename__ = 'stores'
    id = db.Column(db.String(36), primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    category = db.Column(db.String(100), nullable=False, index=True, default='other')
    address = db.Column(db.String(500), nullable=False)
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    phone = db.Column(db.String(20))
    image_url = db.Column(db.String(500))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class InventoryItem(db.Model):
    __tablename__ = 'inventory_item'
    id = db.Column(db.String(36), primary_key=True)
    product_id = db.Column(db.String(36), db.ForeignKey('products.id'), nullable=False)
    store_id = db.Column(db.String(36), db.ForeignKey('stores.id'), nullable=False)
    price = db.Column(db.Float, nullable=False)
    quantity = db.Column(db.Integer, nullable=False)
    original_price = db.Column(db.Float)
    discount_percentage = db.Column(db.Float, default=0)
    offer_valid_until = db.Column(db.DateTime)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    product = db.relationship('Product', backref='inventory_items')
    store = db.relationship('Store', backref='inventory_items')

# ============ INITIALIZATION ============

def create_tables():
    """Create all tables in Supabase"""
    with app.app_context():
        try:
            print("🔄 Creating tables in Supabase PostgreSQL...")
            print("-" * 50)
            
            # Drop existing tables (optional - comment out for production)
            # print("Dropping existing tables...")
            # db.drop_all()
            
            # Create all tables
            db.create_all()
            
            print("✅ Tables created successfully!")
            print("-" * 50)
            
            # Verify tables
            result = db.session.execute(db.text("""
                SELECT table_name FROM information_schema.tables 
                WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
            """))
            
            tables = [row[0] for row in result]
            print(f"\n📊 Created {len(tables)} table(s):")
            for table in sorted(tables):
                print(f"  ✅ {table}")
            
            print("\n✅ Database initialization complete!")
            print("Next steps:")
            print("  1. Run: python seed_supabase.py (to add demo data)")
            print("  2. Run: python main.py (to start the server)")
            
            return True
            
        except Exception as e:
            print(f"\n❌ Error creating tables: {type(e).__name__}")
            print(f"❌ Details: {str(e)}")
            print("\n🔧 Troubleshooting:")
            print("1. Ensure PostgreSQL syntax in models matches Supabase schema")
            print("2. Check database permissions")
            print("3. Verify connection works: python test_supabase_connection.py")
            return False

if __name__ == '__main__':
    print("=" * 50)
    print("Supabase Table Creation")
    print("=" * 50)
    print()
    
    create_tables()

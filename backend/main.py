from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timedelta
from passlib.context import CryptContext
import jwt
import os
from dotenv import load_dotenv
import uuid

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)

# Configure database connection - handle both local SQLite and Render PostgreSQL
database_url = os.getenv('DATABASE_URL', 'sqlite:///material_map.db')

# For Render environment, if DATABASE_URL is sqlite, it means it wasn't properly configured
# Show a warning
if database_url.startswith('sqlite://') and os.getenv('ENVIRONMENT') == 'production':
    print("⚠️  WARNING: Using SQLite on Render. This will NOT persist data!")
    print("⚠️  Please set DATABASE_URL in Render environment variables")
    print("⚠️  See GET_SUPABASE_URL.md for instructions")

# Convert postgresql:// to postgresql+psycopg:// for psycopg v3 compatibility
if database_url and database_url.startswith('postgresql://'):
    database_url = database_url.replace('postgresql://', 'postgresql+psycopg://', 1)
    # Ensure SSL mode is set for security
    if 'sslmode' not in database_url:
        database_url += '?sslmode=require' if '?' not in database_url else '&sslmode=require'
    print(f"✅ Using PostgreSQL connection with IPv6 support")
elif database_url.startswith('sqlite://'):
    print(f"✅ Using SQLite database")

app.config['SQLALCHEMY_DATABASE_URI'] = database_url
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'your-secret-key-change-in-production')
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    'pool_size': 3,
    'max_overflow': 5,
    'pool_recycle': 1800,  # Recycle connections every 30 minutes
    'pool_pre_ping': True,  # Test connections before using
    'connect_args': {
        'connect_timeout': 15,
        'application_name': 'material_map',
    } if not database_url.startswith('sqlite') else {}
}

# Initialize database
db = SQLAlchemy(app)

# Enable CORS with comprehensive configuration
CORS(app, 
     resources={
         r"/api/*": {
             "origins": ["*"],
             "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
             "allow_headers": ["Content-Type", "Authorization"],
             "max_age": 3600
         },
         r"/health": {"origins": ["*"]},
         r"/": {"origins": ["*"]}
     })

# Initialize database tables on first request
@app.before_request
def init_db_tables():
    """Initialize database tables if they don't exist"""
    try:
        # Only run once
        if not hasattr(init_db_tables, 'executed'):
            db.create_all()
            init_db_tables.executed = True
            print("✅ Database tables initialized")
    except Exception as e:
        print(f"⚠️  Database table warning: {e}")

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# ============ DATABASE MODELS ============

class User(db.Model):
    id = db.Column(db.String(36), primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    hashed_password = db.Column(db.String(255), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Product(db.Model):
    id = db.Column(db.String(36), primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    brand = db.Column(db.String(255), nullable=False)
    category = db.Column(db.String(100), nullable=False, index=True)
    image_url = db.Column(db.String(500))
    description = db.Column(db.Text)
    unit = db.Column(db.String(100))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Store(db.Model):
    id = db.Column(db.String(36), primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    category = db.Column(db.String(100), nullable=False, index=True, default='other')  # grocery, stationery, household
    address = db.Column(db.String(500), nullable=False)
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    phone = db.Column(db.String(20))
    image_url = db.Column(db.String(500))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class InventoryItem(db.Model):
    id = db.Column(db.String(36), primary_key=True)
    product_id = db.Column(db.String(36), db.ForeignKey('product.id'), nullable=False)
    store_id = db.Column(db.String(36), db.ForeignKey('store.id'), nullable=False)
    price = db.Column(db.Float, nullable=False)
    quantity = db.Column(db.Integer, nullable=False)
    original_price = db.Column(db.Float)  # Price before offer
    discount_percentage = db.Column(db.Float, default=0)  # Discount percentage
    offer_valid_until = db.Column(db.DateTime)  # When offer expires
    updated_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    product = db.relationship('Product', backref='inventory_items')
    store = db.relationship('Store', backref='inventory_items')

# ============ UTILITY FUNCTIONS ============

def generate_id():
    return str(uuid.uuid4())

def hash_password(password):
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(user_id):
    payload = {
        'sub': user_id,
        'exp': datetime.utcnow() + timedelta(hours=24)
    }
    return jwt.encode(payload, app.config['SECRET_KEY'], algorithm='HS256')

def decode_token(token):
    try:
        payload = jwt.decode(token, app.config['SECRET_KEY'], algorithms=['HS256'])
        return {'user_id': payload.get('sub')}
    except:
        return None

def product_to_dict(product):
    return {
        'id': product.id,
        'name': product.name,
        'brand': product.brand,
        'category': product.category,
        'image_url': product.image_url,
        'description': product.description,
        'unit': product.unit,
        'created_at': product.created_at.isoformat()
    }

def store_to_dict(store):
    return {
        'id': store.id,
        'name': store.name,
        'category': store.category,
        'address': store.address,
        'latitude': store.latitude,
        'longitude': store.longitude,
        'phone': store.phone,
        'image_url': store.image_url,
        'created_at': store.created_at.isoformat()
    }

def inventory_to_dict(item, include_relations=False):
    data = {
        'id': item.id,
        'product_id': item.product_id,
        'store_id': item.store_id,
        'price': item.price,
        'quantity': item.quantity,
        'original_price': item.original_price,
        'discount_percentage': item.discount_percentage,
        'offer_valid_until': item.offer_valid_until.isoformat() if item.offer_valid_until else None,
        'updated_at': item.updated_at.isoformat()
    }
    if include_relations:
        data['product'] = product_to_dict(item.product) if item.product else None
        data['store'] = store_to_dict(item.store) if item.store else None
    return data

# ============ ROUTES ============

@app.route('/')
def root():
    return jsonify({
        'message': 'Material Map API',
        'version': '1.0.0',
        'status': 'running',
        'docs': '/api/docs'
    })

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'healthy',
        'message': 'Material Map API is running',
        'database': 'supabase',
        'timestamp': datetime.utcnow().isoformat()
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

@app.route('/api/status', methods=['GET'])
def status():
    """Backend status endpoint with database check"""
    try:
        # Try to query the database
        user_count = User.query.count()
        product_count = Product.query.count()
        store_count = Store.query.count()
        inventory_count = InventoryItem.query.count()
        
        database_url = os.getenv('DATABASE_URL', 'sqlite:///material_map.db')
        db_type = 'PostgreSQL' if 'postgresql' in database_url else 'SQLite'
        
        return jsonify({
            'status': 'healthy',
            'message': 'Material Map API is operational',
            'database_connected': True,
            'database_type': db_type,
            'environment': os.getenv('ENVIRONMENT', 'development'),
            'api_version': '1.0.0',
            'data_stats': {
                'users': user_count,
                'products': product_count,
                'stores': store_count,
                'inventory_items': inventory_count
            },
            'timestamp': datetime.utcnow().isoformat()
        })
    except Exception as e:
        database_url = os.getenv('DATABASE_URL', 'sqlite:///material_map.db')
        db_type = 'PostgreSQL' if 'postgresql' in database_url else 'SQLite'
        
        return jsonify({
            'status': 'error',
            'message': 'API is running but database connection failed',
            'database_connected': False,
            'database_type': db_type,
            'environment': os.getenv('ENVIRONMENT', 'development'),
            'error': str(e),
            'advice': 'If using Render, ensure DATABASE_URL is set in environment variables. See GET_SUPABASE_URL.md',
            'timestamp': datetime.utcnow().isoformat()
        }), 503

import time

def retry_operation(func, max_retries=3, delay=2):
    """Retry a database operation with exponential backoff"""
    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            print(f"⚠️  Attempt {attempt + 1} failed: {str(e)[:100]}. Retrying in {delay}s...")
            time.sleep(delay)
            delay *= 2  # Exponential backoff

@app.route('/api/quick-seed', methods=['POST'])
def quick_seed():
    """Fast seed with minimal essential data (10+ products)"""
    try:
        product_count = Product.query.count()
        if product_count > 0:
            return jsonify({
                'message': 'Database already contains data',
                'products_count': product_count
            }), 409
        
        print("Quick seeding database...")
        
        def seed_data():
            # Create 3 stores
            stores = [
                Store(id=generate_id(), name="Fresh Market", category="grocery", address="Market St", latitude=11.34, longitude=77.71),
                Store(id=generate_id(), name="Office Supplies", category="stationery", address="School Rd", latitude=11.35, longitude=77.72),
                Store(id=generate_id(), name="Home Mart", category="household", address="Main Ave", latitude=11.33, longitude=77.70),
            ]
            db.session.add_all(stores)
            db.session.commit()
            
            # Create 15 essential products
            products = [
                Product(id=generate_id(), name="Rice", brand="India Gate", category="grocery", unit="1kg", description="Premium rice"),
                Product(id=generate_id(), name="Oil", brand="Fortune", category="grocery", unit="1L"),
                Product(id=generate_id(), name="Flour", brand="Aashirvaad", category="grocery", unit="5kg"),
                Product(id=generate_id(), name="Tomato", brand="Fresh", category="grocery", unit="500g"),
                Product(id=generate_id(), name="Potato", brand="Farm", category="grocery", unit="1kg"),
                Product(id=generate_id(), name="Notebook", brand="ITC", category="stationery", unit="200pg"),
                Product(id=generate_id(), name="Pen", brand="Reynolds", category="stationery", unit="Pack of 5"),
                Product(id=generate_id(), name="Pencil", brand="Camlin", category="stationery", unit="Box of 12"),
                Product(id=generate_id(), name="Soap", brand="Dettol", category="household", unit="100g"),
                Product(id=generate_id(), name="Cleaner", brand="Vim", category="household", unit="500ml"),
                Product(id=generate_id(), name="Detergent", brand="Omo", category="household", unit="1kg"),
                Product(id=generate_id(), name="Sugar", brand="Uttam", category="grocery", unit="1kg"),
                Product(id=generate_id(), name="Salt", brand="Tata", category="grocery", unit="1kg"),
                Product(id=generate_id(), name="Scissors", brand="Kangaro", category="stationery", unit="1pc"),
                Product(id=generate_id(), name="Towels", brand="Scotch", category="household", unit="2 rolls"),
            ]
            db.session.add_all(products)
            db.session.commit()
            
            # Create inventory items (2 per product)
            for product in products:
                for i, store in enumerate(stores[:2]):
                    price = 50 + (len(product.name) * 3) + (i * 10)
                    inventory = InventoryItem(
                        id=generate_id(),
                        product_id=product.id,
                        store_id=store.id,
                        price=price,
                        quantity=100 - i*20,
                        discount_percentage=5 if i == 0 else 0
                    )
                    db.session.add(inventory)
            db.session.commit()
            
            return {
                'stores': len(stores),
                'products': len(products),
                'inventory_items': len(products) * 2
            }
        
        # Retry the seeding operation
        result = retry_operation(seed_data, max_retries=3, delay=2)
        
        return jsonify({
            'message': 'Quick seed successful! ✅',
            'stores': result['stores'],
            'products': result['products'],
            'inventory_items': result['inventory_items']
        }), 201
    except Exception as e:
        db.session.rollback()
        print(f"❌ Seeding failed: {str(e)}")
        return jsonify({'error': 'Seeding failed', 'details': str(e)[:200]}), 500

@app.route('/api/seed', methods=['POST'])
def seed_database():
    """Initialize database with demo data if empty"""
    try:
        # Check if database already has data
        product_count = Product.query.count()
        if product_count > 0:
            return jsonify({
                'message': 'Database already contains data',
                'products_count': product_count
            }), 409
        
        # Initialize database with demo data
        print("Seeding database with demo data...")
        init_db()
        
        return jsonify({
            'message': 'Database seeded successfully',
            'status': 'success'
        }), 201
    except Exception as e:
        return jsonify({
            'detail': 'Error seeding database',
            'error': str(e)
        }), 500

# ---- AUTHENTICATION ROUTES ----

@app.route('/api/auth/register', methods=['POST'])
def register():
    data = request.get_json()
    
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({'detail': 'Email and password required'}), 400
    
    # Check if user exists
    if User.query.filter_by(email=data['email']).first():
        return jsonify({'detail': 'Email already registered'}), 400
    
    # Create new user
    user_id = generate_id()
    user = User(
        id=user_id,
        email=data['email'],
        hashed_password=hash_password(data['password'])
    )
    db.session.add(user)
    db.session.commit()
    
    token = create_access_token(user_id)
    
    return jsonify({
        'access_token': token,
        'token_type': 'bearer',
        'user': {
            'id': user.id,
            'email': user.email,
            'created_at': user.created_at.isoformat()
        }
    }), 201

@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({'detail': 'Email and password required'}), 400
    
    user = User.query.filter_by(email=data['email']).first()
    
    if not user or not verify_password(data['password'], user.hashed_password):
        return jsonify({'detail': 'Invalid email or password'}), 401
    
    token = create_access_token(user.id)
    
    return jsonify({
        'access_token': token,
        'token_type': 'bearer',
        'user': {
            'id': user.id,
            'email': user.email,
            'created_at': user.created_at.isoformat()
        }
    })

@app.route('/api/auth/me', methods=['GET'])
def get_user():
    token = request.args.get('token')
    if not token:
        return jsonify({'detail': 'Missing token'}), 401
    
    token_data = decode_token(token)
    if not token_data:
        return jsonify({'detail': 'Invalid token'}), 401
    
    user = User.query.get(token_data['user_id'])
    if not user:
        return jsonify({'detail': 'User not found'}), 404
    
    return jsonify({
        'id': user.id,
        'email': user.email,
        'created_at': user.created_at.isoformat()
    })

@app.route('/api/auth/logout', methods=['POST'])
def logout():
    return jsonify({'message': 'Logout successful'})

# ---- PRODUCT ROUTES ----

@app.route('/api/products', methods=['GET'])
def get_all_products():
    try:
        products = Product.query.all()
        return jsonify([product_to_dict(p) for p in products])
    except Exception as e:
        return jsonify({
            'detail': 'Error fetching products',
            'error': str(e)
        }), 500

@app.route('/api/products/category/<category>', methods=['GET'])
def get_by_category(category):
    try:
        products = Product.query.filter_by(category=category).limit(30).all()
        return jsonify([product_to_dict(p) for p in products])
    except Exception as e:
        return jsonify({
            'detail': 'Error fetching products by category',
            'error': str(e)
        }), 500

@app.route('/api/products/search', methods=['GET'])
def search_products():
    try:
        query = request.args.get('q', '').lower()
        if not query:
            return jsonify([])
        
        products = Product.query.filter(
            (Product.name.ilike(f'%{query}%')) |
            (Product.brand.ilike(f'%{query}%'))
        ).limit(20).all()
        
        return jsonify([product_to_dict(p) for p in products])
    except Exception as e:
        return jsonify({
            'detail': 'Error searching products',
            'error': str(e)
        }), 500

@app.route('/api/products/<product_id>', methods=['GET'])
def get_product(product_id):
    product = Product.query.get(product_id)
    if not product:
        return jsonify({'detail': 'Product not found'}), 404
    return jsonify(product_to_dict(product))

@app.route('/api/products', methods=['POST'])
def create_product():
    data = request.get_json()
    product = Product(
        id=generate_id(),
        name=data.get('name'),
        brand=data.get('brand'),
        category=data.get('category'),
        image_url=data.get('image_url'),
        description=data.get('description'),
        unit=data.get('unit')
    )
    db.session.add(product)
    db.session.commit()
    return jsonify(product_to_dict(product)), 201

# ---- STORE ROUTES ----

@app.route('/api/stores', methods=['GET'])
def get_all_stores():
    try:
        stores = Store.query.all()
        return jsonify([store_to_dict(s) for s in stores])
    except Exception as e:
        return jsonify({
            'detail': 'Error fetching stores',
            'error': str(e)
        }), 500

@app.route('/api/store-categories', methods=['GET'])
def get_store_categories():
    """Get unique store categories"""
    try:
        categories = db.session.query(Store.category).distinct().all()
        return jsonify([cat[0] for cat in categories if cat[0]])
    except Exception as e:
        return jsonify({
            'detail': 'Error fetching store categories',
            'error': str(e)
        }), 500

@app.route('/api/stores/category/<category>', methods=['GET'])
def get_stores_by_category(category):
    try:
        stores = Store.query.filter_by(category=category).all()
        return jsonify([store_to_dict(s) for s in stores])
    except Exception as e:
        return jsonify({
            'detail': 'Error fetching stores by category',
            'error': str(e)
        }), 500

@app.route('/api/stores/<store_id>', methods=['GET'])
def get_store(store_id):
    store = Store.query.get(store_id)
    if not store:
        return jsonify({'detail': 'Store not found'}), 404
    return jsonify(store_to_dict(store))

@app.route('/api/stores', methods=['POST'])
def create_store():
    data = request.get_json()
    store = Store(
        id=generate_id(),
        name=data.get('name'),
        address=data.get('address'),
        latitude=data.get('latitude'),
        longitude=data.get('longitude'),
        phone=data.get('phone'),
        image_url=data.get('image_url')
    )
    db.session.add(store)
    db.session.commit()
    return jsonify(store_to_dict(store)), 201

@app.route('/api/stores/nearby', methods=['GET'])
def get_nearby_stores():
    try:
        import math
        
        lat = float(request.args.get('latitude', 0))
        lon = float(request.args.get('longitude', 0))
        radius = float(request.args.get('radius', 10))
        
        stores = Store.query.all()
        nearby = []
        
        for store in stores:
            if store.latitude and store.longitude:
                lat1, lon1 = math.radians(lat), math.radians(lon)
                lat2, lon2 = math.radians(store.latitude), math.radians(store.longitude)
                
                dlat = lat2 - lat1
                dlon = lon2 - lon1
                
                a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
                c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
                distance = 6371 * c
                
                if distance <= radius:
                    nearby.append(store)
        
        return jsonify([store_to_dict(s) for s in nearby])
    except Exception as e:
        return jsonify({
            'detail': 'Error fetching nearby stores',
            'error': str(e)
        }), 500

# ---- INVENTORY ROUTES ----

@app.route('/api/inventory', methods=['GET'])
def get_all_inventory():
    try:
        items = InventoryItem.query.all()
        return jsonify([inventory_to_dict(i) for i in items])
    except Exception as e:
        return jsonify({
            'detail': 'Error fetching inventory',
            'error': str(e)
        }), 500

@app.route('/api/inventory/product/<product_id>', methods=['GET'])
def get_product_inventory(product_id):
    try:
        items = InventoryItem.query.filter_by(product_id=product_id).all()
        items.sort(key=lambda x: x.price)
        return jsonify([inventory_to_dict(i, include_relations=True) for i in items])
    except Exception as e:
        return jsonify({
            'detail': 'Error fetching product inventory',
            'error': str(e)
        }), 500

@app.route('/api/inventory/store/<store_id>', methods=['GET'])
def get_store_inventory(store_id):
    try:
        items = InventoryItem.query.filter_by(store_id=store_id).all()
        return jsonify([inventory_to_dict(i) for i in items])
    except Exception as e:
        return jsonify({
            'detail': 'Error fetching store inventory',
            'error': str(e)
        }), 500

@app.route('/api/inventory/<item_id>', methods=['GET'])
def get_inventory_item(item_id):
    item = InventoryItem.query.get(item_id)
    if not item:
        return jsonify({'detail': 'Inventory item not found'}), 404
    return jsonify(inventory_to_dict(item, include_relations=True))

@app.route('/api/inventory', methods=['POST'])
def create_inventory():
    data = request.get_json()
    item = InventoryItem(
        id=generate_id(),
        product_id=data.get('product_id'),
        store_id=data.get('store_id'),
        price=data.get('price'),
        quantity=data.get('quantity'),
        original_price=data.get('original_price'),
        discount_percentage=data.get('discount_percentage'),
        offer_valid_until=data.get('offer_valid_until')
    )
    db.session.add(item)
    db.session.commit()
    return jsonify(inventory_to_dict(item)), 201

@app.route('/api/inventory/<item_id>', methods=['PUT'])
def update_inventory(item_id):
    item = InventoryItem.query.get(item_id)
    if not item:
        return jsonify({'detail': 'Inventory item not found'}), 404
    
    data = request.get_json()
    if 'price' in data:
        item.price = data['price']
    if 'quantity' in data:
        item.quantity = data['quantity']
    if 'original_price' in data:
        item.original_price = data['original_price']
    if 'discount_percentage' in data:
        item.discount_percentage = data['discount_percentage']
    if 'offer_valid_until' in data:
        item.offer_valid_until = data['offer_valid_until']
    
    item.updated_at = datetime.utcnow()
    db.session.commit()
    return jsonify(inventory_to_dict(item))

@app.route('/api/inventory/<item_id>', methods=['DELETE'])
def delete_inventory(item_id):
    item = InventoryItem.query.get(item_id)
    if not item:
        return jsonify({'detail': 'Inventory item not found'}), 404
    
    db.session.delete(item)
    db.session.commit()
    return jsonify({'message': 'Inventory item deleted successfully'})

# ============ INITIALIZATION ============

def init_db():
    """Initialize database with comprehensive demo data"""
    with app.app_context():
        print("Creating database tables...")
        db.drop_all()  # Drop all existing tables to start fresh
        db.create_all()
        print("✅ Tables created (fresh start)")
        
        # ===== GROCERY STORES =====
        print("Seeding stores by category...")
        grocery_stores_data = [
            {
                "id": generate_id(),
                "name": "🥬 Fresh Vegetables",
                "category": "grocery",
                "address": "Green Market, Main Street, Downtown",
                "latitude": 11.3415,
                "longitude": 77.7171,
                "phone": "+91-123-456-7890"
            },
            {
                "id": generate_id(),
                "name": "🆕 New Veggies Market",
                "category": "grocery",
                "address": "Modern Plaza, Park Road, Uptown",
                "latitude": 11.3380,
                "longitude": 77.7250,
                "phone": "+91-123-456-7891"
            },
            {
                "id": generate_id(),
                "name": "🌾 Organic Grains Hub",
                "category": "grocery",
                "address": "Farmer's Market, NH-47, Bypass",
                "latitude": 11.3500,
                "longitude": 77.7100,
                "phone": "+91-123-456-7892"
            },
            {
                "id": generate_id(),
                "name": "🛢️ Premium Foods Store",
                "category": "grocery",
                "address": "Premium Plaza, Business District",
                "latitude": 11.3450,
                "longitude": 77.7300,
                "phone": "+91-123-456-7893"
            },
        ]
        
        # ===== STATIONERY STORES =====
        stationery_stores_data = [
            {
                "id": generate_id(),
                "name": "📚 Manus Store",
                "category": "stationery",
                "address": "Education Plaza, School Road",
                "latitude": 11.3425,
                "longitude": 77.7180,
                "phone": "+91-234-567-8901"
            },
            {
                "id": generate_id(),
                "name": "✏️ Scholar's Hub",
                "category": "stationery",
                "address": "Study Center, College Avenue",
                "latitude": 11.3405,
                "longitude": 77.7210,
                "phone": "+91-234-567-8902"
            },
            {
                "id": generate_id(),
                "name": "📖 Knowledge Corner",
                "category": "stationery",
                "address": "Library Lane, Community Center",
                "latitude": 11.3435,
                "longitude": 77.7160,
                "phone": "+91-234-567-8903"
            },
        ]
        
        # ===== HOUSEHOLD STORES =====
        household_stores_data = [
            {
                "id": generate_id(),
                "name": "🧹 Clean Home Mart",
                "category": "household",
                "address": "Shopping Complex, Market Street",
                "latitude": 11.3410,
                "longitude": 77.7190,
                "phone": "+91-345-678-9012"
            },
            {
                "id": generate_id(),
                "name": "🏠 Home Essentials",
                "category": "household",
                "address": "Retail Park, Trade Avenue",
                "latitude": 11.3420,
                "longitude": 77.7140,
                "phone": "+91-345-678-9013"
            },
        ]
        
        # ===== PLUMBING STORES =====
        plumbing_stores_data = [
            {
                "id": generate_id(),
                "name": "🔧 Pipe & Valve Hub",
                "category": "plumbing",
                "address": "Industrial Area, Engineering Road",
                "latitude": 11.3450,
                "longitude": 77.7210,
                "phone": "+91-456-789-0123"
            },
            {
                "id": generate_id(),
                "name": "💧 Plumbing Plus",
                "category": "plumbing",
                "address": "Trade Center, Commerce Lane",
                "latitude": 11.3380,
                "longitude": 77.7160,
                "phone": "+91-456-789-0124"
            },
        ]
        
        # ===== ELECTRONICS STORES =====
        electronics_stores_data = [
            {
                "id": generate_id(),
                "name": "💡 Electronics World",
                "category": "electronics",
                "address": "Tech Park, Digital Avenue",
                "latitude": 11.3390,
                "longitude": 77.7230,
                "phone": "+91-567-890-1234"
            },
            {
                "id": generate_id(),
                "name": "⚡ Power & Lights",
                "category": "electronics",
                "address": "Shopping Hub, Retail Drive",
                "latitude": 11.3430,
                "longitude": 77.7120,
                "phone": "+91-567-890-1235"
            },
        ]
        
        all_stores = []
        
        # Save all stores
        for store_data in grocery_stores_data + stationery_stores_data + household_stores_data + plumbing_stores_data + electronics_stores_data:
            store = Store(**store_data)
            db.session.add(store)
            all_stores.append(store)
        
        db.session.commit()
        print(f"✅ {len(all_stores)} stores seeded")
        
        # ===== PRODUCTS WITH DETAILED INFO =====
        print("Seeding products with brand, mfg date, and size info...")
        
        products_data = [
            # GROCERY
            ("Basmati Rice", "India Gate", "grocery", "1 kg", "Premium basmati | Mfg: Jan 2026 | Best Before: Dec 2027"),
            ("Jasmine Rice", "Tata", "grocery", "1 kg", "Jasmine fragrant | Mfg: Feb 2026 | Best Before: Jan 2028"),
            ("Cooking Oil", "Fortune", "grocery", "1 L", "Pure vegetable | Mfg: Mar 2026 | Best Before: Mar 2027"),
            ("Olive Oil", "Figaro", "grocery", "500 ml", "Extra virgin | Mfg: Dec 2025 | Best Before: Dec 2026"),
            ("Whole Wheat Atta", "Aashirvaad", "grocery", "5 kg", "Stone ground | Mfg: Feb 2026 | Best Before: Aug 2026"),
            ("Toor Dal", "Tata Sampann", "grocery", "500 g", "Yellow split | Mfg: Jan 2026 | Best Before: Jan 2027"),
            ("Sugar", "Uttam", "grocery", "1 kg", "Refined | Mfg: Feb 2026 | Best Before: Feb 2027"),
            ("Salt", "Tata Salt", "grocery", "1 kg", "Iodized | Mfg: Jan 2026 | Best Before: Dec 2026"),
            
            # VEGETABLES
            ("Tomato", "Local Fresh", "vegetables", "500 g", "Red ripe tomatoes | Fresh arrival | Best within 3 days"),
            ("Potato", "Organic Picks", "vegetables", "1 kg", "White potato | Mfg: Feb 2026"),
            ("Onion", "Farm Fresh", "vegetables", "1 kg", "Golden onion | Fresh stock | Best within 2 weeks"),
            ("Carrot", "Fresh Farm", "vegetables", "500 g", "Orange carrots | Mfg: Feb 2026 | Best: 1 week"),
            ("Broccoli", "Green Picks", "vegetables", "1 head", "Fresh green broccoli | Best consumed within 5 days"),
            ("Capsicum", "Agro Fresh", "vegetables", "250 g", "Mixed colors | Fresh | Best within 1 week"),
            
            # STATIONERY - With sizes and brands
            ("Books", "Classmate", "stationery", "100 pages", "Notebook | Ruled | Mfg: Jan 2026 | Brand: ITC Classmate"),
            ("Books", "Classmate", "stationery", "200 pages", "Notebook | Ruled | Mfg: Jan 2026 | Brand: ITC Classmate"),
            ("Books", "Camlin", "stationery", "150 pages", "Drawing book | Blank | Mfg: Feb 2026 | Brand: Camlin"),
            ("Pens", "Reynolds", "stationery", "Pack of 5", "Blue ballpoint | Mfg: Dec 2025 | Brand: Reynolds"),
            ("Pens", "Reynolds", "stationery", "Pack of 10", "Blue ballpoint | Mfg: Dec 2025 | Brand: Reynolds"),
            ("Pencils", "Camlin", "stationery", "Set of 12", "HB lead | Mfg: Jan 2026 | Brand: Camlin"),
            ("Pencils", "Camlin", "stationery", "Set of 24", "Assorted | Mfg: Jan 2026 | Brand: Camlin"),
            ("Stapler", "Kangaro", "stationery", "1 piece", "Desktop stapler | Mfg: Nov 2025 | Brand: Kangaro"),
            ("Eraser", "Apsara", "stationery", "Pack of 2", "Vinyl eraser | Mfg: Dec 2025 | Brand: Apsara"),
            ("Ruler", "Camlin", "stationery", "30 cm", "Plastic ruler | Mfg: Jan 2026 | Brand: Camlin"),
            
            # HOUSEHOLD
            ("Detergent", "Surf Excel", "household", "1 kg", "Powder detergent | Mfg: Feb 2026 | Best Before: Feb 2027"),
            ("Dish Soap", "Vim", "household", "750 ml", "Liquid soap | Mfg: Mar 2026 | Best Before: Mar 2027"),
            ("Paper Towels", "Scotch Brite", "household", "2 rolls", "2-ply roll | Mfg: Jan 2026 | Best Before: Jan 2028"),
            ("Trash Bags", "Safewrap", "household", "Pack of 30", "Large size bags | Mfg: Feb 2026 | Best Before: Feb 2028"),
            
            # PLUMBING
            ("Chrome Faucet", "Parryware", "plumbing", "1 piece", "Modern chrome finish | Hot & cold water | Mfg: Jan 2026"),
            ("Adjustable Wrench", "Stanley", "plumbing", "10 inch", "Professional grade | Mfg: Dec 2025 | Best for 8-30mm"),
            ("PVC Pipe", "Supreme", "plumbing", "3 m length", "Water delivery | Class B | Mfg: Feb 2026 | Durable"),
            ("Teflon Tape", "Tapex", "plumbing", "Pack of 3", "Thread seal tape | Mfg: Jan 2026 | Standard width"),
            
            # ELECTRONICS
            ("LED Bulb 9W", "Philips", "electronics", "1 piece", "Warm white | 6500K | Mfg: Feb 2026 | Energy efficient"),
            ("Extension Cord", "Anchor", "electronics", "5 m", "Heavy duty | 3 pins | Mfg: Jan 2026 | Safety certified"),
            ("USB-C Charger", "Boat", "electronics", "20W", "Fast charging | Mfg: Mar 2026 | Universal compatible"),
            ("AA Batteries", "Duracell", "electronics", "Pack of 4", "Alkaline | Ultra power | Mfg: Feb 2026 | Long lasting"),
        ]
        
        all_products = []
        for name, brand, category, unit, description in products_data:
            product = Product(
                id=generate_id(),
                name=name,
                brand=brand,
                category=category,
                unit=unit,
                description=description
            )
            db.session.add(product)
            all_products.append(product)
        
        db.session.commit()
        print(f"✅ {len(all_products)} products seeded")
        
        # ===== INVENTORY WITH VARIED PRICING =====
        print("Seeding inventory with different prices per store...")
        
        inventory_count = 0
        
        # Helper function to assign products to appropriate stores
        def add_inventory(product, store, price, quantity, discount_percentage=None, original_price=None):
            nonlocal inventory_count
            # If discount is provided, calculate original_price if not given
            if discount_percentage and not original_price:
                original_price = price / (1 - discount_percentage / 100)
            
            offer_valid_until = None
            if discount_percentage:
                # Offer valid for 30 days
                offer_valid_until = datetime.utcnow() + timedelta(days=30)
            
            inventory = InventoryItem(
                id=generate_id(),
                product_id=product.id,
                store_id=store.id,
                price=float(price),
                quantity=quantity,
                original_price=float(original_price) if original_price else None,
                discount_percentage=float(discount_percentage) if discount_percentage else None,
                offer_valid_until=offer_valid_until
            )
            db.session.add(inventory)
            inventory_count += 1
        
        # Assign grocery items to grocery stores
        grocery_products = [p for p in all_products if p.category == "grocery"]
        grocery_stores = all_stores[:4]
        
        for idx, product in enumerate(grocery_products):
            # Each store has different prices (to show price comparison)
            prices = [95 + idx*5, 100 + idx*5, 110 + idx*5, 92 + idx*5]
            quantities = [45, 52, 38, 60]
            
            for store_idx, (store, price, qty) in enumerate(zip(grocery_stores, prices, quantities)):
                # Add 15% discount to some items in some stores
                discount = 15 if store_idx % 2 == 0 else None
                discounted_price = price if not discount else price * (1 - discount / 100)
                add_inventory(product, store, discounted_price, qty, discount_percentage=discount, original_price=price)
        
        # Assign vegetable items to grocery stores (fresh items)
        veggie_products = [p for p in all_products if p.category == "vegetables"]
        for product in veggie_products:
            prices = [35, 38, 32, 40]
            quantities = [25, 18, 32, 22]
            for store_idx, (store, price, qty) in enumerate(zip(grocery_stores, prices, quantities)):
                # Add 20% discount to alternating items
                discount = 20 if store_idx % 2 == 1 else None
                discounted_price = price if not discount else price * (1 - discount / 100)
                add_inventory(product, store, discounted_price, qty, discount_percentage=discount, original_price=price)
        
        # Assign stationery items to stationery stores
        stationery_products = [p for p in all_products if p.category == "stationery"]
        stationery_stores = all_stores[4:7]
        
        for product in stationery_products:
            # Different prices for different store brands
            prices = [85, 92, 78]
            quantities = [150, 120, 180]
            for store_idx, (store, price, qty) in enumerate(zip(stationery_stores, prices, quantities)):
                base_price = price + len(product.name)
                # Add 10% discount to the first store
                discount = 10 if store_idx == 0 else None
                discounted_price = base_price if not discount else base_price * (1 - discount / 100)
                add_inventory(product, store, discounted_price, qty, discount_percentage=discount, original_price=base_price)
        
        # Assign household items to household stores
        household_products = [p for p in all_products if p.category == "household"]
        household_stores = all_stores[7:9]
        
        for product in household_products:
            prices = [120, 125]
            quantities = [75, 85]
            for store_idx, (store, price, qty) in enumerate(zip(household_stores, prices, quantities)):
                # Add 12% discount to alternating items
                discount = 12 if store_idx == 1 else None
                discounted_price = price if not discount else price * (1 - discount / 100)
                add_inventory(product, store, discounted_price, qty, discount_percentage=discount, original_price=price)
        
        # Assign plumbing items to plumbing stores
        plumbing_products = [p for p in all_products if p.category == "plumbing"]
        plumbing_stores = all_stores[9:11]
        
        for product in plumbing_products:
            prices = [450, 480]
            quantities = [45, 50]
            for store_idx, (store, price, qty) in enumerate(zip(plumbing_stores, prices, quantities)):
                base_price = price + len(product.name) * 5
                # Add 8% discount to first store
                discount = 8 if store_idx == 0 else None
                discounted_price = base_price if not discount else base_price * (1 - discount / 100)
                add_inventory(product, store, discounted_price, qty, discount_percentage=discount, original_price=base_price)
        
        # Assign electronics items to electronics stores
        electronics_products = [p for p in all_products if p.category == "electronics"]
        electronics_stores = all_stores[11:13]
        
        for product in electronics_products:
            prices = [550, 600]
            quantities = [60, 70]
            for store_idx, (store, price, qty) in enumerate(zip(electronics_stores, prices, quantities)):
                base_price = price + len(product.name) * 3
                # Add 18% discount to alternating items
                discount = 18 if store_idx == 1 else None
                discounted_price = base_price if not discount else base_price * (1 - discount / 100)
                add_inventory(product, store, discounted_price, qty, discount_percentage=discount, original_price=base_price)
        
        db.session.commit()
        print(f"✅ {inventory_count} inventory items seeded")
        print("\n🎉 DATABASE FULLY POPULATED!")
        print(f"   - {len(all_stores)} Stores (organized by category)")
        print(f"   - {len(all_products)} Products (with brand, size & mfg date)")
        print(f"   - {inventory_count} Inventory items (with varied prices)")

if __name__ == '__main__':
    print(f"Starting Flask server on {os.getenv('HOST', '0.0.0.0')}:{os.getenv('PORT', 9000)}")
    app.run(
        host=os.getenv('HOST', '0.0.0.0'),
        port=int(os.getenv('PORT', 9000)),
        debug=os.getenv('DEBUG', 'False').lower() == 'true'
    )

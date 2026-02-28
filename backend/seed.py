"""
Seed data for testing/development
"""
from database import SessionLocal, Product, Store, InventoryItem, User
from auth import generate_id, hash_password

def seed_database():
    """Populate database with initial data"""
    db = SessionLocal()
    
    # Check if data already exists
    if db.query(Store).first() is not None:
        db.close()
        return  # Data already exists
    
    # Create test user
    test_user = User(
        id=generate_id(),
        email="test@example.com",
        hashed_password=hash_password("password123")
    )
    db.add(test_user)
    db.commit()
    
    # Create stores
    stores_data = [
        {
            "name": "Fresh Mart",
            "address": "12, Market Road",
            "latitude": 11.3415,
            "longitude": 77.7171,
            "phone": "+91-123-456-7890"
        },
        {
            "name": "Super Save",
            "address": "45, Gandhi Nagar",
            "latitude": 11.3380,
            "longitude": 77.7250,
            "phone": "+91-123-456-7891"
        },
        {
            "name": "Big Bazaar",
            "address": "NH-47 Bypass",
            "latitude": 11.3500,
            "longitude": 77.7100,
            "phone": "+91-123-456-7892"
        },
        {
            "name": "Daily Needs",
            "address": "Bus Stand Road",
            "latitude": 11.3310,
            "longitude": 77.7180,
            "phone": "+91-123-456-7893"
        },
        {
            "name": "Value Mart",
            "address": "Perundurai Rd",
            "latitude": 11.3450,
            "longitude": 77.7300,
            "phone": "+91-123-456-7894"
        }
    ]
    
    stores = []
    for store_data in stores_data:
        store = Store(id=generate_id(), **store_data)
        db.add(store)
        stores.append(store)
    db.commit()
    
    # Create products
    products_data = [
        # Grocery
        {"name": "Jasmine Rice", "brand": "India Gate", "category": "grocery", "unit": "1 kg", "description": "Premium basmati quality rice"},
        {"name": "Cooking Oil", "brand": "Fortune", "category": "grocery", "unit": "1 L"},
        {"name": "Whole Wheat Atta", "brand": "Aashirvaad", "category": "grocery", "unit": "5 kg"},
        {"name": "Toor Dal", "brand": "Tata Sampann", "category": "grocery", "unit": "500 g"},
        {"name": "Sugar", "brand": "Uttam", "category": "grocery", "unit": "1 kg"},
        {"name": "Salt", "brand": "Tata Salt", "category": "grocery", "unit": "1 kg"},
        # Vegetables
        {"name": "Tomato", "brand": "Fresh Farm", "category": "vegetables", "unit": "500 g"},
        {"name": "Potato", "brand": "Organic Picks", "category": "vegetables", "unit": "1 kg"},
        {"name": "Onion", "brand": "Farm Direct", "category": "vegetables", "unit": "1 kg"},
        {"name": "Carrot", "brand": "Fresh Farm", "category": "vegetables", "unit": "500 g"},
        {"name": "Broccoli", "brand": "Green Picks", "category": "vegetables", "unit": "1 head"},
        {"name": "Capsicum", "brand": "Fresh Farm", "category": "vegetables", "unit": "250 g"},
        # Stationery
        {"name": "Classmate Notebook", "brand": "ITC", "category": "stationery", "unit": "200 pages"},
        {"name": "Reynolds Pen", "brand": "Reynolds", "category": "stationery", "unit": "Pack of 5"},
        {"name": "Drawing Pencils", "brand": "Camlin", "category": "stationery", "unit": "Set of 12"},
        {"name": "Stapler", "brand": "Kangaro", "category": "stationery", "unit": "1 piece"},
        {"name": "Eraser", "brand": "Apsara", "category": "stationery", "unit": "Pack of 2"},
        {"name": "Scale / Ruler", "brand": "Camlin", "category": "stationery", "unit": "30 cm"},
        # Household
        {"name": "Surf Excel", "brand": "Hindustan Unilever", "category": "household", "unit": "1 kg"},
        {"name": "Vim Dish Soap", "brand": "Vim", "category": "household", "unit": "750 ml"},
        {"name": "Paper Towels", "brand": "Scotch Brite", "category": "household", "unit": "2 rolls"},
        {"name": "Trash Bags", "brand": "Safewrap", "category": "household", "unit": "Pack of 30"},
        # Plumbing
        {"name": "Chrome Faucet", "brand": "Parryware", "category": "plumbing", "unit": "1 piece"},
        {"name": "Adjustable Wrench", "brand": "Stanley", "category": "plumbing", "unit": "10 inch"},
        {"name": "PVC Pipe", "brand": "Supreme", "category": "plumbing", "unit": "3 m length"},
        {"name": "Teflon Tape", "brand": "Tapex", "category": "plumbing", "unit": "Pack of 3"},
        # Electronics
        {"name": "LED Bulb 9W", "brand": "Philips", "category": "electronics", "unit": "1 piece"},
        {"name": "Extension Cord", "brand": "Anchor", "category": "electronics", "unit": "5 m"},
        {"name": "USB-C Charger", "brand": "Boat", "category": "electronics", "unit": "20W"},
        {"name": "AA Batteries", "brand": "Duracell", "category": "electronics", "unit": "Pack of 4"},
    ]
    
    products = []
    for product_data in products_data:
        product = Product(id=generate_id(), **product_data)
        db.add(product)
        products.append(product)
    db.commit()
    
    # Create inventory items with varying prices for each store
    inventory_prices = {
        'g1': [65, 72, 78],  # Jasmine Rice
        'g2': [149, 155, 162],  # Cooking Oil
        'g3': [245, 260, 275],  # Atta
        'g4': [85, 90, 98],  # Toor Dal
        'g5': [44, 48, 52],  # Sugar
        'g6': [20, 22, 24],  # Salt
        'v1': [28, 32, 35],  # Tomato
        'v2': [30, 34, 38],  # Potato
        'v3': [35, 40, 45],  # Onion
        'v4': [42, 48, 55],  # Carrot
        'v5': [60, 68, 75],  # Broccoli
        'v6': [38, 45, 52],  # Capsicum
        's1': [35, 38, 42],  # Notebook
        's2': [25, 28, 32],  # Pen
        's3': [60, 65, 72],  # Pencils
        's4': [85, 95, 110],  # Stapler
        's5': [12, 15, 18],  # Eraser
        's6': [18, 20, 25],  # Scale
        'h1': [118, 125, 132],  # Surf Excel
        'h2': [75, 82, 90],  # Vim
        'h3': [95, 102, 115],  # Paper Towels
        'h4': [55, 62, 70],  # Trash Bags
        'p1': [550, 620, 690],  # Faucet
        'p2': [380, 420, 470],  # Wrench
        'p3': [120, 135, 150],  # PVC Pipe
        'p4': [25, 28, 32],  # Teflon Tape
        'e1': [75, 82, 90],  # LED Bulb
        'e2': [185, 195, 210],  # Extension Cord
        'e3': [550, 580, 620],  # USB-C Charger
        'e4': [120, 128, 140],  # Batteries
    }
    
    for idx, product in enumerate(products):
        prices = inventory_prices.get(product.id, [100, 110, 120])
        for store_idx, store in enumerate(stores[:3]):  # First 3 stores
            inventory = InventoryItem(
                id=generate_id(),
                product_id=product.id,
                store_id=store.id,
                price=float(prices[store_idx]),
                quantity=15 - store_idx * 4
            )
            db.add(inventory)
    
    db.commit()
    db.close()
    print("Database seeded successfully!")

if __name__ == "__main__":
    seed_database()

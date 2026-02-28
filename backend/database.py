from sqlalchemy import Column, String, Float, Integer, DateTime, Text, ForeignKey, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from datetime import datetime
from config import DATABASE_URL

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    
    id = Column(String, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    products = relationship("Product", back_populates="created_by_user")

class Product(Base):
    __tablename__ = "products"
    
    id = Column(String, primary_key=True, index=True)
    name = Column(String, index=True)
    brand = Column(String, index=True)
    category = Column(String, index=True)
    image_url = Column(String, nullable=True)
    description = Column(Text, nullable=True)
    unit = Column(String, nullable=True)
    created_by = Column(String, ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    created_by_user = relationship("User", back_populates="products")
    inventory_items = relationship("InventoryItem", back_populates="product")

class Store(Base):
    __tablename__ = "stores"
    
    id = Column(String, primary_key=True, index=True)
    name = Column(String, index=True)
    address = Column(String)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    phone = Column(String, nullable=True)
    image_url = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    inventory_items = relationship("InventoryItem", back_populates="store")

class InventoryItem(Base):
    __tablename__ = "inventory"
    
    id = Column(String, primary_key=True, index=True)
    product_id = Column(String, ForeignKey("products.id"))
    store_id = Column(String, ForeignKey("stores.id"))
    price = Column(Float)
    quantity = Column(Integer)
    original_price = Column(Float, nullable=True)  # Price before offer
    discount_percentage = Column(Float, nullable=True, default=0)  # Discount percentage
    offer_valid_until = Column(DateTime, nullable=True)  # When offer expires
    updated_at = Column(DateTime, default=datetime.utcnow)
    
    product = relationship("Product", back_populates="inventory_items")
    store = relationship("Store", back_populates="inventory_items")

# Database setup
if "sqlite" in DATABASE_URL:
    engine = create_engine(
        DATABASE_URL,
        connect_args={"check_same_thread": False}
    )
else:
    # PostgreSQL with connection pooling
    engine = create_engine(
        DATABASE_URL,
        pool_size=5,
        max_overflow=10,
        pool_pre_ping=True,
        pool_recycle=3600,
    )
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Create tables
Base.metadata.create_all(bind=engine)

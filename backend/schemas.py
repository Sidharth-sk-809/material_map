from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime

# User schemas
class UserCreate(BaseModel):
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: str
    email: str
    created_at: datetime
    
    class Config:
        from_attributes = True

class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse

# Product schemas
class ProductCreate(BaseModel):
    name: str
    brand: str
    category: str
    image_url: Optional[str] = None
    description: Optional[str] = None
    unit: Optional[str] = None

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    brand: Optional[str] = None
    category: Optional[str] = None
    image_url: Optional[str] = None
    description: Optional[str] = None
    unit: Optional[str] = None

class ProductResponse(BaseModel):
    id: str
    name: str
    brand: str
    category: str
    image_url: Optional[str] = None
    description: Optional[str] = None
    unit: Optional[str] = None
    created_at: datetime
    
    class Config:
        from_attributes = True

# Store schemas
class StoreCreate(BaseModel):
    name: str
    address: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    phone: Optional[str] = None
    image_url: Optional[str] = None

class StoreResponse(BaseModel):
    id: str
    name: str
    address: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    phone: Optional[str] = None
    image_url: Optional[str] = None
    created_at: datetime
    
    class Config:
        from_attributes = True

# Inventory schemas
class InventoryCreate(BaseModel):
    product_id: str
    store_id: str
    price: float
    quantity: int
    original_price: Optional[float] = None
    discount_percentage: Optional[float] = None
    offer_valid_until: Optional[datetime] = None

class InventoryUpdate(BaseModel):
    price: Optional[float] = None
    quantity: Optional[int] = None
    original_price: Optional[float] = None
    discount_percentage: Optional[float] = None
    offer_valid_until: Optional[datetime] = None

class InventoryResponse(BaseModel):
    id: str
    product_id: str
    store_id: str
    price: float
    quantity: int
    original_price: Optional[float] = None
    discount_percentage: Optional[float] = None
    offer_valid_until: Optional[datetime] = None
    updated_at: datetime
    
    class Config:
        from_attributes = True

class InventoryDetailResponse(BaseModel):
    id: str
    product_id: str
    store_id: str
    price: float
    quantity: int
    updated_at: datetime
    product: Optional[ProductResponse] = None
    store: Optional[StoreResponse] = None
    
    class Config:
        from_attributes = True

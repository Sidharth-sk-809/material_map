from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy import or_, and_
from database import get_db, Product
from schemas import ProductCreate, ProductResponse, ProductUpdate
from auth import generate_id
from typing import List

router = APIRouter(prefix="/api/products", tags=["products"])

@router.get("", response_model=List[ProductResponse])
async def get_all_products(db: Session = Depends(get_db)):
    """Get all products"""
    products = db.query(Product).all()
    return [ProductResponse.from_orm(p) for p in products]

@router.get("/category/{category}", response_model=List[ProductResponse])
async def get_by_category(category: str, db: Session = Depends(get_db)):
    """Get products by category"""
    products = db.query(Product).filter(Product.category == category).limit(30).all()
    return [ProductResponse.from_orm(p) for p in products]

@router.get("/search", response_model=List[ProductResponse])
async def search_products(q: str = Query(..., min_length=1), db: Session = Depends(get_db)):
    """Search products by name or brand"""
    query_lower = q.lower()
    products = db.query(Product).filter(
        or_(
            Product.name.ilike(f"%{query_lower}%"),
            Product.brand.ilike(f"%{query_lower}%")
        )
    ).limit(20).all()
    return [ProductResponse.from_orm(p) for p in products]

@router.get("/{product_id}", response_model=ProductResponse)
async def get_product(product_id: str, db: Session = Depends(get_db)):
    """Get product by ID"""
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    return ProductResponse.from_orm(product)

@router.post("", response_model=ProductResponse)
async def create_product(product: ProductCreate, db: Session = Depends(get_db)):
    """Create a new product"""
    product_id = generate_id()
    db_product = Product(
        id=product_id,
        name=product.name,
        brand=product.brand,
        category=product.category,
        image_url=product.image_url,
        description=product.description,
        unit=product.unit
    )
    db.add(db_product)
    db.commit()
    db.refresh(db_product)
    return ProductResponse.from_orm(db_product)

@router.put("/{product_id}", response_model=ProductResponse)
async def update_product(
    product_id: str, 
    product: ProductUpdate, 
    db: Session = Depends(get_db)
):
    """Update a product"""
    db_product = db.query(Product).filter(Product.id == product_id).first()
    if not db_product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    
    update_data = product.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_product, field, value)
    
    db.commit()
    db.refresh(db_product)
    return ProductResponse.from_orm(db_product)

@router.delete("/{product_id}")
async def delete_product(product_id: str, db: Session = Depends(get_db)):
    """Delete a product"""
    db_product = db.query(Product).filter(Product.id == product_id).first()
    if not db_product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    
    db.delete(db_product)
    db.commit()
    return {"message": "Product deleted successfully"}

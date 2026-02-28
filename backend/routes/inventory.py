from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from database import get_db, InventoryItem
from schemas import InventoryCreate, InventoryResponse, InventoryUpdate, InventoryDetailResponse
from auth import generate_id
from typing import List

router = APIRouter(prefix="/api/inventory", tags=["inventory"])

@router.get("", response_model=List[InventoryResponse])
async def get_all_inventory(db: Session = Depends(get_db)):
    """Get all inventory items"""
    items = db.query(InventoryItem).all()
    return [InventoryResponse.from_orm(item) for item in items]

@router.get("/product/{product_id}", response_model=List[InventoryDetailResponse])
async def get_product_inventory(product_id: str, db: Session = Depends(get_db)):
    """Get all inventory for a specific product"""
    items = db.query(InventoryItem).filter(
        InventoryItem.product_id == product_id
    ).all()
    
    # Sort by price ascending
    items.sort(key=lambda x: x.price)
    
    result = []
    for item in items:
        result.append({
            "id": item.id,
            "product_id": item.product_id,
            "store_id": item.store_id,
            "price": item.price,
            "quantity": item.quantity,
            "updated_at": item.updated_at,
            "product": None,
            "store": {
                "id": item.store.id,
                "name": item.store.name,
                "address": item.store.address,
                "latitude": item.store.latitude,
                "longitude": item.store.longitude,
                "phone": item.store.phone,
                "image_url": item.store.image_url,
                "created_at": item.store.created_at
            } if item.store else None
        })
    
    return result

@router.get("/store/{store_id}", response_model=List[InventoryResponse])
async def get_store_inventory(store_id: str, db: Session = Depends(get_db)):
    """Get all inventory for a specific store"""
    items = db.query(InventoryItem).filter(
        InventoryItem.store_id == store_id
    ).all()
    return [InventoryResponse.from_orm(item) for item in items]

@router.get("/{item_id}", response_model=InventoryDetailResponse)
async def get_inventory_item(item_id: str, db: Session = Depends(get_db)):
    """Get inventory item by ID"""
    item = db.query(InventoryItem).filter(InventoryItem.id == item_id).first()
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Inventory item not found"
        )
    
    return {
        "id": item.id,
        "product_id": item.product_id,
        "store_id": item.store_id,
        "price": item.price,
        "quantity": item.quantity,
        "updated_at": item.updated_at,
        "product": {
            "id": item.product.id,
            "name": item.product.name,
            "brand": item.product.brand,
            "category": item.product.category,
            "image_url": item.product.image_url,
            "description": item.product.description,
            "unit": item.product.unit,
            "created_at": item.product.created_at
        } if item.product else None,
        "store": {
            "id": item.store.id,
            "name": item.store.name,
            "address": item.store.address,
            "latitude": item.store.latitude,
            "longitude": item.store.longitude,
            "phone": item.store.phone,
            "image_url": item.store.image_url,
            "created_at": item.store.created_at
        } if item.store else None
    }

@router.post("", response_model=InventoryResponse)
async def create_inventory_item(item: InventoryCreate, db: Session = Depends(get_db)):
    """Create a new inventory item"""
    item_id = generate_id()
    db_item = InventoryItem(
        id=item_id,
        product_id=item.product_id,
        store_id=item.store_id,
        price=item.price,
        quantity=item.quantity
    )
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return InventoryResponse.from_orm(db_item)

@router.put("/{item_id}", response_model=InventoryResponse)
async def update_inventory_item(
    item_id: str,
    item: InventoryUpdate,
    db: Session = Depends(get_db)
):
    """Update inventory item"""
    db_item = db.query(InventoryItem).filter(InventoryItem.id == item_id).first()
    if not db_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Inventory item not found"
        )
    
    update_data = item.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_item, field, value)
    
    db.commit()
    db.refresh(db_item)
    return InventoryResponse.from_orm(db_item)

@router.delete("/{item_id}")
async def delete_inventory_item(item_id: str, db: Session = Depends(get_db)):
    """Delete inventory item"""
    item = db.query(InventoryItem).filter(InventoryItem.id == item_id).first()
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Inventory item not found"
        )
    
    db.delete(item)
    db.commit()
    return {"message": "Inventory item deleted successfully"}

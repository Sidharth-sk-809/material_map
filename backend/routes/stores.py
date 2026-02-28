from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from database import get_db, Store
from schemas import StoreCreate, StoreResponse
from auth import generate_id
from typing import List
import math

router = APIRouter(prefix="/api/stores", tags=["stores"])

@router.get("", response_model=List[StoreResponse])
async def get_all_stores(db: Session = Depends(get_db)):
    """Get all stores"""
    stores = db.query(Store).all()
    return [StoreResponse.from_orm(s) for s in stores]

@router.get("/nearby", response_model=List[StoreResponse])
async def get_nearby_stores(
    latitude: float,
    longitude: float,
    radius: float = 10,  # Default 10 km radius
    db: Session = Depends(get_db)
):
    """Get stores near a location (using Haversine formula)"""
    stores = db.query(Store).all()
    nearby = []
    
    for store in stores:
        if store.latitude and store.longitude:
            # Haversine formula to calculate distance
            lat1, lon1 = math.radians(latitude), math.radians(longitude)
            lat2, lon2 = math.radians(store.latitude), math.radians(store.longitude)
            
            dlat = lat2 - lat1
            dlon = lon2 - lon1
            
            a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
            c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
            
            distance = 6371 * c  # Earth radius in km
            
            if distance <= radius:
                nearby.append(store)
    
    return [StoreResponse.from_orm(s) for s in nearby]

@router.get("/{store_id}", response_model=StoreResponse)
async def get_store(store_id: str, db: Session = Depends(get_db)):
    """Get store by ID"""
    store = db.query(Store).filter(Store.id == store_id).first()
    if not store:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Store not found"
        )
    return StoreResponse.from_orm(store)

@router.post("", response_model=StoreResponse)
async def create_store(store: StoreCreate, db: Session = Depends(get_db)):
    """Create a new store"""
    store_id = generate_id()
    db_store = Store(
        id=store_id,
        name=store.name,
        address=store.address,
        latitude=store.latitude,
        longitude=store.longitude,
        phone=store.phone,
        image_url=store.image_url
    )
    db.add(db_store)
    db.commit()
    db.refresh(db_store)
    return StoreResponse.from_orm(db_store)

@router.delete("/{store_id}")
async def delete_store(store_id: str, db: Session = Depends(get_db)):
    """Delete a store"""
    store = db.query(Store).filter(Store.id == store_id).first()
    if not store:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Store not found"
        )
    
    db.delete(store)
    db.commit()
    return {"message": "Store deleted successfully"}

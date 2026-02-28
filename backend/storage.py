from supabase import create_client, Client
from config import SUPABASE_URL, SUPABASE_KEY, SUPABASE_BUCKET
from typing import Optional
import uuid

# Initialize Supabase client
supabase: Optional[Client] = None

def init_supabase():
    global supabase
    if SUPABASE_URL and SUPABASE_KEY:
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    return supabase

def upload_image(file_bytes: bytes, file_name: str) -> Optional[str]:
    """Upload image to Supabase storage and return public URL"""
    if not supabase:
        return None
    
    try:
        # Create unique file name
        unique_name = f"{uuid.uuid4()}_{file_name}"
        
        # Upload to Supabase
        response = supabase.storage.from_(SUPABASE_BUCKET).upload(
            unique_name, 
            file_bytes
        )
        
        # Generate public URL
        public_url = supabase.storage.from_(SUPABASE_BUCKET).get_public_url(unique_name)
        return public_url
    except Exception as e:
        print(f"Error uploading image: {e}")
        return None

def delete_image(url: str) -> bool:
    """Delete image from Supabase storage"""
    if not supabase or not url:
        return False
    
    try:
        # Extract file name from URL
        file_name = url.split("/")[-1]
        supabase.storage.from_(SUPABASE_BUCKET).remove([file_name])
        return True
    except Exception as e:
        print(f"Error deleting image: {e}")
        return False

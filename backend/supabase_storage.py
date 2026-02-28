"""
Supabase Storage Handler for image uploads
Use this module to upload/delete product and store images to Supabase Storage
"""

import os
from dotenv import load_dotenv
from typing import Optional

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL", "")
SUPABASE_KEY = os.getenv("SUPABASE_KEY", "")
SUPABASE_BUCKET = os.getenv("SUPABASE_BUCKET", "material-map")

# Optional: Only import if supabase is installed
try:
    from supabase import create_client, Client
    SUPABASE_AVAILABLE = True
except ImportError:
    print("⚠️  Warning: supabase package not installed. File uploads will be disabled.")
    print("   Install with: pip install supabase")
    SUPABASE_AVAILABLE = False
    Client = None

class SupabaseStorage:
    """Handle file uploads/downloads to Supabase Storage"""
    
    def __init__(self):
        if not SUPABASE_AVAILABLE:
            raise Exception("Supabase package not installed. Run: pip install supabase")
        
        if not SUPABASE_URL or not SUPABASE_KEY:
            raise Exception("SUPABASE_URL and SUPABASE_KEY not configured in .env")
        
        self.client: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        self.bucket_name = SUPABASE_BUCKET
    
    def upload_product_image(self, file, product_id: str) -> Optional[str]:
        """
        Upload product image to Supabase Storage
        
        Args:
            file: File object from request (file.stream or file content)
            product_id: UUID of the product
        
        Returns:
            Public URL of the uploaded image, or None if failed
        """
        try:
            # Create bucket if it doesn't exist
            self._ensure_bucket_exists()
            
            # Generate file path
            file_extension = self._get_file_extension(file.filename)
            file_path = f"products/{product_id}.{file_extension}"
            
            # Upload file
            response = self.client.storage.from_(self.bucket_name).upload(
                path=file_path,
                file=file.stream,
                file_options={"content-type": file.content_type}
            )
            
            if response:
                # Return public URL
                public_url = f"{SUPABASE_URL}/storage/v1/object/public/{self.bucket_name}/{file_path}"
                return public_url
            
            return None
            
        except Exception as e:
            print(f"❌ Error uploading product image: {e}")
            return None
    
    def upload_store_image(self, file, store_id: str) -> Optional[str]:
        """
        Upload store image to Supabase Storage
        
        Args:
            file: File object from request
            store_id: UUID of the store
        
        Returns:
            Public URL of the uploaded image, or None if failed
        """
        try:
            self._ensure_bucket_exists()
            
            file_extension = self._get_file_extension(file.filename)
            file_path = f"stores/{store_id}.{file_extension}"
            
            response = self.client.storage.from_(self.bucket_name).upload(
                path=file_path,
                file=file.stream,
                file_options={"content-type": file.content_type}
            )
            
            if response:
                public_url = f"{SUPABASE_URL}/storage/v1/object/public/{self.bucket_name}/{file_path}"
                return public_url
            
            return None
            
        except Exception as e:
            print(f"❌ Error uploading store image: {e}")
            return None
    
    def delete_image(self, file_path: str) -> bool:
        """
        Delete image from Supabase Storage
        
        Args:
            file_path: Path of the file to delete (e.g., "products/product-id.jpg")
        
        Returns:
            True if deleted, False if failed
        """
        try:
            self.client.storage.from_(self.bucket_name).remove([file_path])
            return True
        except Exception as e:
            print(f"❌ Error deleting image: {e}")
            return False
    
    def _ensure_bucket_exists(self):
        """Create bucket if it doesn't exist"""
        try:
            # Try to get bucket metadata
            self.client.storage.get_bucket(self.bucket_name)
        except Exception:
            # Bucket doesn't exist, create it
            try:
                self.client.storage.create_bucket(
                    self.bucket_name,
                    options={"public": True}
                )
                print(f"✅ Created storage bucket: {self.bucket_name}")
            except Exception as e:
                print(f"⚠️  Could not create bucket: {e}")
    
    @staticmethod
    def _get_file_extension(filename: str) -> str:
        """Extract file extension from filename"""
        if not filename:
            return "jpg"
        return filename.rsplit('.', 1)[-1].lower()
    
    @staticmethod
    def validate_image_file(file) -> tuple[bool, str]:
        """
        Validate image file
        
        Returns:
            (is_valid, error_message)
        """
        if not file:
            return False, "No file provided"
        
        # Check file extension
        allowed_extensions = {'jpg', 'jpeg', 'png', 'gif', 'webp'}
        extension = SupabaseStorage._get_file_extension(file.filename).lower()
        
        if extension not in allowed_extensions:
            return False, f"File type not allowed. Allowed: {', '.join(allowed_extensions)}"
        
        # Check file size (max 5MB)
        file.stream.seek(0, 2)  # Seek to end
        file_size = file.stream.tell()
        file.stream.seek(0)  # Reset to beginning
        
        max_size = 5 * 1024 * 1024  # 5MB
        if file_size > max_size:
            return False, f"File too large. Max size: 5MB (Got: {file_size / 1024 / 1024:.2f}MB)"
        
        return True, ""


# ============ EXAMPLE USAGE ============

def example_usage():
    """Example of how to use SupabaseStorage"""
    
    try:
        storage = SupabaseStorage()
        print("✅ Supabase Storage initialized")
        
        # Example: Upload product image
        # storage.upload_product_image(file_object, "product-uuid")
        
        # Example: Delete image
        # storage.delete_image("products/product-uuid.jpg")
        
    except Exception as e:
        print(f"❌ Could not initialize storage: {e}")
        print("\n🔧 Setup instructions:")
        print("1. Install supabase: pip install supabase")
        print("2. Set SUPABASE_URL and SUPABASE_KEY in .env")
        print("3. Ensure Supabase project is created")


if __name__ == '__main__':
    example_usage()

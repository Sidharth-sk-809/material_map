# Material Map Backend API

A FastAPI-based backend for the Material Map Flutter application. Provides authentication, product management, store locations, and inventory management.

## Features

- **User Authentication**: Registration and login with JWT tokens
- **Product Management**: CRUD operations for products across multiple categories
- **Store Management**: Store locations with geographic coordinates
- **Inventory Management**: Price and quantity tracking for products at different stores
- **Geographic Search**: Find nearby stores using Haversine formula
- **Product Search**: Search products by name or brand
- **Supabase Integration**: Image storage and management

## Technology Stack

- **Framework**: FastAPI
- **Database**: SQLite (development) / PostgreSQL (production)
- **Authentication**: JWT (JSON Web Tokens)
- **Storage**: Supabase
- **ORM**: SQLAlchemy
- **Password Hashing**: bcrypt

## Installation

1. Clone the repository or navigate to the backend directory:
```bash
cd backend
```

2. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Create a `.env` file from `.env.example`:
```bash
cp .env.example .env
```

5. Update the `.env` file with your Supabase credentials:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_anon_key
SUPABASE_BUCKET=material-map
SECRET_KEY=your_secret_key
DATABASE_URL=sqlite:///./material_map.db
```

## Running the Server

Development with auto-reload:
```bash
python main.py
```

Or using uvicorn directly:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`
- API Documentation: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Database Initialization

The database is automatically initialized and seeded with sample data on the first run.

To manually seed the database:
```bash
python seed.py
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user (requires token)
- `POST /api/auth/logout` - Logout user

### Products
- `GET /api/products` - Get all products
- `GET /api/products/category/{category}` - Get products by category
- `GET /api/products/search?q=query` - Search products
- `GET /api/products/{product_id}` - Get product details
- `POST /api/products` - Create product
- `PUT /api/products/{product_id}` - Update product
- `DELETE /api/products/{product_id}` - Delete product

### Stores
- `GET /api/stores` - Get all stores
- `GET /api/stores/nearby?latitude=x&longitude=y&radius=10` - Get nearby stores
- `GET /api/stores/{store_id}` - Get store details
- `POST /api/stores` - Create store
- `DELETE /api/stores/{store_id}` - Delete store

### Inventory
- `GET /api/inventory` - Get all inventory items
- `GET /api/inventory/product/{product_id}` - Get product inventory across stores
- `GET /api/inventory/store/{store_id}` - Get store inventory
- `GET /api/inventory/{item_id}` - Get inventory item details
- `POST /api/inventory` - Create inventory item
- `PUT /api/inventory/{item_id}` - Update inventory item
- `DELETE /api/inventory/{item_id}` - Delete inventory item

## Environment Variables

Create a `.env` file in the backend directory with:

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your_supabase_anon_key
SUPABASE_BUCKET=material-map

# JWT
SECRET_KEY=your_secret_key_min_32_chars

# Database
DATABASE_URL=sqlite:///./material_map.db

# Server
DEBUG=False
HOST=0.0.0.0
PORT=8000
```

## Setting Up Supabase for Image Storage

1. Create a Supabase project at https://supabase.com
2. Create a storage bucket named `material-map`
3. Set bucket policies to public (for read access)
4. Get your project URL and anon key from project settings
5. Add these to your `.env` file

## Project Structure

```
backend/
├── main.py                 # FastAPI application entry point
├── config.py              # Configuration management
├── database.py            # SQLAlchemy database models
├── schemas.py             # Pydantic request/response models
├── auth.py                # Authentication utilities
├── storage.py             # Supabase storage integration
├── seed.py                # Database seeding with sample data
├── routes/                # API route handlers
│   ├── auth.py           # Authentication endpoints
│   ├── products.py       # Product management endpoints
│   ├── stores.py         # Store management endpoints
│   └── inventory.py      # Inventory management endpoints
├── requirements.txt       # Python dependencies
├── .env.example          # Environment variables template
└── README.md             # This file
```

## Common Issues

### Database locked error
This typically occurs with SQLite. Ensure only one process is running.

### Supabase connection errors
- Verify your SUPABASE_URL and SUPABASE_KEY in `.env`
- Check that your Supabase project is active
- Ensure the storage bucket exists and is public

### CORS errors
CORS is configured to allow all origins. For production, update the CORS settings in `main.py`

## Testing

Run tests with:
```bash
pytest
```

## Production Deployment

For production:

1. Use PostgreSQL instead of SQLite
2. Set `DEBUG=False` in `.env`
3. Change `SECRET_KEY` to a secure value
4. Update CORS origins to specific domains
5. Set up HTTPS
6. Use a production WSGI server (Gunicorn, etc.)

Example production startup with Gunicorn:
```bash
gunicorn -w 4 -b 0.0.0.0:8000 main:app
```

## License

This project is part of Material Map application.

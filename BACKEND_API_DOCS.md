# Material Map Backend - API Documentation

## Overview
Flask-based REST API backend for Material Map application. Provides endpoints for managing products, stores, inventory, and user authentication.

**Base URL:** `http://localhost:9000/api`

---

## 📋 Table of Contents
1. [Authentication](#authentication)
2. [Products](#products)
3. [Stores](#stores)
4. [Inventory](#inventory)

---

## Authentication

### Register User
**POST** `/auth/register`
- **Description:** Register a new user
- **Request Body:**
  ```json
  {
    "email": "user@example.com",
    "password": "password123"
  }
  ```
- **Response:** 200 OK
  ```json
  {
    "access_token": "token_string",
    "token_type": "bearer",
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "created_at": "2026-02-28T00:00:00"
    }
  }
  ```

### Login User
**POST** `/auth/login`
- **Description:** Login existing user
- **Request Body:**
  ```json
  {
    "email": "user@example.com",
    "password": "password123"
  }
  ```
- **Response:** 200 OK (same as Register)

### Get Current User
**GET** `/auth/me`
- **Description:** Get current logged-in user details
- **Query Parameters:**
  - `token` (required): JWT access token
- **Response:** 200 OK
  ```json
  {
    "id": "uuid",
    "email": "user@example.com",
    "created_at": "2026-02-28T00:00:00"
  }
  ```

### Logout
**POST** `/auth/logout`
- **Description:** Logout user (token invalidation handled client-side)
- **Response:** 200 OK
  ```json
  {
    "message": "Logout successful"
  }
  ```

---

## Products

### Get All Products
**GET** `/products`
- **Description:** Retrieve all products
- **Response:** 200 OK
  ```json
  [
    {
      "id": "uuid",
      "name": "Basmati Rice",
      "brand": "India Gate",
      "category": "grocery",
      "unit": "1 kg",
      "description": "Premium basmati | Mfg: Jan 2026 | Best Before: Dec 2027",
      "image_url": "http://...",
      "created_at": "2026-02-28T00:00:00"
    }
  ]
  ```

### Get Products by Category
**GET** `/products/category/{category}`
- **Description:** Get products filtered by category
- **Path Parameters:**
  - `category` (required): Category name (e.g., "grocery", "stationery", "plumbing")
- **Query Limit:** 30 products max
- **Response:** 200 OK (array of products)

### Search Products
**GET** `/products/search`
- **Description:** Search products by name or brand
- **Query Parameters:**
  - `q` (required): Search query (min 1 character)
- **Query Limit:** 20 products max
- **Response:** 200 OK (array of matching products)

### Get Product by ID
**GET** `/products/{product_id}`
- **Description:** Get specific product details
- **Path Parameters:**
  - `product_id` (required): Product UUID
- **Response:** 200 OK (single product object)
- **Error:** 404 Not Found if product doesn't exist

### Create Product
**POST** `/products`
- **Description:** Create a new product
- **Request Body:**
  ```json
  {
    "name": "Product Name",
    "brand": "Brand Name",
    "category": "grocery",
    "unit": "1 kg",
    "description": "Product description",
    "image_url": "http://..."
  }
  ```
- **Response:** 201 Created (product object with ID)

---

## Stores

### Get All Stores
**GET** `/stores`
- **Description:** Retrieve all stores
- **Response:** 200 OK
  ```json
  [
    {
      "id": "uuid",
      "name": "Fresh Vegetables",
      "category": "grocery",
      "address": "Green Market, Main Street, Downtown",
      "latitude": 11.3415,
      "longitude": 77.7171,
      "phone": "+91-123-456-7890",
      "image_url": "http://...",
      "created_at": "2026-02-28T00:00:00"
    }
  ]
  ```

### Get Store Categories
**GET** `/store-categories`
- **Description:** Get all unique store categories
- **Response:** 200 OK
  ```json
  ["grocery", "stationery", "household", "plumbing", "electronics"]
  ```

### Get Stores by Category
**GET** `/stores/category/{category}`
- **Description:** Get all stores in a specific category
- **Path Parameters:**
  - `category` (required): Category name
- **Response:** 200 OK (array of store objects)

### Get Store by ID
**GET** `/stores/{store_id}`
- **Description:** Get specific store details
- **Path Parameters:**
  - `store_id` (required): Store UUID
- **Response:** 200 OK (single store object)
- **Error:** 404 Not Found if store doesn't exist

### Get Nearby Stores
**GET** `/stores/nearby`
- **Description:** Find stores near a location using Haversine formula
- **Query Parameters:**
  - `latitude` (required): User latitude
  - `longitude` (required): User longitude
  - `radius` (optional): Search radius in km (default: 10 km)
- **Response:** 200 OK (array of stores within radius)
  
### Create Store
**POST** `/stores`
- **Description:** Create a new store
- **Request Body:**
  ```json
  {
    "name": "Store Name",
    "category": "grocery",
    "address": "Street Address",
    "latitude": 11.3415,
    "longitude": 77.7171,
    "phone": "+91-...",
    "image_url": "http://..."
  }
  ```
- **Response:** 201 Created (store object with ID)

---

## Inventory

### Get All Inventory
**GET** `/inventory`
- **Description:** Retrieve all inventory items
- **Response:** 200 OK
  ```json
  [
    {
      "id": "uuid",
      "product_id": "uuid",
      "store_id": "uuid",
      "price": 95.50,
      "quantity": 45,
      "original_price": 112.35,
      "discount_percentage": 15.0,
      "offer_valid_until": "2026-03-30T10:30:00",
      "updated_at": "2026-02-28T00:00:00"
    }
  ]
  ```

### Get Product Inventory
**GET** `/inventory/product/{product_id}`
- **Description:** Get all stores selling a specific product (sorted by price)
- **Path Parameters:**
  - `product_id` (required): Product UUID
- **Response:** 200 OK (array of inventory items with store details)
  ```json
  [
    {
      "id": "uuid",
      "product_id": "uuid",
      "store_id": "uuid",
      "price": 95.50,
      "quantity": 45,
      "updated_at": "2026-02-28T00:00:00",
      "store": {
        "id": "uuid",
        "name": "Store Name",
        "address": "...",
        "latitude": 11.34,
        "longitude": 77.71,
        "phone": "+91-...",
        "image_url": "..."
      }
    }
  ]
  ```

### Get Store Inventory
**GET** `/inventory/store/{store_id}`
- **Description:** Get all products available in a specific store
- **Path Parameters:**
  - `store_id` (required): Store UUID
- **Response:** 200 OK (array of inventory items)

### Get Inventory Item by ID
**GET** `/inventory/{item_id}`
- **Description:** Get specific inventory item with product and store details
- **Path Parameters:**
  - `item_id` (required): Inventory item UUID
- **Response:** 200 OK (inventory object with related product & store)
- **Error:** 404 Not Found if item doesn't exist

### Create Inventory Item
**POST** `/inventory`
- **Description:** Create a new inventory item (add product to store)
- **Request Body:**
  ```json
  {
    "product_id": "uuid",
    "store_id": "uuid",
    "price": 95.50,
    "quantity": 45,
    "original_price": 112.35,
    "discount_percentage": 15.0,
    "offer_valid_until": "2026-03-30"
  }
  ```
- **Response:** 201 Created (inventory object)

### Update Inventory Item
**PUT** `/inventory/{item_id}`
- **Description:** Update price, quantity, or offer details
- **Path Parameters:**
  - `item_id` (required): Inventory item UUID
- **Request Body:** (only include fields to update)
  ```json
  {
    "price": 99.99,
    "quantity": 50,
    "discount_percentage": 12.0,
    "original_price": 113.62
  }
  ```
- **Response:** 200 OK (updated inventory object)
- **Error:** 404 Not Found if item doesn't exist

### Delete Inventory Item
**DELETE** `/inventory/{item_id}`
- **Description:** Remove a product from store inventory
- **Path Parameters:**
  - `item_id` (required): Inventory item UUID
- **Response:** 200 OK
  ```json
  {
    "message": "Inventory item deleted successfully"
  }
  ```
- **Error:** 404 Not Found if item doesn't exist

---

## Database Models

### User
- `id` (UUID, PK): User identifier
- `email` (String): User email (unique)
- `hashed_password` (String): BCrypt hashed password
- `created_at` (DateTime): Account creation timestamp

### Product
- `id` (UUID, PK): Product identifier
- `name` (String): Product name
- `brand` (String): Brand/manufacturer
- `category` (String, indexed): Product category
- `unit` (String): Measure unit (e.g., "1 kg", "Pack of 5")
- `description` (Text): Detailed product info
- `image_url` (String): Product image URL
- `created_at` (DateTime): Creation timestamp

### Store
- `id` (UUID, PK): Store identifier
- `name` (String): Store name
- `category` (String, indexed): Store type (grocery, stationery, etc.)
- `address` (String): Physical address
- `latitude` (Float): Geo latitude
- `longitude` (Float): Geo longitude
- `phone` (String): Contact number
- `image_url` (String): Store image URL
- `created_at` (DateTime): Creation timestamp

### InventoryItem
- `id` (UUID, PK): Inventory item identifier
- `product_id` (UUID, FK): Reference to Product
- `store_id` (UUID, FK): Reference to Store
- `price` (Float): Current selling price
- `quantity` (Integer): Stock quantity
- `original_price` (Float): Price before discount
- `discount_percentage` (Float): Discount % applied
- `offer_valid_until` (DateTime): Offer expiration date
- `updated_at` (DateTime): Last update timestamp

---

## Features

✅ **JWT Authentication** - Secure user authentication with 24-hour token expiry  
✅ **Price Comparison** - Compare prices across stores  
✅ **Location-based Search** - Find nearby stores using Haversine distance formula  
✅ **Category Filtering** - Browse products/stores by category  
✅ **Inventory Management** - Track stock and pricing with discount support  
✅ **Full-text Search** - Search products by name or brand  
✅ **CORS Enabled** - Support for cross-origin requests from any domain  

---

## Error Codes

| Code | Message | Meaning |
|------|---------|---------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Invalid input data |
| 401 | Unauthorized | Missing or invalid token |
| 404 | Not Found | Resource doesn't exist |
| 500 | Server Error | Internal server error |

---

## Example Usage

### Search for rice and compare prices
```bash
# 1. Search for rice
curl "http://localhost:9000/api/products/search?q=rice"

# 2. Get product ID from results
# 3. Find all stores selling this product
curl "http://localhost:9000/api/inventory/product/{product_id}"

# 4. View sorted by price (cheapest first)
```

### Find nearby stores
```bash
curl "http://localhost:9000/api/stores/nearby?latitude=11.3415&longitude=77.7171&radius=5"
```

---

**Last Updated:** February 28, 2026

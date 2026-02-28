class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String? imageUrl;
  final String? description;
  final String? unit; // e.g., "1kg", "500ml", "piece"

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    this.imageUrl,
    this.description,
    this.unit,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['image_url'],
      description: json['description'],
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'image_url': imageUrl,
      'description': description,
      'unit': unit,
    };
  }
}

class StoreModel {
  final String id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? imageUrl;

  StoreModel({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.phone,
    this.imageUrl,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      phone: json['phone'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'image_url': imageUrl,
    };
  }
}

class InventoryItem {
  final String id;
  final String productId;
  final String storeId;
  final double price;
  final int quantity;
  final double? originalPrice;  // Price before offer
  final double? discountPercentage;  // Discount percentage
  final DateTime? offerValidUntil;  // When offer expires
  final DateTime? updatedAt;

  // Joined data (not from API directly)
  StoreModel? store;
  ProductModel? product;

  InventoryItem({
    required this.id,
    required this.productId,
    required this.storeId,
    required this.price,
    required this.quantity,
    this.originalPrice,
    this.discountPercentage,
    this.offerValidUntil,
    this.updatedAt,
    this.store,
    this.product,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      storeId: json['store_id'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      originalPrice: json['original_price'] != null ? (json['original_price'] as num).toDouble() : null,
      discountPercentage: json['discount_percentage'] != null ? (json['discount_percentage'] as num).toDouble() : null,
      offerValidUntil: json['offer_valid_until'] != null ? DateTime.parse(json['offer_valid_until']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      store: json['store'] != null ? StoreModel.fromJson(json['store']) : null,
      product: json['product'] != null ? ProductModel.fromJson(json['product']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'store_id': storeId,
      'price': price,
      'quantity': quantity,
      'original_price': originalPrice,
      'discount_percentage': discountPercentage,
      'offer_valid_until': offerValidUntil?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  StockStatus get stockStatus {
    if (quantity == 0) return StockStatus.outOfStock;
    if (quantity <= 5) return StockStatus.lowStock;
    return StockStatus.inStock;
  }
}

enum StockStatus { inStock, lowStock, outOfStock }

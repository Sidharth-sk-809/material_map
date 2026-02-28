import '../../core/services/api_client.dart';
import '../../core/constants/api_config.dart';
import '../models/product_model.dart';

class ProductRepository {
  final ApiClient _apiClient = ApiClient();

  /// Search products by name or brand across all categories
  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _apiClient.get(
        ApiConfig.PRODUCTS_SEARCH,
        queryParameters: {'q': query},
      );
      
      if (response is List) {
        return (response as List<dynamic>)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  /// Get products by category
  Future<List<ProductModel>> getByCategory(String category) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.PRODUCTS_CATEGORY}/$category',
      );
      
      if (response is List) {
        return (response as List<dynamic>)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Get all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final response = await _apiClient.get(ApiConfig.PRODUCTS);
      
      if (response is List) {
        return (response as List<dynamic>)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Get all inventory items for a product, joined with store info
  Future<List<InventoryItem>> getInventoryForProduct(String productId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.INVENTORY_PRODUCT}/$productId',
      );
      
      if (response is List) {
        List<InventoryItem> items = (response as List<dynamic>)
            .map((item) => InventoryItem.fromJson(item as Map<String, dynamic>))
            .toList();
        // Items are already sorted by price from the backend
        return items;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch inventory: $e');
    }
  }

  /// Get product details by ID
  Future<ProductModel> getProduct(String productId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.PRODUCTS}/$productId',
      );
      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }
}

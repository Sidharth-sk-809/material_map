import 'package:flutter/foundation.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

enum SearchState { idle, loading, loaded, error }

class SearchProvider extends ChangeNotifier {
  final ProductRepository _repo = ProductRepository();

  SearchState _searchState = SearchState.idle;
  List<ProductModel> _results = [];
  String? _error;
  String _query = '';
  String? _selectedCategory;
  List<ProductModel> _allProducts = [];

  SearchState get searchState => _searchState;
  List<ProductModel> get results => _results;
  String? get error => _error;
  String get query => _query;
  String? get selectedCategory => _selectedCategory;

  Future<void> search(String query) async {
    _query = query;
    if (query.trim().isEmpty) {
      _results = [];
      _searchState = SearchState.idle;
      notifyListeners();
      return;
    }
    
    _searchState = SearchState.loading;
    _error = null;
    notifyListeners();

    try {
      final searchResults = await _repo.searchProducts(query);
      _results = searchResults;
      _searchState = SearchState.loaded;
    } catch (e) {
      _error = 'Failed to search: ${e.toString()}';
      _searchState = SearchState.error;
      _results = [];
    }
    notifyListeners();
  }

  Future<void> filterByCategory(String category) async {
    _selectedCategory = category;
    _searchState = SearchState.loading;
    _error = null;
    notifyListeners();
    
    try {
      final categoryResults = await _repo.getByCategory(category);
      _results = categoryResults;
      _searchState = SearchState.loaded;
    } catch (e) {
      _error = 'Failed to load category: ${e.toString()}';
      _searchState = SearchState.error;
      _results = [];
    }
    notifyListeners();
  }

  Future<void> loadAllProducts() async {
    if (_allProducts.isNotEmpty) {
      _results = _allProducts;
      return;
    }
    
    _searchState = SearchState.loading;
    _error = null;
    notifyListeners();
    
    try {
      final products = await _repo.getAllProducts();
      _allProducts = products;
      _results = products;
      _searchState = SearchState.loaded;
    } catch (e) {
      _error = 'Failed to load products: ${e.toString()}';
      _searchState = SearchState.error;
    }
    notifyListeners();
  }

  void clearSearch() {
    _results = [];
    _query = '';
    _selectedCategory = null;
    _searchState = SearchState.idle;
    notifyListeners();
  }

  /// Get products by category - same as filterByCategory
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      return await _repo.getByCategory(category);
    } catch (e) {
      _error = 'Failed to load category: ${e.toString()}';
      return [];
    }
  }

  /// Get top 3 cheapest inventory items for a product
  Future<List<InventoryItem>> getTop3Inventory(String productId) async {
    try {
      final items = await _repo.getInventoryForProduct(productId);
      // Return top 3 (already sorted by price from backend)
      return items.length > 3 ? items.sublist(0, 3) : items;
    } catch (e) {
      _error = 'Failed to load inventory: ${e.toString()}';
      return [];
    }
  }
}

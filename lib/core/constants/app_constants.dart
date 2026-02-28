class AppConstants {
  static const String appName = 'Material Map';
  static const String splashTagline = 'Find. Compare. Save.';

  // Route Names
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeHome = '/home';
  static const String routeSearch = '/search';
  static const String routeProduct = '/product';

  // Firestore Collections
  static const String colProducts = 'products';
  static const String colStores = 'stores';
  static const String colInventory = 'inventory';
  static const String colUsers = 'users';

  // Shared Prefs Keys
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserId = 'userId';

  // Asset Paths
  static const String logoPath = 'assets/images/logo.png';

  // UI Constants
  static const double borderRadius = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double pagePadding = 16.0;
}

class AppCategories {
  static const List<Map<String, dynamic>> categories = [
    {
      'id': 'grocery',
      'name': 'Grocery',
      'icon': '🛒',
      'color': 0xFF10B981,
      'image': 'assets/images/grocery.png',
    },
    {
      'id': 'vegetables',
      'name': 'Vegetables',
      'icon': '🥦',
      'color': 0xFF84CC16,
      'image': 'assets/images/vegetables.png',
    },
    {
      'id': 'stationery',
      'name': 'Stationery',
      'icon': '📝',
      'color': 0xFF6366F1,
      'image': 'assets/images/stationery.png',
    },
    {
      'id': 'household',
      'name': 'Household',
      'icon': '🏠',
      'color': 0xFF3B82F6,
      'image': 'assets/images/household.png',
    },
    {
      'id': 'plumbing',
      'name': 'Plumbing',
      'icon': '🔧',
      'color': 0xFFF97316,
      'image': 'assets/images/plumbing.png',
    },
    {
      'id': 'electronics',
      'name': 'Electronics',
      'icon': '💡',
      'color': 0xFFEC4899,
      'image': 'assets/images/electronics.png',
    },
  ];
}

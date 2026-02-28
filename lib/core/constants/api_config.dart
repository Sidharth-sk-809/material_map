// API Configuration for Material Map
// Change the API_URL based on your environment

class ApiConfig {
  // API Base URL - Update this based on your backend server
  // For development: Use your local machine IP for physical device
  static const String API_URL = 'http://192.168.31.212:9000/api';  // Physical device (wired) - Flask on port 9000
  
  // For  Android emulator, use: http://10.0.2.2:9000/api
  // For physical device, use: http://YOUR_MACHINE_IP:9000/api
  // For production, use: https://your_api_domain.com/api
  
  // Endpoint paths
  static const String AUTH_REGISTER = '/auth/register';
  static const String AUTH_LOGIN = '/auth/login';
  static const String AUTH_ME = '/auth/me';
  static const String AUTH_LOGOUT = '/auth/logout';
  
  static const String PRODUCTS = '/products';
  static const String PRODUCTS_SEARCH = '/products/search';
  static const String PRODUCTS_CATEGORY = '/products/category';
  
  static const String STORES = '/stores';
  static const String STORES_NEARBY = '/stores/nearby';
  
  static const String INVENTORY = '/inventory';
  static const String INVENTORY_PRODUCT = '/inventory/product';
  static const String INVENTORY_STORE = '/inventory/store';
  
  // Timeout configuration (in seconds)
  static const int CONNECT_TIMEOUT = 30;
  static const int RECEIVE_TIMEOUT = 30;
}

import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_client.dart';
import '../../core/constants/api_config.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  /// Register a new user
  Future<Map<String, dynamic>> registerWithEmail(String email, String password) async {
    final response = await _apiClient.post(
      ApiConfig.AUTH_REGISTER,
      data: {
        'email': email,
        'password': password,
      },
    );
    
    if (response.containsKey('access_token')) {
      await _saveToken(response['access_token']);
      return response;
    }
    throw Exception('Registration failed');
  }

  /// Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmail(String email, String password) async {
    final response = await _apiClient.post(
      ApiConfig.AUTH_LOGIN,
      data: {
        'email': email,
        'password': password,
      },
    );
    
    if (response.containsKey('access_token')) {
      await _saveToken(response['access_token']);
      return response;
    }
    throw Exception('Login failed');
  }

  /// Get current user
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    final response = await _apiClient.get(
      ApiConfig.AUTH_ME,
      queryParameters: {'token': token},
    );
    return response;
  }

  /// Sign out
  Future<void> signOut() async {
    await _apiClient.post(ApiConfig.AUTH_LOGOUT);
    await _clearToken();
  }

  /// Save token to local storage
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  /// Clear token from local storage
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user');
  }

  /// Get saved token
  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getSavedToken();
    return token != null;
  }
}

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_config.dart';

class ApiClient {
  late Dio _dio;
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.API_URL,
        connectTimeout: Duration(seconds: ApiConfig.CONNECT_TIMEOUT),
        receiveTimeout: Duration(seconds: ApiConfig.RECEIVE_TIMEOUT),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptor for token handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle common errors
          if (error.response?.statusCode == 401) {
            // Unauthorized - token expired
            // Clear stored token
            SharedPreferences.getInstance().then((prefs) {
              prefs.remove('access_token');
              prefs.remove('user');
            });
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Generic GET request
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response.data ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic POST request
  Future<dynamic> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic PUT request
  Future<dynamic> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Request timeout. Please try again.';
    } else if (error.response?.statusCode == 400) {
      return error.response?.data['detail'] ?? 'Bad request';
    } else if (error.response?.statusCode == 401) {
      return 'Unauthorized. Please login again.';
    } else if (error.response?.statusCode == 404) {
      return 'Resource not found';
    } else if (error.response?.statusCode == 500) {
      return 'Server error. Please try again later.';
    } else {
      return error.message ?? 'An error occurred';
    }
  }

  // Update API URL (useful for changing between dev/prod)
  void setApiUrl(String url) {
    _dio.options.baseUrl = url;
  }

  // Get Dio instance for advanced usage
  Dio getDio() {
    return _dio;
  }
}

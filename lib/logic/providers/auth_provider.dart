import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  String? _userEmail;
  String? _token;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get userEmail => _userEmail;
  String? get token => _token;
  bool get isLoggedIn => _token != null;

  // Initialize with saved token
  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _status = AuthStatus.initial;
    notifyListeners();
    
    try {
      final savedToken = await _repo.getSavedToken();
      if (savedToken != null) {
        _token = savedToken;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _repo.signInWithEmail(email, password);
      _token = response['access_token'];
      _userEmail = email;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _repo.registerWithEmail(email, password);
      _token = response['access_token'];
      _userEmail = email;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _repo.signOut();
      _token = null;
      _userEmail = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to sign out';
    }
  }
}

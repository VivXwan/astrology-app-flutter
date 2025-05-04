import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;
  String _error = '';
  final ApiService _apiService;
  
  // Getters
  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String get error => _error;
  String? get token => _token;

  // Constructor
  AuthProvider(this._apiService) {
    _loadSavedState();
  }

  // Load authentication state from SharedPreferences
  Future<void> _loadSavedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('userData');
      
      if (userData != null) {
        final decodedData = json.decode(userData);
        _user = User.fromJson(decodedData['user']);
        _token = decodedData['token'];
        _isAuthenticated = true;
        
        // Set token in ApiService
        if (_token != null && _token!.isNotEmpty) {
          print('Loading saved token from preferences: ${_token!.substring(0, _token!.length > 10 ? 10 : _token!.length)}...');
          _apiService.setAuthToken(_token!);
        }
      }
    } catch (e) {
      print('Failed to load auth state: $e');
    }
    
    notifyListeners();
  }

  // Save authentication state to SharedPreferences
  Future<void> _saveAuthState() async {
    try {
      if (_user != null && _token != null) {
        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'user': _user!.toJson(),
          'token': _token,
        });
        
        await prefs.setString('userData', userData);
        print('Saved auth state to preferences');
      }
    } catch (e) {
      print('Failed to save auth state: $e');
    }
  }

  // Clear authentication state
  Future<void> _clearSavedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userData');
      print('Cleared saved auth state');
    } catch (e) {
      print('Failed to clear auth state: $e');
    }
  }

  // Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _apiService.registerUser(
        name: name,
        email: email,
        password: password,
      );
      _user = response.user;
      _token = response.accessToken;
      _isAuthenticated = true;
      
      // Set the token in ApiService
      print('Setting token after registration: ${_token!.substring(0, _token!.length > 10 ? 10 : _token!.length)}...');
      _apiService.setAuthToken(_token!);
      
      await _saveAuthState();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _apiService.loginUser(
        email: email,
        password: password,
      );
      _user = response.user;
      _token = response.accessToken;
      _isAuthenticated = true;
      
      // Set the token in ApiService
      print('Setting token after login: ${_token!.substring(0, _token!.length > 10 ? 10 : _token!.length)}...');
      _apiService.setAuthToken(_token!);
      
      await _saveAuthState();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    _user = null;
    _token = null;
    _isAuthenticated = false;
    
    // Clear token from ApiService
    _apiService.clearAuthToken();
    
    await _clearSavedState();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }
} 
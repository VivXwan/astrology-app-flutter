import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  
  User? _currentUser;
  TokenResponse? _tokenResponse;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  TokenResponse? get tokenResponse => _tokenResponse;
  bool get isAuthenticated => _tokenResponse != null && _tokenResponse!.accessToken.isNotEmpty;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const String _refreshTokenKey = 'refreshToken';
  static const String _accessTokenKey = 'accessToken'; // Optional: store for faster startup

  AuthProvider(this._apiService) {
    _tryAutoLogin();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
  }

  Future<void> _tryAutoLogin() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedRefreshToken = prefs.getString(_refreshTokenKey);
      final storedAccessToken = prefs.getString(_accessTokenKey); // Optional

      if (storedRefreshToken != null && storedRefreshToken.isNotEmpty) {
        if (storedAccessToken != null && storedAccessToken.isNotEmpty) {
          // Optionally validate stored access token or just use it and let API calls fail if expired
          _apiService.setAuthToken(storedAccessToken);
          // Attempt to fetch user data or a light validated endpoint to confirm token validity
          // For now, assume if we have tokens, we might be logged in.
          // A better approach is to try refreshing token or fetching user data here.
          print('AuthProvider: Found stored access token. Attempting to use.');
        }
        // Try to refresh the token to ensure session validity and get user data
        // This also helps get the latest access token if the stored one was stale/invalid
        await refreshAuthToken(storedRefreshToken);
        // If refreshAuthToken is successful, it sets currentUser and tokenResponse
      } else {
        print('AuthProvider: No stored refresh token found.');
      }
    } catch (e) {
      print('AuthProvider: Auto-login failed - $e');
      // Clear potentially invalid stored tokens if auto-login fails badly
      await _clearStoredTokens(); 
      _apiService.clearAuthToken();
    }
    _setLoading(false);
  }

  Future<void> _saveTokens(TokenResponse tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, tokens.refreshToken);
    await prefs.setString(_accessTokenKey, tokens.accessToken); // Store access token too
    _tokenResponse = tokens;
    _apiService.setAuthToken(tokens.accessToken);
  }

  Future<void> _clearStoredTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_accessTokenKey);
  }

  Future<bool> signUp(String name, String email, String password) async {
    _setLoading(true);
    clearError();
    try {
      User newUser = await _apiService.registerUser(name: name, email: email, password: password);
      // After successful registration, an app might automatically log the user in
      // or direct them to a login page. Here, we assume they need to log in separately.
      // So, we don't set _currentUser or tokens here from registration alone.
      print('AuthProvider: User registered successfully: ${newUser.email}');
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    clearError();
    try {
      TokenResponse tokens = await _apiService.loginUser(email: email, password: password);
      await _saveTokens(tokens);
      // Fetch user details after login - Assuming /users/me or similar endpoint would be needed
      // For now, we don't have an endpoint that returns User details with TokenResponse from /login
      // We might need a separate call to GET /users/me after login to populate _currentUser
      // Or, the app might not need immediate User object, just the tokens.
      // Let's simulate fetching user details via a placeholder or a new method in ApiService if available.
      // For now, we'll leave _currentUser as null and rely on isAuthenticated.
      // _currentUser = await _fetchUserDetails(); // Placeholder for fetching user details
      print('AuthProvider: User signed in successfully.');
      notifyListeners(); // For isAuthenticated and tokens
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      await _clearStoredTokens();
      _apiService.clearAuthToken();
      _tokenResponse = null;
      _currentUser = null;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshAuthToken(String rToken, {bool isAutoLogin = true}) async {
    if (!isAutoLogin) _setLoading(true);
    clearError();
    try {
      TokenResponse newTokens = await _apiService.refreshToken(currentRefreshToken: rToken);
      await _saveTokens(newTokens);
      // Optionally, fetch/update user details here as well
      // _currentUser = await _fetchUserDetails(); // Placeholder
      print('AuthProvider: Token refreshed successfully.');
      if (!isAutoLogin) _setLoading(false);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      print('AuthProvider: Token refresh failed - $_errorMessage');
      await signOut(); // If refresh fails, sign out the user
      if (!isAutoLogin) _setLoading(false);
      // No notifyListeners() here as signOut() will do it.
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    clearError();
    try {
      if (_tokenResponse?.refreshToken != null) {
        await _apiService.logoutUser(currentRefreshToken: _tokenResponse!.refreshToken);
      }
    } catch (e) {
      // Log error, but proceed with client-side cleanup
      _errorMessage = 'Error during server logout: ${e.toString()}. Cleared local session.';
      print(_errorMessage);
    } finally {
      await _clearStoredTokens();
      _apiService.clearAuthToken();
      _currentUser = null;
      _tokenResponse = null;
      _setLoading(false);
      notifyListeners();
      print('AuthProvider: User signed out.');
    }
  }

  // Placeholder for fetching user details if needed separately
  // Future<User?> _fetchUserDetails() async {
  //   try {
  //     // This would typically call an endpoint like GET /users/me
  //     // final userDetails = await _apiService.getCurrentAuthenticatedUser(); 
  //     // return userDetails;
  //      return null; // Replace with actual API call
  //   } catch (e) {
  //     print('Failed to fetch user details: $e');
  //     return null;
  //   }
  // }
} 
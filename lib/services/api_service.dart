import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import '../models/chart_models.dart';
import '../models/geocode_models.dart';
import '../models/health_models.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: Constants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 30),
  ));

  ApiService() {
    // Add logging interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('\n🌐 API Request:');
        print('URL: ${options.baseUrl}${options.path}');
        print('Method: ${options.method}');
        
        // Enhanced logging for auth header
        if (options.headers.containsKey('Authorization')) {
          final authHeader = options.headers['Authorization'] as String;
          final truncatedToken = authHeader.length > 20 
              ? '${authHeader.substring(0, 20)}...' 
              : authHeader;
          print('Auth Header: $truncatedToken');
        } else {
          print('Auth Header: None (Unauthenticated Request)');
          
          // Warning for endpoints that might require authentication
          if (options.path.contains('/charts') && 
              !options.path.contains('/charts/anon') &&
              options.method == 'POST') {
            print('⚠️ WARNING: Accessing POST /charts endpoint without authentication token for potential save');
          }
        }
        
        print('Headers: ${options.headers}');
        print('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('\n✅ API Response:');
        print('Status Code: ${response.statusCode}');
        print('Data: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('\n❌ API Error:');
        print('Error: ${error.message}');
        print('Response: ${error.response?.data}');
        print('Status Code: ${error.response?.statusCode}');
        
        // Enhanced debugging for auth errors
        if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
          print('🔐 AUTHENTICATION ERROR DETAILS:');
          print('Request Headers: ${error.requestOptions.headers}');
          print('Request Path: ${error.requestOptions.path}');
          print('Request Method: ${error.requestOptions.method}');
          
          if (!error.requestOptions.headers.containsKey('Authorization')) {
            print('❌ No Authorization header was sent with this request!');
          } else {
            print('✅ Authorization header was present but was rejected by the server');
          }
        }
        
        if (error.response?.statusCode == 400) {
          print('Request that caused 400:');
          print('Data sent: ${error.requestOptions.data}');
          print('Query Parameters: ${error.requestOptions.queryParameters}');
          print('Headers: ${error.requestOptions.headers}');
        }
        return handler.next(error);
      },
    ));
  }

  // Add token to requests if available
  void setAuthToken(String token) {
    print('Setting auth token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    _dio.options.headers['Authorization'] = 'Bearer $token';
    print('Updated headers: ${_dio.options.headers}');
  }

  // Clear auth token
  void clearAuthToken() {
    print('Clearing auth token');
    _dio.options.headers.remove('Authorization');
    print('Updated headers: ${_dio.options.headers}');
  }

  // Register a new user - Returns User object
  Future<User> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      print('\n👤 Register User Request:');
      print('Name: $name, Email: $email');

      final response = await _dio.post('/users', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      
      print('\n✅ Registration Successful:');
      print('Status: ${response.statusCode}');
      
      return User.fromJson(response.data);
    } on DioException catch (e) {
      print('\n🚨 Registration Failed:');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Response Status: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      
      if (e.response?.statusCode == 400 && e.response?.data is Map) {
        if (e.response?.data['detail'] != null) {
          throw Exception(e.response?.data['detail']);
        }
      }
      
      throw Exception('Failed to register: ${e.message}');
    }
  }

  // Login user - Returns TokenResponse with access and refresh tokens
  Future<TokenResponse> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('\n🔑 Login Request:');
      print('Email: $email');

      final response = await _dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          contentType: 'application/json',
        ),
      );
      
      print('\n✅ Login Successful:');
      print('Status: ${response.statusCode}');
      
      final tokenResponse = TokenResponse.fromJson(response.data);
      setAuthToken(tokenResponse.accessToken);
      return tokenResponse;
    } on DioException catch (e) {
      print('\n🚨 Login Failed:');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Response Status: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid email or password');
      }
      
      throw Exception('Failed to login: ${e.message}');
    }
  }

  // Refresh Access Token
  Future<TokenResponse> refreshToken({required String currentRefreshToken}) async {
    try {
      final response = await _dio.post('/refresh', data: {'refresh_token': currentRefreshToken});
      final tokenResponse = TokenResponse.fromJson(response.data);
      setAuthToken(tokenResponse.accessToken); // Update with the new access token
      return tokenResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        clearAuthToken(); 
        throw Exception(e.response?.data['detail'] ?? 'Invalid or expired refresh token');
      }
      throw Exception(e.response?.data['detail'] ?? 'Error refreshing token: ${e.message}');
    }
  }

  // Logout User
  Future<void> logoutUser({required String currentRefreshToken}) async {
    try {
      await _dio.post('/logout', data: {'refresh_token': currentRefreshToken});
      clearAuthToken(); // Clear client-side tokens upon successful logout
    } on DioException catch (e) {
      clearAuthToken(); // Clear tokens even if logout fails server-side, for client safety
      throw Exception(e.response?.data['detail'] ?? 'Error during logout: ${e.message}');
    }
  }

  // Get Authenticated User's Charts
  Future<List<ChartSummary>> getAuthenticatedUserCharts() async {
    try {
      final response = await _dio.get('/users/me/charts');
      var list = response.data as List;
      return list.map((i) => ChartSummary.fromJson(i as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception(e.response?.data['detail'] ?? 'Not authenticated. Please login.');
      }
      throw Exception(e.response?.data['detail'] ?? 'An unexpected error occurred while retrieving charts: ${e.message}');
    }
  }

  // Generate Chart (Existing method - ensure it's compatible with optional Auth)
  // The user stated this endpoint is working perfectly.
  // If an auth token is set via setAuthToken(), Dio will automatically include it.
  // If no token is set, it will be an anonymous request.
  Future<Map<String, dynamic>> getChart({
    required int year,
    required int month,
    required int day,
    required double hour,
    required double minute,
    double seconds = 0.0,
    required double latitude,
    required double longitude,
    double? tzOffset, // Optional query parameters
    String? transitDate,
    String? ayanamsaType,
    int? dashaLevel,
  }) async {
    try {
      final requestData = {
        'year': year,
        'month': month,
        'day': day,
        'hour': hour, // API expects float
        'minute': minute, // API expects float
        'second': seconds, // API expects float
        'latitude': latitude,
        'longitude': longitude,
      };
      
      Map<String, dynamic> queryParameters = {};
      if (tzOffset != null) queryParameters['tz_offset'] = tzOffset;
      if (transitDate != null) queryParameters['transit_date'] = transitDate;
      if (ayanamsaType != null) queryParameters['ayanamsa_type'] = ayanamsaType;
      if (dashaLevel != null) queryParameters['dasha_level'] = dashaLevel;

      final response = await _dio.post(
        '/charts', 
        data: requestData,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
         throw Exception(e.response?.data['detail'] ?? 'Chart generation failed: invalid input');
      } else if (e.response?.statusCode == 429) {
         throw Exception(e.response?.data['detail'] ?? 'Rate limit exceeded. Please try again later.');
      }
      throw Exception(e.response?.data['detail'] ?? 'Unexpected error generating chart: ${e.message}');
    }
  }

  // Get Chart by ID
  Future<ChartSummary> getChartById(int chartId) async {
    try {
      final response = await _dio.get('/charts/$chartId');
      return ChartSummary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception(e.response?.data['detail'] ?? 'Chart not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception(e.response?.data['detail'] ?? 'Could not validate credentials');
      } else if (e.response?.statusCode == 403) {
        // API spec says 403: "Chart doesn't exist" - might be for permission reasons on user-owned chart
        throw Exception(e.response?.data['detail'] ?? 'Access to chart forbidden or chart doesn\'t exist');
      }
      throw Exception(e.response?.data['detail'] ?? 'Error fetching chart by ID: ${e.message}');
    }
  }

  // Geocode Location
  Future<GeocodeAPIResult> geocodeLocation(String query) async {
    try {
      final response = await _dio.post('/geocode', data: {'query': query});
      return GeocodeAPIResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
       if (e.response?.statusCode == 400) {
         throw Exception(e.response?.data['detail'] ?? 'Invalid geocode request');
      } else if (e.response?.statusCode == 429) {
         throw Exception(e.response?.data['detail'] ?? 'Rate limit exceeded. Please try again later.');
      }
      throw Exception(e.response?.data['detail'] ?? 'Error during geocoding: ${e.message}');
    }
  }
  
  // Health Check
  Future<HealthStatus> getHealth() async {
    try {
      final response = await _dio.get('/health');
      return HealthStatus.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to get health status: ${e.message}');
    }
  }
}
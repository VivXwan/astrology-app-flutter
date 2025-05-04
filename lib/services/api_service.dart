import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../models/location_model.dart';
import '../models/user_model.dart';

class GeocodeResponse {
  final double latitude;
  final double longitude;
  final String displayName;
  final String placeId;
  final String osmType;
  final String osmId;
  final String type;
  final String classType;
  final double importance;
  final Map<String, String> address;

  GeocodeResponse({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    required this.placeId,
    required this.osmType,
    required this.osmId,
    required this.type,
    required this.classType,
    required this.importance,
    required this.address,
  });

  factory GeocodeResponse.fromJson(Map<String, dynamic> json) {
    return GeocodeResponse(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      displayName: json['display_name'] ?? '',
      placeId: json['place_id']?.toString() ?? '',
      osmType: json['osm_type'] ?? '',
      osmId: json['osm_id']?.toString() ?? '',
      type: json['type'] ?? '',
      classType: json['class_type'] ?? '',
      importance: json['importance']?.toDouble() ?? 0.0,
      address: Map<String, String>.from(json['address'] ?? {}),
    );
  }
}

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: Constants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
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
              !options.path.contains('/charts/anon')) {
            print('⚠️ WARNING: Accessing /charts endpoint without authentication token');
          }
        }
        
        print('Headers: ${options.headers}');
        print('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('\n✅ API Response:');
        print('Status Code: ${response.statusCode}');
        // print('Data: ${response.data}');
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

  // Register a new user
  Future<AuthResponse> registerUser({
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
      
      final authResponse = AuthResponse.fromJson(response.data);
      setAuthToken(authResponse.accessToken);
      return authResponse;
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

  // Login user
  Future<AuthResponse> loginUser({
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
      
      final authResponse = AuthResponse.fromJson(response.data);
      setAuthToken(authResponse.accessToken);
      return authResponse;
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

  Future<Map<String, dynamic>> getChart({
    required int year,
    required int month,
    required int day,
    required double hour,
    required double minute,
    double seconds=0,
    required double latitude,
    required double longitude,
  }) async {
    try {
      print('\n📊 Preparing Chart Request:');
      print('Date: $year-$month-$day');
      print('Time: $hour:$minute:$seconds');
      print('Location: $latitude, $longitude');

      // Ensure hour, minute and seconds are properly formatted as numbers
      final formattedHour = hour.toStringAsFixed(1);
      final formattedMinute = minute.toStringAsFixed(1);
      final formattedSeconds = seconds.toStringAsFixed(1);

      final requestData = {
        'year': year,
        'month': month,
        'day': day,
        'hour': double.parse(formattedHour),
        'minute': double.parse(formattedMinute),
        'seconds': double.parse(formattedSeconds),
        'latitude': latitude,
        'longitude': longitude,
      };

      print('Sending request with data: $requestData');

      final response = await _dio.post('/charts', data: requestData);
      
      print('\n📈 Chart Response Received:');
      print('Status: ${response.statusCode}');
      print('Data Size: ${response.data.length} entries');
      
      return response.data;
    } on DioException catch (e) {
      print('\n🚨 Chart Request Failed:');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Response Status: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Request Data: ${e.requestOptions.data}');
      throw Exception('Failed to fetch chart: ${e.message}');
    }
  }

  Future<List<GeocodeResponse>> geocode(String query) async {
    try {
      print('\n🔍 Geocoding Request:');
      print('Query: $query');

      final response = await _dio.post('/geocode', data: {'query': query});
      
      print('\n📍 Geocoding Response:');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');
      
      if (response.data is Map<String, dynamic> && response.data['locations'] != null) {
        final locations = response.data['locations'] as List;
        return locations.map((item) => GeocodeResponse.fromJson(item)).toList();
      }
      
      throw Exception('Invalid response format from geocoding API');
    } on DioException catch (e) {
      print('\n🚨 Geocoding Failed:');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Response Status: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      throw Exception('Failed to geocode location: ${e.message}');
    }
  }

  Future<List<LocationModel>> searchLocation(String query) async {
    try {
      print('\n🔍 Location Search Request:');
      print('Query: $query');

      final geocodeResults = await geocode(query);
      
      return geocodeResults.map((result) => LocationModel(
        name: query,
        displayName: result.displayName,
        latitude: result.latitude,
        longitude: result.longitude,
        address: result.address,
      )).toList();
    } catch (e) {
      print('\n🚨 Location Search Failed:');
      print('Error: $e');
      throw Exception('Failed to search location: $e');
    }
  }

  // Get a specific chart by ID (requires authentication for private charts)
  Future<Map<String, dynamic>> getChartById(String chartId) async {
    try {
      print('\n📊 Get Chart By ID Request:');
      print('Chart ID: $chartId');

      final response = await _dio.get('/charts/$chartId');
      
      print('\n📈 Chart Retrieved Successfully:');
      print('Status: ${response.statusCode}');
      
      return response.data;
    } on DioException catch (e) {
      print('\n🚨 Get Chart Failed:');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Response Status: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 403) {
        throw Exception('You are not authorized to view this chart');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Chart not found');
      }
      
      throw Exception('Failed to get chart: ${e.message}');
    }
  }

  // Get all charts for the current user (requires authentication)
  // Note: Since the API doesn't have a dedicated endpoint for listing all user charts,
  // this is a placeholder that will show a message to the user
  Future<List<Map<String, dynamic>>> getUserCharts() async {
    try {
      print('\n📊 Get User Charts Request');
      
      // Since there's no API endpoint for getting all charts,
      // we'll return an empty list for now
      // In a real implementation, we might need to store chart IDs locally
      // or have the backend implement a GET /charts endpoint
      
      return [];
      
    } on DioException catch (e) {
      print('\n🚨 Get User Charts Failed:');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Response Status: ${e.response?.statusCode}');
      
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required to view your charts');
      }
      
      throw Exception('Failed to get user charts: ${e.message}');
    }
  }
}
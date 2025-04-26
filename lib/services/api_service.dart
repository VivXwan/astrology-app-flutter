import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../models/location_model.dart';

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

  Future<Map<String, dynamic>> getChart({
    required int year,
    required int month,
    required int day,
    required double hour,
    required double minute,
    required double latitude,
    required double longitude,
    double tzOffset = 5.5,
    String? ayanamsaType,
  }) async {
    try {
      print('\n📊 Preparing Chart Request:');
      print('Date: $year-$month-$day');
      print('Time: $hour:$minute');
      print('Location: $latitude, $longitude');
      print('Timezone Offset: $tzOffset');

      // Ensure hour and minute are properly formatted as numbers
      final formattedHour = hour.toStringAsFixed(1);
      final formattedMinute = minute.toStringAsFixed(1);

      final requestData = {
        'year': year,
        'month': month,
        'day': day,
        'hour': double.parse(formattedHour),
        'minute': double.parse(formattedMinute),
        'latitude': latitude,
        'longitude': longitude,
        'tz_offset': tzOffset,
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
}
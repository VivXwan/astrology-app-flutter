import 'package:dio/dio.dart';
import '../utils/constants.dart';

class GeocodeResponse {
  final double latitude;
  final double longitude;

  GeocodeResponse({required this.latitude, required this.longitude});

  factory GeocodeResponse.fromJson(Map<String, dynamic> json) {
    return GeocodeResponse(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }
}

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: Constants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

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
      final response = await _dio.post('/charts', data: {
        'year': year,
        'month': month,
        'day': day,
        'hour': hour,
        'minute': minute,
        'latitude': latitude,
        'longitude': longitude,
        'tz_offset': tzOffset,
        'ayanamsa_type': ayanamsaType,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to fetch chart: ${e.message}');
    }
  }

  Future<GeocodeResponse> geocode(String query) async {
    try {
      final response = await _dio.post('/geocode', data: {'query': query});
      return GeocodeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to geocode location: ${e.message}');
    }
  }
}
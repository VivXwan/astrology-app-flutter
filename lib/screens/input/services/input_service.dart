import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/api_service.dart';
import '../../../providers/chart_provider.dart';

class InputService {
  final BuildContext context;

  InputService(this.context);

  Future<(double, double)> searchLocation(String query) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final responses = await apiService.geocode(query);
      if (responses.isEmpty) {
        throw Exception('No locations found');
      }
      // Use the first result
      final response = responses.first;
      return (response.latitude, response.longitude);
    } catch (e) {
      throw Exception('Error finding location: $e');
    }
  }

  Future<void> generateChart({
    required DateTime date,
    required TimeOfDay time,
    required double? latitude,
    required double? longitude,
    String? locationQuery,
    BuildContext? context,
  }) async {
    try {
      // Use the context passed as parameter or fall back to this.context
      final ctx = context ?? this.context;
      final chartProvider = Provider.of<ChartProvider>(ctx, listen: false);
      
      // Using the chartProvider with the proper context will ensure it has
      // access to the same ApiService instance that has the auth token set
      await chartProvider.generateChart(
        date: date,
        time: time,
        latitude: latitude,
        longitude: longitude,
        locationQuery: locationQuery,
        context: ctx,
      );
    } catch (e) {
      throw Exception('Error generating chart: $e');
    }
  }
} 
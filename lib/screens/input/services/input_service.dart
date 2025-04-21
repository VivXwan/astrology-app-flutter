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
    required double tzOffset,
    String? locationQuery,
  }) async {
    try {
      // If we have coordinates, use them directly
      if (latitude != null && longitude != null) {
        final provider = Provider.of<ChartProvider>(context, listen: false);
        await provider.fetchChart(
          year: date.year,
          month: date.month,
          day: date.day,
          hour: time.hour.toDouble(),
          minute: time.minute.toDouble(),
          latitude: latitude,
          longitude: longitude,
          tzOffset: tzOffset,
        );
        return;
      }

      // Only search for coordinates if we don't have them
      if (locationQuery != null && locationQuery.isNotEmpty) {
        final (lat, lon) = await searchLocation(locationQuery);
        final provider = Provider.of<ChartProvider>(context, listen: false);
        await provider.fetchChart(
          year: date.year,
          month: date.month,
          day: date.day,
          hour: time.hour.toDouble(),
          minute: time.minute.toDouble(),
          latitude: lat,
          longitude: lon,
          tzOffset: tzOffset,
        );
        return;
      }

      // If we reach here, we have neither coordinates nor location query
      throw Exception('Location coordinates are required');
    } catch (e) {
      throw Exception('Error generating chart: $e');
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../services/api_service.dart';
import '../models/location_model.dart';
import '../../../providers/chart_provider.dart';

class InputService {
  final BuildContext context;

  InputService(this.context);

  Future<(double, double)> searchLocation(String query) async {
    try {
      // Check if query matches a predefined city (case-insensitive)
      final matchedCity = LocationModel.predefinedCities.firstWhere(
        (city) => city.name.toLowerCase() == query.toLowerCase(),
        orElse: () => const LocationModel(name: ''),
      );

      if (matchedCity.name.isNotEmpty && matchedCity.latitude != null && matchedCity.longitude != null) {
        return (matchedCity.latitude!, matchedCity.longitude!);
      } else {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final response = await apiService.geocode(query);
        return (response.latitude, response.longitude);
      }
    } catch (e) {
      throw Exception('Error finding location: $e');
    }
  }

  Future<void> generateChart({
    required DateTime date,
    required TimeOfDay time,
    required double latitude,
    required double longitude,
    required double tzOffset,
  }) async {
    try {
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
    } catch (e) {
      throw Exception('Error generating chart: $e');
    }
  }
} 
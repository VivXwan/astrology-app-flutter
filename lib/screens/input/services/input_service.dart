import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/api_service.dart';
import '../../../providers/chart_provider.dart';
import '../../../models/geocode_models.dart';

class InputService {
  final BuildContext context;

  InputService(this.context);

  Future<(double, double)?> searchLocation(String query) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final GeocodeAPIResult geocodeApiResult = await apiService.geocodeLocation(query);
      
      if (geocodeApiResult.locations.isEmpty) {
        return null;
      }
      final GeocodeResponse firstLocation = geocodeApiResult.locations.first;
      return (firstLocation.latitude, firstLocation.longitude);
    } catch (e) {
      print('Error finding location: $e');
      return null;
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
      final ctx = context ?? this.context;
      final chartProvider = Provider.of<ChartProvider>(ctx, listen: false);
      
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
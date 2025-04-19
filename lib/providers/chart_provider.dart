import 'package:flutter/material.dart';
import '../models/chart.dart';
import '../services/api_service.dart';

class ChartProvider with ChangeNotifier {
  Chart? _chart;
  bool _isLoading = false;
  String? _error;

  Chart? get chart => _chart;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchChart({
    required int year,
    required int month,
    required int day,
    required double hour,
    required double minute,
    required double latitude,
    required double longitude,
    double tzOffset = 5.5,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final apiService = ApiService();
      final data = await apiService.getChart(
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        latitude: latitude,
        longitude: longitude,
        tzOffset: tzOffset,
      );
      _chart = Chart.fromJson(data);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChart() {
    _chart = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
} 
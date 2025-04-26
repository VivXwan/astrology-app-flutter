import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chart.dart';
import '../services/api_service.dart';
import 'kundali_provider.dart';
import 'dasha_provider.dart';
import '../main.dart';

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

      // Update KundaliProvider with the kundali details
      final kundaliProvider = Provider.of<KundaliProvider>(navigatorKey.currentContext!, listen: false);
      kundaliProvider.setKundaliDetails(data['kundali']);

      // Update DashaProvider with the vimshottari dasha data
      final dashaProvider = Provider.of<DashaProvider>(navigatorKey.currentContext!, listen: false);
      dashaProvider.setDashaData(data);
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
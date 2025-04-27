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

  Future<void> generateChart({
    required DateTime date,
    required TimeOfDay time,
    required double? latitude,
    required double? longitude,
    String? locationQuery,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final apiService = ApiService();
      final data = await apiService.getChart(
        year: date.year,
        month: date.month,
        day: date.day,
        hour: time.hour.toDouble(),
        minute: time.minute.toDouble(),
        seconds: 0.0,
        latitude: latitude ?? 0.0,
        longitude: longitude ?? 0.0,
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
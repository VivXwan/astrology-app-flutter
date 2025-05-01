import 'package:flutter/material.dart';
import '../models/dasha_model.dart';

class DashaProvider with ChangeNotifier {
  DashaTimelineData? _dashaData;
  bool _isLoading = false;
  String? _error;

  DashaTimelineData? get dashaData => _dashaData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setDashaData(Map<String, dynamic> jsonData) {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (jsonData.containsKey('vimshottari_dasha')) {
        _dashaData = DashaTimelineData.fromJson(jsonData);
      } else {
        _dashaData = null; // Or handle as error
        _error = 'Vimshottari Dasha data not found in response.';
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to parse Dasha data: $e';
      _dashaData = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearDashaData() {
    _dashaData = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
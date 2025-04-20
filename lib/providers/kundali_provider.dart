import 'package:flutter/foundation.dart';
import '../models/kundali_details.dart';

class KundaliProvider with ChangeNotifier {
  KundaliDetails? _kundaliDetails;
  bool _isLoading = false;
  String? _error;

  KundaliDetails? get kundaliDetails => _kundaliDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setKundaliDetails(Map<String, dynamic> json) {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _kundaliDetails = KundaliDetails.fromJson(json);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to parse Kundali details: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _kundaliDetails = null;
    _error = null;
    notifyListeners();
  }
} 
import 'package:flutter/material.dart';
import '../models/dasha_model.dart';

class DashaProvider extends ChangeNotifier {
  DashaTimelineData? _dashaData;
  bool _isLoading = false;
  String? _error;
  DashaPeriod? _selectedMahaDasha;
  DashaPeriod? _selectedAntarDasha;
  bool _showingAntarDasha = false;
  bool _showingPratyantar = false;

  DashaTimelineData? get dashaData => _dashaData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DashaPeriod? get selectedMahaDasha => _selectedMahaDasha;
  DashaPeriod? get selectedAntarDasha => _selectedAntarDasha;
  bool get showingAntarDasha => _showingAntarDasha;
  bool get showingPratyantar => _showingPratyantar;

  void setDashaData(Map<String, dynamic> json) {
    try {
      print('\n📊 Processing Dasha Data:');
      print('Keys in root JSON: ${json.keys.toList()}');
      
      if (!json.containsKey('vimshottari_dasha')) {
        throw Exception('vimshottari_dasha key not found in JSON');
      }
      
      final vimshottariDasha = json['vimshottari_dasha'];
      print('Type of vimshottari_dasha: ${vimshottariDasha.runtimeType}');
      
      if (vimshottariDasha is! List) {
        throw Exception('vimshottari_dasha is not a List, it is ${vimshottariDasha.runtimeType}');
      }
      
      print('Number of maha dashas: ${vimshottariDasha.length}');
      
      _dashaData = DashaTimelineData.fromJson(json);
      _error = null;
      notifyListeners();
    } catch (e) {
      print('\n❌ Dasha Data Processing Error:');
      print('Error: $e');
      _error = 'Failed to parse Dasha data: $e';
      notifyListeners();
    }
  }

  void selectMahaDasha(DashaPeriod? dasha) {
    if (_selectedMahaDasha == dasha) {
      resetSelection();
    } else {
      _selectedMahaDasha = dasha;
      _selectedAntarDasha = null;
      _showingAntarDasha = true;
      _showingPratyantar = false;
      notifyListeners();
    }
  }

  void selectAntarDasha(DashaPeriod? dasha) {
    if (_selectedAntarDasha == dasha) {
      _selectedAntarDasha = null;
      _showingPratyantar = false;
    } else {
      _selectedAntarDasha = dasha;
      _showingPratyantar = true;
    }
    notifyListeners();
  }

  void resetSelection() {
    _selectedMahaDasha = null;
    _selectedAntarDasha = null;
    _showingAntarDasha = false;
    _showingPratyantar = false;
    notifyListeners();
  }

  void backToMahaDasha() {
    resetSelection();
  }

  void backToAntarDasha() {
    _selectedAntarDasha = null;
    _showingPratyantar = false;
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
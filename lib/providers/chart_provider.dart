import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chart.dart';
import '../services/api_service.dart';
import 'kundali_provider.dart';
import 'dasha_provider.dart';
import '../main.dart';
import '../utils/astrology_utils.dart'; // Correct import now
import '../utils/constants.dart'; // Need this for the prepareVargaChartData fallback

class ChartProvider with ChangeNotifier {
  Chart? _chart; // Stores the API response
  bool _isLoading = false;
  String? _error;

  // State for multiple charts
  int _numberOfCharts = 1;
  List<String> _selectedChartTypes = ['D-1']; // Default: Show only D-1
  final Map<String, Chart?> _chartDataCache = {}; // Cache for prepared chart data

  // List of available chart types (can be expanded later)
  final List<String> availableChartTypes = ['D-1', 'D-2', 'D-3', 'D-7', 'D-9', 'D-12', 'D-30']; // D-1 is Rashi

  Chart? get chart => _chart;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters for new state
  int get numberOfCharts => _numberOfCharts;
  List<String> get selectedChartTypes => _selectedChartTypes;

  // Method to get chart data for a specific type (from cache or prepare)
  Chart? getChartDataForType(String chartType) {
    if (chartType == 'D-1') {
      return _chart;
    }
    if (_chartDataCache.containsKey(chartType)) {
      return _chartDataCache[chartType];
    }
    // Prepare if not in cache (only D-9 implemented for now)
    if (chartType != 'D-1' && _chart != null) {
      _chartDataCache[chartType] = _prepareVargaChartData(chartType, _chart!);
      return _chartDataCache[chartType];
    }
    return null; // Not D-1 and cannot prepare
  }

  Future<void> generateChart({
    required DateTime date,
    required TimeOfDay time,
    required double? latitude,
    required double? longitude,
    String? locationQuery,
  }) async {
    _isLoading = true;
    _error = null;
    _chart = null; // Clear previous chart
    _chartDataCache.clear(); // Clear varga cache
    // Reset selections to default when generating a new chart
    _numberOfCharts = 1;
    _selectedChartTypes = ['D-1']; 
    notifyListeners();

    try {
      // --- Backend API Call (Assume it returns D-1 and Varga sign data as before) ---
      final apiService = ApiService();
      final data = await apiService.getChart(
        year: date.year,
        month: date.month,
        day: date.day,
        hour: time.hour.toDouble(),
        minute: time.minute.toDouble(),
        seconds: 0.0, // Assuming seconds are 0, adjust if needed
        latitude: latitude ?? 0.0,
        longitude: longitude ?? 0.0,
      );
      _chart = Chart.fromJson(data);
      // Add main chart to cache as well for consistency
      _chartDataCache['D-1'] = _chart; 

      // --- Update other providers (as before) ---
       if (navigatorKey.currentContext != null) {
         try {
           final kundaliProvider = Provider.of<KundaliProvider>(navigatorKey.currentContext!, listen: false);
           kundaliProvider.setKundaliDetails(data['kundali']);

           final dashaProvider = Provider.of<DashaProvider>(navigatorKey.currentContext!, listen: false);
           dashaProvider.setDashaData(data);
         } catch (e) {
           // Handle cases where providers might not be available (e.g., during hot restart)
            _error = "Error accessing other providers: $e";
            print(_error); // Log for debugging
         }
       } else {
          _error = "Navigator context not available for provider updates.";
          print(_error); // Log for debugging
       }
      // --- End Update other providers ---

    } catch (e) {
      _error = "Error fetching chart data: $e";
       print(_error); // Log for debugging
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to change the number of charts displayed
  void setNumberOfCharts(int count) {
    if (count > 0 && count != _numberOfCharts) {
      _numberOfCharts = count;
      // Adjust the selected types list
      if (_selectedChartTypes.length > count) {
        _selectedChartTypes = _selectedChartTypes.sublist(0, count);
      } else {
        while (_selectedChartTypes.length < count) {
          // Add default chart type (e.g., D-1 or next available)
          _selectedChartTypes.add('D-1'); 
        }
      }
      notifyListeners();
    }
  }

  // Method to change the type of a specific chart panel
  void setChartType(int index, String type) {
    if (index >= 0 && index < _selectedChartTypes.length && availableChartTypes.contains(type)) {
       if (_selectedChartTypes[index] != type) {
         _selectedChartTypes[index] = type;
         // No need to fetch new data here, getChartDataForType will handle preparation
         notifyListeners();
       }
    }
  }

  // Helper to prepare Varga data
  Chart? _prepareVargaChartData(String vargaType, Chart kundali) {
    if (availableChartTypes.contains(vargaType)) {
      try {
        final Map<String, dynamic> vargaPlanetPositions = {}; // Renamed for clarity
        final vargaData = kundali.data['vargas']?[vargaType] as Map<String, dynamic>?;

        // Get Varga Ascendant Sign - handle potential null
        final String? vargaAscendantSign = vargaData?['Lagna']?['sign'] as String?;

        // Need a valid ascendant to calculate houses
        if (vargaData == null || vargaAscendantSign == null) {
           print("Warning: Varga data or ascendant missing for $vargaType");
           return null; // Cannot prepare chart without ascendant
        }

        kundali.planets.forEach((planetName, planetDetails) {
          // Get the original retrograde status from the D-1 data
          final String? originalRetrograde = planetDetails['retrograde'] as String?;

          final planetVargaInfo = vargaData[planetName] as Map<String, dynamic>?;
          if (planetVargaInfo != null) {
            final vargaSign = planetVargaInfo['sign'] as String?;
            if (vargaSign != null) {
              // Calculate Varga House based on Varga Ascendant
              final vargaHouse = calculateHouse(vargaSign, vargaAscendantSign);

              // Create the structure for the painter, NOW INCLUDING RETROGRADE
              vargaPlanetPositions[planetName] = {
                'sign': vargaSign,
                'house': vargaHouse,
                'retrograde': originalRetrograde ?? 'no', // Include retrograde status, default to 'no' if missing in D-1
                // Add other fields like longitude_dms, nakshatra, pada if needed by painter/widgets for Varga
                // For now, only adding retrograde as requested.
              };
            }
          } else {
             // Handle cases where a D-1 planet might not have Varga data (though unlikely for standard planets)
             print("Warning: Varga sign info missing for $planetName in $vargaType");
          }
        });

        // Construct a map suitable for Chart.fromJson or direct use
        final Map<String, dynamic> vargaChartData = {
           'kundali': {
             'ascendant': {'sign': vargaAscendantSign},
             'planets': vargaPlanetPositions,
             // Include other necessary top-level kundali keys if Chart.fromJson requires them
             // Example: copy ayanamsa, tz_offset etc. if needed from original kundali
             'ayanamsa': kundali.data['kundali']?['ayanamsa'],
             'ayanamsa_type': kundali.data['kundali']?['ayanamsa_type'],
             'tz_offset': kundali.data['kundali']?['tz_offset'],
           },
           // Include other top-level keys if Chart.fromJson requires them (like vimshottari_dasha)
         };

        // Use try-catch specifically for fromJson if it might fail
        try {
           return Chart.fromJson(vargaChartData);
        } catch (e) {
           print("Error creating Chart object from prepared Varga data for $vargaType: $e");
           return null;
        }

      } catch (e) {
        print("Error preparing varga chart data for $vargaType: $e");
        return null;
      }
    }
    print("Varga type $vargaType not supported for preparation.");
    return null;
  }


  void clearChart() {
    _chart = null;
    _error = null;
    _isLoading = false;
    _numberOfCharts = 1; // Reset on clear
    _selectedChartTypes = ['D-1']; // Reset on clear
    _chartDataCache.clear();
    notifyListeners();
  }
}

// --- REMOVE Placeholder Utilities --- 
// Removed calculateHouse function from here
// Removed calculateNavamsaSign placeholder 
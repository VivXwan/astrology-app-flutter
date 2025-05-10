import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chart.dart';
import '../models/varga_chart.dart';
import '../services/api_service.dart';
import 'kundali_provider.dart';
import 'dasha_provider.dart';
import '../providers/auth_provider.dart';
import '../main.dart';
import '../utils/astrology_utils.dart'; // Correct import now
import '../utils/constants.dart'; // Need this for the prepareVargaChartData fallback
import '../models/chart_models.dart'; // Import ChartSummary

class ChartProvider with ChangeNotifier {
  Chart? _chart; // Stores the main chart (D-1)
  Map<ChartType, VargaChart> _vargaCharts = {}; // Cache for prepared varga charts
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService;
  
  // Changed _userCharts to List<ChartSummary>
  List<ChartSummary> _userCharts = [];
  bool _isLoadingUserCharts = false;

  // State for multiple charts
  int _numberOfCharts = 1;
  List<ChartType> _selectedChartTypes = [ChartType.d1]; // Default: Show only D-1

  // Constructor to inject ApiService
  ChartProvider(this._apiService);

  // List of available chart types
  List<ChartType> get availableChartTypes => ChartType.values;
  
  // Available chart styles
  List<ChartStyle> get availableChartStyles => ChartStyle.values;

  Chart? get chart => _chart;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Changed getter to return List<ChartSummary>
  List<ChartSummary> get userCharts => _userCharts;
  bool get isLoadingUserCharts => _isLoadingUserCharts;
  bool get hasUserCharts => _userCharts.isNotEmpty;

  // Getters for state
  int get numberOfCharts => _numberOfCharts;
  List<ChartType> get selectedChartTypes => _selectedChartTypes;

  // Method to get chart data for a specific type (main chart or varga)
  Chart? getMainChart() => _chart;
  
  // Get a specific varga chart, creating it if necessary
  VargaChart? getVargaChart(ChartType chartType) {
    // D-1 is not a varga chart
    if (chartType == ChartType.d1 || _chart == null) {
      return null;
    }
    
    // Return from cache if available
    if (_vargaCharts.containsKey(chartType)) {
      return _vargaCharts[chartType];
    }
    
    // Check if we have the necessary data to create this varga chart
    if (_chart!.hasVargaData(chartType)) {
      try {
        final vargaData = _chart!.getVargaDataForType(chartType);
        if (vargaData != null) {
          final vargaChart = VargaChart.fromChartAndVargaData(
            _chart!,
            chartType,
            vargaData,
          );
          _vargaCharts[chartType] = vargaChart;
          return vargaChart;
        }
      } catch (e) {
        print("Error creating varga chart for $chartType: $e");
      }
    }
    
    return null;
  }

  // Get appropriate chart data based on type
  dynamic getChartDataForDisplay(ChartType chartType) {
    if (chartType == ChartType.d1) {
      return _chart;
    } else {
      return getVargaChart(chartType);
    }
  }

  // Load a user's saved charts
  Future<void> loadUserCharts(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Only try to load if user is authenticated
    if (!authProvider.isAuthenticated) {
      _userCharts = [];
      notifyListeners();
      return;
    }
    
    _isLoadingUserCharts = true;
    _error = null;
    notifyListeners();
    
    try {
      final chartsData = await _apiService.getAuthenticatedUserCharts();
      
      _userCharts = chartsData;
      
      // Sort by most recent first
      _userCharts.sort((a, b) => DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));
      
    } catch (e) {
      _error = "Error loading your charts: $e";
      print(_error);
      _userCharts = [];
    } finally {
      _isLoadingUserCharts = false;
      notifyListeners();
    }
  }
  
  // Load a specific chart by ID
  Future<void> loadChartById(String chartIdStr) async {
    _isLoading = true;
    _error = null;
    _chart = null;
    _vargaCharts.clear();
    notifyListeners();
    try {
      final int chartId = int.parse(chartIdStr); 
      final ChartSummary chartSummaryData = await _apiService.getChartById(chartId); 
      
      if (chartSummaryData.result != null) {
        final Map<String, dynamic> chartResultData = chartSummaryData.result!;
        _chart = Chart.fromJson(chartResultData); 

        // Safely access context and providers
        final currentContext = navigatorKey.currentContext;
        if (currentContext != null && currentContext.mounted) {
          try {
            final kundaliProvider = Provider.of<KundaliProvider>(currentContext, listen: false);
            final kundaliData = chartResultData['kundali'];
            if (kundaliData != null) {
               kundaliProvider.setKundaliDetails(kundaliData as Map<String, dynamic>);
            }

            final dashaProvider = Provider.of<DashaProvider>(currentContext, listen: false);
            dashaProvider.setDashaData(chartResultData); 
          } catch (providerError) {
             _error = "Error updating child providers: $providerError";
            print(_error);
          }
        }
      } else {
        _error = "Chart result data not found.";
        print(_error);
      }
    } catch (e) {
      _error = "Error loading chart by ID: $e";
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateChart({
    required DateTime date,
    required TimeOfDay time,
    required double? latitude,
    required double? longitude,
    String? locationQuery,
    BuildContext? context, // This context is different from navigatorKey.currentContext
  }) async {
    _isLoading = true;
    _error = null;
    _chart = null; 
    _vargaCharts.clear(); 
    _numberOfCharts = 1;
    _selectedChartTypes = [ChartType.d1]; 
    notifyListeners();
    try {
      final Map<String, dynamic> generatedChartData = await _apiService.getChart(
        year: date.year,
        month: date.month,
        day: date.day,
        hour: time.hour.toDouble(),
        minute: time.minute.toDouble(),
        seconds: 0.0, 
        latitude: latitude ?? 0.0,
        longitude: longitude ?? 0.0,
      );
      _chart = Chart.fromJson(generatedChartData); 

      final currentNavContext = navigatorKey.currentContext;
      if (currentNavContext != null && currentNavContext.mounted) {
         try {
            final kundaliProvider = Provider.of<KundaliProvider>(currentNavContext, listen: false);
            final kundaliData = generatedChartData['kundali'];
            if (kundaliData != null ){
               kundaliProvider.setKundaliDetails(kundaliData as Map<String, dynamic>);
            }

            final dashaProvider = Provider.of<DashaProvider>(currentNavContext, listen: false);
            dashaProvider.setDashaData(generatedChartData); 
          
            // Use the passed 'context' for authProvider, not navigatorKey.currentContext
            if (context != null) {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              if (authProvider.isAuthenticated) {
                // Pass the same context to loadUserCharts if it needs one for Provider.of
                loadUserCharts(context); 
              }
            }
        } catch (providerError) {
          _error = "Error accessing other providers during generateChart: $providerError";
          print(_error); 
        }
      } else {
        _error = "Navigator context not available for provider updates during generateChart.";
        print(_error); 
      }
    } catch (e) {
      _error = "Error fetching chart data: $e";
      print(_error); 
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
          _selectedChartTypes.add(ChartType.d1); 
        }
      }
      notifyListeners();
    }
  }

  // Method to change the type of a specific chart panel
  void setChartType(int index, ChartType type) {
    if (index >= 0 && index < _selectedChartTypes.length) {
      if (_selectedChartTypes[index] != type) {
        _selectedChartTypes[index] = type;
        // No need to fetch new data here, getChartDataForType will handle preparation
        notifyListeners();
      }
    }
  }

  void clearChart() {
    _chart = null;
    _error = null;
    _isLoading = false;
    _numberOfCharts = 1; // Reset on clear
    _selectedChartTypes = [ChartType.d1]; // Reset on clear
    _vargaCharts.clear();
    notifyListeners();
  }
}

// --- REMOVE Placeholder Utilities --- 
// Removed calculateHouse function from here
// Removed calculateNavamsaSign placeholder 
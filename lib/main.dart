import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'screens/chart_screen.dart';
import 'screens/input_screen.dart';
import 'models/chart.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ChartProvider(),
      child: const VedicAstrologyApp(),
    ),
  );
}

class VedicAstrologyApp extends StatelessWidget {
  const VedicAstrologyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vedic Astrology',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vedic Astrology'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Charts'),
            Tab(text: 'Dasha'),
            Tab(text: 'Strengths'),
            Tab(text: 'Transits'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ChartScreen(),
          Center(child: Text('Vimshottari Dasha')),
          Center(child: Text('Planetary Strengths')),
          Center(child: Text('Current Transits')),
        ],
      ),
    );
  }
}

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
    String? ayanamsaType,
  }) async {
    if (_chart != null) return; // Avoid refetching if data exists

    _isLoading = true;
    _error = null;
    notifyListeners();

    final apiService = ApiService();
    try {
      final data = await apiService.getChart(
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        latitude: latitude,
        longitude: longitude,
        tzOffset: tzOffset,
        ayanamsaType: ayanamsaType,
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
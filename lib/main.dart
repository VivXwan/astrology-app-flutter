import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'screens/chart_screen.dart';
import 'screens/input_screen.dart';
import 'models/chart.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider<ChartProvider>(create: (_) => ChartProvider()),
      ],
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
    _tabController = TabController(length: 2, vsync: this);
    // Navigate to InputScreen immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InputScreen()),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
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
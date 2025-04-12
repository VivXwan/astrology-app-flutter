import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/chart.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final ApiService _apiService = ApiService();
  Chart? _chart;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchChart();
  }

  Future<void> _fetchChart() async {
    try {
      final data = await _apiService.getChart(
        year: 1990, // Test data
        month: 5,
        day: 15,
        hour: 10.0,
        minute: 30.0,
        latitude: 28.66694444,
        longitude: 77.21694444,
        tzOffset: 5.5,
      );
      setState(() {
        _chart = Chart.fromJson(data);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    if (_chart == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          'Lagna: ${_chart!.kundali['ascendant']['sign']}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Planets:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ..._chart!.kundali['planets'].entries.map((entry) {
          final planet = entry.key;
          final details = entry.value as Map<String, dynamic>;
          return ListTile(
            title: Text(planet),
            subtitle: Text(
              'Sign: ${details['sign']}, Nakshatra: ${details['nakshatra']}, Pada: ${details['pada']}',
            ),
          );
        }).toList(),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/chart.dart';
import '../main.dart'; // Import ChartProvider

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> with AutomaticKeepAliveClientMixin{
  final ApiService _apiService = ApiService();
  Chart? _chart;
  String? _error;

  @override
  bool get wantKeepAlive => true; // Keep state alive

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ChartProvider>(context, listen: false);
    if (provider.chart == null && !provider.isLoading) {
      provider.fetchChart(
        year: 1990,
        month: 5,
        day: 15,
        hour: 10.0,
        minute: 30.0,
        latitude: 28.66694444,
        longitude: 77.21694444,
        tzOffset: 5.5,
      );
    }
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Consumer<ChartProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }
        if (provider.isLoading || provider.chart == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final chart = provider.chart!;
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Lagna: ${chart.kundali['ascendant']['sign']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Planets:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...chart.kundali['planets'].entries.map((entry) {
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
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../providers/auth_provider.dart';
import '../providers/chart_provider.dart';
import '../models/chart_models.dart'; // For ChartSummary
// import '../models/chart.dart'; // Chart model might not be directly needed here anymore
import '../screens/chart_screen.dart'; // For navigation

class UserChartsList extends StatefulWidget {
  const UserChartsList({Key? key}) : super(key: key);

  @override
  State<UserChartsList> createState() => _UserChartsListState();
}

class _UserChartsListState extends State<UserChartsList> {
  // Local state for handling tap on a chart item, to show loading/error specifically for that action
  bool _isFetchingChartDetails = false;
  String? _fetchDetailsError;

  Future<void> _onChartTap(ChartSummary chartSummary) async {
    setState(() {
      _isFetchingChartDetails = true;
      _fetchDetailsError = null;
    });
    try {
      final chartProvider = Provider.of<ChartProvider>(context, listen: false);
      await chartProvider.loadChartById(chartSummary.chartId.toString());
      
      if (mounted) {
        if (chartProvider.error == null) { // Check error from ChartProvider after loading details
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChartScreen()),
          );
        } else {
          // Error is already set in ChartProvider, but we can show a snackbar too
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading chart details: ${chartProvider.error}')),
          );
          setState(() { // Update local error if needed, though chartProvider.error is primary
            _fetchDetailsError = chartProvider.error;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _fetchDetailsError = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load chart: $_fetchDetailsError')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingChartDetails = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    // Watch ChartProvider for changes to userCharts, isLoadingUserCharts, and error
    final chartProvider = context.watch<ChartProvider>(); 

    if (!authProvider.isAuthenticated) {
      return const SizedBox.shrink(); // Don't show anything if not authenticated
    }

    // Proactive loading: If authenticated, charts are empty, not currently loading, and no previous error
    if (chartProvider.userCharts.isEmpty &&
        !chartProvider.isLoadingUserCharts &&
        chartProvider.error == null) { // Check error for the list loading, not _fetchDetailsError
      // Call loadUserCharts after the current build cycle is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // Ensure the widget is still in the tree
          Provider.of<ChartProvider>(context, listen: false).loadUserCharts(context);
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(
            'Your Saved Charts',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (_isFetchingChartDetails) // Show loading indicator when fetching details for a specific chart
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (_fetchDetailsError != null) // Show error if fetching specific chart details failed
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(_fetchDetailsError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        _buildChartList(chartProvider),
      ],
    );
  }

  Widget _buildChartList(ChartProvider chartProvider) {
    if (chartProvider.isLoadingUserCharts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chartProvider.error != null && chartProvider.userCharts.isEmpty) {
      // Show error only if there are no charts to display and an error occurred loading them
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error loading your charts: ${chartProvider.error}',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (chartProvider.userCharts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('You have no saved charts yet.')),
      );
    }

    // Limit the number of charts displayed for performance, e.g., latest 10-20 or implement pagination
    // final displayedCharts = chartProvider.userCharts.take(20).toList();

    return ListView.builder(
      shrinkWrap: true, // Important if ListView is inside a Column
      physics: const NeverScrollableScrollPhysics(), // If inside a SingleChildScrollView
      itemCount: chartProvider.userCharts.length, // Use all charts for now
      itemBuilder: (context, index) {
        final chartSummary = chartProvider.userCharts[index];
        final birthDate = chartSummary.birthData;
        String title = 'Chart for ${birthDate.day}/${birthDate.month}/${birthDate.year}';
        String subtitle = 'Time: ${birthDate.hour.toInt().toString().padLeft(2, '0')}:${birthDate.minute.toInt().toString().padLeft(2, '0')}';
        try {
          final parsedDate = DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(chartSummary.createdAt, true).toLocal();
          subtitle += '\nSaved: ${DateFormat.yMMMd().add_jm().format(parsedDate)}';
        } catch (e) {
           subtitle += '\nSaved: ${chartSummary.createdAt}'; // fallback
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _isFetchingChartDetails ? null : () => _onChartTap(chartSummary),
            // Prevent multiple taps while one is processing
          ),
        );
      },
    );
  }
} 
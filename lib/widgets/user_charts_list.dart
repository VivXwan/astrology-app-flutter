import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/auth_provider.dart';
import '../providers/chart_provider.dart';
import '../models/chart.dart';

class UserChartsList extends StatefulWidget {
  const UserChartsList({Key? key}) : super(key: key);

  @override
  State<UserChartsList> createState() => _UserChartsListState();
}

class _UserChartsListState extends State<UserChartsList> {
  final _chartIdController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  
  @override
  void dispose() {
    _chartIdController.dispose();
    super.dispose();
  }
  
  Future<void> _loadChartById() async {
    final chartId = _chartIdController.text.trim();
    if (chartId.isEmpty) {
      setState(() {
        _error = 'Please enter a chart ID';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final chartProvider = Provider.of<ChartProvider>(context, listen: false);
      await chartProvider.loadChartById(chartId);
      
      if (mounted) {
        // Navigate to chart screen
        Navigator.pushReplacementNamed(context, '/chart');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chartProvider = Provider.of<ChartProvider>(context);
    
    // Only show this widget if user is authenticated
    if (!authProvider.isAuthenticated) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(
            'Authenticated Chart Generation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your charts are automatically saved when you generate them while logged in.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'To access a saved chart, you need to know its specific ID. The current API does not provide a way to list all your saved charts.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Charts you generate will be private to your account and accessible later if you save the chart ID.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        
        // Recently generated chart
        if (chartProvider.chart != null && chartProvider.chart!.userId != null) 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Recently Generated Chart:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Chart ID: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            chartProvider.chart!.id,
                            style: const TextStyle(fontFamily: 'monospace'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: chartProvider.chart!.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chart ID copied to clipboard')),
                            );
                          },
                          tooltip: 'Copy Chart ID',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Created: ${chartProvider.chart!.formattedCreationDate}'),
                    Text('Ascendant: ${chartProvider.chart!.ascendantSign}'),
                  ],
                ),
              ),
            ],
          ),
          
        // Load chart by ID section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Load Chart by ID',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chartIdController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Chart ID',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _loadChartById,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Load'),
                  ),
                ],
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
} 
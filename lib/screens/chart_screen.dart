import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chart_provider.dart';
import '../providers/dasha_provider.dart';
import '../models/chart.dart';
import 'chart/widgets/chart_widget.dart';
import 'chart/widgets/kundali_table_widget.dart';
import 'chart/widgets/dasha_timeline_widget.dart';
import 'dart:math';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Selector<ChartProvider, 
      ({
        bool isLoading,
        String? error,
        Chart? chart,
        int numberOfCharts,
        List<String> selectedChartTypes
      })
    >(
      selector: (_, provider) => (
        isLoading: provider.isLoading,
        error: provider.error,
        chart: provider.chart,
        numberOfCharts: provider.numberOfCharts,
        selectedChartTypes: List.unmodifiable(provider.selectedChartTypes)
      ),
      builder: (context, data, child) {
        if (data.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Error generating chart: ${data.error}')),
          );
        }
        if (data.isLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Chart Details')),
              body: const Center(child: CircularProgressIndicator()),
            );
        }
        if (data.chart == null) {
           return Scaffold(
            appBar: AppBar(title: const Text('Chart Details')),
            body: const Center(child: Text('Generate a chart first.')),
          );
        }

        final provider = context.read<ChartProvider>();

        int crossAxisCount = data.numberOfCharts > 1 ? 2 : 1;
        double childAspectRatio = data.numberOfCharts > 2 ? 1.1 : 1.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chart Details'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: DropdownButton<int>(
                  value: data.numberOfCharts,
                  underline: Container(),
                  icon: const Icon(Icons.grid_view_rounded),
                  items: [1, 2, 4].map((int count) {
                    return DropdownMenuItem<int>(
                      value: count,
                      child: Text('$count Chart${count > 1 ? 's' : ''}'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      provider.setNumberOfCharts(newValue);
                    }
                  },
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio, 
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: data.numberOfCharts,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (index >= data.selectedChartTypes.length) {
                       return const Card(child: Center(child: Text("Error: Invalid state")));
                    }
                    String selectedType = data.selectedChartTypes[index];
                    Chart? chartData = provider.getChartDataForType(selectedType);

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.all(4.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            DropdownButton<String>(
                              value: selectedType,
                              isExpanded: true,
                              items: provider.availableChartTypes.map((String type) {
                                String displayText = switch (type) {
                                  'D-1' => 'Rashi (D-1)',
                                  'D-2' => 'Hora (D-2)', 
                                  'D-3' => 'Drekkana (D-3)',
                                  'D-7' => 'Saptamsa (D-7)',
                                  'D-9' => 'Navamsa (D-9)',
                                  'D-12' => 'Dwadasamsa (D-12)',
                                  'D-30' => 'Trimshamsa (D-30)',
                                  _ => type
                                };
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(displayText),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  provider.setChartType(index, newValue);
                                }
                              },
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: chartData != null
                                    ? ChartWidget(chart: chartData)
                                    : const Center(child: Text('Chart data unavailable')),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16), 
                const KundaliTableWidget(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: DashaTimelineWidget(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
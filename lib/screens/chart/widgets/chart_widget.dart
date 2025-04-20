import 'package:flutter/material.dart';
import '../../../../screens/chart_painter.dart';
import 'dart:math';
import '../../../../models/chart.dart';

class ChartWidget extends StatefulWidget {
  final Chart chart;

  const ChartWidget({super.key, required this.chart});

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  bool isNorthIndian = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7, // 70% of screen height
      child: Column(
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('North Indian')),
              ButtonSegment(value: false, label: Text('South Indian')),
            ],
            selected: {isNorthIndian},
            onSelectionChanged: (selected) {
              setState(() {
                isNorthIndian = selected.first;
              });
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(min(constraints.maxWidth, constraints.maxHeight), min(constraints.maxWidth, constraints.maxHeight)), // Square aspect
                  painter: isNorthIndian
                      ? NorthIndianChartPainter(
                          ascendantSign: widget.chart.ascendantSign,
                          planets: widget.chart.planets,
                        )
                      : SouthIndianChartPainter(
                          ascendantSign: widget.chart.ascendantSign,
                          planets: widget.chart.planets,
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
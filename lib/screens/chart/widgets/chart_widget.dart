import 'package:flutter/material.dart';
import '../../chart_painter.dart';
import 'dart:math';
import '../../../models/chart.dart';

class ChartWidget extends StatelessWidget {
  final Chart chart;
  final String selectedStyle;

  const ChartWidget({super.key, required this.chart, required this.selectedStyle});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        final effectiveSize = max(0.0, size);

        return Center(
          child: CustomPaint(
            size: Size(effectiveSize, effectiveSize),
            painter: selectedStyle == 'North Indian'
                ? NorthIndianChartPainter(
                    ascendantSign: chart.ascendantSign,
                    planets: chart.planets,
                  )
                : SouthIndianChartPainter(
                    ascendantSign: chart.ascendantSign,
                    planets: chart.planets,
                  ),
          ),
        );
      },
    );
  }
}
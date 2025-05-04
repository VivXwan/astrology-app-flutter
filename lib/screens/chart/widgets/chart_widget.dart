import 'package:flutter/material.dart';
import '../../chart_painters/base_chart_painter.dart';
import '../../chart_painters/north_indian_chart_painter.dart';
import '../../chart_painters/south_indian_chart_painter.dart';
import '../../../models/chart.dart';
import '../../../models/varga_chart.dart';
import '../../../config/theme_extensions.dart';

class ChartWidget extends StatelessWidget {
  final dynamic chartData; // Can be Chart or VargaChart
  final ChartStyle chartStyle;

  const ChartWidget({
    super.key,
    required this.chartData,
    required this.chartStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (chartData == null) {
      return const Center(child: Text('No chart data available'));
    }

    // Get our theme extensions
    final chartTheme = Theme.of(context).extension<ChartTheme>() ?? ChartTheme.light;
    
    // Extract chart properties based on the type
    String ascendantSign;
    
    if (chartData is Chart) {
      ascendantSign = chartData.ascendantSign;
    } else if (chartData is VargaChart) {
      ascendantSign = chartData.ascendantSign;
    } else {
      return const Center(child: Text('Unsupported chart data type'));
    }
    
    // Convert planet details to the format expected by painters
    final planets = BaseChartPainter.createPlanetMap(chartData);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the smallest dimension for square chart
        final smallestDimension = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        return Center(
          child: SizedBox(
            width: smallestDimension,
            height: smallestDimension,
            child: CustomPaint(
              painter: chartStyle == ChartStyle.northIndian
                  ? NorthIndianChartPainter(
                      ascendantSign: ascendantSign,
                      planets: planets,
                      chartTheme: chartTheme,
                    )
                  : SouthIndianChartPainter(
                      ascendantSign: ascendantSign,
                      planets: planets,
                      chartTheme: chartTheme,
                    ),
            ),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import '../../config/theme_extensions.dart';
import '../../models/chart.dart';
import '../../models/varga_chart.dart';
import '../../utils/planet_utils.dart';
import '../../utils/constants.dart';

/// Type definition for planet details from both Chart and VargaChart
typedef PlanetDetailsMap = Map<String, dynamic>;

/// Base abstract class for all chart painters
abstract class BaseChartPainter extends CustomPainter {
  final String ascendantSign;
  final PlanetDetailsMap planets;
  final ChartTheme chartTheme;

  /// Create a PlanetDetailsMap from a Chart or VargaChart
  static PlanetDetailsMap createPlanetMap(dynamic chartData) {
    if (chartData is Chart) {
      final map = <String, dynamic>{};
      for (final entry in chartData.planets.entries) {
        map[entry.key] = {
          'sign': entry.value.sign,
          'house': entry.value.house,
          'retrograde': entry.value.isRetrograde ? 'yes' : 'no',
        };
      }
      return map;
    } else if (chartData is VargaChart) {
      final map = <String, dynamic>{};
      for (final entry in chartData.planets.entries) {
        map[entry.key] = {
          'sign': entry.value.sign,
          'house': entry.value.house,
          'retrograde': entry.value.isRetrograde ? 'yes' : 'no',
        };
      }
      return map;
    } else {
      return {};
    }
  }

  BaseChartPainter({
    required this.ascendantSign,
    required this.planets,
    required this.chartTheme,
  });

  /// Main paint method that must be implemented by subclasses
  @override
  void paint(Canvas canvas, Size size);

  /// Repaint when ascendant or planets change
  @override
  bool shouldRepaint(covariant BaseChartPainter oldDelegate) {
    return ascendantSign != oldDelegate.ascendantSign || 
           planets != oldDelegate.planets;
  }

  /// Gets planet color based on theme
  Color getPlanetColor(String planet) {
    // Use theme's planet colors first, fallback to Constants
    return chartTheme.planetColors[planet] ?? 
           Constants.planetColors[planet] ?? 
           chartTheme.textColor;
  }

  /// Draw a text label with an optional retrograde indicator
  TextPainter createPlanetTextPainter(
    String planet, 
    bool isRetrograde,
    double fontSize
  ) {
    final abbreviation = PlanetUtils.getPlanetAbbreviation(planet);
    
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.text = TextSpan(
      text: abbreviation,
      style: TextStyle(
        color: getPlanetColor(planet),
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
      children: isRetrograde ? <TextSpan>[
        TextSpan(
          text: ' (R)',
          style: TextStyle(
            fontSize: fontSize * 0.75,
            fontWeight: FontWeight.normal,
          ),
        )
      ] : null,
    );
    
    textPainter.layout();
    return textPainter;
  }

  /// Prepare planets map for rendering
  Map<int, List<String>> groupPlanetsByHouse() {
    final result = <int, List<String>>{};
    
    planets.forEach((planetName, details) {
      final house = details['house'] as int;
      if (house >= 1 && house <= 12) {
        if (!result.containsKey(house)) {
          result[house] = [];
        }
        result[house]!.add(planetName);
      }
    });
    
    return result;
  }

  /// Get if a planet is retrograde
  bool isPlanetRetrograde(String planet) {
    final details = planets[planet];
    return details != null && 
           details['retrograde'] == 'yes';
  }
} 
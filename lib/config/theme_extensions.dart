export 'theme_extensions.dart';
import 'package:flutter/material.dart';

// Extension for chart-related theming
class ChartTheme extends ThemeExtension<ChartTheme> {
  final Color gridLineColor;
  final Color chartBorderColor;
  final Color chartBackgroundColor;
  final Color textColor;
  final Color ascendantColor;
  final Color retrogradeTextColor;
  final Map<String, Color> planetColors;
  
  const ChartTheme({
    required this.gridLineColor,
    required this.chartBorderColor,
    required this.chartBackgroundColor,
    required this.textColor,
    required this.ascendantColor,
    required this.retrogradeTextColor,
    required this.planetColors,
  });

  // Light theme defaults
  static const light = ChartTheme(
    gridLineColor: Color(0xFFDDDDDD),
    chartBorderColor: Color(0xFF000000),
    chartBackgroundColor: Color(0xFFFAFAFA),
    textColor: Color(0xFF000000),
    ascendantColor: Color(0xFFE91E63),
    retrogradeTextColor: Color(0xFFE53935),
    planetColors: {
      'Su': Color(0xFFFF9800),   // Sun: Orange
      'Mo': Color(0xFF9E9E9E),   // Moon: Silver/Gray
      'Ma': Color(0xFFE53935),   // Mars: Red
      'Me': Color(0xFF4CAF50),   // Mercury: Green
      'Ju': Color(0xFFFFEB3B),   // Jupiter: Yellow
      'Ve': Color(0xFF2196F3),   // Venus: Blue
      'Sa': Color(0xFF607D8B),   // Saturn: Blue Gray
      'Ra': Color(0xFF9C27B0),   // Rahu: Purple
      'Ke': Color(0xFF795548),   // Ketu: Brown
    },
  );

  // Dark theme defaults
  static const dark = ChartTheme(
    gridLineColor: Color(0xFF454545),
    chartBorderColor: Color(0xFFDDDDDD),
    chartBackgroundColor: Color(0xFF303030),
    textColor: Color(0xFFFFFFFF),
    ascendantColor: Color(0xFFFF4081),
    retrogradeTextColor: Color(0xFFFF5252),
    planetColors: {
      'Su': Color(0xFFFFB74D),   // Sun: Lighter Orange
      'Mo': Color(0xFFE0E0E0),   // Moon: Lighter Silver
      'Ma': Color(0xFFFF8A80),   // Mars: Lighter Red
      'Me': Color(0xFF81C784),   // Mercury: Lighter Green
      'Ju': Color(0xFFFFF176),   // Jupiter: Lighter Yellow
      'Ve': Color(0xFF64B5F6),   // Venus: Lighter Blue
      'Sa': Color(0xFF90A4AE),   // Saturn: Lighter Blue Gray
      'Ra': Color(0xFFCE93D8),   // Rahu: Lighter Purple
      'Ke': Color(0xFFA1887F),   // Ketu: Lighter Brown
    },
  );

  @override
  ThemeExtension<ChartTheme> copyWith({
    Color? gridLineColor,
    Color? chartBorderColor,
    Color? chartBackgroundColor,
    Color? textColor,
    Color? ascendantColor,
    Color? retrogradeTextColor,
    Map<String, Color>? planetColors,
  }) {
    return ChartTheme(
      gridLineColor: gridLineColor ?? this.gridLineColor,
      chartBorderColor: chartBorderColor ?? this.chartBorderColor,
      chartBackgroundColor: chartBackgroundColor ?? this.chartBackgroundColor,
      textColor: textColor ?? this.textColor,
      ascendantColor: ascendantColor ?? this.ascendantColor,
      retrogradeTextColor: retrogradeTextColor ?? this.retrogradeTextColor,
      planetColors: planetColors ?? this.planetColors,
    );
  }

  @override
  ThemeExtension<ChartTheme> lerp(ThemeExtension<ChartTheme>? other, double t) {
    if (other is! ChartTheme) {
      return this;
    }
    
    // Create new planetColors map with lerped colors
    final lerpedPlanetColors = <String, Color>{};
    planetColors.forEach((key, value) {
      if (other.planetColors.containsKey(key)) {
        lerpedPlanetColors[key] = Color.lerp(value, other.planetColors[key], t)!;
      } else {
        lerpedPlanetColors[key] = value;
      }
    });
    
    return ChartTheme(
      gridLineColor: Color.lerp(gridLineColor, other.gridLineColor, t)!,
      chartBorderColor: Color.lerp(chartBorderColor, other.chartBorderColor, t)!,
      chartBackgroundColor: Color.lerp(chartBackgroundColor, other.chartBackgroundColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      ascendantColor: Color.lerp(ascendantColor, other.ascendantColor, t)!,
      retrogradeTextColor: Color.lerp(retrogradeTextColor, other.retrogradeTextColor, t)!,
      planetColors: lerpedPlanetColors,
    );
  }
}

// Extension for Dasha timeline
class DashaTheme extends ThemeExtension<DashaTheme> {
  final Color mahaDashaBackgroundColor;
  final Color antarDashaBackgroundColor;
  final Color pratDashaBackgroundColor;
  final Color mahaDashaBorderColor;
  final Color antarDashaBorderColor;
  final Color pratDashaBorderColor;
  final Color textColor;
  
  const DashaTheme({
    required this.mahaDashaBackgroundColor,
    required this.antarDashaBackgroundColor,
    required this.pratDashaBackgroundColor,
    required this.mahaDashaBorderColor,
    required this.antarDashaBorderColor,
    required this.pratDashaBorderColor,
    required this.textColor,
  });

  // Light theme defaults
  static const light = DashaTheme(
    mahaDashaBackgroundColor: Color(0xFFE3F2FD),
    antarDashaBackgroundColor: Color(0xFFE8F5E9),
    pratDashaBackgroundColor: Color(0xFFFFF3E0),
    mahaDashaBorderColor: Color(0xFF2196F3),
    antarDashaBorderColor: Color(0xFF4CAF50),
    pratDashaBorderColor: Color(0xFFFF9800),
    textColor: Color(0xFF212121),
  );

  // Dark theme defaults
  static const dark = DashaTheme(
    mahaDashaBackgroundColor: Color(0xFF0D47A1),
    antarDashaBackgroundColor: Color(0xFF1B5E20),
    pratDashaBackgroundColor: Color(0xFF854D00),
    mahaDashaBorderColor: Color(0xFF64B5F6),
    antarDashaBorderColor: Color(0xFF81C784),
    pratDashaBorderColor: Color(0xFFFFB74D),
    textColor: Color(0xFFEEEEEE),
  );

  @override
  ThemeExtension<DashaTheme> copyWith({
    Color? mahaDashaBackgroundColor,
    Color? antarDashaBackgroundColor,
    Color? pratDashaBackgroundColor,
    Color? mahaDashaBorderColor,
    Color? antarDashaBorderColor,
    Color? pratDashaBorderColor,
    Color? textColor,
  }) {
    return DashaTheme(
      mahaDashaBackgroundColor: mahaDashaBackgroundColor ?? this.mahaDashaBackgroundColor,
      antarDashaBackgroundColor: antarDashaBackgroundColor ?? this.antarDashaBackgroundColor,
      pratDashaBackgroundColor: pratDashaBackgroundColor ?? this.pratDashaBackgroundColor,
      mahaDashaBorderColor: mahaDashaBorderColor ?? this.mahaDashaBorderColor,
      antarDashaBorderColor: antarDashaBorderColor ?? this.antarDashaBorderColor,
      pratDashaBorderColor: pratDashaBorderColor ?? this.pratDashaBorderColor,
      textColor: textColor ?? this.textColor,
    );
  }

  @override
  ThemeExtension<DashaTheme> lerp(ThemeExtension<DashaTheme>? other, double t) {
    if (other is! DashaTheme) {
      return this;
    }
    
    return DashaTheme(
      mahaDashaBackgroundColor: Color.lerp(mahaDashaBackgroundColor, other.mahaDashaBackgroundColor, t)!,
      antarDashaBackgroundColor: Color.lerp(antarDashaBackgroundColor, other.antarDashaBackgroundColor, t)!,
      pratDashaBackgroundColor: Color.lerp(pratDashaBackgroundColor, other.pratDashaBackgroundColor, t)!,
      mahaDashaBorderColor: Color.lerp(mahaDashaBorderColor, other.mahaDashaBorderColor, t)!,
      antarDashaBorderColor: Color.lerp(antarDashaBorderColor, other.antarDashaBorderColor, t)!,
      pratDashaBorderColor: Color.lerp(pratDashaBorderColor, other.pratDashaBorderColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
    );
  }
} 
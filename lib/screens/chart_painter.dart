import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/constants.dart';

class NorthIndianChartPainter extends CustomPainter {
  final String ascendantSign;
  final Map<String, dynamic> planets;
  final List<String> zodiacSigns = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  NorthIndianChartPainter({required this.ascendantSign, required this.planets});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Calculate center and radius
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;

    // Draw outer square
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size.width * 0.9, height: size.width * 0.9),
      paint,
    );

    // Draw inner diamond
    final diamondPath = Path()
      ..moveTo(center.dx, center.dy - radius) // Top
      ..lineTo(center.dx + radius, center.dy) // Right
      ..lineTo(center.dx, center.dy + radius) // Bottom
      ..lineTo(center.dx - radius, center.dy) // Left
      ..close();
    canvas.drawPath(diamondPath, paint);

    // Draw primary diagonal
    final primaryDiagonal = Path()
      ..moveTo(center.dx - radius, center.dy + radius)
      ..lineTo(center.dx + radius, center.dy - radius)
      ..close();
    canvas.drawPath(primaryDiagonal, paint);

    // Draw secondary diagonal
    final secondaryDiagonal = Path()
      ..moveTo(center.dx + radius, center.dy + radius)
      ..lineTo(center.dx - radius, center.dy - radius)
      ..close();
    canvas.drawPath(secondaryDiagonal, paint);

    // Assign signs based on ascendant
    final ascendantIndex = zodiacSigns.indexOf(ascendantSign);
    final houseSigns = List.generate(12, (i) => zodiacSigns[(ascendantIndex + i) % 12]);

    // Place planets in houses
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final houseBoxes = _calculateHouseBoxes(size, center, radius);
    // planets.forEach((planet, details) {
    //   final house = details['house'] - 1; // 1-based to 0-based
    //   final sign = details['sign'];
    //   final box = houseBoxes[house];
    //   final textSpan = TextSpan(
    //     text: _getPlanetAbbreviation(planet),
    //     style: TextStyle(
    //       color: Constants.planetColors[planet] ?? Colors.black,
    //       fontSize: 12,
    //     ),
    //   );
    //   textPainter.text = textSpan;
    //   textPainter.layout();
    //   // Center in box (simplified, adjust for overlaps later)
    //   textPainter.paint(
    //     canvas,
    //     Offset(
    //       box.left + (box.width - textPainter.width) / 2,
    //       box.top + (box.height - textPainter.height) / 2,
    //     ),
    //   );
    // });

    // Draw house numbers and signs (simplified)
    // for (var i = 0; i < 12; i++) {
    //   final box = houseBoxes[i];
    //   final textSpan = TextSpan(
    //     text: '${i + 1} (${houseSigns[i].substring(0, 3)})',
    //     style: TextStyle(color: Colors.black, fontSize: 10),
    //   );
    //   textPainter.text = textSpan;
    //   textPainter.layout();
    //   textPainter.paint(
    //     canvas,
    //     Offset(
    //       box.left + 5,
    //       box.top + 5,
    //     ),
    //   );
    // }
  }

  List<Rect> _calculateHouseBoxes(Size size, Offset center, double radius) {
    // Simplified: Approximate boxes for houses
    // In reality, calculate exact trapezoids based on diamond geometry
    final boxes = <Rect>[];
    final boxSize = size.width * 0.2;
    // Example layout (adjust coordinates based on actual house shapes)
    boxes.add(Rect.fromLTWH(center.dx - boxSize, center.dy - radius - boxSize, boxSize, boxSize)); // House 1
    // Add other houses similarly (requires geometric calculation)
    for (var i = 1; i < 12; i++) {
      boxes.add(Rect.fromLTWH(
        center.dx + (i % 4) * boxSize,
        center.dy + (i ~/ 4) * boxSize,
        boxSize,
        boxSize,
      ));
    }
    return boxes;
  }

  String _getPlanetAbbreviation(String planet) {
    const abbreviations = {
      'Sun': 'Su',
      'Moon': 'Mo',
      'Mars': 'Ma',
      'Mercury': 'Me',
      'Jupiter': 'Ju',
      'Venus': 'Ve',
      'Saturn': 'Sa',
      'Rahu': 'Ra',
      'Ketu': 'Ke',
      'Lagna': 'La',
    };
    return abbreviations[planet] ?? planet[0];
  }

  @override
  bool shouldRepaint(covariant NorthIndianChartPainter oldDelegate) {
    return ascendantSign != oldDelegate.ascendantSign || planets != oldDelegate.planets;
  }
}

class SouthIndianChartPainter extends CustomPainter {
  final String ascendantSign;
  final Map<String, dynamic> planets;
  final List<String> zodiacSigns = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  SouthIndianChartPainter({required this.ascendantSign, required this.planets});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw 4x4 grid
    final cellWidth = size.width / 4;
    final cellHeight = size.height / 4;
    for (var i = 0; i <= 4; i++) {
      canvas.drawLine(
        Offset(i * cellWidth, 0),
        Offset(i * cellWidth, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, i * cellHeight),
        Offset(size.width, i * cellHeight),
        paint,
      );
    }

    // Assign signs (fixed positions)
    final signPositions = [
      [0, 0, 'Pisces'], [1, 0, 'Aries'], [2, 0, 'Taurus'], [3, 0, 'Gemini'],
      [3, 1, 'Cancer'], [3, 2, 'Leo'], [3, 3, 'Virgo'], [2, 3, 'Libra'],
      [1, 3, 'Scorpio'], [0, 3, 'Sagittarius'], [0, 2, 'Capricorn'], [0, 1, 'Aquarius'],
    ];

    // Calculate houses based on ascendant
    final ascendantIndex = zodiacSigns.indexOf(ascendantSign);
    final houseMap = <String, int>{};
    for (var i = 0; i < 12; i++) {
      houseMap[zodiacSigns[(ascendantIndex + i) % 12]] = i + 1;
    }

    // Draw signs and houses
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var pos in signPositions) {
      final x = pos[0] as int;
      final y = pos[1] as int;
      final sign = pos[2] as String;
      final house = houseMap[sign] ?? 0;
      final textSpan = TextSpan(
        text: '$sign${house > 0 ? '\nH$house' : ''}',
        style: TextStyle(color: Colors.black, fontSize: 12),
      );
      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x * cellWidth + 5, y * cellHeight + 5),
      );
    }

    // Place planets
    planets.forEach((planet, details) {
      final sign = details['sign'];
      final pos = signPositions.firstWhere((p) => p[2] == sign, orElse: () => [0, 0, '']);
      if (pos.isNotEmpty) {
        final x = pos[0] as int;
        final y = pos[1] as int;
        final textSpan = TextSpan(
          text: _getPlanetAbbreviation(planet),
          style: TextStyle(
            color: Constants.planetColors[planet] ?? Colors.black,
            fontSize: 12,
          ),
        );
        textPainter.text = textSpan;
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            x * cellWidth + cellWidth / 2,
            y * cellHeight + cellHeight / 2,
          ),
        );
      }
    });
  }

  String _getPlanetAbbreviation(String planet) {
    const abbreviations = {
      'Sun': 'Su',
      'Moon': 'Mo',
      'Mars': 'Ma',
      'Mercury': 'Me',
      'Jupiter': 'Ju',
      'Venus': 'Ve',
      'Saturn': 'Sa',
      'Rahu': 'Ra',
      'Ketu': 'Ke',
      'Lagna': 'La',
    };
    return abbreviations[planet] ?? planet[0];
  }

  @override
  bool shouldRepaint(covariant SouthIndianChartPainter oldDelegate) {
    return ascendantSign != oldDelegate.ascendantSign || planets != oldDelegate.planets;
  }
}
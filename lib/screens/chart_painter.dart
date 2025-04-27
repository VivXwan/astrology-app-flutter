import 'dart:math';
import 'package:flutter/material.dart';
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
    final radius = size.width * 0.5;

    final diamondVertices = [
    Offset(center.dx, center.dy - radius), // Top
    Offset(center.dx + radius, center.dy), // Right
    Offset(center.dx, center.dy + radius), // Bottom
    Offset(center.dx - radius, center.dy), // Left
    ];

    final outerVertices = [
    Offset(center.dx - radius, center.dy + radius), // Bottom-Left
    Offset(center.dx + radius, center.dy + radius), // Bottom-Right
    Offset(center.dx + radius, center.dy - radius), // Top-Right
    Offset(center.dx - radius, center.dy - radius), // Top-Left
    ];

    final innerIntersections = [
    Offset(center.dx + radius / 2, center.dy + radius / 2), // Bottom-Right
    Offset(center.dx + radius / 2, center.dy - radius / 2), // Top-Right
    Offset(center.dx - radius / 2, center.dy - radius / 2), // Top-Left
    Offset(center.dx - radius / 2, center.dy + radius / 2), // Bottom-Left
    ];

    // Draw outer square
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size.width, height: size.width),
      paint,
    );

    // Draw inner diamond
    final diamondPath = Path()
      ..moveTo(diamondVertices[0].dx, diamondVertices[0].dy) // Top
      ..lineTo(diamondVertices[1].dx, diamondVertices[1].dy) // Right
      ..lineTo(diamondVertices[2].dx, diamondVertices[2].dy) // Bottom
      ..lineTo(diamondVertices[3].dx, diamondVertices[3].dy) // Left
      ..close();
    canvas.drawPath(diamondPath, paint);

    // Draw primary diagonal
    final primaryDiagonal = Path()
      ..moveTo(outerVertices[0].dx, outerVertices[0].dy) // Bottom-Left
      ..lineTo(outerVertices[2].dx, outerVertices[2].dy) // Top-Right
      ..close();
    canvas.drawPath(primaryDiagonal, paint);

    // Draw secondary diagonal
    final secondaryDiagonal = Path()
      ..moveTo(outerVertices[1].dx, outerVertices[1].dy) // Bottom-Right
      ..lineTo(outerVertices[3].dx, outerVertices[3].dy) // Top-Left
      ..close();
    canvas.drawPath(secondaryDiagonal, paint);
    
    // Define house paths (trapezoids/triangles)
    final housePaths = <Path>[];
    // House 1: Top Diamond
    housePaths.add(Path()
    ..moveTo(diamondVertices[0].dx, diamondVertices[0].dy)        // Top
    ..lineTo(innerIntersections[1].dx, innerIntersections[1].dy)  // Top-Right
    ..lineTo(center.dx, center.dy)                                // Center
    ..lineTo(innerIntersections[2].dx, innerIntersections[2].dy)  // Top-Left
    ..close());
    // House 2: Top-Left Upper Triangle
    housePaths.add(Path()
    ..moveTo(diamondVertices[0].dx, diamondVertices[0].dy)        // Top
    ..lineTo(innerIntersections[2].dx, innerIntersections[2].dy)  // Top-Left
    ..lineTo(outerVertices[3].dx, outerVertices[3].dy)            // Top-Left
    ..close());
    // House 3: Top-Left Lower Triangle
    housePaths.add(Path()
    ..moveTo(outerVertices[3].dx, outerVertices[3].dy)            // Top-Left
    ..lineTo(diamondVertices[3].dx, diamondVertices[3].dy)        // Left
    ..lineTo(innerIntersections[2].dx, innerIntersections[2].dy)  // Top-Left
    ..close());
    // House 4: Left Diamond
    housePaths.add(Path()
    ..moveTo(diamondVertices[3].dx, diamondVertices[3].dy)        // Left
    ..lineTo(innerIntersections[2].dx, innerIntersections[2].dy)  // Bottom-Left
    ..lineTo(center.dx, center.dy)                                // Center
    ..lineTo(innerIntersections[3].dx, innerIntersections[3].dy)  // Top-Left
    ..close());
    // House 5: Bottom-Left Upper Triangle
    housePaths.add(Path()
    ..moveTo(diamondVertices[3].dx, diamondVertices[3].dy)        // Left
    ..lineTo(outerVertices[0].dx, outerVertices[0].dy)            // Bottom-Left
    ..lineTo(innerIntersections[3].dx, innerIntersections[3].dy)  // Bottom-Left
    ..close());
    // House 6: Bottom-Left Lower Triangle
    housePaths.add(Path()
    ..moveTo(diamondVertices[2].dx, diamondVertices[2].dy)        // Bottom
    ..lineTo(innerIntersections[3].dx, innerIntersections[3].dy)  // Bottom-Left
    ..lineTo(outerVertices[0].dx, outerVertices[0].dy)            // Bottom-Left
    ..close());
    // House 7: Bottom Diamond
    housePaths.add(Path()
    ..moveTo(diamondVertices[2].dx, diamondVertices[2].dy)        // Bottom
    ..lineTo(innerIntersections[0].dx, innerIntersections[0].dy)  // Bottom-Right
    ..lineTo(center.dx, center.dy)                                // Center
    ..lineTo(innerIntersections[3].dx, innerIntersections[3].dy)  // Bottom-Left
    ..close());
    // House 8: Bottom-Right Lower Triangle
    housePaths.add(Path()
    ..moveTo(diamondVertices[2].dx, diamondVertices[2].dy)        // Bottom
    ..lineTo(innerIntersections[0].dx, innerIntersections[0].dy)  // Bottom-Right
    ..lineTo(outerVertices[1].dx, outerVertices[1].dy)            // Bottom-Right
    ..close());
    // House 9: Bottom-Right Upper Triangle
    housePaths.add(Path()
    ..moveTo(diamondVertices[1].dx, diamondVertices[1].dy)        // Right
    ..lineTo(innerIntersections[0].dx, innerIntersections[0].dy)  // Bottom-Right
    ..lineTo(outerVertices[1].dx, outerVertices[1].dy)            // Bottom-Right
    ..close());
    // House 10: Right Diamond
    housePaths.add(Path()
    ..moveTo(diamondVertices[1].dx, diamondVertices[1].dy)        // Right
    ..lineTo(innerIntersections[0].dx, innerIntersections[0].dy)  // Top-Right
    ..lineTo(center.dx, center.dy)                                // Center
    ..lineTo(innerIntersections[1].dx, innerIntersections[1].dy)  // Bottom-Right
    ..close());
    // House 11:
    housePaths.add(Path()
    ..moveTo(diamondVertices[1].dx, diamondVertices[1].dy)        // Right
    ..lineTo(innerIntersections[1].dx, innerIntersections[1].dy)  // Top-Right
    ..lineTo(outerVertices[2].dx, outerVertices[2].dy)            // Top-Right
    ..close());
    // House 12:
    housePaths.add(Path()
    ..moveTo(diamondVertices[0].dx, diamondVertices[0].dy)        // Top
    ..lineTo(innerIntersections[1].dx, innerIntersections[1].dy)  // Top-Right
    ..lineTo(outerVertices[2].dx, outerVertices[2].dy)            // Top-Right
    ..close());

    // Assign signs based on ascendant
    final ascendantIndex = zodiacSigns.indexOf(ascendantSign);
    final signNumbers = List.generate(12, (i) => (ascendantIndex + i) % 12 + 1);

    // Group planets by house
    final planetsByHouse = List<List<String>>.generate(12, (_) => []);
    planets.forEach((planet, details) {
      final house = details['house'] as int;
      if (house >= 1 && house <= 12) {
        planetsByHouse[house - 1].add(planet);
      }
    });

    // Text painting setup
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw house numbers, sign numbers, and planets
    for (var house = 0; house < 12; house++) {
      final housePath = housePaths[house];
      final bounds = housePath.getBounds();

      // House number positions (based on notation style)
      Offset houseNumberPos;
      switch (house + 1) {
        case 1:
          houseNumberPos = Offset(center.dx, center.dy - radius * 0.07);
          break;
        case 2:
          houseNumberPos = Offset(innerIntersections[2].dx, innerIntersections[2].dy - radius * 0.07);
          break;
        case 3:
          houseNumberPos = Offset(innerIntersections[2].dx - radius * 0.07, innerIntersections[2].dy);
          break;
        case 4: // Left vertex
          houseNumberPos = Offset(center.dx - radius * 0.07, center.dy);
          break;
        case 5: // Near bottom-left corner, left side
          houseNumberPos = Offset(innerIntersections[3].dx - radius * 0.07, innerIntersections[3].dy);
          break;
        case 6: // Near bottom vertex, left side
          houseNumberPos = Offset(innerIntersections[3].dx, innerIntersections[3].dy + radius * 0.07);
          break;
        case 7: // Bottom vertex
          houseNumberPos = Offset(center.dx, center.dy + radius * 0.07);
          break;
        case 8: // Near bottom-right corner, bottom side
          houseNumberPos = Offset(innerIntersections[0].dx, innerIntersections[0].dy + radius * 0.07);
          break;
        case 9: // Near right vertex, bottom side
          houseNumberPos = Offset(innerIntersections[0].dx + radius * 0.07, innerIntersections[0].dy);
          break;
        case 10: // Right vertex
          houseNumberPos = Offset(center.dx + radius * 0.07, center.dy);
          break;
        case 11: // Near top-right corner, right side
          houseNumberPos = Offset(innerIntersections[1].dx + radius * 0.07, innerIntersections[1].dy);
          break;
        case 12: // Near top vertex, right side
          houseNumberPos = Offset(innerIntersections[1].dx, innerIntersections[1].dy - radius * 0.07);
          break;
        default:
          houseNumberPos = bounds.center;
      }

      // Draw house number
      textPainter.text = TextSpan(
        // text: '${house + 1}',
        text: '${signNumbers[house]}',
        style: TextStyle(
          color: Colors.black,
          fontSize: size.width * 0.03,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        houseNumberPos.translate(-textPainter.width / 2, -textPainter.height / 2),
      );

      // Draw planets in this house
      if (planetsByHouse[house].isNotEmpty) {
        _drawPlanetsInHouse(canvas, bounds, planetsByHouse[house], house + 1);
      }
    }
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

  Color _getPlanetColor(String planet) {
    switch (planet.toLowerCase()) {
      case 'sun':
        return Colors.orange;
      case 'moon':
        return Colors.blue;
      case 'mars':
        return Colors.red;
      case 'mercury':
        return Colors.green;
      case 'jupiter':
        return Colors.purple;
      case 'venus':
        return Colors.pink;
      case 'saturn':
        return Colors.grey;
      case 'rahu':
        return Colors.brown;
      case 'ketu':
        return Colors.black;
      default:
        return Colors.black;
    }
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

  // New function for planet painting logic
  void _paintPlanets(Canvas canvas, Size size, double cellWidth, Offset center, List<List<dynamic>> signPositions) {
    // 1. Group planets by sign
    Map<String, List<String>> planetsBySign = {};
    planets.forEach((planet, details) {
      final sign = details['sign'];
      if (!planetsBySign.containsKey(sign)) {
        planetsBySign[sign] = [];
      }
      planetsBySign[sign]!.add(planet);
    });

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    // 2. Calculate optimal font size based on number of planets in most occupied cell
    int maxPlanetsInCell = planetsBySign.values
        .map((planets) => planets.length)
        .reduce(max);
    
    double fontSize = min(
      cellWidth * 0.15,  // Max 15% of cell width
      cellWidth / (maxPlanetsInCell * 1.5)  // Ensure all planets fit with 50% padding
    );

    // 3. Paint planets with proper spacing
    planetsBySign.forEach((sign, planetsInSign) {
      // Find cell position for this sign
      final pos = signPositions.firstWhere(
        (p) => p[2] == sign,
        orElse: () => [0, 0, ''] as List<Object>
      );
      
      if (pos.isNotEmpty) {
        final x = pos[0] as int;
        final y = pos[1] as int;
        
        // Calculate starting position in cell
        double startX = center.dx - (2 - x) * cellWidth + cellWidth * 0.1; // 10% padding from left
        double startY = center.dy - (2 - y) * cellWidth + cellWidth * 0.3; // 30% padding from top
        
        // Calculate spacing between planets
        double verticalSpacing = min(
          fontSize * 1.2,  // 20% padding between lines
          (cellWidth * 0.6) / planetsInSign.length  // 60% of cell height divided by number of planets
        );

        // Paint each planet in the sign
        for (int i = 0; i < planetsInSign.length; i++) {
          final planet = planetsInSign[i];
          
          textPainter.text = TextSpan(
            text: _getPlanetAbbreviation(planet),
            style: TextStyle(
              color: Constants.planetColors[planet] ?? Colors.black,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          );
          
          textPainter.layout();
          
          // Calculate position for this planet
          double yOffset = startY + (i * verticalSpacing);
          
          // Ensure planet stays within cell bounds
          yOffset = min(
            yOffset,
            center.dy - (2 - y) * cellWidth + cellWidth * 0.9 - textPainter.height
          );
          
          textPainter.paint(
            canvas,
            Offset(startX, yOffset),
          );
        }
      }
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cellWidth = size.width / 4;
    final center = Offset(size.width / 2, size.height / 2);

    // Draw outer square
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size.width, height: size.width),
      paint,
    );

    for (var i = 0; i < 4; i++) {
      final multiplicationSign = i % 2 == 0 ? 1 : -1;

      canvas.drawLine(
        Offset(center.dx + cellWidth * multiplicationSign, center.dy - 2 * cellWidth),
        Offset(center.dx + cellWidth * multiplicationSign, center.dy + 2 * cellWidth),
        paint,
      );
      canvas.drawLine(
        Offset(center.dx - 2 * cellWidth, center.dy + cellWidth * multiplicationSign),
        Offset(center.dx + 2 * cellWidth, center.dy + cellWidth * multiplicationSign),
        paint,
      );
      canvas.drawLine(
        Offset(center.dx, center.dy + 2 * cellWidth * multiplicationSign),
        Offset(center.dx, center.dy + cellWidth * multiplicationSign),
        paint,
      );
      canvas.drawLine(
        Offset(center.dx + 2 * cellWidth * multiplicationSign, center.dy),
        Offset(center.dx + cellWidth * multiplicationSign, center.dy),
        paint,
      );
    }

    // Assign signs (fixed positions)
    final signPositions = [
      [0, 0, 'Pisces'], [1, 0, 'Aries'], [2, 0, 'Taurus'], [3, 0, 'Gemini'],
      [0, 1, 'Aquarius'],[3, 1, 'Cancer'],
      [0, 2, 'Capricorn'], [3, 2, 'Leo'],
      [0, 3, 'Sagittarius'], [1, 3, 'Scorpio'], [2, 3, 'Libra'], [3, 3, 'Virgo']
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
        style: TextStyle(color: Colors.black, fontSize: cellWidth * 0.08),
      );
      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(center.dx - (2 - x) * cellWidth + 5, center.dy - (2 - y) * cellWidth + 5),
      );
    }

    // Call the new planet painting function
    _paintPlanets(canvas, size, cellWidth, center, signPositions);
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

void _drawPlanetsInHouse(Canvas canvas, Rect bounds, List<String> planets, int house) {
  if (planets.isEmpty) return;

  final textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );

  // Calculate available space (reduced to prevent overflow)
  final availableWidth = bounds.width * 0.85;  // Use 70% of house width
  final availableHeight = bounds.height * 0.85;  // Use 60% of house height
  
  // Calculate grid dimensions
  final planetCount = planets.length;
  int columns = (planetCount > 3) ? 2 : 1;  // Use 2 columns if more than 3 planets
  int rows = (planetCount + columns - 1) ~/ columns;  // Ceiling division
  
  // Calculate maximum font size that will fit in a cell
  double fontSize = min(
    availableWidth / (columns * 3),  // Width constraint
    availableHeight / (rows * 3)     // Height constraint
  );
  fontSize = min(fontSize, 14.0);    // Cap maximum size
  
  // Pre-calculate text dimensions for all planets
  List<Size> textSizes = [];
  double maxTextWidth = 0;
  double maxTextHeight = 0;
  
  for (String planet in planets) {
    textPainter.text = TextSpan(
      text: _getPlanetAbbreviation(planet),
      style: TextStyle(
        color: _getPlanetColor(planet),
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textSizes.add(Size(textPainter.width, textPainter.height));
    maxTextWidth = max(maxTextWidth, textPainter.width);
    maxTextHeight = max(maxTextHeight, textPainter.height);
  }
  
  // Calculate total grid size
  final totalGridWidth = columns * (maxTextWidth * 1.5);  // 1.5x spacing between columns
  final totalGridHeight = rows * (maxTextHeight * 1.5);   // 1.5x spacing between rows
  
  // Calculate starting position to center the entire grid
  final startX = bounds.center.dx - (totalGridWidth / 2);
  final startY = bounds.center.dy - (totalGridHeight / 2);
  
  // Adjust grid position based on house location
  double adjustX = 0;
  double adjustY = 0;
  
  switch (house) {
    case 1: // Top
      adjustY = -bounds.height * 0.1;
      break;
    case 4: // Left
      adjustX = -bounds.width * 0.1;
      break;
    case 7: // Bottom
      adjustY = bounds.height * 0.1;
      break;
    case 10: // Right
      adjustX = bounds.width * 0.1;
      break;
    case 2:
    case 3:
      adjustX = -bounds.width * 0.05;
      adjustY = -bounds.height * 0.05;
      break;
    case 5:
    case 6:
      adjustX = -bounds.width * 0.05;
      adjustY = bounds.height * 0.05;
      break;
    case 8:
    case 9:
      adjustX = bounds.width * 0.05;
      adjustY = bounds.height * 0.05;
      break;
    case 11:
    case 12:
      adjustX = -bounds.width * 0.05;
      adjustY = -bounds.height * 0.05;
      break;
  }

  // Draw each planet
  for (int i = 0; i < planets.length; i++) {
    final row = i ~/ columns;
    final col = i % columns;
    
    textPainter.text = TextSpan(
      text: _getPlanetAbbreviation(planets[i]),
      style: TextStyle(
        color: _getPlanetColor(planets[i]),
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();

    // Calculate centered position within the grid
    final x = startX + (col * maxTextWidth * 1.5) + adjustX;
    final y = startY + (row * maxTextHeight * 1.5) + adjustY;

    textPainter.paint(canvas, Offset(x, y));
  }
}

String _getPlanetAbbreviation(String planet) {
  switch (planet.toLowerCase()) {
    case 'sun': return 'Su';
    case 'moon': return 'Mo';
    case 'mars': return 'Ma';
    case 'mercury': return 'Me';
    case 'jupiter': return 'Ju';
    case 'venus': return 'Ve';
    case 'saturn': return 'Sa';
    case 'rahu': return 'Ra';
    case 'ketu': return 'Ke';
    default: return '';
  }
}

Color _getPlanetColor(String planet) {
  switch (planet.toLowerCase()) {
    case 'sun':
      return Colors.orange;
    case 'moon':
      return Colors.blue;
    case 'mars':
      return Colors.red;
    case 'mercury':
      return Colors.green;
    case 'jupiter':
      return Colors.purple;
    case 'venus':
      return Colors.pink;
    case 'saturn':
      return Colors.grey;
    case 'rahu':
      return Colors.brown;
    case 'ketu':
      return Colors.black;
    default:
      return Colors.black;
  }
}
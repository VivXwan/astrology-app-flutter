import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class NorthIndianChartPainter extends CustomPainter {
  final String ascendantSign;
  final Map<String, dynamic> planets;

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
    
    // Define house paths (trapezoids/triangles) and their vertices
    final housePaths = <Path>[];
    final houseVertices = <List<Offset>>[];

    // House 1: Top Diamond
    List<Offset> h1Vertices = [
      diamondVertices[0], // Top
      innerIntersections[1], // Top-Right
      center, // Center
      innerIntersections[2], // Top-Left
    ];
    houseVertices.add(h1Vertices);
    housePaths.add(Path()
      ..addPolygon(h1Vertices, true)); // Use addPolygon for simplicity
    
    // House 2: Top-Left Upper Triangle
    List<Offset> h2Vertices = [
      diamondVertices[0], // Top
      innerIntersections[2], // Top-Left
      outerVertices[3], // Top-Left Outer
    ];
    houseVertices.add(h2Vertices);
    housePaths.add(Path()
      ..addPolygon(h2Vertices, true));
      
    // House 3: Top-Left Lower Triangle
     List<Offset> h3Vertices = [
      outerVertices[3], // Top-Left Outer
      diamondVertices[3], // Left
      innerIntersections[2], // Top-Left Inner
    ];
    houseVertices.add(h3Vertices);
    housePaths.add(Path()
      ..addPolygon(h3Vertices, true));
      
    // House 4: Left Diamond
    List<Offset> h4Vertices = [
      diamondVertices[3], // Left
      innerIntersections[3], // Bottom-Left Inner
      center, // Center
      innerIntersections[2], // Top-Left Inner
    ];
    houseVertices.add(h4Vertices);
    housePaths.add(Path()
      ..addPolygon(h4Vertices, true));

    // House 5: Bottom-Left Upper Triangle
    List<Offset> h5Vertices = [
      diamondVertices[3], // Left
      outerVertices[0], // Bottom-Left Outer
      innerIntersections[3], // Bottom-Left Inner
    ];
    houseVertices.add(h5Vertices);
    housePaths.add(Path()
      ..addPolygon(h5Vertices, true));
      
    // House 6: Bottom-Left Lower Triangle
    List<Offset> h6Vertices = [
      outerVertices[0], // Bottom-Left Outer
      diamondVertices[2], // Bottom
      innerIntersections[3], // Bottom-Left Inner
    ];
    houseVertices.add(h6Vertices);
    housePaths.add(Path()
      ..addPolygon(h6Vertices, true));

    // House 7: Bottom Diamond
    List<Offset> h7Vertices = [
      diamondVertices[2], // Bottom
      innerIntersections[3], // Bottom-Left Inner
      center, // Center
      innerIntersections[0], // Bottom-Right Inner
    ];
    houseVertices.add(h7Vertices);
    housePaths.add(Path()
      ..addPolygon(h7Vertices, true));

    // House 8: Bottom-Right Lower Triangle
     List<Offset> h8Vertices = [
      diamondVertices[2], // Bottom
      innerIntersections[0], // Bottom-Right Inner
      outerVertices[1], // Bottom-Right Outer
    ];
    houseVertices.add(h8Vertices);
    housePaths.add(Path()
      ..addPolygon(h8Vertices, true));
      
    // House 9: Bottom-Right Upper Triangle
    List<Offset> h9Vertices = [
       outerVertices[1], // Bottom-Right Outer
       diamondVertices[1], // Right
       innerIntersections[0], // Bottom-Right Inner
    ];
    houseVertices.add(h9Vertices);
    housePaths.add(Path()
      ..addPolygon(h9Vertices, true));

    // House 10: Right Diamond
    List<Offset> h10Vertices = [
      diamondVertices[1], // Right
      innerIntersections[1], // Top-Right Inner
      center, // Center
      innerIntersections[0], // Bottom-Right Inner
    ];
    houseVertices.add(h10Vertices);
    housePaths.add(Path()
      ..addPolygon(h10Vertices, true));

    // House 11: Top-Right Upper Triangle
     List<Offset> h11Vertices = [
      diamondVertices[1], // Right
      innerIntersections[1], // Top-Right Inner
      outerVertices[2], // Top-Right Outer
    ];
    houseVertices.add(h11Vertices);
    housePaths.add(Path()
      ..addPolygon(h11Vertices, true));
      
    // House 12: Top-Right Lower Triangle
     List<Offset> h12Vertices = [
       outerVertices[2], // Top-Right Outer
       diamondVertices[0], // Top
       innerIntersections[1], // Top-Right Inner
    ];
    houseVertices.add(h12Vertices);
    housePaths.add(Path()
      ..addPolygon(h12Vertices, true));


    // Assign signs based on ascendant
    final ascendantIndex = Constants.zodiacSigns.indexOf(ascendantSign);
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
      final bounds = housePaths[house].getBounds(); // Calculate bounds for house number placement
      final vertices = houseVertices[house]; // Get vertices for this house

      // House number positions (based on notation style)
      Offset houseNumberPos;
      switch (house + 1) {
        case 1:
          houseNumberPos = Offset(center.dx, center.dy - radius * 0.08);
          break;
        case 2:
          houseNumberPos = Offset(innerIntersections[2].dx, innerIntersections[2].dy - radius * 0.08);
          break;
        case 3:
          houseNumberPos = Offset(innerIntersections[2].dx - radius * 0.08, innerIntersections[2].dy);
          break;
        case 4: // Left vertex
          houseNumberPos = Offset(center.dx - radius * 0.08, center.dy);
          break;
        case 5: // Near bottom-left corner, left side
          houseNumberPos = Offset(innerIntersections[3].dx - radius * 0.08, innerIntersections[3].dy);
          break;
        case 6: // Near bottom vertex, left side
          houseNumberPos = Offset(innerIntersections[3].dx, innerIntersections[3].dy + radius * 0.08);
          break;
        case 7: // Bottom vertex
          houseNumberPos = Offset(center.dx, center.dy + radius * 0.08);
          break;
        case 8: // Near bottom-right corner, bottom side
          houseNumberPos = Offset(innerIntersections[0].dx, innerIntersections[0].dy + radius * 0.08);
          break;
        case 9: // Near right vertex, bottom side
          houseNumberPos = Offset(innerIntersections[0].dx + radius * 0.08, innerIntersections[0].dy);
          break;
        case 10: // Right vertex
          houseNumberPos = Offset(center.dx + radius * 0.08, center.dy);
          break;
        case 11: // Near top-right corner, right side
          houseNumberPos = Offset(innerIntersections[1].dx + radius * 0.08, innerIntersections[1].dy);
          break;
        case 12: // Near top vertex, right side
          houseNumberPos = Offset(innerIntersections[1].dx, innerIntersections[1].dy - radius * 0.08);
          break;
        default:
          houseNumberPos = bounds.center;
      }

      // Draw house number
      textPainter.text = TextSpan(
        text: '${signNumbers[house]}',
        style: TextStyle(
          color: Colors.black,
          fontSize: size.width * 0.035,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        houseNumberPos.translate(-textPainter.width / 2, -textPainter.height / 2),
      );

      // Draw planets in this house using vertices for centroid calculation
      if (planetsByHouse[house].isNotEmpty) {
        // Pass both path and vertices now
        _drawPlanetsInHouse(canvas, housePaths[house], houseVertices[house], planetsByHouse[house], house + 1);
      }
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
    final ascendantIndex = Constants.zodiacSigns.indexOf(ascendantSign);
    final houseMap = <String, int>{};
    for (var i = 0; i < 12; i++) {
      houseMap[Constants.zodiacSigns[(ascendantIndex + i) % 12]] = i + 1;
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

// Helper function to calculate bounds from vertices
Rect _getBoundsFromVertices(List<Offset> vertices) {
  if (vertices.isEmpty) return Rect.zero;
  double minX = vertices[0].dx;
  double minY = vertices[0].dy;
  double maxX = vertices[0].dx;
  double maxY = vertices[0].dy;
  for (int i = 1; i < vertices.length; i++) {
    minX = min(minX, vertices[i].dx);
    minY = min(minY, vertices[i].dy);
    maxX = max(maxX, vertices[i].dx);
    maxY = max(maxY, vertices[i].dy);
  }
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

// --- Start: New Planet Drawing Logic --- 

// Function signature changed: Added Path housePath
void _drawPlanetsInHouse(Canvas canvas, Path housePath, List<Offset> vertices, List<String> planets, int house) {
  if (planets.isEmpty || vertices.length < 3) return; 

  final textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );
  
  final centroid = _calculateCentroid(vertices);
  // Fallback if centroid calculation fails
  final centerPoint = (centroid == Offset.zero && !_getBoundsFromVertices(vertices).isEmpty) 
                      ? _getBoundsFromVertices(vertices).center 
                      : centroid;

  Map<String, Offset> finalPositions = {};
  double finalFontSize = 0.0;

  // Loop through font sizes, largest to smallest
  for (double currentFontSize = 18.0; currentFontSize >= 12.0; currentFontSize -= 1.0) {
    bool success = true;
    Map<String, Offset> currentPositions = {};
    List<Rect> placedRects = [];

    // Attempt to place all planets at this font size
    for (String planet in planets) {
      textPainter.text = TextSpan(
        text: _getPlanetAbbreviation(planet),
        style: TextStyle(
          color: _getPlanetColor(planet),
          fontSize: currentFontSize,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      final textSize = textPainter.size;

      bool placed = false;
      Offset currentTryPos = centerPoint; // Start near centroid
      int attempts = 0;
      int maxAttempts = 100; // Limit attempts to prevent infinite loops

      while (attempts < maxAttempts) {
        // Calculate potential bounding box centered around currentTryPos
        // Adjust position slightly to center the text box
        final tryRect = Rect.fromCenter(
          center: currentTryPos, 
          width: textSize.width,
          height: textSize.height
        );

        // Check boundaries and collisions
        if (_isRectInsidePath(tryRect, housePath) && !_rectIntersectsWithList(tryRect, placedRects)) {
          // Success! Place the planet
          placedRects.add(tryRect);
          currentPositions[planet] = tryRect.topLeft; // Store top-left for drawing
          placed = true;
          break; // Exit adjustment loop, move to next planet
        }

        // Failure - Adjust position and try again
        attempts++;
        currentTryPos = _getNextTrialPosition(currentTryPos, centerPoint, attempts);
      }

      if (!placed) {
        // Failed to place this planet at currentFontSize
        success = false;
        break; // Exit the planet loop for this font size
      }
    }

    if (success) {
      // Successfully placed all planets at this font size
      finalFontSize = currentFontSize;
      finalPositions = currentPositions;
      break; // Exit the font size loop
    }
    // Otherwise, loop continues to try smaller font size
  }

  // If no font size worked, fallback (draw at minimum size, possibly overlapping)
  if (finalFontSize < 8.0) {
    finalFontSize = 8.0;
    // Simple fallback: place all at centroid (will overlap)
    planets.forEach((planet) { 
        textPainter.text = TextSpan(
          text: _getPlanetAbbreviation(planet),
          style: TextStyle(color: _getPlanetColor(planet), fontSize: finalFontSize, fontWeight: FontWeight.bold),
        );
        textPainter.layout();
        finalPositions[planet] = centerPoint.translate(-textPainter.width / 2, -textPainter.height/2);
     });
  }

  // Draw all planets at their final positions and font size
  finalPositions.forEach((planet, position) {
    textPainter.text = TextSpan(
      text: _getPlanetAbbreviation(planet),
      style: TextStyle(
        color: _getPlanetColor(planet),
        fontSize: finalFontSize,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  });
}

// Helper to check if a Rect overlaps with any in a list
bool _rectIntersectsWithList(Rect rect, List<Rect> others) {
  for (final otherRect in others) {
    if (rect.overlaps(otherRect)) {
      return true;
    }
  }
  return false;
}

// Helper to check if all 4 corners of a Rect are inside a Path
// NOTE: This is a basic check and might fail for complex paths/rects near edges.
// A more robust check might involve Path.combine or other geometry libraries.
bool _isRectInsidePath(Rect rect, Path path) {
  return path.contains(rect.topLeft) &&
         path.contains(rect.topRight) &&
         path.contains(rect.bottomLeft) &&
         path.contains(rect.bottomRight);
}

// Helper to find the next position to try (simple spiral out)
Offset _getNextTrialPosition(Offset currentPos, Offset center, int attempt) {
  // Simple spiral out logic (can be improved)
  double angle = attempt * 0.5; // Radians
  double radius = attempt * 1.2; // Increase radius with attempts
  return Offset(
    center.dx + cos(angle) * radius,
    center.dy + sin(angle) * radius,
  );
}

// Helper function to calculate the centroid of a Polygon given its vertices
Offset _calculateCentroid(List<Offset> vertices) {
  double signedArea = 0.0;
  double cx = 0.0;
  double cy = 0.0;
  int n = vertices.length;

  if (n < 3) return Offset.zero; // Cannot calculate centroid for lines or points

  for (int i = 0; i < n; i++) {
    final p1 = vertices[i];
    final p2 = vertices[(i + 1) % n]; // Wrap around for the last segment

    final double crossProduct = (p1.dx * p2.dy - p2.dx * p1.dy);
    signedArea += crossProduct;
    cx += (p1.dx + p2.dx) * crossProduct;
    cy += (p1.dy + p2.dy) * crossProduct;
  }

  signedArea /= 2.0;

  // Avoid division by zero for degenerate polygons (collinear points)
  if (signedArea.abs() < 1e-6) { 
      // Fallback: Average of vertices (not true centroid, but better than zero)
       if (n > 0) {
         double avgX = 0;
         double avgY = 0;
         for(var p in vertices) {
           avgX += p.dx;
           avgY += p.dy;
         }
         return Offset(avgX / n, avgY / n);
       }
       return Offset.zero; // Should not happen if n>=3
  }

  cx /= (6.0 * signedArea);
  cy /= (6.0 * signedArea);

  return Offset(cx, cy);
}
// --- End: New Planet Drawing Logic --- 

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
      return Constants.planetColors['Sun']!;
    case 'moon':
      return Constants.planetColors['Moon']!;
    case 'mars':
      return Constants.planetColors['Mars']!;
    case 'mercury':
      return Constants.planetColors['Mercury']!;
    case 'jupiter':
      return Constants.planetColors['Jupiter']!;
    case 'venus':
      return Constants.planetColors['Venus']!;
    case 'saturn':
      return Constants.planetColors['Saturn']!;
    case 'rahu':
      return Constants.planetColors['Rahu']!;
    case 'ketu':
      return Constants.planetColors['Ketu']!;
    default:
      return Colors.black;
  }
}
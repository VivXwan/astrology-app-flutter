import 'dart:math';
import 'dart:ui' as ui; // Import dart:ui for ParagraphBuilder
import 'package:flutter/material.dart';
import '../utils/constants.dart';

// --- Moved Helper Functions (Shared Logic) ---

// Helper to check if a Rect overlaps with any in a list
bool _rectIntersectsWithList(Rect rect, List<Rect> others) {
  for (final otherRect in others) {
    // Add a small buffer to prevent text touching
    if (rect.inflate(1.0).overlaps(otherRect.inflate(1.0))) {
      return true;
    }
  }
  return false;
}

// Helper to check if a Rect is fully contained within another Rect
bool _isRectInsideRect(Rect innerRect, Rect outerRect) {
  return outerRect.contains(innerRect.topLeft) &&
         outerRect.contains(innerRect.topRight) &&
         outerRect.contains(innerRect.bottomLeft) &&
         outerRect.contains(innerRect.bottomRight);
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

String _getPlanetAbbreviation(String planet) {
  // Ensure case-insensitivity and handle potential null from map lookup
  final lowerPlanet = planet.toLowerCase();
  const abbreviations = {
    'sun': 'Su',
    'moon': 'Mo',
    'mars': 'Ma',
    'mercury': 'Me',
    'jupiter': 'Ju',
    'venus': 'Ve',
    'saturn': 'Sa',
    'rahu': 'Ra',
    'ketu': 'Ke',
    'lagna': 'La', // Added Lagna just in case
  };
  // Safer default with uppercase and ensuring minimum length 2 if possible
  String defaultAbbr = planet.length >= 2 ? planet.substring(0, 2) : planet;
  return abbreviations[lowerPlanet] ?? defaultAbbr.toUpperCase();
}


Color _getPlanetColor(String planet) {
  // Use Constants map directly, handle potential null
  return Constants.planetColors[planet] ?? Colors.black;
}

// Helper function to calculate bounds from vertices (Used by North Indian)
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

// --- End Helper Functions ---


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
        _drawPlanetsInHouse(canvas, housePaths[house], houseVertices[house], planetsByHouse[house], planets);
      }
    }
  }

  @override
  bool shouldRepaint(covariant NorthIndianChartPainter oldDelegate) {
    return ascendantSign != oldDelegate.ascendantSign || planets != oldDelegate.planets;
  }
}

// --- Start: Modified Planet Drawing Logic for North Indian ---
// Function signature changed: Removed house int, uses allPlanetsData map directly
void _drawPlanetsInHouse(Canvas canvas, Path housePath, List<Offset> vertices, List<String> planetsInThisHouse, Map<String, dynamic> allPlanetsData) {
  if (planetsInThisHouse.isEmpty || vertices.length < 3) return;

  // Use TextPainter directly
   final textPainter = TextPainter(
     textDirection: TextDirection.ltr,
     textAlign: TextAlign.center,
   );


  final centroid = _calculateCentroid(vertices);
  // Fallback if centroid calculation fails or path is empty
  final fallbackCenter = _getBoundsFromVertices(vertices).center;
  final centerPoint = (centroid == Offset.zero && !fallbackCenter.dx.isNaN && !fallbackCenter.dy.isNaN)
                      ? fallbackCenter
                      : centroid;


  Map<String, Offset> finalPositions = {};
  double finalFontSize = 0.0;
  // Define padding around text
  const double textPadding = 1.0;


  // Loop through font sizes, largest to smallest
  // Adjusted max font size based on typical usage
  for (double currentFontSize = 14.0; currentFontSize >= 6.0; currentFontSize -= 0.5) {
    bool success = true;
    Map<String, Offset> currentPositions = {};
    List<Rect> placedRects = [];

    // Attempt to place all planets at this font size
    for (String planet in planetsInThisHouse) {
        final planetDetails = allPlanetsData[planet];
        if (planetDetails == null) continue;

           final bool isRetrograde = planetDetails['retrograde'] == 'yes';
           final String abbreviation = _getPlanetAbbreviation(planet);


        // --- Use TextPainter for size calculation ---
          textPainter.text = TextSpan(
          text: abbreviation, // Base abbreviation
            style: TextStyle(
            color: _getPlanetColor(planet),
            fontSize: currentFontSize,
              fontWeight: FontWeight.bold,
            ),
             children: isRetrograde ? <TextSpan>[
              TextSpan(
                text: ' (R)',
                style: TextStyle(
                fontSize: currentFontSize * 0.75, // Smaller font for (R)
                  fontWeight: FontWeight.normal,
                 ),
              )
            ] : null,
          );
          textPainter.layout();
        final textSize = textPainter.size;
        // --- End TextPainter size calculation ---


      bool placed = false;
      Offset currentTryPos = centerPoint; // Start near centroid
      int attempts = 0;
      int maxAttempts = 150; // Limit attempts, increased slightly

      while (attempts < maxAttempts) {
        // Calculate potential bounding box centered around currentTryPos, add padding
        final tryRect = Rect.fromCenter(
          center: currentTryPos,
          width: textSize.width + textPadding * 2, // Add padding
          height: textSize.height + textPadding * 2 // Add padding
        );


        // Check boundaries (using Path.contains for arbitrary shapes) and collisions
        if (housePath.contains(tryRect.center) && // Basic check: center must be inside
            _isRectInsidePathApprox(tryRect, housePath) && // Check corners approximately
            !_rectIntersectsWithList(tryRect, placedRects)) {

          // Success! Place the planet
          placedRects.add(tryRect);
          // Store top-left for drawing (adjusted for no padding)
          currentPositions[planet] = currentTryPos.translate(-textSize.width / 2, -textSize.height / 2);
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
   if (finalFontSize < 6.0) {
     finalFontSize = 6.0; // Use the minimum attempted size
     // Simple fallback: place all near centroid (will overlap, slight offset)
     int i = 0;
     planetsInThisHouse.forEach((planet) {
       final planetDetails = allPlanetsData[planet];
       if (planetDetails == null) return;
        final bool isRetrograde = planetDetails['retrograde'] == 'yes';
        final String abbreviation = _getPlanetAbbreviation(planet);

       // --- Use TextPainter for fallback size calculation ---
       textPainter.text = TextSpan(
         text: abbreviation, // Base abbreviation
         style: TextStyle(color: _getPlanetColor(planet), fontSize: finalFontSize, fontWeight: FontWeight.bold),
          children: isRetrograde ? <TextSpan>[
           TextSpan(
             text: ' (R)',
             style: TextStyle(fontSize: finalFontSize * 0.75, fontWeight: FontWeight.normal),
           )
         ] : null,
       );
       textPainter.layout();
       // --- End TextPainter size calculation ---
       // Apply a small offset based on index to reduce direct overlap
       final offset = Offset(i * 2.0 - (planetsInThisHouse.length -1), i * 2.0 - (planetsInThisHouse.length -1));
       finalPositions[planet] = centerPoint.translate(-textPainter.width / 2 + offset.dx, -textPainter.height / 2 + offset.dy);
       i++;
     });
   }


  // Draw all planets at their final positions and font size
  finalPositions.forEach((planet, position) {
     final planetDetails = allPlanetsData[planet];
     if (planetDetails == null) return;
      final bool isRetrograde = planetDetails['retrograde'] == 'yes';
      final String abbreviation = _getPlanetAbbreviation(planet);


      // --- Use TextPainter for final drawing ---
      textPainter.text = TextSpan(
        text: abbreviation, // Base abbreviation
        style: TextStyle(
          color: _getPlanetColor(planet),
          fontSize: finalFontSize,
          fontWeight: FontWeight.bold,
        ),
        children: isRetrograde ? <TextSpan>[
          TextSpan(
            text: ' (R)',
            style: TextStyle(
              fontSize: finalFontSize * 0.75, // Smaller font for (R)
              fontWeight: FontWeight.normal,
            ),
          )
        ] : null,
      );
      textPainter.layout();
      // Ensure position is valid before painting
       if (!position.dx.isNaN && !position.dy.isNaN) {
            textPainter.paint(canvas, position);
       } else {
            // Optionally log an error or draw at a default position
            print("Warning: Invalid position for planet $planet. Skipping draw.");
       }
      // --- End TextPainter final drawing ---
  });
}

// Helper to check if all 4 corners of a Rect are inside a Path
// NOTE: This is a basic check and might fail for complex paths/rects near edges.
bool _isRectInsidePathApprox(Rect rect, Path path) {
  // Check all four corners. For concave shapes, this might not be sufficient.
  return path.contains(rect.topLeft) &&
         path.contains(rect.topRight) &&
         path.contains(rect.bottomLeft) &&
         path.contains(rect.bottomRight);
        }
// --- End: Modified Planet Drawing Logic for North Indian ---



class SouthIndianChartPainter extends CustomPainter {
  final String ascendantSign;
  final Map<String, dynamic> planets;

  SouthIndianChartPainter({required this.ascendantSign, required this.planets});

  // REMOVED _paintPlanets function as its logic is replaced by _drawPlanetsInCell

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

    // Draw grid lines (simplified loop)
    for (int i = 1; i < 4; i++) {
        // Vertical lines
      canvas.drawLine(
            Offset(center.dx - 2 * cellWidth + i * cellWidth, center.dy - 2 * cellWidth),
            Offset(center.dx - 2 * cellWidth + i * cellWidth, center.dy + 2 * cellWidth),
            paint
      );
        // Horizontal lines
      canvas.drawLine(
            Offset(center.dx - 2 * cellWidth, center.dy - 2 * cellWidth + i * cellWidth),
            Offset(center.dx + 2 * cellWidth, center.dy - 2 * cellWidth + i * cellWidth),
            paint
      );
    }


    // Assign signs (fixed positions)
    // Keep sign names short for more space
    final signPositions = [
      [0, 0, 'Pis'], [1, 0, 'Ari'], [2, 0, 'Tau'], [3, 0, 'Gem'],
      [0, 1, 'Aqu'],                 [3, 1, 'Can'],
      [0, 2, 'Cap'],                 [3, 2, 'Leo'],
      [0, 3, 'Sag'], [1, 3, 'Sco'], [2, 3, 'Lib'], [3, 3, 'Vir']
    ];

     // Mapping for full sign names needed for house calculation
     const fullSignNames = {
       'Pis': 'Pisces', 'Ari': 'Aries', 'Tau': 'Taurus', 'Gem': 'Gemini',
       'Aqu': 'Aquarius', 'Can': 'Cancer',
       'Cap': 'Capricorn', 'Leo': 'Leo',
       'Sag': 'Sagittarius', 'Sco': 'Scorpio', 'Lib': 'Libra', 'Vir': 'Virgo'
     };


    // Calculate houses based on ascendant
    final ascendantIndex = Constants.zodiacSigns.indexOf(ascendantSign);
    final houseMap = <String, int>{};
    for (var i = 0; i < 12; i++) {
      // Use the full sign name for lookup in Constants.zodiacSigns
      houseMap[Constants.zodiacSigns[(ascendantIndex + i) % 12]] = i + 1;
    }


    // Group planets by sign (using full sign names from planet data)
     Map<String, List<String>> planetsBySign = {};
     this.planets.forEach((planet, details) {
       final sign = details['sign'] as String?; // Make nullable
       if (sign != null) {
         if (!planetsBySign.containsKey(sign)) {
           planetsBySign[sign] = [];
         }
         // Only add planet if it's not Lagna (often handled separately or implied)
         // if (planet.toLowerCase() != 'lagna') {
             planetsBySign[sign]!.add(planet);
         // }
       }
     });


    // Draw signs, houses, and planets cell by cell
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var pos in signPositions) {
      final x = pos[0] as int;
      final y = pos[1] as int;
      final signAbbr = pos[2] as String;
      final fullSign = fullSignNames[signAbbr] ?? ''; // Get full sign name
      final house = houseMap[fullSign] ?? 0;

      // Calculate cell boundaries
       final double left = center.dx - (2 - x) * cellWidth;
       final double top = center.dy - (2 - y) * cellWidth;
       final cellRect = Rect.fromLTWH(left, top, cellWidth, cellWidth);


      // Draw sign and house number
      final textSpan = TextSpan(
         // Use abbreviation for sign display
         text: '${house > 0 ? '${house}H' : ''}',
         style: TextStyle(
             color: Colors.black,
             fontSize: cellWidth * 0.12, // Adjust size as needed
             fontWeight: FontWeight.bold),
      );
      textPainter.text = textSpan;
       textPainter.layout(maxWidth: cellWidth - 10); // Ensure text fits horizontally
      textPainter.paint(
        canvas,
         // Position top-left within the cell, with small padding
         cellRect.topLeft.translate(5, 5),
      );


      // Get planets for this sign (using full name)
      final planetsInThisSign = planetsBySign[fullSign] ?? [];

      // Draw planets using the new dynamic placement function
      if (planetsInThisSign.isNotEmpty) {
        _drawPlanetsInCell(canvas, cellRect, planetsInThisSign, this.planets);
      }
    }
  }


  @override
  bool shouldRepaint(covariant SouthIndianChartPainter oldDelegate) {
    return ascendantSign != oldDelegate.ascendantSign || planets != oldDelegate.planets;
  }
}


// --- New Planet Drawing Logic for South Indian Cells ---
void _drawPlanetsInCell(Canvas canvas, Rect cellRect, List<String> planetsInThisSign, Map<String, dynamic> allPlanetsData) {
  if (planetsInThisSign.isEmpty) return;

   final textPainter = TextPainter(
     textDirection: TextDirection.ltr,
     textAlign: TextAlign.center,
   );

  // Calculate center of the cell for initial placement attempts
  final centerPoint = cellRect.center;

  Map<String, Offset> finalPositions = {};
  double finalFontSize = 0.0;
  const double textPadding = 1.0; // Padding around text for collision


  // Loop through font sizes, largest to smallest
  // Use slightly smaller max size for potentially smaller cells
  for (double currentFontSize = 14.0; currentFontSize >= 6.0; currentFontSize -= 0.5) {
    bool success = true;
    Map<String, Offset> currentPositions = {};
    List<Rect> placedRects = [];

    // Attempt to place all planets at this font size
    for (String planet in planetsInThisSign) {
        final planetDetails = allPlanetsData[planet];
        if (planetDetails == null) continue;

        final bool isRetrograde = planetDetails['retrograde'] == 'yes';
        final String abbreviation = _getPlanetAbbreviation(planet);

        // --- Use TextPainter for size calculation ---
        textPainter.text = TextSpan(
        text: abbreviation,
          style: TextStyle(
            color: _getPlanetColor(planet),
            fontSize: currentFontSize,
            fontWeight: FontWeight.bold,
          ),
           children: isRetrograde ? <TextSpan>[
            TextSpan(
              text: ' (R)',
              style: TextStyle(
              fontSize: currentFontSize * 0.75,
                fontWeight: FontWeight.normal,
              ),
            )
          ] : null,
        );
        textPainter.layout();
        final textSize = textPainter.size;
        // --- End TextPainter size calculation ---

      bool placed = false;
      Offset currentTryPos = centerPoint; // Start near cell center
      int attempts = 0;
      int maxAttempts = 150; // Limit attempts


      // Define the drawing area within the cell (add some padding)
       final EdgeInsets cellPadding = EdgeInsets.all(cellRect.shortestSide * 0.1); // 10% padding
       final Rect drawingArea = cellPadding.deflateRect(cellRect);


      while (attempts < maxAttempts) {
        // Calculate potential bounding box, add padding
        final tryRect = Rect.fromCenter(
          center: currentTryPos,
          width: textSize.width + textPadding * 2,
          height: textSize.height + textPadding * 2,
        );

        // Check boundaries (use drawingArea) and collisions
        if (_isRectInsideRect(tryRect, drawingArea) && !_rectIntersectsWithList(tryRect, placedRects)) {
          // Success! Place the planet
          placedRects.add(tryRect);
           // Store top-left for drawing (adjusted for no padding)
          currentPositions[planet] = currentTryPos.translate(-textSize.width / 2, -textSize.height / 2);
          placed = true;
          break; // Exit adjustment loop
        }

        // Failure - Adjust position
        attempts++;
        // Use a bounded random walk or improved spiral for better cell coverage
        // currentTryPos = _getNextTrialPosition(currentTryPos, centerPoint, attempts);
         currentTryPos = _getNextTrialPositionInRect(currentTryPos, drawingArea, attempts);
      }

      if (!placed) {
        success = false;
        break; // Exit planet loop for this font size
      }
    }

    if (success) {
      finalFontSize = currentFontSize;
      finalPositions = currentPositions;
      break; // Exit font size loop
    }
  }

  // Fallback if no placement worked
   if (finalFontSize < 6.0) {
     finalFontSize = 6.0; // Minimum size
     // Place near center with slight offset to reduce overlap
     int i = 0;
     planetsInThisSign.forEach((planet) {
       final planetDetails = allPlanetsData[planet];
       if (planetDetails == null) return;
        final bool isRetrograde = planetDetails['retrograde'] == 'yes';
        final String abbreviation = _getPlanetAbbreviation(planet);

       textPainter.text = TextSpan(
         text: abbreviation,
         style: TextStyle(color: _getPlanetColor(planet), fontSize: finalFontSize, fontWeight: FontWeight.bold),
          children: isRetrograde ? <TextSpan>[
           TextSpan(
             text: ' (R)',
             style: TextStyle(fontSize: finalFontSize * 0.75, fontWeight: FontWeight.normal),
           )
         ] : null,
       );
       textPainter.layout();

       final offset = Offset(i * 2.0 - (planetsInThisSign.length -1), i * 2.0 - (planetsInThisSign.length -1));
       final potentialPos = centerPoint.translate(-textPainter.width / 2 + offset.dx, -textPainter.height / 2 + offset.dy);

        // Clamp fallback position to be roughly within cell bounds
        final fallbackRect = Rect.fromCenter(center: potentialPos, width: textPainter.width, height: textPainter.height);
        double finalX = potentialPos.dx;
        double finalY = potentialPos.dy;

        if (fallbackRect.left < cellRect.left + 2) finalX = cellRect.left + 2;
        if (fallbackRect.right > cellRect.right - 2) finalX = cellRect.right - 2 - textPainter.width;
        if (fallbackRect.top < cellRect.top + 2) finalY = cellRect.top + 2;
        if (fallbackRect.bottom > cellRect.bottom - 2) finalY = cellRect.bottom - 2 - textPainter.height;

        finalPositions[planet] = Offset(finalX, finalY);

       i++;
     });
   }

  // Draw all planets
  finalPositions.forEach((planet, position) {
     final planetDetails = allPlanetsData[planet];
     if (planetDetails == null) return;
      final bool isRetrograde = planetDetails['retrograde'] == 'yes';
      final String abbreviation = _getPlanetAbbreviation(planet);

      textPainter.text = TextSpan(
      text: abbreviation,
        style: TextStyle(
          color: _getPlanetColor(planet),
          fontSize: finalFontSize,
          fontWeight: FontWeight.bold,
        ),
        children: isRetrograde ? <TextSpan>[
          TextSpan(
            text: ' (R)',
          style: TextStyle(fontSize: finalFontSize * 0.75, fontWeight: FontWeight.normal),
          )
        ] : null,
      );
      textPainter.layout();
     if (!position.dx.isNaN && !position.dy.isNaN) {
      textPainter.paint(canvas, position);
     } else {
         print("Warning: Invalid position for planet $planet in cell. Skipping draw.");
    }
  });
}


// Helper for trying positions within a Rect (improvement over simple spiral)
Offset _getNextTrialPositionInRect(Offset currentPos, Rect bounds, int attempt) {
  // Combine spiral out with clamping/wrapping within bounds
  final center = bounds.center;
  double angle = attempt * 0.618; // Use golden angle ratio for better distribution
  double radius = sqrt(attempt) * 2.0; // Increase radius slower

  Offset nextPos = Offset(
    center.dx + cos(angle) * radius,
    center.dy + sin(angle) * radius,
  );

  // Clamp position to stay within bounds
  return Offset(
    nextPos.dx.clamp(bounds.left, bounds.right),
    nextPos.dy.clamp(bounds.top, bounds.bottom),
  );
  }
// --- End: New Planet Drawing Logic for South Indian Cells ---
// ... delete existing helper functions below SouthIndianChartPainter ...
// delete _getPlanetAbbreviation and _getBoundsFromVertices here if they exist


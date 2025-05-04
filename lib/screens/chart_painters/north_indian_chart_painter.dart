import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/theme_extensions.dart';
import '../../utils/planet_utils.dart';
import '../../utils/constants.dart';
import 'base_chart_painter.dart';

/// North Indian style chart painter implementation
class NorthIndianChartPainter extends BaseChartPainter {
  NorthIndianChartPainter({
    required String ascendantSign,
    required PlanetDetailsMap planets,
    required ChartTheme chartTheme,
  }) : super(
    ascendantSign: ascendantSign,
    planets: planets,
    chartTheme: chartTheme,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = chartTheme.chartBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = chartTheme.chartBackgroundColor,
    );

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

    // Create the 12 house paths
    _createHousePaths(
      housePaths: housePaths,
      houseVertices: houseVertices,
      diamondVertices: diamondVertices,
      outerVertices: outerVertices,
      innerIntersections: innerIntersections,
      center: center
    );

    // Assign signs based on ascendant
    final ascendantIndex = Constants.zodiacSigns.indexOf(ascendantSign);
    final signNumbers = List.generate(12, (i) => (ascendantIndex + i) % 12 + 1);

    // Group planets by house
    final planetsByHouse = groupPlanetsByHouse();

    // Text painting setup
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw house numbers and signs
    _drawHouseNumbersAndSigns(
      canvas: canvas,
      textPainter: textPainter,
      housePaths: housePaths,
      houseVertices: houseVertices,
      innerIntersections: innerIntersections,
      center: center,
      radius: radius,
      signNumbers: signNumbers
    );

    // Draw planets in each house
    _drawPlanetsInHouses(
      canvas: canvas,
      planetsByHouse: planetsByHouse,
      housePaths: housePaths,
      houseVertices: houseVertices
    );
  }

  /// Creates the 12 house paths for the North Indian chart
  void _createHousePaths({
    required List<Path> housePaths,
    required List<List<Offset>> houseVertices,
    required List<Offset> diamondVertices,
    required List<Offset> outerVertices,
    required List<Offset> innerIntersections,
    required Offset center,
  }) {
    // House 1: Top Diamond
    List<Offset> h1Vertices = [
      diamondVertices[0], // Top
      innerIntersections[1], // Top-Right
      center, // Center
      innerIntersections[2], // Top-Left
    ];
    houseVertices.add(h1Vertices);
    housePaths.add(Path()..addPolygon(h1Vertices, true));
    
    // House 2: Top-Left Upper Triangle
    List<Offset> h2Vertices = [
      diamondVertices[0], // Top
      innerIntersections[2], // Top-Left
      outerVertices[3], // Top-Left Outer
    ];
    houseVertices.add(h2Vertices);
    housePaths.add(Path()..addPolygon(h2Vertices, true));
      
    // House 3: Top-Left Lower Triangle
    List<Offset> h3Vertices = [
      outerVertices[3], // Top-Left Outer
      diamondVertices[3], // Left
      innerIntersections[2], // Top-Left Inner
    ];
    houseVertices.add(h3Vertices);
    housePaths.add(Path()..addPolygon(h3Vertices, true));
      
    // House 4: Left Diamond
    List<Offset> h4Vertices = [
      diamondVertices[3], // Left
      innerIntersections[3], // Bottom-Left Inner
      center, // Center
      innerIntersections[2], // Top-Left Inner
    ];
    houseVertices.add(h4Vertices);
    housePaths.add(Path()..addPolygon(h4Vertices, true));

    // House 5: Bottom-Left Upper Triangle
    List<Offset> h5Vertices = [
      diamondVertices[3], // Left
      outerVertices[0], // Bottom-Left Outer
      innerIntersections[3], // Bottom-Left Inner
    ];
    houseVertices.add(h5Vertices);
    housePaths.add(Path()..addPolygon(h5Vertices, true));
      
    // House 6: Bottom-Left Lower Triangle
    List<Offset> h6Vertices = [
      outerVertices[0], // Bottom-Left Outer
      diamondVertices[2], // Bottom
      innerIntersections[3], // Bottom-Left Inner
    ];
    houseVertices.add(h6Vertices);
    housePaths.add(Path()..addPolygon(h6Vertices, true));

    // House 7: Bottom Diamond
    List<Offset> h7Vertices = [
      diamondVertices[2], // Bottom
      innerIntersections[3], // Bottom-Left Inner
      center, // Center
      innerIntersections[0], // Bottom-Right Inner
    ];
    houseVertices.add(h7Vertices);
    housePaths.add(Path()..addPolygon(h7Vertices, true));

    // House 8: Bottom-Right Lower Triangle
    List<Offset> h8Vertices = [
      diamondVertices[2], // Bottom
      innerIntersections[0], // Bottom-Right Inner
      outerVertices[1], // Bottom-Right Outer
    ];
    houseVertices.add(h8Vertices);
    housePaths.add(Path()..addPolygon(h8Vertices, true));
      
    // House 9: Bottom-Right Upper Triangle
    List<Offset> h9Vertices = [
      outerVertices[1], // Bottom-Right Outer
      diamondVertices[1], // Right
      innerIntersections[0], // Bottom-Right Inner
    ];
    houseVertices.add(h9Vertices);
    housePaths.add(Path()..addPolygon(h9Vertices, true));

    // House 10: Right Diamond
    List<Offset> h10Vertices = [
      diamondVertices[1], // Right
      innerIntersections[1], // Top-Right Inner
      center, // Center
      innerIntersections[0], // Bottom-Right Inner
    ];
    houseVertices.add(h10Vertices);
    housePaths.add(Path()..addPolygon(h10Vertices, true));

    // House 11: Top-Right Upper Triangle
    List<Offset> h11Vertices = [
      diamondVertices[1], // Right
      innerIntersections[1], // Top-Right Inner
      outerVertices[2], // Top-Right Outer
    ];
    houseVertices.add(h11Vertices);
    housePaths.add(Path()..addPolygon(h11Vertices, true));
      
    // House 12: Top-Right Lower Triangle
    List<Offset> h12Vertices = [
      outerVertices[2], // Top-Right Outer
      diamondVertices[0], // Top
      innerIntersections[1], // Top-Right Inner
    ];
    houseVertices.add(h12Vertices);
    housePaths.add(Path()..addPolygon(h12Vertices, true));
  }

  /// Draws house numbers and signs in the chart
  void _drawHouseNumbersAndSigns({
    required Canvas canvas,
    required TextPainter textPainter,
    required List<Path> housePaths,
    required List<List<Offset>> houseVertices,
    required List<Offset> innerIntersections,
    required Offset center,
    required double radius,
    required List<int> signNumbers,
  }) {
    // Fixed positions for house numbers
    final houseNumberPositions = [
      Offset(center.dx, center.dy - radius * 0.08), // House 1
      Offset(innerIntersections[2].dx, innerIntersections[2].dy - radius * 0.08), // House 2
      Offset(innerIntersections[2].dx - radius * 0.08, innerIntersections[2].dy), // House 3
      Offset(center.dx - radius * 0.08, center.dy), // House 4
      Offset(innerIntersections[3].dx - radius * 0.08, innerIntersections[3].dy), // House 5
      Offset(innerIntersections[3].dx, innerIntersections[3].dy + radius * 0.08), // House 6
      Offset(center.dx, center.dy + radius * 0.08), // House 7
      Offset(innerIntersections[0].dx, innerIntersections[0].dy + radius * 0.08), // House 8
      Offset(innerIntersections[0].dx + radius * 0.08, innerIntersections[0].dy), // House 9
      Offset(center.dx + radius * 0.08, center.dy), // House 10
      Offset(innerIntersections[1].dx + radius * 0.08, innerIntersections[1].dy), // House 11
      Offset(innerIntersections[1].dx, innerIntersections[1].dy - radius * 0.08), // House 12
    ];

    // Draw house numbers and sign numbers
    for (var house = 0; house < 12; house++) {
      final signNumber = signNumbers[house] - 1; // 0-based index for signs array
      final sign = signNumber + 1;

      // Draw sign number
      textPainter.text = TextSpan(
        text: '$sign',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: chartTheme.textColor,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        houseNumberPositions[house].translate(-textPainter.width / 2, -textPainter.height / 2),
      );
    }
  }

  /// Draws planets in their houses
  void _drawPlanetsInHouses({
    required Canvas canvas,
    required Map<int, List<String>> planetsByHouse,
    required List<Path> housePaths,
    required List<List<Offset>> houseVertices,
  }) {
    // Loop through each house
    for (int house = 1; house <= 12; house++) {
      if (!planetsByHouse.containsKey(house) || planetsByHouse[house]!.isEmpty) {
        continue; // Skip houses with no planets
      }

      final planetsInThisHouse = planetsByHouse[house]!;
      final housePath = housePaths[house - 1];
      final vertices = houseVertices[house - 1];

      // Calculate centroid for this house (starting position)
      final centerPoint = PlanetUtils.calculateCentroid(vertices);

      // Attempt planet placement with iterative font size reduction
      _placePlanetsInHouse(
        canvas: canvas,
        planetsInThisHouse: planetsInThisHouse,
        housePath: housePath,
        centerPoint: centerPoint,
      );
    }
  }

  /// Place planets within a house with collision detection
  void _placePlanetsInHouse({
    required Canvas canvas,
    required List<String> planetsInThisHouse,
    required Path housePath,
    required Offset centerPoint,
  }) {
    if (planetsInThisHouse.isEmpty) return;

    const double textPadding = 1.0; // Padding around text for collision detection
    Map<String, Offset> finalPositions = {};
    double finalFontSize = 0.0;

    // Try progressively smaller font sizes until all planets fit
    for (double currentFontSize = 14.0; currentFontSize >= 6.0; currentFontSize -= 0.5) {
      bool success = true;
      Map<String, Offset> currentPositions = {};
      List<Rect> placedRects = [];

      // Try to place each planet at this font size
      for (String planet in planetsInThisHouse) {
        bool isRetrograde = isPlanetRetrograde(planet);
        
        // Create text painter for this planet
        final textPainter = createPlanetTextPainter(planet, isRetrograde, currentFontSize);
        final textSize = textPainter.size;

        bool placed = false;
        Offset currentTryPos = centerPoint;
        int attempts = 0;
        const int maxAttempts = 150;

        // Try different positions until successful or max attempts reached
        while (attempts < maxAttempts && !placed) {
          final tryRect = Rect.fromCenter(
            center: currentTryPos,
            width: textSize.width + textPadding * 2,
            height: textSize.height + textPadding * 2
          );

          // Check if this position works
          if (housePath.contains(tryRect.center) && 
              PlanetUtils.isRectInsidePathApprox(tryRect, housePath) && 
              !PlanetUtils.rectIntersectsWithList(tryRect, placedRects)) {
            
            // Success - save this position
            placedRects.add(tryRect);
            currentPositions[planet] = currentTryPos.translate(-textSize.width / 2, -textSize.height / 2);
            placed = true;
            break;
          }

          // Try next position
          attempts++;
          currentTryPos = PlanetUtils.getNextTrialPosition(currentTryPos, centerPoint, attempts);
        }

        if (!placed) {
          // Failed to place this planet at current font size
          success = false;
          break;
        }
      }

      if (success) {
        // Successfully placed all planets at this font size
        finalFontSize = currentFontSize;
        finalPositions = currentPositions;
        break;
      }
    }

    // If no font size worked, use fallback approach
    if (finalFontSize < 6.0) {
      _placePlanetsFallback(
        canvas: canvas, 
        planetsInThisHouse: planetsInThisHouse, 
        centerPoint: centerPoint
      );
      return;
    }

    // Draw all planets at their final positions and font size
    finalPositions.forEach((planet, position) {
      bool isRetrograde = isPlanetRetrograde(planet);
      final textPainter = createPlanetTextPainter(planet, isRetrograde, finalFontSize);
      
      // Ensure position is valid before painting
      if (!position.dx.isNaN && !position.dy.isNaN) {
        textPainter.paint(canvas, position);
      }
    });
  }

  /// Fallback planet placement when normal algorithm fails
  void _placePlanetsFallback({
    required Canvas canvas, 
    required List<String> planetsInThisHouse, 
    required Offset centerPoint
  }) {
    // Use the minimum font size
    final double fontSize = 6.0;
    int i = 0;
    
    for (final planet in planetsInThisHouse) {
      bool isRetrograde = isPlanetRetrograde(planet);
      final textPainter = createPlanetTextPainter(planet, isRetrograde, fontSize);
      
      // Apply a small offset based on index to reduce direct overlap
      final offset = Offset(
        i * 2.0 - (planetsInThisHouse.length - 1), 
        i * 2.0 - (planetsInThisHouse.length - 1)
      );
      
      final position = centerPoint.translate(
        -textPainter.width / 2 + offset.dx, 
        -textPainter.height / 2 + offset.dy
      );
      
      // Paint the text
      textPainter.paint(canvas, position);
      i++;
    }
  }
} 
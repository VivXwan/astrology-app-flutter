import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/theme_extensions.dart';
import '../../utils/planet_utils.dart';
import '../../utils/constants.dart';
import 'base_chart_painter.dart';

/// South Indian style chart painter implementation
class SouthIndianChartPainter extends BaseChartPainter {
  SouthIndianChartPainter({
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

    final cellWidth = size.width / 4;
    final center = Offset(size.width / 2, size.height / 2);

    // Draw outer square
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size.width, height: size.width),
      paint,
    );

    // Draw grid lines (simplified loop)
    for (int i = 1; i < 4; i++) {
      if (i != 2) {
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
    else {
      // Vertical line
      canvas.drawLine(
        Offset(center.dx - 2 * cellWidth + i * cellWidth, center.dy - 2 * cellWidth),
        Offset(center.dx - 2 * cellWidth + i * cellWidth, center.dy - cellWidth),
        paint
      );
      // Vertical line
      canvas.drawLine(
        Offset(center.dx - 2 * cellWidth + i * cellWidth, center.dy + cellWidth),
        Offset(center.dx - 2 * cellWidth + i * cellWidth, center.dy + 2 * cellWidth),
        paint
      );
      // Horizontal line
      canvas.drawLine(
        Offset(center.dx - 2 * cellWidth, center.dy - 2 * cellWidth + i * cellWidth),
        Offset(center.dx - cellWidth, center.dy - 2 * cellWidth + i * cellWidth),
        paint
      );
      // Horizontal line
      canvas.drawLine(
        Offset(center.dx + cellWidth, center.dy - 2 * cellWidth + i * cellWidth),
        Offset(center.dx + 2 * cellWidth, center.dy - 2 * cellWidth + i * cellWidth),
        paint
      );
    }
    }

    // Sign positions in the South Indian chart grid
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

    // Group planets by sign
    Map<String, List<String>> planetsBySign = {};
    this.planets.forEach((planet, details) {
      final sign = details['sign'] as String?;
      if (sign != null) {
        if (!planetsBySign.containsKey(sign)) {
          planetsBySign[sign] = [];
        }
        planetsBySign[sign]!.add(planet);
      }
    });

    // Draw signs, houses, and planets cell by cell
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var pos in signPositions) {
      final x = pos[0] as int;
      final y = pos[1] as int;
      final signAbbr = pos[2] as String;
      final fullSign = fullSignNames[signAbbr] ?? '';
      final house = houseMap[fullSign] ?? 0;

      // Calculate cell boundaries
      final double left = center.dx - (2 - x) * cellWidth;
      final double top = center.dy - (2 - y) * cellWidth;
      final cellRect = Rect.fromLTWH(left, top, cellWidth, cellWidth);

      // Draw sign and house number
      _drawCellLabels(
        canvas: canvas,
        textPainter: textPainter,
        cellRect: cellRect,
        sign: signAbbr,
        house: house,
      );

      // Get planets for this sign and draw them
      final planetsInThisSign = planetsBySign[fullSign] ?? [];
      if (planetsInThisSign.isNotEmpty) {
        _drawPlanetsInCell(
          canvas: canvas,
          cellRect: cellRect,
          planetsInThisSign: planetsInThisSign,
        );
      }
    }
  }

  /// Draws the sign and house label in a cell
  void _drawCellLabels({
    required Canvas canvas,
    required TextPainter textPainter,
    required Rect cellRect,
    required String sign,
    required int house,
  }) {
    // Draw house number in top-left
    if (house > 0) {
      textPainter.text = TextSpan(
        text: '${house}H',
        style: TextStyle(
          color: chartTheme.textColor,
          fontSize: cellRect.width * 0.12,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout(maxWidth: cellRect.width - 10);
      textPainter.paint(
        canvas,
        // Position top-left within the cell, with small padding
        cellRect.topLeft.translate(5, 5),
      );
    }

    // Draw sign name in top-right
    textPainter.text = TextSpan(
      text: sign,
      style: TextStyle(
        color: chartTheme.textColor,
        fontSize: cellRect.width * 0.12,
        fontWeight: FontWeight.normal,
      ),
    );
    textPainter.layout(maxWidth: cellRect.width - 10);
    textPainter.paint(
      canvas,
      // Position top-right within the cell, with small padding
      Offset(
        cellRect.right - textPainter.width - 5,
        cellRect.top + 5,
      ),
    );
  }

  /// Draws planets in a cell with collision detection
  void _drawPlanetsInCell({
    required Canvas canvas,
    required Rect cellRect,
    required List<String> planetsInThisSign,
  }) {
    if (planetsInThisSign.isEmpty) return;

    const double textPadding = 1.0; // Padding around text for collision
    
    // Calculate center of the cell for initial placement attempts
    final centerPoint = cellRect.center;

    Map<String, Offset> finalPositions = {};
    double finalFontSize = 0.0;

    // Loop through font sizes, largest to smallest
    for (double currentFontSize = 14.0; currentFontSize >= 6.0; currentFontSize -= 0.5) {
      bool success = true;
      Map<String, Offset> currentPositions = {};
      List<Rect> placedRects = [];

      // Attempt to place all planets at this font size
      for (String planet in planetsInThisSign) {
        final bool isRetrograde = isPlanetRetrograde(planet);
        
        // Create text painter for this planet
        final textPainter = createPlanetTextPainter(planet, isRetrograde, currentFontSize);
        final textSize = textPainter.size;

        bool placed = false;
        Offset currentTryPos = centerPoint;
        int attempts = 0;
        const int maxAttempts = 150;

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
          if (PlanetUtils.isRectInsideRect(tryRect, drawingArea) && 
              !PlanetUtils.rectIntersectsWithList(tryRect, placedRects)) {
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
          currentTryPos = PlanetUtils.getNextTrialPositionInRect(currentTryPos, drawingArea, attempts);
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
      _placePlanetsFallback(
        canvas: canvas,
        planetsInThisSign: planetsInThisSign,
        cellRect: cellRect
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
    required List<String> planetsInThisSign,
    required Rect cellRect,
  }) {
    // Use the minimum font size
    final double fontSize = 6.0;
    final centerPoint = cellRect.center;
    int i = 0;
    
    for (final planet in planetsInThisSign) {
      bool isRetrograde = isPlanetRetrograde(planet);
      final textPainter = createPlanetTextPainter(planet, isRetrograde, fontSize);
      
      // Apply a small offset based on index to reduce direct overlap
      final offset = Offset(
        i * 2.0 - (planetsInThisSign.length - 1),
        i * 2.0 - (planetsInThisSign.length - 1)
      );
      
      final potentialPos = centerPoint.translate(
        -textPainter.width / 2 + offset.dx,
        -textPainter.height / 2 + offset.dy
      );
      
      // Clamp fallback position to be roughly within cell bounds
      double finalX = potentialPos.dx;
      double finalY = potentialPos.dy;
      
      if (finalX < cellRect.left + 2) finalX = cellRect.left + 2;
      if (finalX + textPainter.width > cellRect.right - 2) finalX = cellRect.right - 2 - textPainter.width;
      if (finalY < cellRect.top + 2) finalY = cellRect.top + 2;
      if (finalY + textPainter.height > cellRect.bottom - 2) finalY = cellRect.bottom - 2 - textPainter.height;
      
      // Paint the text
      textPainter.paint(canvas, Offset(finalX, finalY));
      i++;
    }
  }
} 
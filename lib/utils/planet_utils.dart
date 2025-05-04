import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/theme_extensions.dart';
import '../models/chart.dart';
import '../models/varga_chart.dart';

/// Utility class for planet-related functions and calculations
class PlanetUtils {
  /// Checks if a Rect overlaps with any in a list
  static bool rectIntersectsWithList(Rect rect, List<Rect> others) {
    for (final otherRect in others) {
      // Add a small buffer to prevent text touching
      if (rect.inflate(1.0).overlaps(otherRect.inflate(1.0))) {
        return true;
      }
    }
    return false;
  }

  /// Checks if a Rect is fully contained within another Rect
  static bool isRectInsideRect(Rect innerRect, Rect outerRect) {
    return outerRect.contains(innerRect.topLeft) &&
           outerRect.contains(innerRect.topRight) &&
           outerRect.contains(innerRect.bottomLeft) &&
           outerRect.contains(innerRect.bottomRight);
  }

  /// Checks if all 4 corners of a Rect are inside a Path (approximate)
  static bool isRectInsidePathApprox(Rect rect, Path path) {
    // Check all four corners. For concave shapes, this might not be sufficient.
    return path.contains(rect.topLeft) &&
           path.contains(rect.topRight) &&
           path.contains(rect.bottomLeft) &&
           path.contains(rect.bottomRight);
  }

  /// Finds the next position to try (simple spiral out)
  static Offset getNextTrialPosition(Offset currentPos, Offset center, int attempt) {
    // Simple spiral out logic (can be improved)
    double angle = attempt * 0.5; // Radians
    double radius = attempt * 1.2; // Increase radius with attempts
    return Offset(
      center.dx + cos(angle) * radius,
      center.dy + sin(angle) * radius,
    );
  }

  /// Finds the next position within a bounded rectangle (improved spiral)
  static Offset getNextTrialPositionInRect(Offset currentPos, Rect bounds, int attempt) {
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

  /// Calculates the centroid of a Polygon given its vertices
  static Offset calculateCentroid(List<Offset> vertices) {
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

  /// Gets planet abbreviation for display
  static String getPlanetAbbreviation(String planet) {
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

  /// Calculate bounds from vertices
  static Rect getBoundsFromVertices(List<Offset> vertices) {
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

  /// Calculates house number for a planet based on its sign and the ascendant sign
  static int calculateHouse(String planetSign, String ascendantSign) {
    // List of signs in order
    const List<String> signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer',
      'Leo', 'Virgo', 'Libra', 'Scorpio',
      'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    
    // Find indices
    final int ascendantIndex = signs.indexOf(ascendantSign);
    final int planetIndex = signs.indexOf(planetSign);
    
    if (ascendantIndex == -1 || planetIndex == -1) {
      return 1; // Default to 1st house if signs not found
    }
    
    // Calculate house (1-based)
    int house = (planetIndex - ascendantIndex + 1);
    if (house <= 0) house += 12;
    return house;
  }
} 
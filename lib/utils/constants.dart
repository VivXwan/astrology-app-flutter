import 'package:flutter/material.dart';

class Constants {
  // static const String apiBaseUrl = 'http://localhost:8000';
  static const String apiBaseUrl = 'http://192.168.1.10:8000';
  static const Map<String, Color> planetColors = {
    'Sun': Color(0xFFD37F00),
    'Moon': Color(0xFF5FBAE7),
    'Mars': Color(0xFFff0000),
    'Mercury': Color(0xFF4CAF50),
    'Jupiter': Color(0xFFFFC107),
    'Venus': Color(0xFFE91E63),
    'Saturn': Color(0xFF0B3950),
    'Rahu': Color(0xFF423C34),
    'Ketu': Color(0xFF423C34),
  };
  static const List<String> zodiacSigns = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];
}
import 'chart.dart';
import 'kundali_details.dart';

/// VargaPlanetDetails contains simplified information for a planet in a Varga chart
class VargaPlanetDetails {
  final String sign;
  final int house;
  final bool isRetrograde;

  const VargaPlanetDetails({
    required this.sign,
    required this.house,
    this.isRetrograde = false,
  });

  factory VargaPlanetDetails.fromJson(Map<String, dynamic> json, bool isRetrograde) {
    return VargaPlanetDetails(
      sign: json['sign'] as String,
      house: json['house'] as int,
      isRetrograde: isRetrograde,
    );
  }

  /// Create a Varga planet details from a D-1 planet details and varga sign
  factory VargaPlanetDetails.fromD1AndVarga(
    PlanetDetails d1PlanetDetails,
    String vargaSign,
    String vargaAscendantSign,
  ) {
    // Calculate the house based on the difference between the varga sign and ascendant
    final int vargaHouse = _calculateHouse(vargaSign, vargaAscendantSign);
    
    return VargaPlanetDetails(
      sign: vargaSign,
      house: vargaHouse,
      isRetrograde: d1PlanetDetails.isRetrograde,
    );
  }

  static int _calculateHouse(String planetSign, String ascendantSign) {
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VargaPlanetDetails &&
        other.sign == sign &&
        other.house == house &&
        other.isRetrograde == isRetrograde;
  }

  @override
  int get hashCode => sign.hashCode ^ house.hashCode ^ isRetrograde.hashCode;
}

/// VargaChart represents a divisional chart in Vedic astrology
class VargaChart {
  final ChartType chartType;
  final String ascendantSign;
  final Map<String, VargaPlanetDetails> planets;

  const VargaChart({
    required this.chartType,
    required this.ascendantSign,
    required this.planets,
  });

  /// Creates a VargaChart from the main chart and varga data
  factory VargaChart.fromChartAndVargaData(
    Chart mainChart,
    ChartType chartType,
    Map<String, dynamic> vargaData,
  ) {
    final String? vargaAscendantSign = vargaData['Lagna']?['sign'] as String?;
    
    if (vargaAscendantSign == null) {
      throw ArgumentError('Varga data is missing ascendant sign');
    }

    final Map<String, VargaPlanetDetails> vargaPlanets = {};
    
    // Process each planet
    for (final entry in mainChart.planets.entries) {
      final planetName = entry.key;
      final d1PlanetDetails = entry.value;
      
      // Get varga data for this planet
      final planetVargaInfo = vargaData[planetName] as Map<String, dynamic>?;
      
      if (planetVargaInfo != null) {
        final vargaSign = planetVargaInfo['sign'] as String?;
        
        if (vargaSign != null) {
          // Create VargaPlanetDetails
          vargaPlanets[planetName] = VargaPlanetDetails.fromD1AndVarga(
            d1PlanetDetails,
            vargaSign,
            vargaAscendantSign,
          );
        }
      }
    }

    return VargaChart(
      chartType: chartType,
      ascendantSign: vargaAscendantSign,
      planets: vargaPlanets,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VargaChart &&
        other.chartType == chartType &&
        other.ascendantSign == ascendantSign &&
        _mapEquals(other.planets, planets);
  }

  @override
  int get hashCode => chartType.hashCode ^ ascendantSign.hashCode ^ planets.hashCode;
  
  // Helper method to compare maps since Dart's mapEquals requires foundation.dart
  static bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    return a.entries.every((e) => b.containsKey(e.key) && b[e.key] == e.value);
  }
} 
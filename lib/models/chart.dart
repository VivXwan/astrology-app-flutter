import 'package:flutter/foundation.dart';
import 'kundali_details.dart';

/// Enum representing the different chart types in Vedic astrology
enum ChartType {
  d1('D-1', 'Rashi'),
  d2('D-2', 'Hora'),
  d3('D-3', 'Drekkana'),
  d7('D-7', 'Saptamsa'),
  d9('D-9', 'Navamsa'),
  d12('D-12', 'Dwadasamsa'),
  d30('D-30', 'Trimshamsa');

  final String code;
  final String name;
  const ChartType(this.code, this.name);

  static ChartType fromCode(String code) {
    return ChartType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => ChartType.d1,
    );
  }

  @override
  String toString() => '$code ($name)';
}

/// Enum representing the different chart styles
enum ChartStyle {
  northIndian('North Indian'),
  southIndian('South Indian');

  final String displayName;
  const ChartStyle(this.displayName);

  @override
  String toString() => displayName;
}

class Chart {
  final KundaliDetails kundali;
  final Map<String, dynamic> rawData;
  final Map<ChartType, Map<String, dynamic>>? vargaData;

  const Chart({
    required this.kundali,
    required this.rawData,
    this.vargaData,
  });

  factory Chart.fromJson(Map<String, dynamic> json) {
    final kundaliJson = json['kundali'] as Map<String, dynamic>;
    final kundali = KundaliDetails.fromJson(kundaliJson);

    // Parse varga data if available
    Map<ChartType, Map<String, dynamic>>? vargaData;
    if (json.containsKey('vargas')) {
      vargaData = {};
      final vargasJson = json['vargas'] as Map<String, dynamic>;
      for (final entry in vargasJson.entries) {
        final chartType = ChartType.fromCode(entry.key);
        vargaData[chartType] = entry.value as Map<String, dynamic>;
      }
    }

    return Chart(
      kundali: kundali,
      rawData: json,
      vargaData: vargaData,
    );
  }

  String get ascendantSign => kundali.ascendant.sign;
  Map<String, PlanetDetails> get planets => kundali.planets;

  // Helper method to get varga chart data for a specific chart type
  Map<String, dynamic>? getVargaDataForType(ChartType type) {
    return vargaData?[type];
  }

  // Helper to check if a specific varga chart type is available
  bool hasVargaData(ChartType type) {
    return vargaData != null && vargaData!.containsKey(type);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Chart &&
        other.kundali == kundali &&
        mapEquals(other.vargaData, vargaData);
  }

  @override
  int get hashCode => kundali.hashCode ^ (vargaData?.hashCode ?? 0);
}
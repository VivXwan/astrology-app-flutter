import 'package:flutter/material.dart';

class DashaPeriod {
  final String planet;
  final DateTime startDate;
  final DateTime endDate;
  final List<DashaPeriod>? antardashas;
  final List<DashaPeriod>? pratyantarDashas;

  DashaPeriod({
    required this.planet,
    required this.startDate,
    required this.endDate,
    this.antardashas,
    this.pratyantarDashas,
  });

  factory DashaPeriod.fromJson(Map<String, dynamic> json) {
    return DashaPeriod(
      planet: json['planet'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      antardashas: json['antardashas'] != null
          ? (json['antardashas'] as List)
              .map((e) => DashaPeriod.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      pratyantarDashas: json['pratyantar_dashas'] != null
          ? (json['pratyantar_dashas'] as List)
              .map((e) => DashaPeriod.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  // Helper method to calculate duration in years
  double get durationYears {
    return endDate.difference(startDate).inDays / 365.25;
  }
}

class DashaTimelineData {
  final List<DashaPeriod> mahaDashas;
  final DateTime startDate;
  final DateTime endDate;

  DashaTimelineData({
    required this.mahaDashas,
    required this.startDate,
    required this.endDate,
  });

  factory DashaTimelineData.fromJson(Map<String, dynamic> json) {
    final vimshottariDasha = json['vimshottari_dasha'] as List;
    final mahaDashas = vimshottariDasha
        .map((e) => DashaPeriod.fromJson(e as Map<String, dynamic>))
        .toList();

    // Calculate start and end dates
    final startDate = mahaDashas.first.startDate;
    final endDate = mahaDashas.last.endDate;

    return DashaTimelineData(
      mahaDashas: mahaDashas,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
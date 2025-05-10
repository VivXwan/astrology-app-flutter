class BirthData {
  final int year;
  final int month;
  final int day;
  final double hour;
  final double minute;
  final double second;
  final double latitude;
  final double longitude;
  // final double? timezoneOffset; // As per API spec, not in this particular response object

  BirthData({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.second,
    required this.latitude,
    required this.longitude,
    // this.timezoneOffset,
  });

  factory BirthData.fromJson(Map<String, dynamic> json) {
    return BirthData(
      year: json['year'] as int,
      month: json['month'] as int,
      day: json['day'] as int,
      hour: (json['hour'] as num).toDouble(),
      minute: (json['minute'] as num).toDouble(),
      second: (json['second'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      // timezoneOffset: (json['timezone_offset'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() { // Added for completeness, if needed for requests
    return {
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'minute': minute,
      'second': second,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class ChartSummary {
  final int chartId;
  final int? userId; // Nullable if anonymous
  final BirthData birthData;
  final String createdAt; // Consider DateTime for parsing
  final Map<String, dynamic>? result; // For GET /charts/{chart_id} full data

  ChartSummary({
    required this.chartId,
    this.userId,
    required this.birthData,
    required this.createdAt,
    this.result,
  });

  factory ChartSummary.fromJson(Map<String, dynamic> json) {
    return ChartSummary(
      chartId: json['chart_id'] as int,
      userId: json['user_id'] as int?,
      birthData: BirthData.fromJson(json['birth_data'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String,
      result: json['result'] as Map<String, dynamic>?,
    );
  }
} 
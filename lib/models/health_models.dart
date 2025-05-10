class HealthStatus {
  final String status;
  final String timestamp; // Consider DateTime for parsing in provider/service if needed
  final String version;

  HealthStatus({
    required this.status,
    required this.timestamp,
    required this.version,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      status: json['status'] as String? ?? 'unknown',
      timestamp: json['timestamp'] as String? ?? '',
      version: json['version'] as String? ?? '0.0.0',
    );
  }
} 
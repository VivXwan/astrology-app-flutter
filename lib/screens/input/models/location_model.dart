class LocationModel {
  final String name;
  final String displayName;
  final double? latitude;
  final double? longitude;

  const LocationModel({
    required this.name,
    String? displayName,
    this.latitude,
    this.longitude,
  }) : displayName = displayName ?? name;
} 
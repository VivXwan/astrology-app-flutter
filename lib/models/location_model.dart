class LocationModel {
  final String name;
  final String displayName;
  final double latitude;
  final double longitude;
  final Map<String, String> address;

  const LocationModel({
    String? name,
    String? displayName,
    required this.latitude,
    required this.longitude,
    required this.address,
  }) : 
    this.name = name ?? displayName ?? '',
    this.displayName = displayName ?? name ?? '';

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] as String?,
      displayName: json['display_name'] as String?,
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
      address: Map<String, String>.from(json['address'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'display_name': displayName,
      'lat': latitude,
      'lon': longitude,
      'address': address,
    };
  }
} 
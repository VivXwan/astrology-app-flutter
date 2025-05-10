// Individual geocode location item model
class GeocodeResponse {
  final double latitude;
  final double longitude;
  final String displayName;
  final String placeId;
  final String osmType;
  final String osmId;
  final String type;
  final String classType;
  final double importance;
  final Map<String, String> address;

  GeocodeResponse({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    required this.placeId,
    required this.osmType,
    required this.osmId,
    required this.type,
    required this.classType,
    required this.importance,
    required this.address,
  });

  factory GeocodeResponse.fromJson(Map<String, dynamic> json) {
    return GeocodeResponse(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      displayName: json['display_name'] as String? ?? '',
      placeId: json['place_id']?.toString() ?? '',
      osmType: json['osm_type'] as String? ?? '',
      osmId: json['osm_id']?.toString() ?? '',
      type: json['type'] as String? ?? '',
      classType: json['class_type'] as String? ?? '',
      importance: (json['importance'] as num?)?.toDouble() ?? 0.0,
      address: Map<String, String>.from(json['address'] as Map? ?? {}),
    );
  }
}

// Wrapper for the geocode API response
class GeocodeAPIResult {
  final List<GeocodeResponse> locations;
  final int totalResults;

  GeocodeAPIResult({required this.locations, required this.totalResults});

  factory GeocodeAPIResult.fromJson(Map<String, dynamic> json) {
    var list = json['locations'] as List? ?? [];
    List<GeocodeResponse> locationsList = list.map((i) => GeocodeResponse.fromJson(i as Map<String, dynamic>)).toList();
    return GeocodeAPIResult(
      locations: locationsList,
      totalResults: json['total_results'] as int? ?? 0,
    );
  }
} 
class LocationModel {
  final String name;
  final double? latitude;
  final double? longitude;

  const LocationModel({
    required this.name,
    this.latitude,
    this.longitude,
  });

  static const List<LocationModel> predefinedCities = [
    LocationModel(name: "Select a city"),
    LocationModel(name: "Delhi, India", latitude: 28.666944, longitude: 77.216944),
    LocationModel(name: "Mumbai, India", latitude: 19.0760, longitude: 72.8777),
    LocationModel(name: "Bangalore, India", latitude: 12.9716, longitude: 77.5946),
    LocationModel(name: "Kolkata, India", latitude: 22.5726, longitude: 88.3639),
    LocationModel(name: "Chennai, India", latitude: 13.0827, longitude: 80.2707),
    LocationModel(name: "New York, NY, USA", latitude: 40.7128, longitude: -74.0060),
    LocationModel(name: "London, UK", latitude: 51.5074, longitude: -0.1278),
    LocationModel(name: "Tokyo, Japan", latitude: 35.6762, longitude: 139.6503),
    LocationModel(name: "Sydney, Australia", latitude: -33.8688, longitude: 151.2093),
    LocationModel(name: "Paris, France", latitude: 48.8566, longitude: 2.3522),
    LocationModel(name: "Other"),
  ];
} 
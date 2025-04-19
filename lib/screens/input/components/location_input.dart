import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import '../models/location_model.dart';
import '../../../../services/api_service.dart';

class LocationInput extends StatefulWidget {
  final bool useManualInput;
  final Function(bool) onToggleManualInput;
  final Function(double, double) onLocationSelected;
  final Function(String) onError;

  const LocationInput({
    super.key,
    required this.useManualInput,
    required this.onToggleManualInput,
    required this.onLocationSelected,
    required this.onError,
  });

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  final _locationController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _locationController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if query matches a predefined city (case-insensitive)
      final matchedCity = LocationModel.predefinedCities.firstWhere(
        (city) => city.name.toLowerCase() == query.toLowerCase(),
        orElse: () => const LocationModel(name: ''),
      );

      if (matchedCity.name.isNotEmpty && matchedCity.latitude != null && matchedCity.longitude != null) {
        widget.onLocationSelected(matchedCity.latitude!, matchedCity.longitude!);
      } else {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final response = await apiService.geocode(query);
        widget.onLocationSelected(response.latitude, response.longitude);
      }
    } catch (e) {
      widget.onError('Error finding location: $e. Try manual input.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle between geocoding and manual input
        Row(
          children: [
            const Text('Manual Lat/Long Input'),
            Switch(
              value: widget.useManualInput,
              onChanged: (value) {
                widget.onToggleManualInput(value);
                _locationController.clear();
                _latitudeController.clear();
                _longitudeController.clear();
              },
            ),
          ],
        ),
        // Location input (autocomplete or manual)
        if (!widget.useManualInput)
          TypeAheadField<String>(
            suggestionsCallback: (pattern) async {
              if (pattern.isEmpty) return [];
              return LocationModel.predefinedCities
                  .where((city) => city.name.toLowerCase().contains(pattern.toLowerCase()))
                  .map((city) => city.name)
                  .toList();
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSelected: (suggestion) {
              _locationController.text = suggestion;
              _searchLocation(suggestion);
            },
            builder: (context, controller, focusNode) {
              _locationController.text = controller.text;
              return TextField(
                controller: _locationController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Place of Birth (e.g., Delhi, India)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _isLoading
                        ? null
                        : () {
                            final query = _locationController.text;
                            if (query.isNotEmpty) {
                              _searchLocation(query);
                            }
                          },
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _searchLocation(value);
                  }
                },
              );
            },
          )
        else
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final lat = double.tryParse(value ?? '');
                    if (lat == null || lat < -90 || lat > 90) {
                      return 'Enter a valid latitude (-90 to 90)';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final lat = double.tryParse(value);
                    final lon = double.tryParse(_longitudeController.text);
                    if (lat != null && lon != null) {
                      widget.onLocationSelected(lat, lon);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _longitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final lon = double.tryParse(value ?? '');
                    if (lon == null || lon < -180 || lon > 180) {
                      return 'Enter a valid longitude (-180 to 180)';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final lat = double.tryParse(_latitudeController.text);
                    final lon = double.tryParse(value);
                    if (lat != null && lon != null) {
                      widget.onLocationSelected(lat, lon);
                    }
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
} 
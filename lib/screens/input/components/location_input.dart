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
  final Function(String) onLocationQuery;

  const LocationInput({
    super.key,
    required this.useManualInput,
    required this.onToggleManualInput,
    required this.onLocationSelected,
    required this.onError,
    required this.onLocationQuery,
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
          TypeAheadField<GeocodeResponse>(
            suggestionsCallback: (pattern) async {
              if (pattern.isEmpty) return [];
              setState(() => _isLoading = true);
              try {
                print('Fetching suggestions for: $pattern'); // Debug print
                final apiService = Provider.of<ApiService>(context, listen: false);
                final responses = await apiService.geocode(pattern);
                print('Received ${responses.length} suggestions'); // Debug print
                
                // Debug print first suggestion's coordinates
                if (responses.isNotEmpty) {
                  print('First suggestion coordinates: ${responses.first.latitude}, ${responses.first.longitude}'); // Debug print
                }
                
                return responses;
              } catch (e) {
                print('Error fetching suggestions: $e'); // Debug print
                widget.onError('Error fetching locations: $e');
                return [];
              } finally {
                setState(() => _isLoading = false);
              }
            },
            builder: (context, controller, focusNode) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Place of Birth (e.g., Delhi, India)',
                  suffixIcon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : null,
                ),
                onChanged: (value) {
                  print('Location query updated: $value'); // Debug print
                  widget.onLocationQuery(value);
                },
              );
            },
            onSelected: (suggestion) {
              print('Location selected: ${suggestion.displayName}'); // Debug print
              print('Raw suggestion data: $suggestion'); // Debug print
              print('Coordinates selected: ${suggestion.latitude}, ${suggestion.longitude}'); // Debug print
              
              _locationController.text = suggestion.displayName;
              widget.onLocationQuery(suggestion.displayName);
              
              // Ensure coordinates are not 0,0 before updating
              if (suggestion.latitude != 0 || suggestion.longitude != 0) {
                print('Updating coordinates to: ${suggestion.latitude}, ${suggestion.longitude}'); // Debug print
                widget.onLocationSelected(suggestion.latitude, suggestion.longitude);
                
                // Update the manual input fields as well
                _latitudeController.text = suggestion.latitude.toString();
                _longitudeController.text = suggestion.longitude.toString();
              } else {
                print('Warning: Received 0,0 coordinates from suggestion'); // Debug print
              }
            },
            itemBuilder: (context, suggestion) {
              final address = suggestion.address;
              final city = address['city'] ?? address['town'] ?? address['village'] ?? '';
              final state = address['state'] ?? '';
              final country = address['country'] ?? '';
              final subtitle = [city, state, country].where((e) => e.isNotEmpty).join(', ');

              return ListTile(
                title: Text(suggestion.displayName),
                subtitle: Text(subtitle),
              );
            },
            emptyBuilder: (context) => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No locations found'),
            ),
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
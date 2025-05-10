import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../../models/location_model.dart';
import '../../../services/api_service.dart';
import 'package:provider/provider.dart';
import '../../../models/geocode_models.dart'; // Added for GeocodeResponse and GeocodeAPIResult

class LocationInput extends StatefulWidget {
  final bool useManualInput;
  final Function(bool) onToggleManualInput;
  final Function(double, double) onLocationSelected;
  final Function(String) onError;
  final Function(String) onLocationQuery;

  const LocationInput({
    Key? key,
    required this.useManualInput,
    required this.onToggleManualInput,
    required this.onLocationSelected,
    required this.onError,
    required this.onLocationQuery,
  }) : super(key: key);

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  LocationModel? _selectedCity;
  TextEditingController? _textEditingController;
  DateTime? _lastSelectionTime;
  
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  bool _validateCoordinates() {
    try {
      final latitude = double.parse(_latitudeController.text);
      final longitude = double.parse(_longitudeController.text);
      
      if (latitude < -90 || latitude > 90) {
        widget.onError("Latitude must be between -90 and 90 degrees");
        return false;
      }
      
      if (longitude < -180 || longitude > 180) {
        widget.onError("Longitude must be between -180 and 180 degrees");
        return false;
      }
      
      widget.onLocationSelected(latitude, longitude);
      return true;
    } catch (e) {
      widget.onError("Please enter valid numbers for coordinates");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Location', style: TextStyle(fontSize: 16)),
            Row(
              children: [
                Text('Manual Input'),
                Switch(
                  value: widget.useManualInput,
                  onChanged: (value) {
                    widget.onError('');
                    widget.onToggleManualInput(value);
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.useManualInput)
          Column(
            children: [
              TextField(
                controller: _latitudeController,
                decoration: InputDecoration(
                  labelText: 'Latitude (-90 to 90)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 37.7749',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),
                ],
                onChanged: (_) {
                  if (_latitudeController.text.isNotEmpty && 
                      _longitudeController.text.isNotEmpty) {
                    _validateCoordinates();
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _longitudeController,
                decoration: InputDecoration(
                  labelText: 'Longitude (-180 to 180)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. -122.4194',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),
                ],
                onChanged: (_) {
                  if (_latitudeController.text.isNotEmpty && 
                      _longitudeController.text.isNotEmpty) {
                    _validateCoordinates();
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the exact coordinates of the birth location.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          )
        else
          TypeAheadField<LocationModel>(
            builder: (context, controller, focusNode) {
              _textEditingController = controller;
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Search Location',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      setState(() {
                        _selectedCity = null;
                        _lastSelectionTime = null;
                      });
                    },
                  ),
                ),
              );
            },
            suggestionsCallback: (pattern) async {
              if (_lastSelectionTime != null) {
                final timeSinceSelection = DateTime.now().difference(_lastSelectionTime!);
                if (timeSinceSelection.inMilliseconds < 1500) {
                  return [];
                }
              }
              if (pattern.isEmpty || pattern.length < 2) {
                return [];
              }
              widget.onLocationQuery(pattern);
              try {
                final apiService = Provider.of<ApiService>(context, listen: false);
                final GeocodeAPIResult geocodeApiResult = await apiService.geocodeLocation(pattern);
                
                return geocodeApiResult.locations.map((geoRes) {
                  return LocationModel(
                    name: geoRes.address['city'] ?? geoRes.address['town'] ?? geoRes.address['village'] ?? geoRes.displayName.split(',').first,
                    displayName: geoRes.displayName,
                    latitude: geoRes.latitude,
                    longitude: geoRes.longitude,
                    address: geoRes.address,
                  );
                }).toList();
              } catch (e) {
                widget.onError(e.toString());
                return [];
              }
            },
            itemBuilder: (context, LocationModel suggestion) {
              return ListTile(
                title: Text(suggestion.displayName),
              );
            },
            onSelected: (LocationModel suggestion) {
              _lastSelectionTime = DateTime.now();
              setState(() {
                _selectedCity = suggestion;
              });
              widget.onLocationSelected(suggestion.latitude, suggestion.longitude);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (_textEditingController != null && mounted) {
                  _textEditingController!.text = suggestion.displayName;
                }
              });
            },
            hideOnSelect: true,
            debounceDuration: const Duration(milliseconds: 500),
            emptyBuilder: (context) => const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No locations found. Try a different query.'),
            ),
          ),
      ],
    );
  }
}
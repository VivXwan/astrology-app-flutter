import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../../models/location_model.dart';
import '../../../services/api_service.dart';
import 'package:provider/provider.dart';

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
  List<LocationModel> _searchResults = [];
  TextEditingController? _textEditingController;
  DateTime? _lastSelectionTime; // Timestamp of last selection instead of a boolean flag
  
  // Controllers for manual input fields
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  // Helper to validate coordinates
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
      
      // Valid coordinates, pass them to parent
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
                    // Clear any error messages when switching modes
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
          // Manual coordinate input fields
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
                  // Try to validate when both fields have values
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
                  // Try to validate when both fields have values
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
          // Location search functionality
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
                        _searchResults = [];
                        _lastSelectionTime = null; // Reset selection timestamp
                      });
                    },
                  ),
                ),
              );
            },
            suggestionsCallback: (pattern) async {
              print('🔍 suggestionsCallback called with pattern: $pattern');
              if (_lastSelectionTime != null) {
                final timeSinceSelection = DateTime.now().difference(_lastSelectionTime!);
                print('⏱ Time since last selection: ${timeSinceSelection.inMilliseconds}ms');
                
                // Block API calls if within debounce window (1.5 seconds)
                if (timeSinceSelection.inMilliseconds < 1500) {
                  print('🛑 Blocking API call - within debounce period');
                  return []; // Return empty list to hide dropdown
                }
              }
              
              if (pattern.isEmpty) {
                print('📝 Pattern empty, returning empty list');
                return [];
              }
              
              widget.onLocationQuery(pattern);
              try {
                print('🌐 Calling API with query: $pattern');
                final apiService = Provider.of<ApiService>(context, listen: false);
                final results = await apiService.searchLocation(pattern);
                setState(() {
                  _searchResults = results;
                });
                print('✅ API returned ${results.length} results');
                return results;
              } catch (e) {
                print('❌ API error: $e');
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
              print('🎯 Item selected: ${suggestion.displayName}');
              
              // Record selection timestamp immediately
              _lastSelectionTime = DateTime.now();
              print('🕒 Selection timestamp recorded: ${_lastSelectionTime}');
              
              setState(() {
                _selectedCity = suggestion;
              });
              
              widget.onLocationSelected(suggestion.latitude, suggestion.longitude);
              
              // Update the text field with a slight delay
              Future.delayed(Duration(milliseconds: 100), () {
                print('⏱ Updating text after 100ms');
                if (_textEditingController != null) {
                  print('📝 Setting text to: ${suggestion.displayName}');
                  _textEditingController!.text = suggestion.displayName;
                }
              });
            },
            hideOnSelect: true,
            hideOnEmpty: true,
            debounceDuration: Duration(milliseconds: 500),
            emptyBuilder: (context) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('No locations found'),
            ),
          ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
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
  final TextEditingController _typeAheadController = TextEditingController();
  LocationModel? _selectedCity;
  List<LocationModel> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text('Manual Input:'),
            Switch(
              value: widget.useManualInput,
              onChanged: widget.onToggleManualInput,
            ),
          ],
        ),
        if (!widget.useManualInput)
          TypeAheadField<LocationModel>(
            builder: (context, controller, focusNode) {
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
                      });
                    },
                  ),
                ),
              );
            },
            suggestionsCallback: (pattern) async {
              if (pattern.isEmpty) {
                return [];
              }
              widget.onLocationQuery(pattern);
              try {
                final apiService = Provider.of<ApiService>(context, listen: false);
                final results = await apiService.searchLocation(pattern);
                setState(() {
                  _searchResults = results;
                });
                return results;
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
              setState(() {
                _selectedCity = suggestion;
                _typeAheadController.text = suggestion.displayName;
              });
              widget.onLocationSelected(suggestion.latitude, suggestion.longitude);
            },
            debounceDuration: Duration(milliseconds: 500),
            hideOnEmpty: true,
            hideOnLoading: false,
            hideOnError: true,
            loadingBuilder: (context) => Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            ),
            errorBuilder: (context, error) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Error: $error',
                style: TextStyle(color: Colors.red),
              ),
            ),
            emptyBuilder: (context) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('No locations found'),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _typeAheadController.dispose();
    super.dispose();
  }
} 
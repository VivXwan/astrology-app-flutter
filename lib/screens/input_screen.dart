import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../services/api_service.dart';
import '../main.dart'; // For ChartProvider
import 'chart_screen.dart'; // To navigate to ChartScreen

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  double? _tzOffset;
  String? _locationQuery;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  String? _errorMessage;
  bool _useManualInput = false;

  // Predefined city list
  static const List<Map<String, dynamic>> predefinedCities = [
    {"name": "Select a city", "lat": null, "long": null},
    {"name": "Delhi, India", "lat": 28.666944, "long": 77.216944},
    {"name": "Mumbai, India", "lat": 19.0760, "long": 72.8777},
    {"name": "Bangalore, India", "lat": 12.9716, "long": 77.5946},
    {"name": "Kolkata, India", "lat": 22.5726, "long": 88.3639},
    {"name": "Chennai, India", "lat": 13.0827, "long": 80.2707},
    {"name": "New York, NY, USA", "lat": 40.7128, "long": -74.0060},
    {"name": "London, UK", "lat": 51.5074, "long": -0.1278},
    {"name": "Tokyo, Japan", "lat": 35.6762, "long": 139.6503},
    {"name": "Sydney, Australia", "lat": -33.8688, "long": 151.2093},
    {"name": "Paris, France", "lat": 48.8566, "long": 2.3522},
    {"name": "Other", "lat": null, "long": null},
  ];

  // Date picker
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Time picker (simplified, assuming time_picker_with_timezone provides a widget or method)
  Future<void> _pickTime(BuildContext context) async {
    // Note: time_picker_with_timezone is not a standard package, so this is a placeholder.
    // You'll need to replace this with the actual implementation based on the package API.
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        // Placeholder for timezone offset; replace with actual timezone picker logic
        _tzOffset = 5.5; // Example: IST offset
      });
    }
  }

  // Geocoding using the backend proxy
  Future<void> _searchLocation(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _latitude = null;
      _longitude = null;
    });
    try {
      // Check if query matches a predefined city (case-insensitive)
      final matchedCity = predefinedCities.firstWhere(
        (city) => city['name'].toLowerCase() == query.toLowerCase(),
        orElse: () => {},
      );
      if (matchedCity.isNotEmpty) {
        // Use predefined lat/long if found
        setState(() {
          _latitude = matchedCity['lat'] as double;
          _longitude = matchedCity['long'] as double;
          _locationQuery = query;
          print('Predefined location found: Lat: $_latitude, Long: $_longitude');
        });
      }
      else {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final response = await apiService.geocode(query);
        setState(() {
          _latitude = response.latitude;
          _longitude = response.longitude;
          _locationQuery = query;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error finding location: $e. Try manual input.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Form submission
  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Manually validate place of birth if not using manual input
    if (!_useManualInput) {
      final query = _locationController.text;
      if (query.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter a place of birth';
        });
        return;
      }
      _locationQuery = query; // Set _locationQuery manually
      if (_latitude == null || _longitude == null) {
        await _searchLocation(_locationQuery!);
      }
    }

      // Validate all fields
      if (_selectedDate == null || _selectedTime == null || _latitude == null || _longitude == null || _tzOffset == null) {
        setState(() {
          _errorMessage = 'Please fill all fields';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        print('Submitting chart request: Year: ${_selectedDate!.year}, '
            'Month: ${_selectedDate!.month}, Day: ${_selectedDate!.day}, '
            'Hour: ${_selectedTime!.hour}, Minute: ${_selectedTime!.minute}, '
            'Lat: $_latitude, Long: $_longitude, TZ: $_tzOffset'); // Debug log
        final provider = Provider.of<ChartProvider>(context, listen: false);
        await provider.fetchChart(
          year: _selectedDate!.year,
          month: _selectedDate!.month,
          day: _selectedDate!.day,
          hour: _selectedTime!.hour.toDouble(),
          minute: _selectedTime!.minute.toDouble(),
          latitude: _latitude!,
          longitude: _longitude!,
          tzOffset: _tzOffset!,
        );
        // Navigate to ChartScreen to display the chart
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChartScreen()),
        );
      } catch (e) {
        setState(() {
          _errorMessage = 'Error generating chart: $e';
          print('Chart fetch error: $e'); // Debug log
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Birth Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Date of Birth
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Select Date of Birth'
                      : 'Date: ${_selectedDate!.toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(context),
              ),
              // Time of Birth
              ListTile(
                title: Text(
                  _selectedTime == null
                      ? 'Select Time of Birth'
                      : 'Time: ${_selectedTime!.format(context)} (TZ: $_tzOffset)',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(context),
              ),
              // Toggle between geocoding and manual input
              Row(
                children: [
                  const Text('Manual Lat/Long Input'),
                  Switch(
                    value: _useManualInput,
                    onChanged: (value) {
                      setState(() {
                        _useManualInput = value;
                        _latitude = null;
                        _longitude = null;
                        _locationQuery = null;
                        _locationController.clear();
                        _latitudeController.clear();
                        _longitudeController.clear();
                        _errorMessage = null;
                      });
                    },
                  ),
                ],
              ),
              // Location input (autocomplete or manual)
              if (!_useManualInput)
                TypeAheadField<String>(
                  suggestionsCallback: (pattern) async {
                    if (pattern.isEmpty) return [];
                    return predefinedCities
                        .where((city) => city['name'].toLowerCase().contains(pattern.toLowerCase()))
                        .map((city) => city['name'] as String)
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
                    // Use the provided controller and focusNode to ensure suggestions box works
                    _locationController.text = controller.text; // Sync controller
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
                                    _locationQuery = query; // Manually set _locationQuery
                                    _searchLocation(query);
                                  }
                                },
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _locationQuery = value; // Manually set _locationQuery
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
                        onSaved: (value) {
                          _latitude = double.tryParse(value ?? '');
                        },
                        validator: (value) {
                          final lat = double.tryParse(value ?? '');
                          if (lat == null || lat < -90 || lat > 90) {
                            return 'Enter a valid latitude (-90 to 90)';
                          }
                          return null;
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
                        onSaved: (value) {
                          _longitude = double.tryParse(value ?? '');
                        },
                        validator: (value) {
                          final lon = double.tryParse(value ?? '');
                          if (lon == null || lon < -180 || lon > 180) {
                            return 'Enter a valid longitude (-180 to 180)';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Text(
                _latitude != null && _longitude != null
                    ? 'Lat: $_latitude, Long: $_longitude'
                    : 'No location selected',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              // Error message
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : () => _submitForm(context),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Generate Chart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
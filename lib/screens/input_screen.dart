import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // For ChartProvider and ApiService
import 'chart_screen.dart'; // To navigate to ChartScreen

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  double? _tzOffset;
  String? _locationQuery;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  String? _errorMessage;

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

  // Geocoding for location
  Future<void> _searchLocation(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
        print('Geocoding query: $query'); // Debug log
        List<Location> locations = await locationFromAddress(query);
        if (locations.isNotEmpty) {
            setState(() {
            _latitude = locations.first.latitude;
            _longitude = locations.first.longitude;
            _locationQuery = query;
            print('Location found: Lat: $_latitude, Long: $_longitude'); // Debug log
            });
        } else {
            setState(() {
            _errorMessage = 'Location not found';
            _latitude = null;
            _longitude = null;
            print('No locations found'); // Debug log
            });
        }
    } catch (e) {
        setState(() {
        _errorMessage = 'Error finding location: $e';
        _latitude = null;
        _longitude = null;
        print('Geocoding error: $e'); // Debug log
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

      // If location query is filled but lat/long are null, trigger geocoding
      if (_locationQuery != null && _locationQuery!.isNotEmpty && (_latitude == null || _longitude == null)) {
        await _searchLocation(_locationQuery!);
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
    _locationController.dispose(); // Dispose controller
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
              // Location
              TextFormField(
                controller: _locationController, // Add controller
                decoration: const InputDecoration(
                  labelText: 'Location (e.g., Delhi, India)',
                  suffixIcon: Icon(Icons.search),
                ),
                onSaved: (value) {
                  _locationQuery = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
                onFieldSubmitted: (value) {
                  _searchLocation(value);
                },
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
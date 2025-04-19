import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'input/components/date_time_input.dart';
import 'input/components/location_input.dart';
import 'input/services/input_service.dart';
import 'chart_screen.dart';
import '../providers/chart_provider.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  double? _tzOffset;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  String? _errorMessage;
  bool _useManualInput = false;

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _handleTimeSelected(TimeOfDay time, double tzOffset) {
    setState(() {
      _selectedTime = time;
      _tzOffset = tzOffset;
    });
  }

  void _handleLocationSelected(double latitude, double longitude) {
    setState(() {
      _latitude = latitude;
      _longitude = longitude;
    });
  }

  void _handleError(String error) {
    setState(() {
      _errorMessage = error;
    });
  }

  void _handleToggleManualInput(bool value) {
    setState(() {
      _useManualInput = value;
      _latitude = null;
      _longitude = null;
      _errorMessage = null;
    });
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

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
        final inputService = InputService(context);
        await inputService.generateChart(
          date: _selectedDate!,
          time: _selectedTime!,
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
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
              DateTimeInput(
                onDateSelected: _handleDateSelected,
                onTimeSelected: _handleTimeSelected,
                selectedDate: _selectedDate,
                selectedTime: _selectedTime,
                timezoneOffset: _tzOffset,
              ),
              const SizedBox(height: 16),
              LocationInput(
                useManualInput: _useManualInput,
                onToggleManualInput: _handleToggleManualInput,
                onLocationSelected: _handleLocationSelected,
                onError: _handleError,
              ),
              const SizedBox(height: 8),
              Text(
                _latitude != null && _longitude != null
                    ? 'Lat: $_latitude, Long: $_longitude'
                    : 'No location selected',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
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
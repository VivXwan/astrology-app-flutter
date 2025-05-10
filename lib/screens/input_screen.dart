import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chart_provider.dart';
import 'input/components/date_time_input.dart';
import 'input/components/location_input.dart';
import 'input/services/input_service.dart';
import '../widgets/auth/auth_container.dart';
import '../widgets/user_charts_list.dart';
import 'chart_screen.dart';
import '../widgets/app_settings.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  String? _errorMessage;
  bool _useManualInput = false;
  String _locationQuery = '';

  @override
  void initState() {
    super.initState();
    // Load user charts when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chartProvider = Provider.of<ChartProvider>(context, listen: false);
      
      if (authProvider.isAuthenticated) {
        chartProvider.loadUserCharts(context);
      }
    });
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _handleTimeSelected(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
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

  void _handleLocationQuery(String query) {
    setState(() {
      _locationQuery = query;
    });
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedDate == null || _selectedTime == null) {
        setState(() {
          _errorMessage = 'Please fill all date and time fields';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final inputService = InputService(context);
        double? currentLatitude = _latitude;
        double? currentLongitude = _longitude;

        if (!_useManualInput && (currentLatitude == null || currentLongitude == null)) {
          if (_locationQuery.isEmpty) {
            throw Exception('Please enter a location to search or input coordinates manually.');
          }
          final coordinates = await inputService.searchLocation(_locationQuery);
          if (coordinates != null) {
            currentLatitude = coordinates.$1;
            currentLongitude = coordinates.$2;
          } else {
            throw Exception('Location \"$_locationQuery\" not found. Please try a different query or enter coordinates manually.');
          }
        }
        
        if (currentLatitude == null || currentLongitude == null) {
          throw Exception('Coordinates are missing. Please select a location or enter them manually.');
        }

        await inputService.generateChart(
          date: _selectedDate!,
          time: _selectedTime!,
          latitude: currentLatitude,
          longitude: currentLongitude,
          locationQuery: (_latitude == null || _longitude == null) ? _locationQuery : null,
          context: context,
        );

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChartScreen()),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAuthDialog(BuildContext context) {
    // Clear any previous auth errors before showing the dialog
    // Provider.of<AuthProvider>(context, listen: false).clearError(); // AuthContainer already does this in initState
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use a Builder to get a context that is a descendant of the Dialog
        // This is important if LoginForm/RegisterForm need to pop the dialog
        return Builder(
          builder: (contextForDialog) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              // AlertDialog has its own padding, AuthContainer also has padding.
              // Consider wrapping AuthContainer in a SizedBox to control its size in dialog.
              content: SingleChildScrollView( // Important for smaller screens or if content overflows
                child: AuthContainer(), // AuthContainer will show login/register or welcome/logout
              ),
              // Optionally add actions like a close button if needed, though forms might handle it
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vedic Astrology'),
        actions: [
          IconButton(
            icon: Icon(
              authProvider.isAuthenticated 
                ? Icons.account_circle 
                : Icons.account_circle_outlined
            ),
            tooltip: authProvider.isAuthenticated 
              ? 'Account Info / Logout' 
              : 'Login / Register',
            onPressed: () {
              _showAuthDialog(context);
            },
          ),
          AppSettings.settingsButton(context),
        ],
      ),
      body: isSmallScreen 
          ? _buildVerticalLayout()
          : _buildHorizontalLayout(),
    );
  }

  Widget _buildVerticalLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBirthDetailsForm(),
            const UserChartsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildBirthDetailsForm(),
                const UserChartsList(),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
      ],
    );
  }

  Widget _buildBirthDetailsForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter Birth Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          DateTimeInput(
            onDateSelected: _handleDateSelected,
            onTimeSelected: _handleTimeSelected,
            selectedDate: _selectedDate,
            selectedTime: _selectedTime,
          ),
          const SizedBox(height: 16),
          LocationInput(
            useManualInput: _useManualInput,
            onToggleManualInput: _handleToggleManualInput,
            onLocationSelected: _handleLocationSelected,
            onError: _handleError,
            onLocationQuery: _handleLocationQuery,
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
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (!authProvider.isAuthenticated) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Login or create an account to save your charts',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

// Helper function to parse and simplify auth error messages
String _parseAuthErrorMessage(String? rawErrorMessage) {
  if (rawErrorMessage == null) return 'An unknown error occurred.';
  if (rawErrorMessage.contains('DioExceptionType.connectionError') || rawErrorMessage.contains('SocketException')) {
    return 'Could not connect to the server. Please check your internet connection and try again.';
  }
  if (rawErrorMessage.contains('422')) {
    if (rawErrorMessage.toLowerCase().contains('email')) {
      if (rawErrorMessage.toLowerCase().contains('already registered') || 
          rawErrorMessage.toLowerCase().contains('exists') || 
          rawErrorMessage.toLowerCase().contains('duplicate entry')) { // Common SQL error text
        return 'This email address is already registered. Please try logging in or use a different email.';
      }
      return 'The email address provided is not valid. Please check and try again.';
    }
    // Generic 422 for other validation issues
    return 'Registration failed. Please check the information you provided and try again. (Error 422)';
  }
  if (rawErrorMessage.contains('401')) {
    return 'Authentication failed. Please check your credentials.'; // More generic for 401
  }
  if (rawErrorMessage.contains('400')) {
    return 'Registration failed due to invalid data. Please review your entries. (Error 400)';
  }
  // For other errors, a more generic message but still hint it's from the server
  if (rawErrorMessage.contains('DioException')) {
      return 'A server communication error occurred. Please try again later.';
  }
  return 'An unexpected error occurred. Please try again.'; // Generic fallback
}

class RegisterForm extends StatefulWidget {
  final VoidCallback onToggleForm;
  
  const RegisterForm({
    Key? key,
    required this.onToggleForm,
  }) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }
  
  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }
  
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pop(); // Pop the dialog
        // Show a message prompting to log in. The AuthContainer will then show the login form.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please log in.')),
        );
        // widget.onToggleForm(); // Not calling this as dialog closes. User will click icon again.
      } else if (!success && mounted) { // Handle failure after attempting to sign up
        setState(() => _isLoading = false); // Keep dialog open to show error
        // Error message is displayed by the Text widget watching authProvider.errorMessage
        // Optionally, if authProvider.errorMessage is null but success is false, show a generic error
        if (authProvider.errorMessage == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration failed. Please try again.')),
            );
        }
      }
      // If !mounted, do nothing as widget is disposed.
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>(); // Listen for errors
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create Account',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: _togglePasswordVisibility,
              ),
            ),
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: _toggleConfirmPasswordVisibility,
              ),
            ),
            obscureText: _obscureConfirmPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 8),
          if (authProvider.errorMessage != null && !authProvider.isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                _parseAuthErrorMessage(authProvider.errorMessage),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Register', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isLoading ? null : widget.onToggleForm,
            child: const Text('Already have an account? Login'),
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_form.dart';
import 'register_form.dart';

class AuthContainer extends StatefulWidget {
  const AuthContainer({Key? key}) : super(key: key);

  @override
  State<AuthContainer> createState() => _AuthContainerState();
}

class _AuthContainerState extends State<AuthContainer> with SingleTickerProviderStateMixin {
  bool _showLogin = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
    // Clear any previous errors when the widget is initialized
    Provider.of<AuthProvider>(context, listen: false).clearError();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _toggleForm() {
    // Clear any existing error
    Provider.of<AuthProvider>(context, listen: false).clearError();
    
    // Animate out, then switch form, then animate in
    _animationController.reverse().then((_) {
      setState(() {
        _showLogin = !_showLogin;
      });
      _animationController.forward();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // If already logged in, show a welcome message and logout button
    if (authProvider.isAuthenticated) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome, ${authProvider.currentUser?.name ?? "User"}!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'You are logged in as ${authProvider.currentUser?.email ?? "your_email@example.com"}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: authProvider.isLoading 
              ? null 
              : () async {
                  await authProvider.signOut();
                  // After signing out, if the widget is still mounted (i.e., dialog is open),
                  // pop the dialog.
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white),
                  )
                : const Text('Logout'),
          ),
        ],
      );
    }
    
    // Otherwise show login or register form
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: _showLogin
            ? LoginForm(onToggleForm: _toggleForm)
            : RegisterForm(onToggleForm: _toggleForm),
      ),
    );
  }
} 
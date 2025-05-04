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
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome, ${authProvider.user?.name}!',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You are logged in as ${authProvider.user?.email}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: authProvider.isLoading ? null : () => authProvider.logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
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
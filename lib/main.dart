import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'screens/chart_screen.dart';
import 'screens/input_screen.dart';
import 'providers/chart_provider.dart';
import 'screens/input/services/input_service.dart';
import 'providers/kundali_provider.dart';
import 'providers/dasha_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'config/app_themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final apiService = ApiService(); // ApiService instance needed by AuthProvider
  final prefs = await SharedPreferences.getInstance(); // SharedPreferences instance

  // Removed old token loading logic. AuthProvider will handle this.
  // final userData = prefs.getString('userData');
  // if (userData != null) {
  //   try {
  //     final decodedData = json.decode(userData);
  //     if (decodedData['token'] != null) {
  //       final token = decodedData['token'] as String;
  //       print('Setting auth token from SharedPreferences: ${token.substring(0, min(20, token.length))}...');
  //       apiService.setAuthToken(token);
  //     }
  //   } catch (e) {
  //     print('Error loading auth token: $e');
  //   }
  // }
  
  runApp(
    MultiProvider(
      providers: [
        // ApiService provided first as AuthProvider depends on it.
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(prefs), // Pass prefs to ThemeProvider
        ),
        // AuthProvider depends on ApiService. It will attempt auto-login.
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<ApiService>()),
        ),
        // ChartProvider depends on ApiService and indirectly on AuthProvider for authenticated calls.
        ChangeNotifierProvider<ChartProvider>(
          create: (context) => ChartProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(create: (_) => KundaliProvider()),
        ChangeNotifierProvider(create: (_) => DashaProvider()),
        Provider<InputService>(
          create: (context) => InputService(context),
        ),
      ],
      child: const VedicAstrologyApp(),
    ),
  );
}

// int min(int a, int b) => a < b ? a : b; // Already exists or not needed if old token logic removed

class VedicAstrologyApp extends StatelessWidget {
  const VedicAstrologyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Vedic Astrology',
      // Use theme provider to determine current theme
      themeMode: themeProvider.themeMode,
      // Apply our configured themes
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      home: const InputScreen(),
      routes: {
        '/input': (context) => const InputScreen(),
        '/chart': (context) => const ChartScreen(),
      },
    );
  }
}
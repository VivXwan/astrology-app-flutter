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
import 'config/app_themes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider<ChartProvider>(create: (_) => ChartProvider()),
        ChangeNotifierProvider(create: (_) => KundaliProvider()),
        ChangeNotifierProvider(create: (_) => DashaProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<InputService>(
          create: (context) => InputService(context),
        ),
      ],
      child: const VedicAstrologyApp(),
    ),
  );
}

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
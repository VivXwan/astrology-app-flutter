import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'screens/chart_screen.dart';
import 'screens/input_screen.dart';
import 'providers/chart_provider.dart';
import 'screens/input/services/input_service.dart';
import 'providers/kundali_provider.dart';
import 'providers/dasha_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider<ChartProvider>(create: (_) => ChartProvider()),
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

class VedicAstrologyApp extends StatelessWidget {
  const VedicAstrologyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Vedic Astrology',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        ),
      home: const InputScreen(),
      routes: {
        '/input': (context) => const InputScreen(),
        '/chart': (context) => const ChartScreen(),
      },
    );
  }
}
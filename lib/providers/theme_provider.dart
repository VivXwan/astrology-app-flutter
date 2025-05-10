import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Theme mode with default as system
  ThemeMode _themeMode = ThemeMode.system;
  final SharedPreferences prefs; // Added field for injected SharedPreferences
  
  // Getter for current theme mode
  ThemeMode get themeMode => _themeMode;
  
  // Modified constructor to accept SharedPreferences instance
  ThemeProvider(this.prefs) {
    _loadThemeFromPrefs();
  }
  
  // Check if dark mode is active
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Get from system
      final brightness = WidgetsBinding.instance.window.platformBrightness;
      return brightness == Brightness.dark;
    }
    // Return explicit setting
    return _themeMode == ThemeMode.dark;
  }
  
  // Toggle between light and dark
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    _saveThemeToPrefs();
    notifyListeners();
  }
  
  // Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemeToPrefs();
    notifyListeners();
  }
  
  // Load theme preference from storage
  Future<void> _loadThemeFromPrefs() async {
    // Use the injected prefs instance
    // final prefs = await SharedPreferences.getInstance(); // Removed internal instance creation
    final themeModeIndex = prefs.getInt('theme_mode') ?? ThemeMode.system.index; // Default to system index
    if (themeModeIndex >= 0 && themeModeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeModeIndex];
    } else {
      _themeMode = ThemeMode.system; // Fallback if index is out of bounds
    }
    notifyListeners();
  }
  
  // Save theme preference to storage
  Future<void> _saveThemeToPrefs() async {
    // Use the injected prefs instance
    // final prefs = await SharedPreferences.getInstance(); // Removed internal instance creation
    await prefs.setInt('theme_mode', _themeMode.index);
  }
} 
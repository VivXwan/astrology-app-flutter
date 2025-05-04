import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Theme mode with default as system
  ThemeMode _themeMode = ThemeMode.system;
  
  // Getter for current theme mode
  ThemeMode get themeMode => _themeMode;
  
  // Constructor loads saved theme
  ThemeProvider() {
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
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('theme_mode') ?? 0; // Default system
    _themeMode = ThemeMode.values[themeModeIndex];
    notifyListeners();
  }
  
  // Save theme preference to storage
  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', _themeMode.index);
  }
} 
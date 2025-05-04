import 'package:flutter/material.dart';
import '../widgets/theme_switch.dart';

/// A utility class for app-wide settings functionality.
/// 
/// This class provides static methods to display a settings dialog
/// and a reusable settings button that can be used in any AppBar.
class AppSettings {
  /// Shows a settings dialog with various app configuration options.
  ///
  /// The dialog includes theme settings and placeholders for future settings.
  static void showSettingsDialog(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.settings, color: textColor, size: 24),
              const SizedBox(width: 10),
              Text('Settings', style: TextStyle(color: textColor)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme Settings Section
                Text(
                  'Theme',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dark Mode'),
                    ThemeSwitch(),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Future Settings Sections can be added here
                // Example placeholder for chart settings
                Text(
                  'Chart Settings',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Chart settings will be available in future updates'),
                
                // Additional settings sections would go here
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
  
  /// Returns a settings IconButton that can be used in any AppBar.
  ///
  /// This button will display the settings dialog when pressed.
  static Widget settingsButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      tooltip: 'Settings',
      onPressed: () => showSettingsDialog(context),
    );
  }
} 
import 'package:flutter/material.dart';
import 'dark_mode.dart';
import 'light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  // Initialize with system theme mode
  ThemeMode _themeMode = ThemeMode.system;

  // Getter for the current theme mode
  ThemeMode get themeMode => _themeMode;

  // This getter now properly respects the theme mode setting
  ThemeData get themeData {
    if (_themeMode == ThemeMode.system) {
      // Only check system brightness when in system mode
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark ? darkMode : lightMode;
    } else {
      // Otherwise use the explicitly set theme
      return _themeMode == ThemeMode.dark ? darkMode : lightMode;
    }
  }

  // Method to manually toggle theme
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Method to reset to system theme
  void useSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}
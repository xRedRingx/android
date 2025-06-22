import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isSystemMode => _themeMode == ThemeMode.system;
  bool get isInitialized => _isInitialized;

  // Get the current theme data based on theme mode and system brightness
  ThemeData getTheme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;

    switch (_themeMode) {
      case ThemeMode.light:
        AppTheme.setThemeMode(false);
        return AppTheme.lightTheme;
      case ThemeMode.dark:
        AppTheme.setThemeMode(true);
        return AppTheme.darkTheme;
      case ThemeMode.system:
        final isDark = brightness == Brightness.dark;
        AppTheme.setThemeMode(isDark);
        return isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
    }
  }

  // Initialize theme from shared preferences
  Future<void> initializeTheme() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeIndex = prefs.getInt('theme_mode') ?? 0;

      _themeMode = ThemeMode.values[savedThemeIndex];
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // Fallback to system theme if there's an error
      _themeMode = ThemeMode.system;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  // Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', mode.index);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  // Set theme to light
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  // Set theme to dark
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  // Set theme to system
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  // Check if current effective theme is dark (considering system theme)
  bool isCurrentlyDark(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;

    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return brightness == Brightness.dark;
    }
  }
}
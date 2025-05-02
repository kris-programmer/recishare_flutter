import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Holds the current theme mode (light or dark).
  ThemeMode _themeMode = ThemeMode.light;

  // Getter to access the current theme mode.
  ThemeMode get themeMode => _themeMode;

  // Constructor to initialize the theme provider and load the saved theme.
  ThemeProvider() {
    _loadThemeFromPreferences();
  }

  // Toggles the theme between light and dark modes.
  void toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify listeners about the theme change.
    await _saveThemeToPreferences(); // Save the updated theme to preferences.
  }

  // Loads the saved theme mode from shared preferences.
  Future<void> _loadThemeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify listeners after loading the theme.
  }

  // Saves the current theme mode to shared preferences.
  Future<void> _saveThemeToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
  }

  // Public method to explicitly load the theme from preferences.
  Future<void> loadTheme() async {
    await _loadThemeFromPreferences();
  }
}

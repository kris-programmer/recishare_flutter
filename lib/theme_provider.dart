import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeFromPreferences();
  }

  void toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _saveThemeToPreferences();
  }

  Future<void> _loadThemeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> _saveThemeToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
  }

  Future<void> loadTheme() async {
    await _loadThemeFromPreferences();
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ThemeProvider manages whether the app is in dark mode or light mode.
// It works exactly like CartProvider and AuthProvider — it extends ChangeNotifier
// so any widget that listens to it will rebuild when the theme changes.
class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  // Public getter — any widget can read this
  bool get isDark => _isDark;

  // Flutter's MaterialApp uses ThemeMode to decide which theme to show.
  // ThemeMode.light  → always use the light theme
  // ThemeMode.dark   → always use the dark theme
  // ThemeMode.system → follow the phone's system setting
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  // Constructor — loads the saved preference as soon as the provider is created.
  // This means on every app start, the last chosen theme is automatically restored.
  ThemeProvider() {
    _loadTheme();
  }

  // Reads the saved 'is_dark' boolean from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('is_dark') ?? false; // default: light mode
    notifyListeners(); // rebuild any widgets that are listening
  }

  // Called when the user flips the dark mode switch in Profile screen
  Future<void> toggleTheme() async {
    _isDark = !_isDark; // flip the value
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark', _isDark); // save to local storage
    notifyListeners(); // 🔔 tell all widgets: theme has changed, rebuild!
  }
}

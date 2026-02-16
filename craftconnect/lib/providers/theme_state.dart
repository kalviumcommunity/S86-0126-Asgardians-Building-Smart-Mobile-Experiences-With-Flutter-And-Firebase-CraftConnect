import 'package:flutter/material.dart';

/// Theme state for managing app-wide theme settings
/// Demonstrates global state management
class ThemeState with ChangeNotifier {
  bool _isDarkMode = false;
  Color _primaryColor = Colors.teal;

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;

  ThemeData get themeData {
    return ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      primarySwatch: _primaryColor as MaterialColor? ?? Colors.teal,
      scaffoldBackgroundColor: _isDarkMode 
          ? Colors.grey.shade900 
          : _primaryColor.shade50,
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
    );
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }
}

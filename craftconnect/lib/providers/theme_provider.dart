import 'package:flutter/material.dart';
import '../services/theme_service.dart';

/// Theme provider that manages the app's theme mode state
/// Handles theme switching and persistence via ThemeService
class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService = ThemeService();
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDynamicColorEnabled = true;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isLight => _themeMode == ThemeMode.light;
  bool get isSystem => _themeMode == ThemeMode.system;
  bool get isDynamicColorEnabled => _isDynamicColorEnabled;

  /// Initialize theme from saved preferences
  Future<void> initializeTheme() async {
    try {
      final savedTheme = await _themeService.getThemeMode();
      final savedDynamicColor = await _themeService.isDynamicColorEnabled();

      _themeMode = savedTheme;
      _isDynamicColorEnabled = savedDynamicColor;

      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing theme: $e');
      // Fallback to system theme if initialization fails
      _themeMode = ThemeMode.system;
      _isDynamicColorEnabled = true;
    }
  }

  /// Toggle between light and dark mode
  /// Does not affect system mode
  Future<void> toggleTheme(bool isDark) async {
    try {
      final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
      await _setThemeMode(newMode);
    } catch (e) {
      debugPrint('Error toggling theme: $e');
    }
  }

  /// Set theme mode explicitly
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      await _setThemeMode(mode);
    } catch (e) {
      debugPrint('Error setting theme mode: $e');
    }
  }

  /// Set light theme
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Set dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Set system theme (follows device preference)
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Enable/disable dynamic color (Material You)
  Future<void> setDynamicColorEnabled(bool enabled) async {
    try {
      _isDynamicColorEnabled = enabled;
      await _themeService.setDynamicColorEnabled(enabled);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting dynamic color: $e');
    }
  }

  /// Toggle dynamic color support
  Future<void> toggleDynamicColor() async {
    await setDynamicColorEnabled(!_isDynamicColorEnabled);
  }

  /// Reset theme to system default
  Future<void> resetToDefault() async {
    await setThemeMode(ThemeMode.system);
    await setDynamicColorEnabled(true);
  }

  /// Private method to set theme mode and persist it
  Future<void> _setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return; // No change needed

    _themeMode = mode;
    await _themeService.setThemeMode(mode);
    notifyListeners();
  }

  /// Get theme name as string (for UI display)
  String get currentThemeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Get theme description (for accessibility)
  String get currentThemeDescription {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light theme with bright colors';
      case ThemeMode.dark:
        return 'Dark theme for low-light environments';
      case ThemeMode.system:
        return 'Follows device theme preference';
    }
  }

  /// Check if current theme matches the given mode
  bool isCurrentTheme(ThemeMode mode) => _themeMode == mode;

  /// Get icon for current theme mode
  IconData get currentThemeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

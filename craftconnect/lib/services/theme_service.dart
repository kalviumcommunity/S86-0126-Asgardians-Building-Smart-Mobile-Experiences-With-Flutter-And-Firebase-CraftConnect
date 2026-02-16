import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting theme preferences using SharedPreferences
/// Handles saving and loading theme mode and related settings
class ThemeService {
  // SharedPreferences keys
  static const String _themeModeKey = 'theme_mode';
  static const String _dynamicColorKey = 'dynamic_color_enabled';

  // Theme mode constants for storage
  static const String _lightMode = 'light';
  static const String _darkMode = 'dark';
  static const String _systemMode = 'system';

  /// Get the saved theme mode from SharedPreferences
  /// Returns ThemeMode.system as default if no preference is saved
  Future<ThemeMode> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_themeModeKey);

      return _stringToThemeMode(themeString);
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
      return ThemeMode.system; // Fallback to system theme
    }
  }

  /// Save the theme mode to SharedPreferences
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = _themeModeToString(mode);
      await prefs.setString(_themeModeKey, themeString);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  /// Get dynamic color preference from SharedPreferences
  /// Returns true as default (dynamic color enabled)
  Future<bool> isDynamicColorEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_dynamicColorKey) ?? true;
    } catch (e) {
      debugPrint('Error loading dynamic color preference: $e');
      return true; // Fallback to enabled
    }
  }

  /// Save dynamic color preference to SharedPreferences
  Future<void> setDynamicColorEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_dynamicColorKey, enabled);
    } catch (e) {
      debugPrint('Error saving dynamic color preference: $e');
    }
  }

  /// Clear all theme preferences
  Future<void> clearThemePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeModeKey);
      await prefs.remove(_dynamicColorKey);
    } catch (e) {
      debugPrint('Error clearing theme preferences: $e');
    }
  }

  /// Check if theme preferences exist
  Future<bool> hasThemePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_themeModeKey);
    } catch (e) {
      debugPrint('Error checking theme preferences: $e');
      return false;
    }
  }

  /// Get all theme settings as a map (useful for debugging or export)
  Future<Map<String, dynamic>> getThemeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'theme_mode': prefs.getString(_themeModeKey) ?? _systemMode,
        'dynamic_color_enabled': prefs.getBool(_dynamicColorKey) ?? true,
        'has_preferences': prefs.containsKey(_themeModeKey),
      };
    } catch (e) {
      debugPrint('Error getting theme settings: $e');
      return {
        'theme_mode': _systemMode,
        'dynamic_color_enabled': true,
        'has_preferences': false,
        'error': e.toString(),
      };
    }
  }

  /// Convert string to ThemeMode enum
  ThemeMode _stringToThemeMode(String? themeString) {
    switch (themeString) {
      case _lightMode:
        return ThemeMode.light;
      case _darkMode:
        return ThemeMode.dark;
      case _systemMode:
      default:
        return ThemeMode.system;
    }
  }

  /// Convert ThemeMode enum to string
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return _lightMode;
      case ThemeMode.dark:
        return _darkMode;
      case ThemeMode.system:
        return _systemMode;
    }
  }

  /// Migrate old theme preferences (if needed for backward compatibility)
  Future<void> migrateOldPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check for old boolean-based theme preference
      if (prefs.containsKey('isDarkMode')) {
        final oldIsDark = prefs.getBool('isDarkMode') ?? false;
        final newMode = oldIsDark ? ThemeMode.dark : ThemeMode.light;

        await setThemeMode(newMode);
        await prefs.remove('isDarkMode'); // Remove old preference

        debugPrint('Migrated old theme preference: $oldIsDark -> $newMode');
      }
    } catch (e) {
      debugPrint('Error migrating old theme preferences: $e');
    }
  }

  /// Reset to default theme settings
  Future<void> resetToDefaults() async {
    await setThemeMode(ThemeMode.system);
    await setDynamicColorEnabled(true);
  }
}

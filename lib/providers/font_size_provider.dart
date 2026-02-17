import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeProvider with ChangeNotifier {
  static const String _fontSizeKey = 'font_size_scale';
  double _fontScale = 1.0;
  bool _isLoading = true;

  double get fontScale => _fontScale;
  bool get isLoading => _isLoading;

  FontSizeProvider() {
    _loadFontScale();
  }

  Future<void> _loadFontScale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _fontScale = prefs.getDouble(_fontSizeKey) ?? 1.0;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setFontScale(double scale) async {
    if (scale < 0.8 || scale > 2.0) return;

    _fontScale = scale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_fontSizeKey, scale);
    } catch (e) {
      debugPrint('Error saving font scale: $e');
    }
  }

  Future<void> increaseFontSize() async {
    if (_fontScale < 2.0) {
      await setFontScale(_fontScale + 0.1);
    }
  }

  Future<void> decreaseFontSize() async {
    if (_fontScale > 0.8) {
      await setFontScale(_fontScale - 0.1);
    }
  }

  Future<void> resetFontSize() async {
    await setFontScale(1.0);
  }

  String getFontSizeLabel() {
    if (_fontScale <= 0.9) return 'Small';
    if (_fontScale <= 1.1) return 'Normal';
    if (_fontScale <= 1.4) return 'Large';
    return 'Extra Large';
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product_model.dart';

class RecentlyViewedProvider extends ChangeNotifier {
  List<ProductModel> _recentlyViewed = [];
  static const String _storageKey = 'recently_viewed_products';
  static const int _maxRecentItems = 20;

  List<ProductModel> get recentlyViewed => _recentlyViewed;

  /// Add product to recently viewed
  Future<void> addProduct(ProductModel product) async {
    // Remove if already exists to avoid duplicates
    _recentlyViewed.removeWhere((p) => p.productId == product.productId);

    // Add to beginning of list
    _recentlyViewed.insert(0, product);

    // Keep only last N items
    if (_recentlyViewed.length > _maxRecentItems) {
      _recentlyViewed = _recentlyViewed.take(_maxRecentItems).toList();
    }

    await _saveToStorage();
    notifyListeners();
  }

  /// Load recently viewed from local storage
  Future<void> loadRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);

      if (jsonStr != null) {
        final List<dynamic> jsonList = json.decode(jsonStr);
        _recentlyViewed = jsonList
            .map((item) => ProductModel.fromMap(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      // Error loading recently viewed - ignore
      _recentlyViewed = [];
    }
  }

  /// Save to local storage
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _recentlyViewed.map((p) => p.toMap()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      // Error saving - ignore
    }
  }

  /// Clear recently viewed
  Future<void> clearAll() async {
    _recentlyViewed = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }

  /// Remove single product
  Future<void> removeProduct(String productId) async {
    _recentlyViewed.removeWhere((p) => p.productId == productId);
    await _saveToStorage();
    notifyListeners();
  }
}

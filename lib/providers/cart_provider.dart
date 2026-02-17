import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItemModel> _items = [];
  static const String _storageKey = 'cart_items';

  CartProvider() {
    _initProvider();
  }

  Future<void> _initProvider() async {
    await _loadFromPrefs();
  }

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(_items.map((i) => i.toJson()).toList());
      await prefs.setString(_storageKey, cartJson);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_storageKey);
      if (cartJson != null) {
        final List<dynamic> decoded = json.decode(cartJson);
        _items.clear();
        _items.addAll(decoded.map((i) => CartItemModel.fromJson(i)).toList());
        Future.microtask(() => notifyListeners());
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  void addItem({
    required String productId,
    required String productName,
    required String imageUrl,
    required double price,
    required String artisanId,
    required String shopId,
  }) {
    final existingIndex =
        _items.indexWhere((item) => item.productId == productId);

    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + 1,
      );
    } else {
      _items.add(
        CartItemModel(
          productId: productId,
          productName: productName,
          imageUrl: imageUrl,
          price: price,
          quantity: 1,
          artisanId: artisanId,
          shopId: shopId,
        ),
      );
    }
    _saveToPrefs();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    _saveToPrefs();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      _saveToPrefs();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _saveToPrefs();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  int getQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItemModel(
        productId: '',
        productName: '',
        imageUrl: '',
        price: 0,
        quantity: 0,
        artisanId: '',
        shopId: '',
      ),
    );
    return item.quantity;
  }
}

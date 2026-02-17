import 'package:flutter/material.dart';
import '../models/product_model.dart';

class WishlistProvider with ChangeNotifier {
  final List<ProductModel> _wishlistItems = [];

  List<ProductModel> get wishlistItems => _wishlistItems;

  bool isInWishlist(String productId) {
    return _wishlistItems.any((item) => item.productId == productId);
  }

  void addToWishlist(ProductModel product) {
    if (!isInWishlist(product.productId)) {
      _wishlistItems.add(product);
      notifyListeners();
    }
  }

  void removeFromWishlist(String productId) {
    _wishlistItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void toggleWishlist(ProductModel product) {
    if (isInWishlist(product.productId)) {
      removeFromWishlist(product.productId);
    } else {
      addToWishlist(product);
    }
  }

  void clearWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }

  Future<void> refreshWishlist() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, this would refetch wishlist items from Firestore
    // For now, just notify listeners to refresh UI
    notifyListeners();
  }
}

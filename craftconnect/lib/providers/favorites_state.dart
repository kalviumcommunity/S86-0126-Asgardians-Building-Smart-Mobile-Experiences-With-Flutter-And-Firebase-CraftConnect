import 'package:flutter/foundation.dart';

/// Favorites state for managing a list of favorite items
/// Demonstrates multi-screen shared state
class FavoritesState with ChangeNotifier {
  final List<String> _items = [];

  List<String> get items => List.unmodifiable(_items);

  int get count => _items.length;

  bool isFavorite(String item) {
    return _items.contains(item);
  }

  void addItem(String item) {
    if (!_items.contains(item)) {
      _items.add(item);
      notifyListeners();
    }
  }

  void removeItem(String item) {
    _items.remove(item);
    notifyListeners();
  }

  void toggleFavorite(String item) {
    if (_items.contains(item)) {
      removeItem(item);
    } else {
      addItem(item);
    }
  }

  void clearAll() {
    _items.clear();
    notifyListeners();
  }
}

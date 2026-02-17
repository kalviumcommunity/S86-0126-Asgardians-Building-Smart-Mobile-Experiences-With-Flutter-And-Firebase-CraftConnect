import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryProvider extends ChangeNotifier {
  List<String> _recentSearches = [];
  static const String _searchHistoryKey = 'recent_searches';
  static const int _maxSearchHistory = 10;

  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  SearchHistoryProvider() {
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList(_searchHistoryKey) ?? [];
      _recentSearches = searches;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading search history: $e');
    }
  }

  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;

    final trimmedQuery = query.trim();

    // Remove if already exists
    _recentSearches.remove(trimmedQuery);

    // Add to beginning
    _recentSearches.insert(0, trimmedQuery);

    // Limit history size
    if (_recentSearches.length > _maxSearchHistory) {
      _recentSearches = _recentSearches.take(_maxSearchHistory).toList();
    }

    await _saveSearchHistory();
    notifyListeners();
  }

  Future<void> removeSearch(String query) async {
    _recentSearches.remove(query);
    await _saveSearchHistory();
    notifyListeners();
  }

  Future<void> clearAllSearches() async {
    _recentSearches.clear();
    await _saveSearchHistory();
    notifyListeners();
  }

  List<String> getFilteredSearches(String query) {
    if (query.isEmpty) return _recentSearches;

    return _recentSearches
        .where((search) => search.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> _saveSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_searchHistoryKey, _recentSearches);
    } catch (e) {
      debugPrint('Error saving search history: $e');
    }
  }
}

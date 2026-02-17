import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/firestore_service.dart';
import '../models/shop_model.dart';

class FollowProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // Following list (shopIds)
  Set<String> _following = {};

  // Number of followers for each shop
  final Map<String, int> _followerCounts = {};

  // Followed shops details
  final List<ShopModel> _followedShops = [];

  bool _isLoading = false;

  Set<String> get following => _following;
  Map<String, int> get followerCounts => _followerCounts;
  List<ShopModel> get followedShops => _followedShops;
  bool get isLoading => _isLoading;

  // Check if following a specific shop
  bool isFollowing(String shopId) {
    return _following.contains(shopId);
  }

  // Get follower count for a shop
  int getFollowerCount(String shopId) {
    return _followerCounts[shopId] ?? 0;
  }

  // Load user's following list
  Future<void> loadFollowing(String userId) async {
    if (userId.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Load from Firestore
      final following = await _firestoreService.getFollowing(userId);
      _following = following.toSet();

      // Cache locally
      await _cacheFollowing();

      // Load followed shops details
      await loadFollowedShops();
    } catch (e) {
      debugPrint('Error loading following: $e');
      // Load from cache on error
      await _loadCachedFollowing();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load details of followed shops
  Future<void> loadFollowedShops() async {
    try {
      _followedShops.clear();
      for (final shopId in _following) {
        final shop = await _firestoreService.getShopById(shopId);
        if (shop != null) {
          _followedShops.add(shop);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading followed shops: $e');
    }
  }

  // Follow a shop
  Future<bool> followShop(String userId, String shopId) async {
    if (userId.isEmpty || shopId.isEmpty) return false;

    try {
      await _firestoreService.followShop(userId, shopId);
      _following.add(shopId);
      _followerCounts[shopId] = (_followerCounts[shopId] ?? 0) + 1;

      // Update cache
      await _cacheFollowing();

      // Reload followed shops
      await loadFollowedShops();

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error following shop: $e');
      return false;
    }
  }

  // Unfollow a shop
  Future<bool> unfollowShop(String userId, String shopId) async {
    if (userId.isEmpty || shopId.isEmpty) return false;

    try {
      await _firestoreService.unfollowShop(userId, shopId);
      _following.remove(shopId);
      _followerCounts[shopId] = (_followerCounts[shopId] ?? 1) - 1;

      // Update cache
      await _cacheFollowing();

      // Reload followed shops
      await loadFollowedShops();

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error unfollowing shop: $e');
      return false;
    }
  }

  // Toggle follow status
  Future<bool> toggleFollow(String userId, String shopId) async {
    if (isFollowing(shopId)) {
      return await unfollowShop(userId, shopId);
    } else {
      return await followShop(userId, shopId);
    }
  }

  // Load follower count for a shop
  Future<void> loadFollowerCount(String shopId) async {
    try {
      final count = await _firestoreService.getFollowerCount(shopId);
      _followerCounts[shopId] = count;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading follower count: $e');
    }
  }

  // Load follower counts for multiple shops
  Future<void> loadFollowerCounts(List<String> shopIds) async {
    for (final shopId in shopIds) {
      await loadFollowerCount(shopId);
    }
  }

  // Cache following list locally
  Future<void> _cacheFollowing() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('following', jsonEncode(_following.toList()));
    } catch (e) {
      debugPrint('Error caching following: $e');
    }
  }

  // Load following from cache
  Future<void> _loadCachedFollowing() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('following');
      if (cached != null) {
        final list = List<String>.from(jsonDecode(cached));
        _following = list.toSet();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached following: $e');
    }
  }

  // Clear all data (for logout)
  Future<void> clear() async {
    _following.clear();
    _followerCounts.clear();
    _followedShops.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('following');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }

    notifyListeners();
  }
}

import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get Firebase Analytics instance
  FirebaseAnalytics get analytics => _analytics;

  /// Get Firebase Analytics Observer for navigation tracking
  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  // ==================== PRODUCT EVENTS ====================

  /// Log when a user views a product
  Future<void> logProductView({
    required String productId,
    required String productName,
    required String category,
    required double price,
  }) async {
    await _analytics.logEvent(
      name: 'product_view',
      parameters: {
        'product_id': productId,
        'product_name': productName,
        'category': category,
        'price': price,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log when a user adds a product to cart
  Future<void> logAddToCart({
    required String productId,
    required String productName,
    required double price,
    required int quantity,
    required String category,
  }) async {
    await _analytics.logAddToCart(
      currency: 'INR',
      value: price * quantity,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productName,
          itemCategory: category,
          price: price,
          quantity: quantity,
        ),
      ],
    );
  }

  /// Log when a user removes a product from cart
  Future<void> logRemoveFromCart({
    required String productId,
    required String productName,
    required double price,
    required int quantity,
    required String category,
  }) async {
    await _analytics.logRemoveFromCart(
      currency: 'INR',
      value: price * quantity,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productName,
          itemCategory: category,
          price: price,
          quantity: quantity,
        ),
      ],
    );
  }

  // ==================== WISHLIST EVENTS ====================

  /// Log when a user adds a product to wishlist
  Future<void> logAddToWishlist({
    required String productId,
    required String productName,
    required double price,
    required String category,
  }) async {
    await _analytics.logAddToWishlist(
      currency: 'INR',
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productName,
          itemCategory: category,
          price: price,
        ),
      ],
    );
  }

  // ==================== CHECKOUT EVENTS ====================

  /// Log when a user begins checkout
  Future<void> logBeginCheckout({
    required double totalAmount,
    required int itemCount,
    required List<Map<String, dynamic>> items,
  }) async {
    await _analytics.logBeginCheckout(
      value: totalAmount,
      currency: 'INR',
      items: items
          .map((item) => AnalyticsEventItem(
                itemId: item['productId'] ?? '',
                itemName: item['productName'] ?? '',
                itemCategory: item['category'] ?? '',
                price: (item['price'] ?? 0.0).toDouble(),
                quantity: item['quantity'] ?? 1,
              ))
          .toList(),
    );
  }

  /// Log when a user completes a purchase
  Future<void> logPurchase({
    required String orderId,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
    double? tax,
    double? shipping,
  }) async {
    await _analytics.logPurchase(
      currency: 'INR',
      transactionId: orderId,
      value: totalAmount,
      tax: tax,
      shipping: shipping,
      items: items
          .map((item) => AnalyticsEventItem(
                itemId: item['productId'] ?? '',
                itemName: item['productName'] ?? '',
                itemCategory: item['category'] ?? '',
                price: (item['price'] ?? 0.0).toDouble(),
                quantity: item['quantity'] ?? 1,
              ))
          .toList(),
    );
  }

  // ==================== SEARCH EVENTS ====================

  /// Log when a user searches
  Future<void> logSearch({
    required String searchTerm,
    int? resultCount,
  }) async {
    await _analytics.logSearch(
      searchTerm: searchTerm,
      parameters: {
        'result_count': resultCount ?? 0,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ==================== USER EVENTS ====================

  /// Log when a user signs up
  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  /// Log when a user logs in
  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// Set user ID for tracking
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Set user property
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // ==================== ARTISAN/SHOP EVENTS ====================

  /// Log when a user views an artisan profile
  Future<void> logViewArtisanProfile({
    required String shopId,
    required String shopName,
  }) async {
    await _analytics.logEvent(
      name: 'view_artisan_profile',
      parameters: {
        'shop_id': shopId,
        'shop_name': shopName,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log when a user follows an artisan
  Future<void> logFollowArtisan({
    required String shopId,
    required String shopName,
  }) async {
    await _analytics.logEvent(
      name: 'follow_artisan',
      parameters: {
        'shop_id': shopId,
        'shop_name': shopName,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log when a user unfollows an artisan
  Future<void> logUnfollowArtisan({
    required String shopId,
    required String shopName,
  }) async {
    await _analytics.logEvent(
      name: 'unfollow_artisan',
      parameters: {
        'shop_id': shopId,
        'shop_name': shopName,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ==================== REVIEW EVENTS ====================

  /// Log when a user submits a review
  Future<void> logSubmitReview({
    required String productId,
    required String productName,
    required double rating,
    bool hasComment = false,
  }) async {
    await _analytics.logEvent(
      name: 'submit_review',
      parameters: {
        'product_id': productId,
        'product_name': productName,
        'rating': rating,
        'has_comment': hasComment,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ==================== FILTER & SORT EVENTS ====================

  /// Log when a user applies filters
  Future<void> logApplyFilters({
    required Map<String, dynamic> filters,
  }) async {
    await _analytics.logEvent(
      name: 'apply_filters',
      parameters: {
        'filters': filters.toString(),
        'filter_count': filters.length,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ==================== SHARE EVENTS ====================

  /// Log when a user shares a product
  Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method ?? 'unknown',
    );
  }

  // ==================== CUSTOM EVENTS ====================

  /// Log a custom event
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }
}

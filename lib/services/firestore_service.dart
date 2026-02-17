import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/address_model.dart';
import '../models/review_model.dart';
import '../models/notification_model.dart';
import '../models/coupon_model.dart';
import '../config/firebase_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== SHOP OPERATIONS ====================

  /// Create a new shop
  Future<void> createShop(ShopModel shop) async {
    try {
      await _firestore
          .collection(FirebaseCollections.shops)
          .doc(shop.shopId)
          .set(shop.toMap());
    } catch (e) {
      throw 'Failed to create shop: $e';
    }
  }

  /// Get shop by slug
  Future<ShopModel?> getShopBySlug(String slug) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.shops)
          .where('slug', isEqualTo: slug)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return ShopModel.fromDocument(querySnapshot.docs.first);
    } catch (e) {
      throw 'Failed to get shop: $e';
    }
  }

  /// Get shop by ID
  Future<ShopModel?> getShopById(String shopId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.shops)
          .doc(shopId)
          .get();

      if (!doc.exists) return null;

      return ShopModel.fromDocument(doc);
    } catch (e) {
      throw 'Failed to get shop: $e';
    }
  }

  /// Get shops by owner
  Future<List<ShopModel>> getShopsByOwner(String ownerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.shops)
          .where('ownerId', isEqualTo: ownerId)
          .get();

      return querySnapshot.docs
          .map((doc) => ShopModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get shops: $e';
    }
  }

  /// Update shop
  Future<void> updateShop(ShopModel shop) async {
    try {
      await _firestore
          .collection(FirebaseCollections.shops)
          .doc(shop.shopId)
          .update(shop.toMap());
    } catch (e) {
      throw 'Failed to update shop: $e';
    }
  }

  /// Delete shop
  Future<void> deleteShop(String shopId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.shops)
          .doc(shopId)
          .delete();
    } catch (e) {
      throw 'Failed to delete shop: $e';
    }
  }

  /// Get all shops (admin only)
  Future<List<ShopModel>> getAllShops() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.shops)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ShopModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get all shops: $e';
    }
  }

  /// Check if slug is available
  Future<bool> isSlugAvailable(String slug) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.shops)
          .where('slug', isEqualTo: slug)
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw 'Failed to check slug availability: $e';
    }
  }

  // ==================== PRODUCT OPERATIONS ====================

  /// Add a new product
  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore
          .collection(FirebaseCollections.products)
          .doc(product.productId)
          .set(product.toMap());
    } catch (e) {
      throw 'Failed to add product: $e';
    }
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.products)
          .doc(productId)
          .get();

      if (!doc.exists) return null;

      return ProductModel.fromDocument(doc);
    } catch (e) {
      throw 'Failed to get product: $e';
    }
  }

  /// Get products by shop
  Future<List<ProductModel>> getProductsByShop(String shopId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.products)
          .where('shopId', isEqualTo: shopId)
          .orderBy('createdAt', descending: true)
          .get();

      final products = querySnapshot.docs
          .map((doc) => ProductModel.fromDocument(doc))
          .toList();

      return products;
    } catch (e) {
      throw 'Failed to get products: $e';
    }
  }

  /// Update product
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore
          .collection(FirebaseCollections.products)
          .doc(product.productId)
          .update(product.toMap());
    } catch (e) {
      throw 'Failed to update product: $e';
    }
  }

  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.products)
          .where('category', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true)
          .get();

      List<ProductModel> products = [];
      for (var doc in querySnapshot.docs) {
        products.add(ProductModel.fromDocument(doc));
      }

      return products;
    } catch (e) {
      throw 'Failed to get products by category: $e';
    }
  }

  /// Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.products)
          .doc(productId)
          .delete();
    } catch (e) {
      throw 'Failed to delete product: $e';
    }
  }

  /// Update product stock
  Future<void> updateProductStock(String productId, int newStock) async {
    try {
      await _firestore
          .collection(FirebaseCollections.products)
          .doc(productId)
          .update({'stock': newStock, 'updatedAt': Timestamp.now()});
    } catch (e) {
      throw 'Failed to update stock: $e';
    }
  }

  /// Get all products (admin only)
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.products)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get all products: $e';
    }
  }

  /// Get products with pagination (paginated)
  Future<List<ProductModel>> getProductsPaginated({
    int limit = 20,
    DocumentSnapshot? lastDocument,
    String? category,
    String? sortBy,
  }) async {
    try {
      Query query = _firestore.collection(FirebaseCollections.products);

      // Filter by category if specified
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      // Sort
      switch (sortBy) {
        case 'price_low':
          query = query.orderBy('price', descending: false);
          break;
        case 'price_high':
          query = query.orderBy('price', descending: true);
          break;
        case 'rating':
          query = query.orderBy('averageRating', descending: true);
          break;
        default:
          query = query.orderBy('createdAt', descending: true);
      }

      // Pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get paginated products: $e';
    }
  }

  /// Get trending products based on views and purchases
  Future<List<ProductModel>> getTrendingProducts({int limit = 10}) async {
    try {
      // Get all products with analytics data
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.products)
          .where('viewCount', isGreaterThan: 0)
          .get();

      // Convert to ProductModel list
      final products = querySnapshot.docs
          .map((doc) => ProductModel.fromDocument(doc))
          .toList();

      // Sort by trending score (viewCount × 1 + purchaseCount × 10)
      products.sort((a, b) => b.trendingScore.compareTo(a.trendingScore));

      // Return top N products
      return products.take(limit).toList();
    } catch (e) {
      throw 'Failed to get trending products: $e';
    }
  }

  /// Increment product view count
  Future<void> incrementProductViewCount(String productId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.products)
          .doc(productId)
          .update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw 'Failed to increment view count: $e';
    }
  }

  /// Increment product purchase count
  Future<void> incrementProductPurchaseCount(String productId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.products)
          .doc(productId)
          .update({
        'purchaseCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw 'Failed to increment purchase count: $e';
    }
  }

  // ==================== ORDER OPERATIONS ====================

  /// Create a new order
  Future<void> createOrder(OrderModel order) async {
    try {
      await _firestore
          .collection(FirebaseCollections.orders)
          .doc(order.orderId)
          .set(order.toMap());
    } catch (e) {
      throw 'Failed to create order: $e';
    }
  }

  /// Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.orders)
          .doc(orderId)
          .get();

      if (!doc.exists) return null;

      return OrderModel.fromDocument(doc);
    } catch (e) {
      throw 'Failed to get order: $e';
    }
  }

  /// Delete order
  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.orders)
          .doc(orderId)
          .delete();
    } catch (e) {
      throw 'Failed to delete order: $e';
    }
  }

  /// Get orders by artisan
  Future<List<OrderModel>> getOrdersByArtisan(String artisanId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.orders)
          .where('artisanId', isEqualTo: artisanId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get orders: $e';
    }
  }

  /// Get orders by shop
  Future<List<OrderModel>> getOrdersByShop(String shopId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.orders)
          .where('shopId', isEqualTo: shopId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get orders: $e';
    }
  }

  /// Get orders by buyer ID
  Future<List<OrderModel>> getOrdersByBuyer(String buyerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.orders)
          .where('buyerId', isEqualTo: buyerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get orders: $e';
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore
          .collection(FirebaseCollections.orders)
          .doc(orderId)
          .update({'status': status.name, 'updatedAt': Timestamp.now()});
    } catch (e) {
      throw 'Failed to update order status: $e';
    }
  }

  /// Update payment status
  Future<void> updatePaymentStatus(
    String orderId,
    PaymentStatus paymentStatus,
  ) async {
    try {
      await _firestore
          .collection(FirebaseCollections.orders)
          .doc(orderId)
          .update({
        'paymentStatus': paymentStatus.name,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Failed to update payment status: $e';
    }
  }

  /// Get all orders (admin only)
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.orders)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get all orders: $e';
    }
  }

  // ==================== STREAM OPERATIONS ====================

  /// Stream products by shop
  Stream<List<ProductModel>> streamProductsByShop(String shopId) {
    return _firestore
        .collection(FirebaseCollections.products)
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromDocument(doc))
              .toList(),
        );
  }

  /// Stream orders by artisan
  Stream<List<OrderModel>> streamOrdersByArtisan(String artisanId) {
    return _firestore
        .collection(FirebaseCollections.orders)
        .where('artisanId', isEqualTo: artisanId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => OrderModel.fromDocument(doc)).toList(),
        );
  }

  /// Stream order by ID
  Stream<OrderModel?> streamOrderById(String orderId) {
    return _firestore
        .collection(FirebaseCollections.orders)
        .doc(orderId)
        .snapshots()
        .map((doc) => doc.exists ? OrderModel.fromDocument(doc) : null);
  }

  // ==================== ADDRESS OPERATIONS ====================

  /// Get user addresses
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .collection('addresses')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AddressModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw 'Failed to get addresses: $e';
    }
  }

  /// Add new address
  Future<void> addAddress(AddressModel address) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(address.userId)
          .collection('addresses')
          .doc(address.id)
          .set(address.toMap());
    } catch (e) {
      throw 'Failed to add address: $e';
    }
  }

  /// Update address
  Future<void> updateAddress(AddressModel address) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(address.userId)
          .collection('addresses')
          .doc(address.id)
          .update(address.toMap());
    } catch (e) {
      throw 'Failed to update address: $e';
    }
  }

  /// Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      // We need to find which user this belongs to
      final usersSnapshot =
          await _firestore.collection(FirebaseCollections.users).get();

      for (var userDoc in usersSnapshot.docs) {
        final addressDoc = await userDoc.reference
            .collection('addresses')
            .doc(addressId)
            .get();

        if (addressDoc.exists) {
          await addressDoc.reference.delete();
          return;
        }
      }
    } catch (e) {
      throw 'Failed to delete address: $e';
    }
  }

  // ==================== REVIEW OPERATIONS ====================

  /// Get product reviews
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.products)
          .doc(productId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ReviewModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw 'Failed to get reviews: $e';
    }
  }

  /// Get all reviews across all products
  Future<List<ReviewModel>> getAllReviews() async {
    try {
      final List<ReviewModel> allReviews = [];
      final productsSnapshot =
          await _firestore.collection(FirebaseCollections.products).get();

      for (var productDoc in productsSnapshot.docs) {
        final reviewsSnapshot =
            await productDoc.reference.collection('reviews').get();

        for (var reviewDoc in reviewsSnapshot.docs) {
          allReviews.add(
            ReviewModel.fromMap({...reviewDoc.data(), 'id': reviewDoc.id}),
          );
        }
      }

      return allReviews;
    } catch (e) {
      throw 'Failed to get all reviews: $e';
    }
  }

  /// Add review
  Future<void> addReview(ReviewModel review) async {
    try {
      await _firestore
          .collection(FirebaseCollections.products)
          .doc(review.productId)
          .collection('reviews')
          .doc(review.id)
          .set(review.toMap());
    } catch (e) {
      throw 'Failed to add review: $e';
    }
  }

  /// Delete review
  Future<void> deleteReview(String reviewId) async {
    try {
      // Find and delete the review from any product's reviews subcollection
      final productsSnapshot =
          await _firestore.collection(FirebaseCollections.products).get();

      for (var productDoc in productsSnapshot.docs) {
        final reviewDoc = await productDoc.reference
            .collection('reviews')
            .doc(reviewId)
            .get();

        if (reviewDoc.exists) {
          await reviewDoc.reference.delete();
          return;
        }
      }
    } catch (e) {
      throw 'Failed to delete review: $e';
    }
  }

  // ==================== NOTIFICATION OPERATIONS ====================

  /// Get user notifications
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['notificationId'] = doc.id;
        return NotificationModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw 'Failed to load notifications: $e';
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(
      String userId, String notificationId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw 'Failed to mark notification as read: $e';
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to mark all notifications as read: $e';
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw 'Failed to delete notification: $e';
    }
  }

  /// Create notification (helper for order updates, promotions)
  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(notification.userId)
          .collection('notifications')
          .add(notification.toMap());
    } catch (e) {
      throw 'Failed to create notification: $e';
    }
  }

  // ==================== COUPON OPERATIONS ====================

  /// Get all active coupons
  Future<List<CouponModel>> getAllCoupons() async {
    try {
      final querySnapshot = await _firestore
          .collection('coupons')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => CouponModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get coupons: $e';
    }
  }

  /// Get user-specific coupons
  Future<List<CouponModel>> getUserCoupons(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('user_coupons')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => CouponModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get user coupons: $e';
    }
  }

  /// Get coupon by code
  Future<CouponModel?> getCouponByCode(String couponCode) async {
    try {
      final querySnapshot = await _firestore
          .collection('coupons')
          .where('code', isEqualTo: couponCode.toUpperCase())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return CouponModel.fromDocument(querySnapshot.docs.first);
    } catch (e) {
      throw 'Failed to get coupon: $e';
    }
  }

  /// Increment coupon usage count
  Future<void> incrementCouponUsage(String couponId) async {
    try {
      await _firestore.collection('coupons').doc(couponId).update({
        'usedCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw 'Failed to update coupon usage: $e';
    }
  }

  /// Create a new coupon
  Future<void> createCoupon(CouponModel coupon) async {
    try {
      await _firestore
          .collection('coupons')
          .doc(coupon.couponId)
          .set(coupon.toMap());
    } catch (e) {
      throw 'Failed to create coupon: $e';
    }
  }

  /// Assign coupon to user
  Future<void> assignCouponToUser(String userId, CouponModel coupon) async {
    try {
      await _firestore.collection('user_coupons').add({
        'userId': userId,
        ...coupon.toMap(),
      });
    } catch (e) {
      throw 'Failed to assign coupon to user: $e';
    }
  }

  /// Update existing coupon
  Future<void> updateCoupon(CouponModel coupon) async {
    try {
      await _firestore
          .collection('coupons')
          .doc(coupon.couponId)
          .update(coupon.toMap());
    } catch (e) {
      throw 'Failed to update coupon: $e';
    }
  }

  /// Delete coupon
  Future<void> deleteCoupon(String couponId) async {
    try {
      await _firestore.collection('coupons').doc(couponId).delete();
    } catch (e) {
      throw 'Failed to delete coupon: $e';
    }
  }

  // ==================== CHAT/MESSAGING OPERATIONS ====================

  /// Create a new conversation
  Future<void> createConversation(dynamic conversation) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversation.conversationId)
          .set(conversation.toMap());
    } catch (e) {
      throw 'Failed to create conversation: $e';
    }
  }

  /// Get conversation between two users
  Future<dynamic> getConversationBetweenUsers(
    String userId1,
    String userId2,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: userId1)
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participantIds'] ?? []);
        if (participants.contains(userId2)) {
          return _conversationFromDocument(doc);
        }
      }

      return null;
    } catch (e) {
      throw 'Failed to get conversation: $e';
    }
  }

  /// Get user conversations
  Future<List<dynamic>> getUserConversations(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: userId)
          .orderBy('lastMessageAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => _conversationFromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get conversations: $e';
    }
  }

  /// Send a message
  Future<void> sendMessage(dynamic message) async {
    try {
      // Add message
      await _firestore
          .collection('messages')
          .doc(message.messageId)
          .set(message.toMap());

      // Update conversation
      final conversation = await _firestore
          .collection('conversations')
          .doc(message.conversationId)
          .get();

      if (conversation.exists) {
        final data = conversation.data()!;
        final unreadCount = Map<String, int>.from(data['unreadCount'] ?? {});
        unreadCount[message.receiverId] =
            (unreadCount[message.receiverId] ?? 0) + 1;

        await _firestore
            .collection('conversations')
            .doc(message.conversationId)
            .update({
          'lastMessage': message.content,
          'lastMessageSenderId': message.senderId,
          'lastMessageAt': message.createdAt,
          'unreadCount': unreadCount,
          'updatedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      throw 'Failed to send message: $e';
    }
  }

  /// Get messages for a conversation
  Future<List<dynamic>> getConversationMessages(String conversationId) async {
    try {
      final querySnapshot = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => _messageFromDocument(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get messages: $e';
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(
    String conversationId,
    String userId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(
            doc.reference, {'isRead': true, 'updatedAt': Timestamp.now()});
      }
      await batch.commit();

      // Update conversation unread count
      final conversation = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (conversation.exists) {
        final data = conversation.data()!;
        final unreadCount = Map<String, int>.from(data['unreadCount'] ?? {});
        unreadCount[userId] = 0;

        await _firestore
            .collection('conversations')
            .doc(conversationId)
            .update({
          'unreadCount': unreadCount,
          'updatedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      throw 'Failed to mark messages as read: $e';
    }
  }

  // Helper methods to avoid circular dependencies
  dynamic _conversationFromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Return a dynamic object that chat_provider can work with
    return data;
  }

  dynamic _messageFromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return data;
  }

  // ==================== RETURN/REFUND OPERATIONS ====================

  /// Create a return request
  Future<void> createReturnRequest(dynamic returnRequest) async {
    try {
      await _firestore
          .collection('returns')
          .doc(returnRequest.returnId)
          .set(returnRequest.toMap());
    } catch (e) {
      throw 'Failed to create return request: $e';
    }
  }

  /// Get return by ID
  Future<dynamic> getReturnById(String returnId) async {
    try {
      final doc = await _firestore.collection('returns').doc(returnId).get();

      if (!doc.exists) return null;

      return doc.data();
    } catch (e) {
      throw 'Failed to get return: $e';
    }
  }

  /// Get user returns
  Future<List<dynamic>> getUserReturns(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('returns')
          .where('userId', isEqualTo: userId)
          .orderBy('requestedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw 'Failed to get user returns: $e';
    }
  }

  /// Get shop returns
  Future<List<dynamic>> getShopReturns(String shopId) async {
    try {
      final querySnapshot = await _firestore
          .collection('returns')
          .where('shopId', isEqualTo: shopId)
          .orderBy('requestedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw 'Failed to get shop returns: $e';
    }
  }

  /// Get all returns (admin)
  Future<List<dynamic>> getAllReturns() async {
    try {
      final querySnapshot = await _firestore
          .collection('returns')
          .orderBy('requestedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw 'Failed to get all returns: $e';
    }
  }

  /// Update return status
  Future<void> updateReturnStatus(
    String returnId,
    dynamic status, {
    String? adminNotes,
    DateTime? approvedAt,
    DateTime? completedAt,
    DateTime? refundedAt,
  }) async {
    try {
      final updateData = {
        'status': status.toString().split('.').last,
        'updatedAt': Timestamp.now(),
      };

      if (adminNotes != null) updateData['adminNotes'] = adminNotes;
      if (approvedAt != null) {
        updateData['approvedAt'] = Timestamp.fromDate(approvedAt);
      }
      if (completedAt != null) {
        updateData['completedAt'] = Timestamp.fromDate(completedAt);
      }
      if (refundedAt != null) {
        updateData['refundedAt'] = Timestamp.fromDate(refundedAt);
      }

      await _firestore.collection('returns').doc(returnId).update(updateData);
    } catch (e) {
      throw 'Failed to update return status: $e';
    }
  }

  // ==================== FOLLOW OPERATIONS ====================

  /// Follow a shop
  Future<void> followShop(String userId, String shopId) async {
    try {
      final batch = _firestore.batch();

      // Add to user's following collection
      final followingRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .doc(shopId);

      batch.set(followingRef, {
        'shopId': shopId,
        'followedAt': Timestamp.now(),
      });

      // Add to shop's followers collection
      final followerRef = _firestore
          .collection(FirebaseCollections.shops)
          .doc(shopId)
          .collection('followers')
          .doc(userId);

      batch.set(followerRef, {
        'userId': userId,
        'followedAt': Timestamp.now(),
      });

      await batch.commit();
    } catch (e) {
      throw 'Failed to follow shop: $e';
    }
  }

  /// Unfollow a shop
  Future<void> unfollowShop(String userId, String shopId) async {
    try {
      final batch = _firestore.batch();

      // Remove from user's following collection
      final followingRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .doc(shopId);

      batch.delete(followingRef);

      // Remove from shop's followers collection
      final followerRef = _firestore
          .collection(FirebaseCollections.shops)
          .doc(shopId)
          .collection('followers')
          .doc(userId);

      batch.delete(followerRef);

      await batch.commit();
    } catch (e) {
      throw 'Failed to unfollow shop: $e';
    }
  }

  /// Get list of shops the user is following
  Future<List<String>> getFollowing(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .get();

      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw 'Failed to get following: $e';
    }
  }

  /// Get list of users following a shop
  Future<List<String>> getFollowers(String shopId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.shops)
          .doc(shopId)
          .collection('followers')
          .get();

      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw 'Failed to get followers: $e';
    }
  }

  /// Get follower count for a shop
  Future<int> getFollowerCount(String shopId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseCollections.shops)
          .doc(shopId)
          .collection('followers')
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      throw 'Failed to get follower count: $e';
    }
  }

  /// Check if user is following a shop
  Future<bool> isFollowing(String userId, String shopId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .doc(shopId)
          .get();

      return doc.exists;
    } catch (e) {
      throw 'Failed to check follow status: $e';
    }
  }
}

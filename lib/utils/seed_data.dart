import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/shop_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/review_model.dart';
import '../models/cart_item_model.dart';

class SeedData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Predefined user IDs for consistency
  final String buyerUserId = 'buyer_user_001';
  final String sellerUserId = 'seller_user_001';
  final String shopId = 'shop_001';

  // Seed all data
  Future<void> seedAllData() async {
    debugPrint('🌱 Starting database seeding...');

    try {
      // 1. Create users
      await _seedUsers();

      // 2. Create shop
      await _seedShop();

      // 3. Create products
      final productIds = await _seedProducts();

      // 4. Create reviews for first 5 products
      await _seedReviews(productIds.take(5).toList());

      // 5. Create orders (2 products ordered)
      await _seedOrders(productIds.take(2).toList());

      // 6. Create cart items (2 products in cart)
      await _seedCart(productIds.skip(2).take(2).toList());

      // 7. Create wishlist (1 product)
      await _seedWishlist([productIds[4]]);

      debugPrint('✅ Database seeding completed successfully!');
      debugPrint('📊 Summary:');
      debugPrint('   - 2 Users created');
      debugPrint('   - 1 Shop created');
      debugPrint('   - 10 Products created');
      debugPrint('   - 15 Reviews created (3 per product for 5 products)');
      debugPrint('   - 2 Orders created');
      debugPrint('   - 2 Cart items created');
      debugPrint('   - 1 Wishlist item created');
    } catch (e) {
      debugPrint('❌ Error seeding database: $e');
      rethrow;
    }
  }

  // Seed users (1 buyer, 1 seller)
  Future<void> _seedUsers() async {
    debugPrint('👥 Creating users...');

    final users = [
      UserModel(
        uid: buyerUserId,
        name: 'Rajesh Kumar',
        email: 'rajesh.buyer@craftconnect.app',
        phone: '+919876543210',
        role: UserRole.buyer,
        language: 'en',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        profilePicture: 'https://i.pravatar.cc/150?img=12',
      ),
      UserModel(
        uid: sellerUserId,
        name: 'Priya Sharma',
        email: 'priya.artisan@craftconnect.app',
        phone: '+919876543211',
        role: UserRole.artisan,
        language: 'en',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        profilePicture: 'https://i.pravatar.cc/150?img=47',
      ),
    ];

    for (final user in users) {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    }

    debugPrint('   ✓ Created 2 users');
  }

  // Seed shop
  Future<void> _seedShop() async {
    debugPrint('🏪 Creating shop...');

    final shop = ShopModel(
      shopId: shopId,
      ownerId: sellerUserId,
      shopName: 'Priya\'s Handicrafts',
      businessName: 'Priya Sharma Handicrafts',
      slug: 'priyas-handicrafts',
      description:
          'Authentic handmade crafts with traditional Indian designs. Specializing in pottery, jewelry, and home decor items.',
      contact: '+919876543211',
      contactPhone: '+919876543211',
      contactEmail: 'priya.artisan@craftconnect.app',
      imageUrl:
          'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=800',
      isApproved: true,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    );

    await _firestore.collection('shops').doc(shop.shopId).set(shop.toMap());

    debugPrint('   ✓ Created 1 shop');
  }

  // Seed products (10 products across various categories)
  Future<List<String>> _seedProducts() async {
    debugPrint('📦 Creating products...');

    final products = [
      // 1. Jewelry
      {
        'name': 'Handcrafted Silver Earrings',
        'description':
            'Beautiful handcrafted silver earrings with traditional Indian design. Perfect for weddings and special occasions.',
        'price': 1299.0,
        'category': 'Jewelry',
        'stock': 15,
        'imageUrl':
            'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=500',
        'images': [
          'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=500',
          'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=500',
        ],
      },
      // 2. Jewelry
      {
        'name': 'Traditional Kundan Necklace',
        'description':
            'Exquisite Kundan necklace set with matching earrings. Handmade with high-quality materials.',
        'price': 3499.0,
        'category': 'Jewelry',
        'stock': 8,
        'imageUrl':
            'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=500',
        'images': [
          'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=500',
          'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=500',
        ],
      },
      // 3. Home Decor
      {
        'name': 'Ceramic Wall Hanging',
        'description':
            'Hand-painted ceramic wall hanging depicting traditional Indian art. Perfect for home decoration.',
        'price': 899.0,
        'category': 'Home Decor',
        'stock': 20,
        'imageUrl':
            'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=500',
        'images': [
          'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=500',
          'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=500',
        ],
      },
      // 4. Home Decor
      {
        'name': 'Handwoven Bamboo Basket',
        'description':
            'Eco-friendly handwoven bamboo basket. Multi-purpose storage solution with traditional weaving techniques.',
        'price': 499.0,
        'category': 'Home Decor',
        'stock': 25,
        'imageUrl':
            'https://images.unsplash.com/photo-1591462158929-de36136c69f2?w=500',
        'images': [
          'https://images.unsplash.com/photo-1591462158929-de36136c69f2?w=500',
          'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=500',
        ],
      },
      // 5. Clothing
      {
        'name': 'Handloom Cotton Saree',
        'description':
            'Pure handloom cotton saree with traditional border design. Comfortable and elegant.',
        'price': 2199.0,
        'category': 'Clothing',
        'stock': 12,
        'imageUrl':
            'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=500',
        'images': [
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=500',
          'https://images.unsplash.com/photo-1583391733956-6c78276477e2?w=500',
        ],
      },
      // 6. Clothing
      {
        'name': 'Block Print Cotton Kurta',
        'description':
            'Hand block printed cotton kurta with traditional Rajasthani prints. Available in multiple sizes.',
        'price': 1599.0,
        'category': 'Clothing',
        'stock': 18,
        'imageUrl':
            'https://images.unsplash.com/photo-1596783074918-c84cb06531ca?w=500',
        'images': [
          'https://images.unsplash.com/photo-1596783074918-c84cb06531ca?w=500',
          'https://images.unsplash.com/photo-1562272454-1633878a5976?w=500',
        ],
      },
      // 7. Accessories
      {
        'name': 'Leather Wallet - Handmade',
        'description':
            'Genuine leather wallet with multiple card slots. Handcrafted with precision and care.',
        'price': 799.0,
        'category': 'Accessories',
        'stock': 30,
        'imageUrl':
            'https://images.unsplash.com/photo-1627123424574-724758594e93?w=500',
        'images': [
          'https://images.unsplash.com/photo-1627123424574-724758594e93?w=500',
          'https://images.unsplash.com/photo-1591033594119-11fa5da5c7c0?w=500',
        ],
      },
      // 8. Art
      {
        'name': 'Madhubani Painting',
        'description':
            'Traditional Madhubani art painting on canvas. Depicts folk tales and nature themes.',
        'price': 2999.0,
        'category': 'Art',
        'stock': 5,
        'imageUrl':
            'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=500',
        'images': [
          'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=500',
          'https://images.unsplash.com/photo-1547891654-e66ed7ebb968?w=500',
        ],
      },
      // 9. Pottery
      {
        'name': 'Terracotta Planter Set',
        'description':
            'Set of 3 handmade terracotta planters. Perfect for indoor plants and succulents.',
        'price': 699.0,
        'category': 'Pottery',
        'stock': 22,
        'imageUrl':
            'https://images.unsplash.com/photo-1616627781889-e1e8c4f7faee?w=500',
        'images': [
          'https://images.unsplash.com/photo-1616627781889-e1e8c4f7faee?w=500',
          'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=500',
        ],
      },
      // 10. Accessories
      {
        'name': 'Jute Tote Bag',
        'description':
            'Eco-friendly handmade jute tote bag with leather handles. Spacious and durable.',
        'price': 599.0,
        'category': 'Accessories',
        'stock': 35,
        'imageUrl':
            'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=500',
        'images': [
          'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=500',
          'https://images.unsplash.com/photo-1573167710701-35950a41e251?w=500',
        ],
      },
    ];

    final productIds = <String>[];

    for (int i = 0; i < products.length; i++) {
      final productData = products[i];
      final productId = 'product_${(i + 1).toString().padLeft(3, '0')}';

      final product = ProductModel(
        productId: productId,
        shopId: shopId,
        artisanId: sellerUserId,
        name: productData['name'] as String,
        description: productData['description'] as String,
        price: productData['price'] as double,
        category: productData['category'] as String,
        stock: productData['stock'] as int,
        imageUrl: productData['imageUrl'] as String,
        images: productData['images'] as List<String>,
        isAvailable: true,
        createdAt: DateTime.now().subtract(Duration(days: 30 - i)),
        averageRating: 0.0,
        reviewCount: 0,
        viewCount: (50 - (i * 3)),
        purchaseCount: (10 - i),
      );

      await _firestore
          .collection('products')
          .doc(product.productId)
          .set(product.toMap());
      productIds.add(productId);
    }

    debugPrint('   ✓ Created 10 products');
    return productIds;
  }

  // Seed reviews for products
  Future<void> _seedReviews(List<String> productIds) async {
    debugPrint('⭐ Creating reviews...');

    final reviewTemplates = [
      {
        'rating': 5.0,
        'comments': [
          'Excellent quality! Exactly as described. Very happy with my purchase.',
          'Beautiful craftsmanship. Worth every penny!',
          'Amazing product! Highly recommended to everyone.',
        ],
      },
      {
        'rating': 4.0,
        'comments': [
          'Good quality but delivery took longer than expected.',
          'Nice product. Minor packaging issues but product is fine.',
          'Very good. Slightly expensive but quality justifies the price.',
        ],
      },
      {
        'rating': 5.0,
        'comments': [
          'Outstanding! This is my third purchase from this seller.',
          'Premium quality! Fast shipping. Will buy again.',
          'Perfect gift! Loved by everyone. Thank you!',
        ],
      },
    ];

    final reviewerNames = [
      'Amit Patel',
      'Sneha Reddy',
      'Vikram Singh',
      'Anita Desai',
      'Rahul Mehta',
      'Kavita Joshi',
    ];

    int reviewCount = 0;

    for (final productId in productIds) {
      double totalRating = 0;
      final productReviews = <ReviewModel>[];

      // Create 3 reviews per product
      for (int i = 0; i < 3; i++) {
        final template = reviewTemplates[i];
        final rating = template['rating'] as double;
        final comments = template['comments'] as List<String>;

        final review = ReviewModel(
          id: _uuid.v4(),
          productId: productId,
          userId: 'user_${_uuid.v4().substring(0, 8)}',
          userName: reviewerNames[(reviewCount + i) % reviewerNames.length],
          rating: rating,
          comment: comments[i % comments.length],
          createdAt: DateTime.now().subtract(Duration(days: 20 - i)),
          isVerifiedPurchase: true,
        );

        await _firestore
            .collection('reviews')
            .doc(review.id)
            .set(review.toMap());
        productReviews.add(review);
        totalRating += rating;
        reviewCount++;
      }

      // Update product with average rating and review count
      final averageRating = totalRating / 3;
      await _firestore.collection('products').doc(productId).update({
        'averageRating': averageRating,
        'reviewCount': 3,
      });
    }

    debugPrint('   ✓ Created $reviewCount reviews');
  }

  Future<void> _seedOrders(List<String> productIds) async {
    debugPrint('📋 Creating orders...');

    for (int i = 0; i < productIds.length; i++) {
      final productId = productIds[i];
      final orderId = 'order_${_uuid.v4().substring(0, 13)}';

      final order = OrderModel(
        orderId: orderId,
        productId: productId,
        shopId: shopId,
        artisanId: sellerUserId,
        buyerId: buyerUserId,
        buyerName: 'Rajesh Kumar',
        buyerPhone: '+919876543210',
        buyerAddress: '123, MG Road, Bangalore, Karnataka - 560001',
        quantity: i + 1,
        totalAmount: (1299.0 + (i * 200)) * (i + 1),
        status: i == 0 ? OrderStatus.shipped : OrderStatus.completed,
        paymentStatus: PaymentStatus.success,
        paymentMethod: 'upi',
        upiId: 'rajesh@upi',
        createdAt: DateTime.now().subtract(Duration(days: 10 - i)),
        updatedAt: DateTime.now().subtract(Duration(days: 8 - i)),
        hasGiftWrapping: i == 1,
        giftMessage: i == 1 ? 'Happy Birthday! Love from family.' : null,
        giftWrappingCharge: i == 1 ? 50.0 : 0.0,
      );

      // Save to global orders collection
      await _firestore
          .collection('orders')
          .doc(order.orderId)
          .set(order.toMap());
    }

    debugPrint('   ✓ Created 2 orders');
  }

  Future<void> _seedCart(List<String> productIds) async {
    debugPrint('🛒 Creating cart items...');

    // Get product details for cart items
    for (int i = 0; i < productIds.length; i++) {
      final productId = productIds[i];
      final productDoc =
          await _firestore.collection('products').doc(productId).get();
      final productData = productDoc.data()!;

      final cartItem = CartItemModel(
        productId: productId,
        productName: productData['name'],
        imageUrl: productData['imageUrl'],
        price: productData['price'].toDouble(),
        quantity: i + 1,
        artisanId: sellerUserId,
        shopId: shopId,
      );

      await _firestore
          .collection('users')
          .doc(buyerUserId)
          .collection('cart')
          .doc(productId)
          .set(cartItem.toJson());
    }

    debugPrint('   ✓ Created 2 cart items');
  }

  Future<void> _seedWishlist(List<String> productIds) async {
    debugPrint('💝 Creating wishlist items...');

    for (final productId in productIds) {
      final productDoc =
          await _firestore.collection('products').doc(productId).get();
      final productData = productDoc.data()!;

      await _firestore
          .collection('users')
          .doc(buyerUserId)
          .collection('wishlist')
          .doc(productId)
          .set({
        'productId': productId,
        'productName': productData['name'],
        'imageUrl': productData['imageUrl'],
        'price': productData['price'],
        'addedAt': Timestamp.now(),
      });
    }

    debugPrint('   ✓ Created 1 wishlist item');
  }

  Future<void> clearAllSeedData() async {
    debugPrint('🗑️ Clearing seed data...');

    try {
      // Delete users
      await _firestore.collection('users').doc(buyerUserId).delete();
      await _firestore.collection('users').doc(sellerUserId).delete();

      // Delete shop
      await _firestore.collection('shops').doc(shopId).delete();

      // Delete products (and their subcollections)
      final productsSnapshot = await _firestore
          .collection('products')
          .where('shopId', isEqualTo: shopId)
          .get();

      for (final doc in productsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete all reviews
      final reviewsSnapshot = await _firestore.collection('reviews').get();
      for (final doc in reviewsSnapshot.docs) {
        await doc.reference.delete();
      }

      debugPrint('✅ Seed data cleared successfully!');
    } catch (e) {
      debugPrint('❌ Error clearing seed data: $e');
    }
  }
}

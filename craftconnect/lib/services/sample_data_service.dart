import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class SampleDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Populates Firestore with sample product data for query testing
  Future<void> populateSampleProducts() async {
    try {
      final products = _getSampleProducts();

      // Use batch write for better performance
      WriteBatch batch = _db.batch();

      for (Product product in products) {
        DocumentReference docRef = _db.collection('products').doc(product.id);
        batch.set(docRef, product.toJson());
      }

      await batch.commit();
      print('Sample products added to Firestore successfully!');
    } catch (e) {
      print('Error adding sample products: $e');
      rethrow;
    }
  }

  /// Checks if sample data already exists
  Future<bool> hasSampleData() async {
    try {
      final snapshot = await _db.collection('products').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking sample data: $e');
      return false;
    }
  }

  /// Clears all product data from Firestore
  Future<void> clearAllProducts() async {
    try {
      final snapshot = await _db.collection('products').get();
      WriteBatch batch = _db.batch();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('All products cleared from Firestore');
    } catch (e) {
      print('Error clearing products: $e');
      rethrow;
    }
  }

  List<Product> _getSampleProducts() {
    return [
      Product(
        id: 'prod_001',
        name: 'Handwoven Ceramic Bowl',
        description: 'Beautiful handmade ceramic bowl perfect for serving.',
        price: 45.00,
        category: 'Ceramics',
        imageUrl:
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
        artisanName: 'Maria Rodriguez',
        rating: 4.8,
        reviewCount: 24,
        inStock: true,
      ),
      Product(
        id: 'prod_002',
        name: 'Vintage Leather Bag',
        description: 'Handcrafted leather messenger bag with vintage appeal.',
        price: 180.00,
        category: 'Textiles',
        imageUrl:
            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
        artisanName: 'John Smith',
        rating: 4.9,
        reviewCount: 18,
        inStock: true,
      ),
      Product(
        id: 'prod_003',
        name: 'Silver Pendant Necklace',
        description: 'Elegant handmade silver necklace with turquoise stone.',
        price: 75.00,
        category: 'Jewelry',
        imageUrl:
            'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400',
        artisanName: 'Sarah Chen',
        rating: 4.6,
        reviewCount: 31,
        inStock: false,
      ),
      Product(
        id: 'prod_004',
        name: 'Wooden Coffee Table',
        description: 'Rustic oak coffee table with natural finish.',
        price: 320.00,
        category: 'Woodwork',
        imageUrl:
            'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?w=400',
        artisanName: 'Michael Johnson',
        rating: 4.7,
        reviewCount: 15,
        inStock: true,
      ),
      Product(
        id: 'prod_005',
        name: 'Abstract Canvas Art',
        description: 'Original abstract painting on canvas.',
        price: 250.00,
        category: 'Paintings',
        imageUrl:
            'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=400',
        artisanName: 'Emma Wilson',
        rating: 4.4,
        reviewCount: 9,
        inStock: true,
      ),
      Product(
        id: 'prod_006',
        name: 'Ceramic Vase Set',
        description: 'Set of 3 decorative ceramic vases in earth tones.',
        price: 85.00,
        category: 'Ceramics',
        imageUrl:
            'https://images.unsplash.com/photo-1578500351865-d5cd75c09449?w=400',
        artisanName: 'David Lee',
        rating: 4.2,
        reviewCount: 12,
        inStock: true,
      ),
      Product(
        id: 'prod_007',
        name: 'Handknit Wool Scarf',
        description: 'Soft merino wool scarf in natural colors.',
        price: 35.00,
        category: 'Textiles',
        imageUrl:
            'https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?w=400',
        artisanName: 'Lisa Anderson',
        rating: 4.9,
        reviewCount: 27,
        inStock: true,
      ),
      Product(
        id: 'prod_008',
        name: 'Copper Bracelet',
        description: 'Handforged copper bracelet with healing properties.',
        price: 28.00,
        category: 'Jewelry',
        imageUrl:
            'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=400',
        artisanName: 'Robert Taylor',
        rating: 3.8,
        reviewCount: 22,
        inStock: true,
      ),
      Product(
        id: 'prod_009',
        name: 'Bamboo Cutting Board',
        description: 'Eco-friendly bamboo cutting board with juice groove.',
        price: 42.00,
        category: 'Woodwork',
        imageUrl:
            'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400',
        artisanName: 'Grace Kim',
        rating: 4.5,
        reviewCount: 19,
        inStock: false,
      ),
      Product(
        id: 'prod_010',
        name: 'Landscape Oil Painting',
        description: 'Beautiful mountain landscape in oil on canvas.',
        price: 450.00,
        category: 'Paintings',
        imageUrl:
            'https://images.unsplash.com/photo-1544967882-7ad5ac882d5d?w=400',
        artisanName: 'Thomas Brown',
        rating: 4.8,
        reviewCount: 7,
        inStock: true,
      ),
      Product(
        id: 'prod_011',
        name: 'Glazed Dinner Set',
        description: 'Complete dinner set for 4 with unique glaze finish.',
        price: 120.00,
        category: 'Ceramics',
        imageUrl:
            'https://images.unsplash.com/photo-1574493264050-9b5b8086b24c?w=400',
        artisanName: 'Ana Garcia',
        rating: 4.6,
        reviewCount: 33,
        inStock: true,
      ),
      Product(
        id: 'prod_012',
        name: 'Embroidered Throw Pillow',
        description: 'Hand-embroidered decorative pillow with floral design.',
        price: 55.00,
        category: 'Textiles',
        imageUrl:
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
        artisanName: 'Nancy White',
        rating: 4.3,
        reviewCount: 16,
        inStock: true,
      ),
      Product(
        id: 'prod_013',
        name: 'Gold-plated Earrings',
        description: 'Elegant dangling earrings with gold plating.',
        price: 95.00,
        category: 'Jewelry',
        imageUrl:
            'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=400',
        artisanName: 'Jennifer Davis',
        rating: 4.7,
        reviewCount: 25,
        inStock: true,
      ),
      Product(
        id: 'prod_014',
        name: 'Reclaimed Wood Shelf',
        description: 'Floating shelf made from reclaimed barn wood.',
        price: 68.00,
        category: 'Woodwork',
        imageUrl:
            'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?w=400',
        artisanName: 'Mark Wilson',
        rating: 4.1,
        reviewCount: 14,
        inStock: true,
      ),
      Product(
        id: 'prod_015',
        name: 'Watercolor Flower Art',
        description: 'Delicate watercolor painting of spring flowers.',
        price: 125.00,
        category: 'Paintings',
        imageUrl:
            'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400',
        artisanName: 'Sophie Martin',
        rating: 4.4,
        reviewCount: 11,
        inStock: false,
      ),
    ];
  }

  /// Adds sample task data for testing real-time listeners
  Future<void> populateSampleTasks() async {
    try {
      final tasks = [
        {
          'title': 'Update product catalog',
          'status': 'In Progress',
          'priority': 1,
          'createdAt': Timestamp.now(),
        },
        {
          'title': 'Process customer orders',
          'status': 'Completed',
          'priority': 2,
          'createdAt': Timestamp.now(),
        },
        {
          'title': 'Inventory management',
          'status': 'Pending',
          'priority': 3,
          'createdAt': Timestamp.now(),
        },
      ];

      WriteBatch batch = _db.batch();

      for (int i = 0; i < tasks.length; i++) {
        DocumentReference docRef = _db.collection('tasks').doc('task_${i + 1}');
        batch.set(docRef, tasks[i]);
      }

      await batch.commit();
      print('Sample tasks added to Firestore successfully!');
    } catch (e) {
      print('Error adding sample tasks: $e');
      rethrow;
    }
  }
}

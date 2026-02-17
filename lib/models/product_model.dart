import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_variant_model.dart';
import 'bulk_pricing_tier.dart';

class ProductModel {
  final String productId;
  final String shopId;
  final String artisanId;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final List<String> images;
  final int stock;
  final bool isAvailable;
  final String category;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double averageRating;
  final int reviewCount;
  final List<ProductVariantModel> variants;
  final bool hasVariants;
  final List<BulkPricingTier> bulkPricingTiers;
  final int viewCount;
  final int purchaseCount;

  ProductModel({
    required this.productId,
    required this.shopId,
    required this.artisanId,
    required this.name,
    this.description = '',
    required this.price,
    this.imageUrl,
    this.images = const [],
    this.stock = 0,
    this.isAvailable = true,
    this.category = 'Other',
    required this.createdAt,
    this.updatedAt,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.variants = const [],
    this.bulkPricingTiers = const [],
    this.hasVariants = false,
    this.viewCount = 0,
    this.purchaseCount = 0,
  });

  // Get product URL
  String get productUrl => 'https://craftconnect.app/product/$productId';

  // Check if in stock
  bool get inStock => hasVariants
      ? variants.any((variant) => variant.inStock)
      : (stock > 0 && isAvailable);

  // Get total stock (including variants)
  int get totalStock => hasVariants
      ? variants.fold(0, (total, variant) => total + variant.stock)
      : stock;

  // Calculate trending score (views × 1 + purchases × 10)
  double get trendingScore => (viewCount * 1.0) + (purchaseCount * 10.0);

  // C
  bool get hasBulkPricing => bulkPricingTiers.isNotEmpty;

  // Get applicable bulk pricing for a quantity
  BulkPricingTier? getBulkPricingForQuantity(int quantity) {
    if (!hasBulkPricing) return null;

    // Sort tiers by minQuantity descending to find the highest applicable tier
    final sortedTiers = List<BulkPricingTier>.from(bulkPricingTiers)
      ..sort((a, b) => b.minQuantity.compareTo(a.minQuantity));

    // Find the first tier where quantity meets minimum
    for (final tier in sortedTiers) {
      if (quantity >= tier.minQuantity) {
        return tier;
      }
    }

    return null;
  }

  // Get discounted price for quantity (considering bulk pricing)
  double getPriceForQuantity(int quantity) {
    final bulkTier = getBulkPricingForQuantity(quantity);
    if (bulkTier != null) {
      return bulkTier.getDiscountedPrice(price);
    }
    return price;
  }

  // Get total price for quantity (considering bulk pricing)
  double getTotalPriceForQuantity(int quantity) {
    return getPriceForQuantity(quantity) * quantity;
  }

  // C
  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'shopId': shopId,
      'artisanId': artisanId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'images': images,
      'stock': stock,
      'isAvailable': isAvailable,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'hasVariants': hasVariants,
      'variants': variants.map((variant) => variant.toMap()).toList(),
      'bulkPricingTiers': bulkPricingTiers.map((tier) => tier.toMap()).toList(),
      'viewCount': viewCount,
      'purchaseCount': purchaseCount,
    };
  }

  // Create from Firestore document
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['productId'] ?? '',
      shopId: map['shopId'] ?? '',
      artisanId: map['artisanId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'],
      images: List<String>.from(map['images'] ?? []),
      stock: (map['stock'] ?? 0) as int,
      isAvailable: map['isAvailable'] ?? true,
      category: map['category'] ?? 'Other',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      reviewCount: (map['reviewCount'] ?? 0) as int,
      hasVariants: map['hasVariants'] ?? false,
      variants: map['variants'] != null
          ? (map['variants'] as List)
              .map((v) => ProductVariantModel.fromMap(v))
              .toList()
          : [],
      bulkPricingTiers: map['bulkPricingTiers'] != null
          ? (map['bulkPricingTiers'] as List)
              .map((t) => BulkPricingTier.fromMap(t))
              .toList()
          : [],
      viewCount: (map['viewCount'] ?? 0) as int,
      purchaseCount: (map['purchaseCount'] ?? 0) as int,
    );
  }

  // Create from Firestore DocumentSnapshot
  factory ProductModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromMap(data);
  }

  // Copy with method
  ProductModel copyWith({
    String? productId,
    String? shopId,
    String? artisanId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    List<String>? images,
    int? stock,
    bool? isAvailable,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? averageRating,
    int? reviewCount,
    List<ProductVariantModel>? variants,
    bool? hasVariants,
    List<BulkPricingTier>? bulkPricingTiers,
    int? viewCount,
    int? purchaseCount,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      shopId: shopId ?? this.shopId,
      artisanId: artisanId ?? this.artisanId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      variants: variants ?? this.variants,
      hasVariants: hasVariants ?? this.hasVariants,
      bulkPricingTiers: bulkPricingTiers ?? this.bulkPricingTiers,
      viewCount: viewCount ?? this.viewCount,
      purchaseCount: purchaseCount ?? this.purchaseCount,
    );
  }
}

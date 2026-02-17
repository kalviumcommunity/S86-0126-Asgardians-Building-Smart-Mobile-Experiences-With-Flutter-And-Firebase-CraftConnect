import 'package:cloud_firestore/cloud_firestore.dart';

class ProductVariantModel {
  final String variantId;
  final String productId;
  final String name; // e.g., "Red - Large", "Blue - Medium"
  final Map<String, String>
      attributes; // e.g., {"color": "Red", "size": "Large"}
  final double? priceAdjustment; // Additional price for this variant
  final int stock;
  final bool isAvailable;
  final String? imageUrl;
  final DateTime createdAt;

  ProductVariantModel({
    required this.variantId,
    required this.productId,
    required this.name,
    this.attributes = const {},
    this.priceAdjustment,
    this.stock = 0,
    this.isAvailable = true,
    this.imageUrl,
    required this.createdAt,
  });

  // Check if in stock
  bool get inStock => stock > 0 && isAvailable;

  // Get final price with adjustments
  double getFinalPrice(double basePrice) {
    return basePrice + (priceAdjustment ?? 0);
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'variantId': variantId,
      'productId': productId,
      'name': name,
      'attributes': attributes,
      'priceAdjustment': priceAdjustment,
      'stock': stock,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory ProductVariantModel.fromMap(Map<String, dynamic> map) {
    return ProductVariantModel(
      variantId: map['variantId'] ?? '',
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      attributes: Map<String, String>.from(map['attributes'] ?? {}),
      priceAdjustment: map['priceAdjustment']?.toDouble(),
      stock: map['stock'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Create from Firestore DocumentSnapshot
  factory ProductVariantModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductVariantModel.fromMap(data);
  }

  // Copy with method
  ProductVariantModel copyWith({
    String? variantId,
    String? productId,
    String? name,
    Map<String, String>? attributes,
    double? priceAdjustment,
    int? stock,
    bool? isAvailable,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return ProductVariantModel(
      variantId: variantId ?? this.variantId,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      attributes: attributes ?? this.attributes,
      priceAdjustment: priceAdjustment ?? this.priceAdjustment,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductVariantModel && other.variantId == variantId;
  }

  @override
  int get hashCode => variantId.hashCode;
}

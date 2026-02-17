class BulkPricingTier {
  final int minQuantity;
  final double discountPercentage; // Percentage discount (0-100)

  BulkPricingTier({
    required this.minQuantity,
    required this.discountPercentage,
  });

  // Calculate discounted price
  double getDiscountedPrice(double basePrice) {
    return basePrice * (1 - discountPercentage / 100);
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'minQuantity': minQuantity,
      'discountPercentage': discountPercentage,
    };
  }

  // Create from Map
  factory BulkPricingTier.fromMap(Map<String, dynamic> map) {
    return BulkPricingTier(
      minQuantity: map['minQuantity'] ?? 0,
      discountPercentage: (map['discountPercentage'] ?? 0).toDouble(),
    );
  }

  // Copy with method
  BulkPricingTier copyWith({
    int? minQuantity,
    double? discountPercentage,
  }) {
    return BulkPricingTier(
      minQuantity: minQuantity ?? this.minQuantity,
      discountPercentage: discountPercentage ?? this.discountPercentage,
    );
  }
}

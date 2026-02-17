import 'package:cloud_firestore/cloud_firestore.dart';

enum CouponType {
  percentage,
  fixedAmount,
  freeShipping,
}

class CouponModel {
  final String couponId;
  final String code;
  final String title;
  final String description;
  final CouponType type;
  final double value; // percentage (0-100) or fixed amount
  final double minOrderAmount;
  final double? maxDiscountAmount; // for percentage coupons
  final DateTime startDate;
  final DateTime endDate;
  final int usageLimit;
  final int usedCount;
  final bool isActive;
  final List<String> applicableCategories; // empty means all categories
  final List<String> excludedProducts;
  final bool isFirstTimeOnly;
  final DateTime createdAt;

  CouponModel({
    required this.couponId,
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    this.minOrderAmount = 0,
    this.maxDiscountAmount,
    required this.startDate,
    required this.endDate,
    this.usageLimit = -1, // -1 means unlimited
    this.usedCount = 0,
    this.isActive = true,
    this.applicableCategories = const [],
    this.excludedProducts = const [],
    this.isFirstTimeOnly = false,
    required this.createdAt,
  });

  // Check if coupon is valid
  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        (usageLimit == -1 || usedCount < usageLimit);
  }

  // Check if coupon is applicable for given order amount and category
  bool isApplicableFor({
    required double orderAmount,
    String? category,
    List<String> productIds = const [],
    bool isFirstTimeUser = false,
  }) {
    if (!isValid) return false;
    if (orderAmount < minOrderAmount) return false;
    if (isFirstTimeOnly && !isFirstTimeUser) return false;

    // Check category restrictions
    if (applicableCategories.isNotEmpty && category != null) {
      if (!applicableCategories.contains(category)) return false;
    }

    // Check product exclusions
    if (excludedProducts.isNotEmpty && productIds.isNotEmpty) {
      for (String productId in productIds) {
        if (excludedProducts.contains(productId)) return false;
      }
    }

    return true;
  }

  // Calculate discount amount
  double calculateDiscount(double orderAmount) {
    if (!isValid) return 0;
    if (orderAmount < minOrderAmount) return 0;

    switch (type) {
      case CouponType.percentage:
        double discount = orderAmount * (value / 100);
        if (maxDiscountAmount != null && discount > maxDiscountAmount!) {
          return maxDiscountAmount!;
        }
        return discount;

      case CouponType.fixedAmount:
        return value > orderAmount ? orderAmount : value;

      case CouponType.freeShipping:
        return value; // shipping cost
    }
  }

  // Get formatted discount text
  String get discountText {
    switch (type) {
      case CouponType.percentage:
        return '${value.toInt()}% OFF';
      case CouponType.fixedAmount:
        return '₹${value.toInt()} OFF';
      case CouponType.freeShipping:
        return 'FREE SHIPPING';
    }
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'couponId': couponId,
      'code': code,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'value': value,
      'minOrderAmount': minOrderAmount,
      'maxDiscountAmount': maxDiscountAmount,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'isActive': isActive,
      'applicableCategories': applicableCategories,
      'excludedProducts': excludedProducts,
      'isFirstTimeOnly': isFirstTimeOnly,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory CouponModel.fromMap(Map<String, dynamic> map) {
    return CouponModel(
      couponId: map['couponId'] ?? '',
      code: map['code'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: CouponType.values.firstWhere(
        (t) => t.toString().split('.').last == map['type'],
        orElse: () => CouponType.percentage,
      ),
      value: (map['value'] ?? 0).toDouble(),
      minOrderAmount: (map['minOrderAmount'] ?? 0).toDouble(),
      maxDiscountAmount: map['maxDiscountAmount']?.toDouble(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      usageLimit: map['usageLimit'] ?? -1,
      usedCount: map['usedCount'] ?? 0,
      isActive: map['isActive'] ?? true,
      applicableCategories:
          List<String>.from(map['applicableCategories'] ?? []),
      excludedProducts: List<String>.from(map['excludedProducts'] ?? []),
      isFirstTimeOnly: map['isFirstTimeOnly'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Create from Firestore DocumentSnapshot
  factory CouponModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CouponModel.fromMap(data);
  }

  // Copy with method
  CouponModel copyWith({
    String? couponId,
    String? code,
    String? title,
    String? description,
    CouponType? type,
    double? value,
    double? minOrderAmount,
    double? maxDiscountAmount,
    DateTime? startDate,
    DateTime? endDate,
    int? usageLimit,
    int? usedCount,
    bool? isActive,
    List<String>? applicableCategories,
    List<String>? excludedProducts,
    bool? isFirstTimeOnly,
    DateTime? createdAt,
  }) {
    return CouponModel(
      couponId: couponId ?? this.couponId,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      isActive: isActive ?? this.isActive,
      applicableCategories: applicableCategories ?? this.applicableCategories,
      excludedProducts: excludedProducts ?? this.excludedProducts,
      isFirstTimeOnly: isFirstTimeOnly ?? this.isFirstTimeOnly,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CouponModel && other.couponId == couponId;
  }

  @override
  int get hashCode => couponId.hashCode;
}

import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  newOrder,
  accepted,
  shipped,
  completed,
  cancelled,
}

enum PaymentStatus {
  pending,
  success,
  failed,
}

class OrderModel {
  final String orderId;
  final String productId;
  final String shopId;
  final String artisanId;
  final String buyerId;
  final String buyerName;
  final String buyerPhone;
  final String buyerAddress;
  final int quantity;
  final double totalAmount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String paymentMethod;
  final String? upiId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool hasGiftWrapping;
  final String? giftMessage;
  final double giftWrappingCharge;

  OrderModel({
    required this.orderId,
    required this.productId,
    required this.shopId,
    required this.artisanId,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    required this.buyerAddress,
    this.quantity = 1,
    required this.totalAmount,
    this.status = OrderStatus.newOrder,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentMethod = 'upi',
    this.upiId,
    required this.createdAt,
    this.updatedAt,
    this.hasGiftWrapping = false,
    this.giftMessage,
    this.giftWrappingCharge = 0,
  });

  // Get status display text
  String get statusText {
    switch (status) {
      case OrderStatus.newOrder:
        return 'New Order';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Get payment status display text
  String get paymentStatusText {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.success:
        return 'Success';
      case PaymentStatus.failed:
        return 'Failed';
    }
  }

  // Check if order can be cancelled
  bool get canBeCancelled {
    return status == OrderStatus.newOrder || status == OrderStatus.accepted;
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'productId': productId,
      'shopId': shopId,
      'artisanId': artisanId,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'buyerAddress': buyerAddress,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'paymentMethod': paymentMethod,
      'upiId': upiId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'hasGiftWrapping': hasGiftWrapping,
      'giftMessage': giftMessage,
      'giftWrappingCharge': giftWrappingCharge,
    };
  }

  // Convert to JSON for local storage (SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'productId': productId,
      'shopId': shopId,
      'artisanId': artisanId,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'buyerAddress': buyerAddress,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'paymentMethod': paymentMethod,
      'upiId': upiId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'hasGiftWrapping': hasGiftWrapping,
      'giftMessage': giftMessage,
      'giftWrappingCharge': giftWrappingCharge,
    };
  }

  // Create from JSON (for local storage)
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'] ?? '',
      productId: json['productId'] ?? '',
      shopId: json['shopId'] ?? '',
      artisanId: json['artisanId'] ?? '',
      buyerId: json['buyerId'] ?? '',
      buyerName: json['buyerName'] ?? '',
      buyerPhone: json['buyerPhone'] ?? '',
      buyerAddress: json['buyerAddress'] ?? '',
      quantity: json['quantity'] ?? 1,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.newOrder,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentMethod: json['paymentMethod'] ?? 'upi',
      upiId: json['upiId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      hasGiftWrapping: json['hasGiftWrapping'] ?? false,
      giftMessage: json['giftMessage'],
      giftWrappingCharge: (json['giftWrappingCharge'] ?? 0).toDouble(),
    );
  }

  // Create from Firestore document
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      productId: map['productId'] ?? '',
      shopId: map['shopId'] ?? '',
      artisanId: map['artisanId'] ?? '',
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      buyerPhone: map['buyerPhone'] ?? '',
      buyerAddress: map['buyerAddress'] ?? '',
      quantity: map['quantity'] ?? 1,
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.newOrder,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentMethod: map['paymentMethod'] ?? 'upi',
      upiId: map['upiId'],
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? ((map['updatedAt'] is Timestamp)
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(map['updatedAt']))
          : null,
      hasGiftWrapping: map['hasGiftWrapping'] ?? false,
      giftMessage: map['giftMessage'],
      giftWrappingCharge: (map['giftWrappingCharge'] ?? 0).toDouble(),
    );
  }

  // Create from Firestore DocumentSnapshot
  factory OrderModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel.fromMap(data);
  }

  // Copy with method
  OrderModel copyWith({
    String? orderId,
    String? productId,
    String? shopId,
    String? artisanId,
    String? buyerId,
    String? buyerName,
    String? buyerPhone,
    String? buyerAddress,
    int? quantity,
    double? totalAmount,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentMethod,
    String? upiId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasGiftWrapping,
    String? giftMessage,
    double? giftWrappingCharge,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      shopId: shopId ?? this.shopId,
      artisanId: artisanId ?? this.artisanId,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      buyerAddress: buyerAddress ?? this.buyerAddress,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      upiId: upiId ?? this.upiId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasGiftWrapping: hasGiftWrapping ?? this.hasGiftWrapping,
      giftMessage: giftMessage ?? this.giftMessage,
      giftWrappingCharge: giftWrappingCharge ?? this.giftWrappingCharge,
    );
  }
}

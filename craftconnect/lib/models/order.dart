class Order {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double totalPrice;
  final DateTime orderDate;
  final OrderStatus status;
  final String deliveryAddress;
  final String artisanName;

  Order({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
    required this.orderDate,
    required this.status,
    required this.deliveryAddress,
    required this.artisanName,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      orderDate: DateTime.parse(
        json['orderDate'] ?? DateTime.now().toIso8601String(),
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: json['deliveryAddress'] ?? '',
      artisanName: json['artisanName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'orderDate': orderDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'deliveryAddress': deliveryAddress,
      'artisanName': artisanName,
    };
  }
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

class CartItemModel {
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final int quantity;
  final String artisanId;
  final String shopId;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.artisanId,
    required this.shopId,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'imageUrl': imageUrl,
        'price': price,
        'quantity': quantity,
        'artisanId': artisanId,
        'shopId': shopId,
      };

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        productId: json['productId'] ?? '',
        productName: json['productName'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        quantity: json['quantity'] ?? 1,
        artisanId: json['artisanId'] ?? '',
        shopId: json['shopId'] ?? '',
      );

  CartItemModel copyWith({
    String? productId,
    String? productName,
    String? imageUrl,
    double? price,
    int? quantity,
    String? artisanId,
    String? shopId,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      artisanId: artisanId ?? this.artisanId,
      shopId: shopId ?? this.shopId,
    );
  }
}

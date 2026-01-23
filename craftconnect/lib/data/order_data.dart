import '../models/order.dart';

class OrderData {
  static List<Order> getSampleOrders() {
    return [
      Order(
        id: 'ORD001',
        productId: '1',
        productName: 'Handwoven Basket',
        quantity: 2,
        totalPrice: 91.98,
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        status: OrderStatus.shipped,
        deliveryAddress: '123 Main St, New York, NY 10001',
        artisanName: 'Maria Santos',
      ),
      Order(
        id: 'ORD002',
        productId: '3',
        productName: 'Leather Wallet',
        quantity: 1,
        totalPrice: 35.50,
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        status: OrderStatus.delivered,
        deliveryAddress: '456 Oak Ave, Brooklyn, NY 11201',
        artisanName: 'David Craft',
      ),
      Order(
        id: 'ORD003',
        productId: '5',
        productName: 'Macrame Plant Hanger',
        quantity: 3,
        totalPrice: 86.97,
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        status: OrderStatus.processing,
        deliveryAddress: '789 Pine Rd, Queens, NY 11101',
        artisanName: 'Emma Thread',
      ),
      Order(
        id: 'ORD004',
        productId: '2',
        productName: 'Ceramic Pottery Set',
        quantity: 1,
        totalPrice: 89.99,
        orderDate: DateTime.now().subtract(const Duration(hours: 12)),
        status: OrderStatus.confirmed,
        deliveryAddress: '321 Elm St, Manhattan, NY 10002',
        artisanName: 'John Maker',
      ),
      Order(
        id: 'ORD005',
        productId: '6',
        productName: 'Knitted Wool Scarf',
        quantity: 2,
        totalPrice: 84.00,
        orderDate: DateTime.now().subtract(const Duration(days: 10)),
        status: OrderStatus.delivered,
        deliveryAddress: '654 Maple Dr, Bronx, NY 10451',
        artisanName: 'Lisa Knits',
      ),
    ];
  }
}

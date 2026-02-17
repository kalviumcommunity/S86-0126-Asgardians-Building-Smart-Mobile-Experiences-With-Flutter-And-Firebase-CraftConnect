import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

class OrderProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  static const String _storageKey = 'cached_orders';

  OrderProvider() {
    _initProvider();
  }

  Future<void> _initProvider() async {
    await loadFromStorage();
  }

  List<OrderModel> _orders = [];
  OrderModel? _currentOrder;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<OrderModel> get orders => _orders;
  OrderModel? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filtered orders by status
  List<OrderModel> get newOrders =>
      _orders.where((o) => o.status == OrderStatus.newOrder).toList();
  List<OrderModel> get acceptedOrders =>
      _orders.where((o) => o.status == OrderStatus.accepted).toList();
  List<OrderModel> get shippedOrders =>
      _orders.where((o) => o.status == OrderStatus.shipped).toList();
  List<OrderModel> get completedOrders =>
      _orders.where((o) => o.status == OrderStatus.completed).toList();

  // Create order
  Future<String?> createOrder({
    required String productId,
    required String shopId,
    required String artisanId,
    required String buyerId,
    required String buyerName,
    required String buyerPhone,
    required String buyerAddress,
    required int quantity,
    required double totalAmount,
    String? upiId,
    bool hasGiftWrapping = false,
    String? giftMessage,
    double giftWrappingCharge = 0,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final orderId = const Uuid().v4();

      final order = OrderModel(
        orderId: orderId,
        productId: productId,
        shopId: shopId,
        artisanId: artisanId,
        buyerId: buyerId,
        buyerName: buyerName,
        buyerPhone: buyerPhone,
        buyerAddress: buyerAddress,
        quantity: quantity,
        totalAmount: totalAmount,
        upiId: upiId,
        createdAt: DateTime.now(),
        hasGiftWrapping: hasGiftWrapping,
        giftMessage: giftMessage,
        giftWrappingCharge: giftWrappingCharge,
      );

      await _firestoreService.createOrder(order);

      _currentOrder = order;
      _orders.insert(0, order);
      await _saveToStorage();
      _isLoading = false;
      notifyListeners();
      return orderId;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    Future.microtask(() => notifyListeners());

    try {
      final order = await _firestoreService.getOrderById(orderId);
      _currentOrder = order;
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Get orders by artisan
  Future<void> getOrdersByArtisan(String artisanId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _firestoreService.getOrdersByArtisan(artisanId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get orders by shop
  Future<void> getOrdersByShop(String shopId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _firestoreService.getOrdersByShop(shopId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get orders by buyer
  Future<void> getOrdersByBuyer(String buyerId) async {
    _isLoading = true;
    _errorMessage = null;
    Future.microtask(() => notifyListeners());

    try {
      _orders = await _firestoreService.getOrdersByBuyer(buyerId);
      await _saveToStorage();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateOrderStatus(orderId, status);

      // Update in local list
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
      }

      // Update current order if it's the same
      if (_currentOrder?.orderId == orderId) {
        _currentOrder = _currentOrder!.copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Accept order
  Future<bool> acceptOrder(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.accepted);
  }

  // Ship order
  Future<bool> shipOrder(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.shipped);
  }

  // Complete order
  Future<bool> completeOrder(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.completed);
  }

  // Update payment status
  Future<bool> updatePaymentStatus(
    String orderId,
    PaymentStatus paymentStatus,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updatePaymentStatus(orderId, paymentStatus);

      // Update in local list
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          paymentStatus: paymentStatus,
          updatedAt: DateTime.now(),
        );
      }

      // Update current order if it's the same
      if (_currentOrder?.orderId == orderId) {
        _currentOrder = _currentOrder!.copyWith(
          paymentStatus: paymentStatus,
          updatedAt: DateTime.now(),
        );
      }

      await _saveToStorage();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get all orders (admin)
  Future<void> getAllOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _firestoreService.getAllOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Stream orders by artisan
  Stream<List<OrderModel>> streamOrdersByArtisan(String artisanId) {
    return _firestoreService.streamOrdersByArtisan(artisanId);
  }

  // Stream order by ID
  Stream<OrderModel?> streamOrderById(String orderId) {
    return _firestoreService.streamOrderById(orderId);
  }

  // Cancel order (buyer can cancel if status is new or accepted)
  Future<bool> cancelOrderByBuyer(String orderId) async {
    try {
      final order = await _firestoreService.getOrderById(orderId);
      if (order == null) return false;

      // Only allow cancellation for new or accepted orders
      if (order.status != OrderStatus.newOrder &&
          order.status != OrderStatus.accepted) {
        _errorMessage = 'Order cannot be cancelled at this stage';
        notifyListeners();
        return false;
      }

      await _firestoreService.updateOrderStatus(orderId, OrderStatus.cancelled);

      // Update local orders list
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: OrderStatus.cancelled);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Set current order
  void setCurrentOrder(OrderModel order) {
    _currentOrder = order;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear data
  void clear() {
    _orders = [];
    _currentOrder = null;
    _errorMessage = null;
    _clearStorage();
    notifyListeners();
  }

  // Local Storage Methods
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _orders.map((o) => o.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(data));
    } catch (e) {
      debugPrint('Error saving orders to storage: $e');
    }
  }

  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);
      if (data != null) {
        final List<dynamic> jsonList = json.decode(data);
        _orders = jsonList.map((j) => OrderModel.fromJson(j)).toList();
        Future.microtask(() => notifyListeners());
      }
    } catch (e) {
      debugPrint('Error loading orders from storage: $e');
    }
  }

  Future<void> _clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint('Error clearing order storage: $e');
    }
  }

  // Cancel Order
  Future<bool> cancelOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.updateOrderStatus(orderId, OrderStatus.cancelled);

      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: OrderStatus.cancelled);
      }

      if (_currentOrder?.orderId == orderId) {
        _currentOrder = _currentOrder!.copyWith(status: OrderStatus.cancelled);
      }

      await _saveToStorage();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete Order
  Future<bool> deleteOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.deleteOrder(orderId);

      _orders.removeWhere((o) => o.orderId == orderId);

      if (_currentOrder?.orderId == orderId) {
        _currentOrder = null;
      }

      await _saveToStorage();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

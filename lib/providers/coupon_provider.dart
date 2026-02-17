import 'package:flutter/foundation.dart';
import '../models/coupon_model.dart';
import '../services/firestore_service.dart';

class CouponProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CouponModel> _coupons = [];
  List<CouponModel> _userCoupons = [];
  CouponModel? _appliedCoupon;
  bool _isLoading = false;
  String? _error;

  List<CouponModel> get coupons => List.unmodifiable(_coupons);
  List<CouponModel> get userCoupons => List.unmodifiable(_userCoupons);
  CouponModel? get appliedCoupon => _appliedCoupon;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all active coupons
  Future<void> getAllCoupons() async {
    _setLoading(true);
    try {
      _coupons = await _firestoreService.getAllCoupons();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error getting coupons: $e');
    }
    _setLoading(false);
  }

  // Get user-specific coupons
  Future<void> getUserCoupons(String userId) async {
    _setLoading(true);
    try {
      _userCoupons = await _firestoreService.getUserCoupons(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error getting user coupons: $e');
    }
    _setLoading(false);
  }

  // Apply coupon
  Future<bool> applyCoupon({
    required String couponCode,
    required double orderAmount,
    String? category,
    List<String> productIds = const [],
    bool isFirstTimeUser = false,
  }) async {
    try {
      // Find coupon by code
      final coupon = await _firestoreService.getCouponByCode(couponCode);
      if (coupon == null) {
        _error = 'Invalid coupon code';
        notifyListeners();
        return false;
      }

      // Check if coupon is applicable
      if (!coupon.isApplicableFor(
        orderAmount: orderAmount,
        category: category,
        productIds: productIds,
        isFirstTimeUser: isFirstTimeUser,
      )) {
        _error = _getCouponErrorMessage(coupon, orderAmount, isFirstTimeUser);
        notifyListeners();
        return false;
      }

      _appliedCoupon = coupon;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error applying coupon: $e';
      notifyListeners();
      return false;
    }
  }

  // Remove applied coupon
  void removeCoupon() {
    _appliedCoupon = null;
    _error = null;
    notifyListeners();
  }

  // Get discount amount for current applied coupon
  double getDiscountAmount(double orderAmount) {
    if (_appliedCoupon == null) return 0;
    return _appliedCoupon!.calculateDiscount(orderAmount);
  }

  // Mark coupon as used
  Future<void> markCouponAsUsed(String couponId) async {
    try {
      await _firestoreService.incrementCouponUsage(couponId);

      // Update local coupon data
      final index = _coupons.indexWhere((c) => c.couponId == couponId);
      if (index != -1) {
        _coupons[index] = _coupons[index].copyWith(
          usedCount: _coupons[index].usedCount + 1,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error marking coupon as used: $e');
    }
  }

  // Get applicable coupons for order
  List<CouponModel> getApplicableCoupons({
    required double orderAmount,
    String? category,
    List<String> productIds = const [],
    bool isFirstTimeUser = false,
  }) {
    return _coupons.where((coupon) {
      return coupon.isApplicableFor(
        orderAmount: orderAmount,
        category: category,
        productIds: productIds,
        isFirstTimeUser: isFirstTimeUser,
      );
    }).toList();
  }

  // Get best coupon for order (highest discount)
  CouponModel? getBestCoupon({
    required double orderAmount,
    String? category,
    List<String> productIds = const [],
    bool isFirstTimeUser = false,
  }) {
    final applicableCoupons = getApplicableCoupons(
      orderAmount: orderAmount,
      category: category,
      productIds: productIds,
      isFirstTimeUser: isFirstTimeUser,
    );

    if (applicableCoupons.isEmpty) return null;

    return applicableCoupons.reduce((a, b) {
      final discountA = a.calculateDiscount(orderAmount);
      final discountB = b.calculateDiscount(orderAmount);
      return discountA > discountB ? a : b;
    });
  }

  String _getCouponErrorMessage(
      CouponModel coupon, double orderAmount, bool isFirstTimeUser) {
    if (!coupon.isValid) {
      if (DateTime.now().isAfter(coupon.endDate)) {
        return 'This coupon has expired';
      }
      if (DateTime.now().isBefore(coupon.startDate)) {
        return 'This coupon is not yet active';
      }
      if (coupon.usageLimit != -1 && coupon.usedCount >= coupon.usageLimit) {
        return 'This coupon has reached its usage limit';
      }
      return 'This coupon is not active';
    }

    if (orderAmount < coupon.minOrderAmount) {
      return 'Minimum order amount is ₹${coupon.minOrderAmount.toInt()}';
    }

    if (coupon.isFirstTimeOnly && !isFirstTimeUser) {
      return 'This coupon is only for first-time users';
    }

    return 'This coupon is not applicable for your order';
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Create new coupon (Admin)
  Future<bool> createCoupon(CouponModel coupon) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.createCoupon(coupon);
      _coupons.add(coupon);

      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update coupon (Admin)
  Future<bool> updateCoupon(CouponModel coupon) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.updateCoupon(coupon);

      final index = _coupons.indexWhere((c) => c.couponId == coupon.couponId);
      if (index != -1) {
        _coupons[index] = coupon;
      }

      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete coupon (Admin)
  Future<bool> deleteCoupon(String couponId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.deleteCoupon(couponId);
      _coupons.removeWhere((c) => c.couponId == couponId);

      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/return_request_model.dart';
import '../services/firestore_service.dart';

class ReturnProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  List<ReturnRequestModel> _returns = [];
  ReturnRequestModel? _currentReturn;
  bool _isLoading = false;
  String? _error;

  List<ReturnRequestModel> get returns => _returns;
  ReturnRequestModel? get currentReturn => _currentReturn;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get returns by status
  List<ReturnRequestModel> get pendingReturns =>
      _returns.where((r) => r.status == ReturnStatus.requested).toList();

  List<ReturnRequestModel> get approvedReturns =>
      _returns.where((r) => r.status == ReturnStatus.approved).toList();

  List<ReturnRequestModel> get completedReturns =>
      _returns.where((r) => r.status == ReturnStatus.completed).toList();

  // Create a return request
  Future<bool> createReturnRequest({
    required String orderId,
    required String userId,
    required String productId,
    required String productName,
    required String shopId,
    required ReturnReason reason,
    String? customReason,
    required String description,
    List<String> images = const [],
    required double refundAmount,
    RefundMethod refundMethod = RefundMethod.originalPayment,
    bool isExchange = false,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final returnId = _uuid.v4();
      final returnRequest = ReturnRequestModel(
        returnId: returnId,
        orderId: orderId,
        userId: userId,
        productId: productId,
        productName: productName,
        shopId: shopId,
        reason: reason,
        customReason: customReason,
        description: description,
        images: images,
        status: ReturnStatus.requested,
        refundAmount: refundAmount,
        refundMethod: refundMethod,
        isExchange: isExchange,
        requestedAt: DateTime.now(),
      );

      await _firestoreService.createReturnRequest(returnRequest);
      _returns.add(returnRequest);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load returns for a user
  Future<void> loadUserReturns(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _firestoreService.getUserReturns(userId);
      _returns = data.map((d) => ReturnRequestModel.fromMap(d)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load returns for a shop (artisan)
  Future<void> loadShopReturns(String shopId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _firestoreService.getShopReturns(shopId);
      _returns = data.map((d) => ReturnRequestModel.fromMap(d)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all returns (admin)
  Future<void> loadAllReturns() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _firestoreService.getAllReturns();
      _returns = data.map((d) => ReturnRequestModel.fromMap(d)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get return by ID
  Future<ReturnRequestModel?> getReturnById(String returnId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _firestoreService.getReturnById(returnId);

      _isLoading = false;
      notifyListeners();
      return data != null ? ReturnRequestModel.fromMap(data) : null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update return status
  Future<bool> updateReturnStatus(
    String returnId,
    ReturnStatus status, {
    String? adminNotes,
    DateTime? approvedAt,
    DateTime? completedAt,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.updateReturnStatus(
        returnId,
        status,
        adminNotes: adminNotes,
        approvedAt: approvedAt,
        completedAt: completedAt,
      );

      // Update local list
      final index = _returns.indexWhere((r) => r.returnId == returnId);
      if (index != -1) {
        _returns[index] = _returns[index].copyWith(
          status: status,
          adminNotes: adminNotes,
          approvedAt: approvedAt,
          completedAt: completedAt,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Approve return
  Future<bool> approveReturn(String returnId, {String? adminNotes}) async {
    return updateReturnStatus(
      returnId,
      ReturnStatus.approved,
      adminNotes: adminNotes,
      approvedAt: DateTime.now(),
    );
  }

  // Reject return
  Future<bool> rejectReturn(String returnId, {String? adminNotes}) async {
    return updateReturnStatus(
      returnId,
      ReturnStatus.rejected,
      adminNotes: adminNotes,
    );
  }

  // Complete return (refund processed)
  Future<bool> completeReturn(String returnId) async {
    return updateReturnStatus(
      returnId,
      ReturnStatus.completed,
      completedAt: DateTime.now(),
    );
  }

  // Cancel return
  Future<bool> cancelReturn(String returnId) async {
    return updateReturnStatus(returnId, ReturnStatus.cancelled);
  }

  // Set current return
  void setCurrentReturn(ReturnRequestModel? returnRequest) {
    _currentReturn = returnRequest;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear all
  void clear() {
    _returns = [];
    _currentReturn = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}

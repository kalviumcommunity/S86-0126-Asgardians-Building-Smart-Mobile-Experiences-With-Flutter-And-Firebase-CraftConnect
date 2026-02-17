import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ReturnReason {
  defective,
  wrongItem,
  notAsDescribed,
  damageInTransit,
  changeOfMind,
  sizeIssue,
  qualityIssue,
  other,
}

enum ReturnStatus {
  requested,
  approved,
  rejected,
  pickupScheduled,
  pickedUp,
  inspecting,
  refunded,
  exchangeInitiated,
  completed,
  cancelled,
}

enum RefundMethod {
  originalPayment,
  walletCredit,
  bankTransfer,
}

class ReturnRequestModel {
  final String returnId;
  final String orderId;
  final String userId;
  final String productId;
  final String productName;
  final String shopId;
  final ReturnReason reason;
  final String? customReason;
  final String description;
  final List<String> images; // Photos of damaged/defective items
  final ReturnStatus status;
  final double refundAmount;
  final RefundMethod refundMethod;
  final bool isExchange;
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final DateTime? completedAt;
  final String? adminNotes;
  final String? trackingNumber;
  final Map<String, String> statusHistory; // timestamp -> status

  ReturnRequestModel({
    required this.returnId,
    required this.orderId,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.shopId,
    required this.reason,
    this.customReason,
    required this.description,
    this.images = const [],
    this.status = ReturnStatus.requested,
    required this.refundAmount,
    this.refundMethod = RefundMethod.originalPayment,
    this.isExchange = false,
    required this.requestedAt,
    this.approvedAt,
    this.completedAt,
    this.adminNotes,
    this.trackingNumber,
    this.statusHistory = const {},
  });

  // Get reason display text
  String get reasonText {
    switch (reason) {
      case ReturnReason.defective:
        return 'Product is defective';
      case ReturnReason.wrongItem:
        return 'Wrong item received';
      case ReturnReason.notAsDescribed:
        return 'Not as described';
      case ReturnReason.damageInTransit:
        return 'Damaged during shipping';
      case ReturnReason.changeOfMind:
        return 'Changed my mind';
      case ReturnReason.sizeIssue:
        return 'Size issue';
      case ReturnReason.qualityIssue:
        return 'Quality issue';
      case ReturnReason.other:
        return customReason ?? 'Other';
    }
  }

  // Get status display text
  String get statusText {
    switch (status) {
      case ReturnStatus.requested:
        return 'Return Requested';
      case ReturnStatus.approved:
        return 'Return Approved';
      case ReturnStatus.rejected:
        return 'Return Rejected';
      case ReturnStatus.pickupScheduled:
        return 'Pickup Scheduled';
      case ReturnStatus.pickedUp:
        return 'Item Picked Up';
      case ReturnStatus.inspecting:
        return 'Under Inspection';
      case ReturnStatus.refunded:
        return 'Refund Processed';
      case ReturnStatus.exchangeInitiated:
        return 'Exchange in Progress';
      case ReturnStatus.completed:
        return 'Completed';
      case ReturnStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Get status color
  Color get statusColor {
    switch (status) {
      case ReturnStatus.requested:
        return const Color(0xFFFF9800); // Orange
      case ReturnStatus.approved:
        return const Color(0xFF4CAF50); // Green
      case ReturnStatus.rejected:
      case ReturnStatus.cancelled:
        return const Color(0xFFF44336); // Red
      case ReturnStatus.pickupScheduled:
      case ReturnStatus.pickedUp:
      case ReturnStatus.inspecting:
      case ReturnStatus.exchangeInitiated:
        return const Color(0xFF2196F3); // Blue
      case ReturnStatus.refunded:
      case ReturnStatus.completed:
        return const Color(0xFF4CAF50); // Green
    }
  }

  // Check if return can be cancelled by user
  bool get canBeCancelled {
    return status == ReturnStatus.requested || status == ReturnStatus.approved;
  }

  // Check if tracking is available
  bool get hasTracking {
    return trackingNumber != null && trackingNumber!.isNotEmpty;
  }

  // Get refund method display text
  String get refundMethodText {
    switch (refundMethod) {
      case RefundMethod.originalPayment:
        return 'Original Payment Method';
      case RefundMethod.walletCredit:
        return 'Wallet Credit';
      case RefundMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'returnId': returnId,
      'orderId': orderId,
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'shopId': shopId,
      'reason': reason.toString().split('.').last,
      'customReason': customReason,
      'description': description,
      'images': images,
      'status': status.toString().split('.').last,
      'refundAmount': refundAmount,
      'refundMethod': refundMethod.toString().split('.').last,
      'isExchange': isExchange,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'adminNotes': adminNotes,
      'trackingNumber': trackingNumber,
      'statusHistory': statusHistory,
    };
  }

  // Create from Firestore document
  factory ReturnRequestModel.fromMap(Map<String, dynamic> map) {
    return ReturnRequestModel(
      returnId: map['returnId'] ?? '',
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      shopId: map['shopId'] ?? '',
      reason: ReturnReason.values.firstWhere(
        (r) => r.toString().split('.').last == map['reason'],
        orElse: () => ReturnReason.other,
      ),
      customReason: map['customReason'],
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      status: ReturnStatus.values.firstWhere(
        (s) => s.toString().split('.').last == map['status'],
        orElse: () => ReturnStatus.requested,
      ),
      refundAmount: (map['refundAmount'] ?? 0).toDouble(),
      refundMethod: RefundMethod.values.firstWhere(
        (m) => m.toString().split('.').last == map['refundMethod'],
        orElse: () => RefundMethod.originalPayment,
      ),
      isExchange: map['isExchange'] ?? false,
      requestedAt: (map['requestedAt'] as Timestamp).toDate(),
      approvedAt: map['approvedAt'] != null
          ? (map['approvedAt'] as Timestamp).toDate()
          : null,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      adminNotes: map['adminNotes'],
      trackingNumber: map['trackingNumber'],
      statusHistory: Map<String, String>.from(map['statusHistory'] ?? {}),
    );
  }

  // Create from Firestore DocumentSnapshot
  factory ReturnRequestModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReturnRequestModel.fromMap(data);
  }

  // Copy with method
  ReturnRequestModel copyWith({
    String? returnId,
    String? orderId,
    String? userId,
    String? productId,
    String? productName,
    String? shopId,
    ReturnReason? reason,
    String? customReason,
    String? description,
    List<String>? images,
    ReturnStatus? status,
    double? refundAmount,
    RefundMethod? refundMethod,
    bool? isExchange,
    DateTime? requestedAt,
    DateTime? approvedAt,
    DateTime? completedAt,
    String? adminNotes,
    String? trackingNumber,
    Map<String, String>? statusHistory,
  }) {
    return ReturnRequestModel(
      returnId: returnId ?? this.returnId,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      shopId: shopId ?? this.shopId,
      reason: reason ?? this.reason,
      customReason: customReason ?? this.customReason,
      description: description ?? this.description,
      images: images ?? this.images,
      status: status ?? this.status,
      refundAmount: refundAmount ?? this.refundAmount,
      refundMethod: refundMethod ?? this.refundMethod,
      isExchange: isExchange ?? this.isExchange,
      requestedAt: requestedAt ?? this.requestedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      completedAt: completedAt ?? this.completedAt,
      adminNotes: adminNotes ?? this.adminNotes,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReturnRequestModel && other.returnId == returnId;
  }

  @override
  int get hashCode => returnId.hashCode;
}

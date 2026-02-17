import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/environment.dart';

class ShopModel {
  final String shopId;
  final String ownerId;
  final String shopName;
  final String businessName;
  final String slug; // Unique URL-friendly identifier
  final String description;
  final String contact;
  final String contactPhone;
  final String contactEmail;
  final String? imageUrl;
  final bool isApproved;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ShopModel({
    required this.shopId,
    required this.ownerId,
    required this.shopName,
    String? businessName,
    required this.slug,
    this.description = '',
    required this.contact,
    String? contactPhone,
    String? contactEmail,
    this.imageUrl,
    this.isApproved = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  })  : businessName = businessName ?? shopName,
        contactPhone = contactPhone ?? contact,
        contactEmail = contactEmail ?? '';

  // Generate slug from shop name
  static String generateSlug(String shopName) {
    return shopName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  // Get store URL (environment-aware)
  String get storeUrl => AppEnvironment.getShopUrl(slug);

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'ownerId': ownerId,
      'shopName': shopName,
      'slug': slug,
      'description': description,
      'contact': contact,
      'imageUrl': imageUrl,
      'isApproved': isApproved,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create from Firestore document
  factory ShopModel.fromMap(Map<String, dynamic> map) {
    return ShopModel(
      shopId: map['shopId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      shopName: map['shopName'] ?? '',
      slug: map['slug'] ?? '',
      description: map['description'] ?? '',
      contact: map['contact'] ?? '',
      imageUrl: map['imageUrl'],
      isApproved: map['isApproved'] ?? false,
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Create from Firestore DocumentSnapshot
  factory ShopModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShopModel.fromMap(data);
  }

  // Copy with method
  ShopModel copyWith({
    String? shopId,
    String? ownerId,
    String? shopName,
    String? slug,
    String? description,
    String? contact,
    String? imageUrl,
    bool? isApproved,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShopModel(
      shopId: shopId ?? this.shopId,
      ownerId: ownerId ?? this.ownerId,
      shopName: shopName ?? this.shopName,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      contact: contact ?? this.contact,
      imageUrl: imageUrl ?? this.imageUrl,
      isApproved: isApproved ?? this.isApproved,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

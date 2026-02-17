import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String conversationId;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String?> participantProfilePics;
  final String? productId;
  final String? productName;
  final String? productImage;
  final String? shopId;
  final String? shopName;
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime lastMessageAt;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ConversationModel({
    required this.conversationId,
    required this.participantIds,
    required this.participantNames,
    required this.participantProfilePics,
    this.productId,
    this.productName,
    this.productImage,
    this.shopId,
    this.shopName,
    this.lastMessage = '',
    this.lastMessageSenderId = '',
    required this.lastMessageAt,
    this.unreadCount = const {},
    required this.createdAt,
    this.updatedAt,
  });

  // Get other participant's name
  String getOtherParticipantName(String currentUserId) {
    final otherUserId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    return participantNames[otherUserId] ?? 'Unknown User';
  }

  // Get other participant's profile pic
  String? getOtherParticipantProfilePic(String currentUserId) {
    final otherUserId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    return participantProfilePics[otherUserId];
  }

  // Get other participant's ID
  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  // Get unread count for user
  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantProfilePics': participantProfilePics,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'shopId': shopId,
      'shopName': shopName,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create from Firestore document
  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    try {
      return ConversationModel(
        conversationId: map['conversationId'] ?? '',
        participantIds: List<String>.from(map['participantIds'] ?? []),
        participantNames:
            Map<String, String>.from(map['participantNames'] ?? {}),
        participantProfilePics: Map<String, String?>.from(
          map['participantProfilePics'] ?? {},
        ),
        productId: map['productId'],
        productName: map['productName'],
        productImage: map['productImage'],
        shopId: map['shopId'],
        shopName: map['shopName'],
        lastMessage: map['lastMessage'] ?? '',
        lastMessageSenderId: map['lastMessageSenderId'] ?? '',
        lastMessageAt: map['lastMessageAt'] != null
            ? (map['lastMessageAt'] is Timestamp
                ? (map['lastMessageAt'] as Timestamp).toDate()
                : DateTime.parse(map['lastMessageAt']))
            : DateTime.now(),
        unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
        createdAt: map['createdAt'] != null
            ? (map['createdAt'] is Timestamp
                ? (map['createdAt'] as Timestamp).toDate()
                : DateTime.parse(map['createdAt']))
            : DateTime.now(),
        updatedAt: map['updatedAt'] != null
            ? (map['updatedAt'] is Timestamp
                ? (map['updatedAt'] as Timestamp).toDate()
                : DateTime.parse(map['updatedAt']))
            : null,
      );
    } catch (e) {
      throw 'Failed to parse ConversationModel: $e';
    }
  }

  // Create from Firestore DocumentSnapshot
  factory ConversationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel.fromMap(data);
  }

  // Copy with method
  ConversationModel copyWith({
    String? conversationId,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    Map<String, String?>? participantProfilePics,
    String? productId,
    String? productName,
    String? productImage,
    String? shopId,
    String? shopName,
    String? lastMessage,
    String? lastMessageSenderId,
    DateTime? lastMessageAt,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConversationModel(
      conversationId: conversationId ?? this.conversationId,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      participantProfilePics:
          participantProfilePics ?? this.participantProfilePics,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

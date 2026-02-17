import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  product,
  order,
}

class MessageModel {
  final String messageId;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderProfilePic;
  final String receiverId;
  final String content;
  final MessageType type;
  final String? imageUrl;
  final String? productId;
  final String? orderId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MessageModel({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderProfilePic,
    required this.receiverId,
    required this.content,
    this.type = MessageType.text,
    this.imageUrl,
    this.productId,
    this.orderId,
    this.isRead = false,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderProfilePic': senderProfilePic,
      'receiverId': receiverId,
      'content': content,
      'type': type.name,
      'imageUrl': imageUrl,
      'productId': productId,
      'orderId': orderId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create from Firestore document
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'] ?? '',
      conversationId: map['conversationId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderProfilePic: map['senderProfilePic'],
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      imageUrl: map['imageUrl'],
      productId: map['productId'],
      orderId: map['orderId'],
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Create from Firestore DocumentSnapshot
  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel.fromMap(data);
  }

  // Copy with method
  MessageModel copyWith({
    String? messageId,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderProfilePic,
    String? receiverId,
    String? content,
    MessageType? type,
    String? imageUrl,
    String? productId,
    String? orderId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderProfilePic: senderProfilePic ?? this.senderProfilePic,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      productId: productId ?? this.productId,
      orderId: orderId ?? this.orderId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

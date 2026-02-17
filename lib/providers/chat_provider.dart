import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/firestore_service.dart';

class ChatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  ConversationModel? _currentConversation;
  bool _isLoading = false;
  String? _error;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  ConversationModel? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get or create conversation between two users
  Future<ConversationModel?> getOrCreateConversation({
    required String currentUserId,
    required String currentUserName,
    String? currentUserProfilePic,
    required String otherUserId,
    required String otherUserName,
    String? otherUserProfilePic,
    String? productId,
    String? productName,
    String? productImage,
    String? shopId,
    String? shopName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());

      // Validate required fields
      if (currentUserId.isEmpty) {
        throw 'Current user ID is empty';
      }
      if (otherUserId.isEmpty) {
        throw 'Artisan ID is empty';
      }
      if (currentUserName.isEmpty) {
        throw 'Current user name is empty';
      }
      if (otherUserName.isEmpty) {
        throw 'Artisan name is empty';
      }

      debugPrint(
          'ChatProvider: Looking for conversation between $currentUserId and $otherUserId');
      debugPrint(
          'ChatProvider: Current user: $currentUserName, Other user: $otherUserName');

      // Try to find existing conversation
      try {
        final existingData =
            await _firestoreService.getConversationBetweenUsers(
          currentUserId,
          otherUserId,
        );

        if (existingData != null) {
          debugPrint('ChatProvider: Found existing conversation');
          final existing = ConversationModel.fromMap(existingData);
          _currentConversation = existing;
          _isLoading = false;
          notifyListeners();
          return existing;
        }
      } catch (e) {
        debugPrint('ChatProvider: Error finding existing conversation: $e');
        // Continue to create new conversation
      }

      debugPrint('ChatProvider: Creating new conversation');

      // Create new conversation
      final conversationId = _uuid.v4();
      final conversation = ConversationModel(
        conversationId: conversationId,
        participantIds: [currentUserId, otherUserId],
        participantNames: {
          currentUserId: currentUserName,
          otherUserId: otherUserName,
        },
        participantProfilePics: {
          currentUserId: currentUserProfilePic,
          otherUserId: otherUserProfilePic,
        },
        productId: productId,
        productName: productName,
        productImage: productImage,
        shopId: shopId,
        shopName: shopName,
        lastMessageAt: DateTime.now(),
        unreadCount: {currentUserId: 0, otherUserId: 0},
        createdAt: DateTime.now(),
      );

      await _firestoreService.createConversation(conversation);
      _currentConversation = conversation;
      _isLoading = false;
      notifyListeners();
      debugPrint('ChatProvider: Conversation created successfully');
      return conversation;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('ChatProvider: Error in getOrCreateConversation: $e');
      return null;
    }
  }

  // Load user conversations
  Future<void> loadConversations(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());

      final data = await _firestoreService.getUserConversations(userId);
      _conversations = data.map((d) => ConversationModel.fromMap(d)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load messages for a conversation
  Future<void> loadMessages(String conversationId) async {
    try {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());

      final data = await _firestoreService.getConversationMessages(
        conversationId,
      );
      _messages = data.map((d) => MessageModel.fromMap(d)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send a message
  Future<bool> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    String? senderProfilePic,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
    String? imageUrl,
    String? productId,
    String? orderId,
  }) async {
    try {
      final messageId = _uuid.v4();
      final message = MessageModel(
        messageId: messageId,
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        senderProfilePic: senderProfilePic,
        receiverId: receiverId,
        content: content,
        type: type,
        imageUrl: imageUrl,
        productId: productId,
        orderId: orderId,
        createdAt: DateTime.now(),
      );

      await _firestoreService.sendMessage(message);

      // Add to local list
      _messages.add(message);
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(
    String conversationId,
    String userId,
  ) async {
    try {
      await _firestoreService.markMessagesAsRead(conversationId, userId);

      // Update local messages
      for (var i = 0; i < _messages.length; i++) {
        if (_messages[i].receiverId == userId && !_messages[i].isRead) {
          _messages[i] = _messages[i].copyWith(isRead: true);
        }
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get total unread count for a user
  int getTotalUnreadCount(String userId) {
    return _conversations.fold(
      0,
      (sum, conv) => sum + conv.getUnreadCount(userId),
    );
  }

  // Set current conversation
  void setCurrentConversation(ConversationModel? conversation) {
    _currentConversation = conversation;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear all
  void clear() {
    _conversations = [];
    _messages = [];
    _currentConversation = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}

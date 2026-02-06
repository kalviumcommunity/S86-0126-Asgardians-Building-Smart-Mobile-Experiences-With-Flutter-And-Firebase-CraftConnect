import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
}

/// Service to handle Firebase Cloud Messaging (FCM) operations
class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;

  /// Get the current FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize FCM and set up listeners
  Future<void> initialize() async {
    try {
      // Request notification permissions (iOS)
      await _requestPermission();

      // Get the device FCM token
      await _getToken();

      // Set up token refresh listener
      _setupTokenRefreshListener();

      // Set up message handlers
      _setupMessageHandlers();

      debugPrint('✅ NotificationService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
      'Notification permission status: ${settings.authorizationStatus}',
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('⚠️ User granted provisional notification permission');
    } else {
      debugPrint('❌ User declined or has not accepted notification permission');
    }
  }

  /// Get FCM token
  Future<void> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('📱 FCM Token: $_fcmToken');

      // TODO: Send token to your backend server for targeted notifications
      // await _sendTokenToServer(_fcmToken);
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  /// Listen for token refresh
  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      debugPrint('🔄 FCM Token refreshed: $newToken');

      // TODO: Update token on server
      // await _sendTokenToServer(newToken);
    });
  }

  /// Set up message handlers for different app states
  void _setupMessageHandlers() {
    // 1. Foreground messages (app is open and in use)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 2. Background messages (app is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 3. Terminated state (app was completely closed)
    _checkInitialMessage();

    // 4. Background handler (must be registered in main.dart)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📬 Foreground message received');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // Show in-app notification or local notification here
    // For a complete solution, you could use flutter_local_notifications
  }

  /// Handle when user taps notification while app is in background
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('🔔 User opened app from notification');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // Navigate to specific screen based on message data
    _handleNotificationNavigation(message);
  }

  /// Check if app was opened from terminated state
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('🚀 App opened from terminated state via notification');
      debugPrint('Title: ${initialMessage.notification?.title}');
      debugPrint('Body: ${initialMessage.notification?.body}');

      _handleNotificationNavigation(initialMessage);
    }
  }

  /// Handle navigation based on notification data
  void _handleNotificationNavigation(RemoteMessage message) {
    // Example: Navigate based on notification data
    final data = message.data;

    if (data.containsKey('route')) {
      final route = data['route'];
      debugPrint('📍 Navigating to: $route');

      // TODO: Implement navigation logic
      // Example: Navigator.pushNamed(context, route);
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      debugPrint('✅ FCM token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting token: $e');
    }
  }
}

# Firebase Cloud Messaging (FCM) - Push Notifications Setup Guide

## Overview
Firebase Cloud Messaging (FCM) enables real-time push notifications across Android, iOS, and web platforms. This guide covers the implementation in the CraftConnect Flutter app.

## ✅ Implementation Checklist

### 1. Dependencies Added
- ✅ `firebase_messaging: ^15.1.6` added to `pubspec.yaml`
- ✅ `firebase_core: ^4.4.0` (already present)

### 2. Service Implementation
- ✅ Created `lib/services/notification_service.dart`
- ✅ Singleton pattern for global access
- ✅ Background message handler implemented

### 3. Main App Integration
- ✅ NotificationService initialized in `main.dart`
- ✅ Firebase initialized before notification service

### 4. Demo Screen
- ✅ Created `lib/screens/push_notification_demo_screen.dart`
- ✅ Added route `/push-notifications`
- ✅ Navigation button added to HomeScreen

## 🔧 Features Implemented

### NotificationService Features
1. **Permission Handling**
   - Request notification permissions (iOS/Android)
   - Check permission status
   - Handle authorization states

2. **FCM Token Management**
   - Get device FCM token
   - Listen for token refresh
   - Delete and regenerate tokens

3. **Message Handlers**
   - **Foreground**: Handle notifications when app is open
   - **Background**: Handle notifications when app is in background
   - **Terminated**: Handle notifications when app is completely closed
   - **Tap handling**: Respond when user taps notification

4. **Topic Subscriptions**
   - Subscribe to topics for group messaging
   - Unsubscribe from topics
   - Manage multiple topic subscriptions

### Demo Screen Features
- View FCM token
- Copy token to clipboard
- Check notification permission status
- Subscribe/unsubscribe to topics
- Refresh FCM token
- Step-by-step testing instructions

## 📱 Platform-Specific Setup

### Android Setup

1. **Firebase Configuration**
   - ✅ `android/app/google-services.json` (already present)

2. **AndroidManifest.xml** (Add if not present)
   ```xml
   <manifest>
     <uses-permission android:name="android.permission.INTERNET"/>
     <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
     
     <application>
       <!-- Firebase Messaging -->
       <meta-data
         android:name="com.google.firebase.messaging.default_notification_channel_id"
         android:value="high_importance_channel" />
     </application>
   </manifest>
   ```

3. **Build.gradle**
   - Ensure Google Services plugin is applied
   - Minimum SDK version should be 21+

### iOS Setup

1. **Firebase Configuration**
   - Add `GoogleService-Info.plist` to `ios/Runner/`

2. **APNs (Apple Push Notification service)**
   - Enable Push Notifications in Xcode capabilities
   - Upload APNs authentication key to Firebase Console
   - Configure APNs certificates in Apple Developer Console

3. **Info.plist**
   ```xml
   <key>UIBackgroundModes</key>
   <array>
     <string>fetch</string>
     <string>remote-notification</string>
   </array>
   ```

4. **AppDelegate.swift**
   ```swift
   import Flutter
   import UIKit
   import Firebase

   @main
   @objc class AppDelegate: FlutterAppDelegate {
     override func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
       FirebaseApp.configure()
       
       if #available(iOS 10.0, *) {
         UNUserNotificationCenter.current().delegate = self
       }
       
       return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }
   }
   ```

## 🧪 Testing Push Notifications

### Method 1: Firebase Console (Recommended for Initial Testing)

1. **Get FCM Token**
   - Run the app
   - Navigate to "Push Notifications Demo"
   - Copy the FCM token displayed

2. **Send Test Notification**
   - Open Firebase Console
   - Go to Cloud Messaging
   - Click "Send your first message"
   - Enter notification title and body
   - Click "Send test message"
   - Paste your FCM token
   - Click "Test"

3. **Test Different App States**
   - **Foreground**: App is open (check debug logs)
   - **Background**: App is minimized (notification appears in tray)
   - **Terminated**: App is completely closed (notification appears, app opens on tap)

### Method 2: Topic-Based Messaging

1. **Subscribe to Topic**
   - In demo screen, enter topic name (e.g., "news")
   - Click subscribe button

2. **Send to Topic**
   - In Firebase Console
   - Select "Topic" instead of device token
   - Enter your topic name
   - Send notification

3. **Test Multiple Devices**
   - Subscribe multiple devices to same topic
   - Send one notification to reach all devices

### Method 3: API Testing (Advanced)

Use Firebase Admin SDK or REST API:

```bash
curl -X POST https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "DEVICE_FCM_TOKEN",
      "notification": {
        "title": "Test Notification",
        "body": "This is a test message"
      },
      "data": {
        "route": "/some-screen",
        "customKey": "customValue"
      }
    }
  }'
```

## 📊 Notification States Explained

| App State | Behavior | Handler |
|-----------|----------|---------|
| **Foreground** | App is open and active | `FirebaseMessaging.onMessage` |
| **Background** | App is minimized/in background | `FirebaseMessaging.onMessageOpenedApp` |
| **Terminated** | App is completely closed | `getInitialMessage()` + `onBackgroundMessage` |

## 🎯 Key Code Locations

```
lib/
├── services/
│   └── notification_service.dart    # Core FCM service
├── screens/
│   └── push_notification_demo_screen.dart  # Testing UI
└── main.dart  # Service initialization
```

## 🔍 Debugging Tips

### No Token Generated
```dart
// Check Firebase initialization
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

// Check permission status
NotificationSettings settings = await FirebaseMessaging.instance.getNotificationSettings();
print(settings.authorizationStatus);
```

### Notifications Not Received (Android API 33+)
```dart
// Request POST_NOTIFICATIONS permission at runtime
// Add to AndroidManifest.xml:
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### iOS: Notifications Not Working
1. Check APNs certificates in Firebase Console
2. Verify `GoogleService-Info.plist` is added to Xcode
3. Enable Push Notifications capability in Xcode
4. Test on physical device (not simulator)

### Background Handler Not Called
```dart
// Ensure handler is top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handler code
}

// Register in main.dart BEFORE runApp()
FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
```

## 📝 Common Issues & Solutions

### Issue: "MissingPluginException"
**Solution**: Run `flutter clean && flutter pub get` and rebuild

### Issue: Token is null
**Solution**: 
- Check internet connection
- Verify Firebase configuration files
- Check permission status
- Restart app after granting permissions

### Issue: Notifications work on Android but not iOS
**Solution**:
- Upload APNs authentication key to Firebase
- Enable Push Notifications capability in Xcode
- Test on physical device (not simulator)
- Check iOS deployment target (iOS 10+)

### Issue: Data not received in notification payload
**Solution**: Use both `notification` and `data` fields in payload:
```json
{
  "notification": {
    "title": "Title",
    "body": "Body"
  },
  "data": {
    "key": "value"
  }
}
```

## 🚀 Advanced Features (Future Enhancements)

1. **Local Notifications**
   - Add `flutter_local_notifications` package
   - Show custom notifications when app is in foreground

2. **Rich Notifications**
   - Images, actions, and custom layouts
   - Expandable notifications

3. **Analytics Integration**
   - Track notification open rates
   - User engagement metrics

4. **Scheduled Notifications**
   - Time-based delivery
   - Recurring notifications

5. **Deep Linking**
   - Navigate to specific screens from notifications
   - Pass parameters via notification data

## 📚 Additional Resources

- [FlutterFire Messaging Documentation](https://firebase.flutter.dev/docs/messaging/overview)
- [Firebase Cloud Messaging Official Docs](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Background Message Handling](https://firebase.flutter.dev/docs/messaging/usage#background-messages)
- [Android Notification Permissions (API 33+)](https://developer.android.com/develop/ui/views/notifications/notification-permission)
- [iOS Push Notification Setup](https://firebase.google.com/docs/cloud-messaging/ios/client)

## ✨ Next Steps

1. **Run the app**: `flutter run`
2. **Navigate to**: Push Notifications Demo (from Home Screen)
3. **Copy your FCM token**
4. **Send test notification** from Firebase Console
5. **Test in all app states** (foreground, background, terminated)
6. **Subscribe to topics** for group messaging

## 🎓 Learning Outcomes

After completing this implementation, you understand:
- How FCM works with Flutter
- Permission handling across platforms
- Message handling in different app states
- Token management and refresh
- Topic-based messaging
- Testing strategies for push notifications

---

**Implementation Status**: ✅ Complete and Ready for Testing

**Last Updated**: February 6, 2026

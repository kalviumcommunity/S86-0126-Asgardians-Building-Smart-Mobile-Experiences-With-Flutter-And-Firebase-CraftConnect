// File generated manually for Firebase configuration
// Replace the placeholder values with your actual Firebase config

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Replace these values with your actual Firebase Web config

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDJfpPfs5U7hOTEDkBf5eVzm9CX5UMkMY4',
    appId: '1:1063137654489:web:019900cd74c1f1c257b0c8',
    messagingSenderId: '1063137654489',
    projectId: 'craft-connect-3',
    authDomain: 'craft-connect-3.firebaseapp.com',
    storageBucket: 'craft-connect-3.firebasestorage.app',
    measurementId: 'G-GNYN021LJJ',
  );

  // Get these from Firebase Console → Web App → Config

  // TODO: Replace these values with your actual Firebase Android config

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCmn_8zaiVxJT5iXRi-ld65S7seLsyepI0',
    appId: '1:1063137654489:android:d7892edb60bb29ea57b0c8',
    messagingSenderId: '1063137654489',
    projectId: 'craft-connect-3',
    storageBucket: 'craft-connect-3.firebasestorage.app',
  );

  // Get these from google-services.json file

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBJU8FJgIQLwf8Tid0Xd9a2TP38YGV0Rv0',
    appId: '1:1063137654489:ios:0cbffd063c8892de57b0c8',
    messagingSenderId: '1063137654489',
    projectId: 'craft-connect-3',
    storageBucket: 'craft-connect-3.firebasestorage.app',
    iosBundleId: 'com.example.craftconnectDemo',
  );

  // iOS configuration (optional - only if you're building for iOS)

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBJU8FJgIQLwf8Tid0Xd9a2TP38YGV0Rv0',
    appId: '1:1063137654489:ios:0cbffd063c8892de57b0c8',
    messagingSenderId: '1063137654489',
    projectId: 'craft-connect-3',
    storageBucket: 'craft-connect-3.firebasestorage.app',
    iosBundleId: 'com.example.craftconnectDemo',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDJfpPfs5U7hOTEDkBf5eVzm9CX5UMkMY4',
    appId: '1:1063137654489:web:81e5058479a4deff57b0c8',
    messagingSenderId: '1063137654489',
    projectId: 'craft-connect-3',
    authDomain: 'craft-connect-3.firebaseapp.com',
    storageBucket: 'craft-connect-3.firebasestorage.app',
    measurementId: 'G-CC7Z6N6GFW',
  );

}

/*
 * HOW TO FILL THIS FILE:
 * 
 * 1. Go to Firebase Console: https://console.firebase.google.com/
 * 
 * 2. For WEB configuration:
 *    - Click on Web app icon (</>)
 *    - You'll see a config object with these values:
 *      apiKey, authDomain, projectId, storageBucket, 
 *      messagingSenderId, appId, measurementId
 *    - Copy each value and replace the placeholders above
 * 
 * 3. For ANDROID configuration:
 *    - Download google-services.json
 *    - Place it in: android/app/google-services.json
 *    - Open the file and find these values:
 *      - project_info.project_number → messagingSenderId
 *      - project_info.project_id → projectId
 *      - project_info.storage_bucket → storageBucket
 *      - client[0].client_info.mobilesdk_app_id → appId
 *      - client[0].api_key[0].current_key → apiKey
 * 
 * 4. Save this file
 * 
 * 5. Make sure main.dart imports this file:
 *    import 'firebase_options.dart';
 * 
 * 6. Run: flutter clean && flutter pub get && flutter gen-l10n
 */
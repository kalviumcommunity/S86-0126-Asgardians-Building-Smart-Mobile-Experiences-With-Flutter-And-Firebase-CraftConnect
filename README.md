# Sprint #2 – Flutter & Firebase Persistent Session Handling 
## CraftConnect Mobile Application

### Team Name
Asgardians

---

## 📱 Project Overview
CraftConnect is a mobile-first digital storefront designed for local artisans to showcase handmade products and connect directly with customers. Built using Flutter and Firebase, the app features **persistent user sessions** that ensure users remain logged in even after closing and reopening the app.

This implementation demonstrates Firebase Authentication's built-in session persistence capabilities using `authStateChanges()` stream for seamless user experience.

---

## 🔐 Persistent Session Implementation

### 📋 Table of Contents
1. [How Firebase Session Persistence Works](#how-firebase-session-persistence-works)
2. [authStateChanges() StreamBuilder Implementation](#authstatechanges-streambuilder-implementation)
3. [Auto-Login Flow](#auto-login-flow)
4. [Session Testing Guide](#session-testing-guide)
5. [Code Structure](#code-structure)
6. [Reflection](#reflection)

---

## 🔥 How Firebase Session Persistence Works

Firebase Auth automatically persists user sessions using secure tokens stored on the device:

✅ **Users stay logged in** even after app restart  
✅ **Tokens auto-refresh** in the background  
✅ **No manual storage** (like SharedPreferences) required  
✅ **Automatic session validation** on app startup  

### Key Benefits:
- **Seamless UX**: No repeated logins required
- **Security**: Encrypted token storage
- **Cross-platform**: Works on iOS, Android, Web
- **Auto-refresh**: Handles token expiry automatically

---

## 📱 authStateChanges() StreamBuilder Implementation

The core of persistent session handling is implemented in [main.dart](craftconnect/lib/main.dart):

```dart
// 🔥 AUTH FLOW ENTRY POINT - PERSISTENT SESSION HANDLING
home: StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    // Show splash screen while checking authentication state
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SplashScreen();
    }

    // If user is authenticated, go to HomeScreen
    if (snapshot.hasData) {
      return const HomeScreen();
    }

    // If no user is authenticated, go to AuthScreen
    return AuthScreen();
  },
),
```

### 🎯 How This Works:

1. **Stream Listening**: `authStateChanges()` creates a stream that emits whenever:
   - User logs in
   - User logs out  
   - Session becomes invalid
   - App restarts and checks existing session

2. **Automatic Routing**: Based on the auth state:
   - `snapshot.hasData` = User logged in → **HomeScreen**
   - No data = No user → **AuthScreen**
   - Waiting = Checking session → **SplashScreen**

3. **Real-time Updates**: Any auth state change immediately triggers UI rebuild

---

## 🔄 Auto-Login Flow

### Login Process:
```
User Opens App → Check Auth State → Show Appropriate Screen
     ↓                ↓                    ↓
 Splash Screen   Check Firebase      Authenticated?
                     Token               ↙    ↘
                                    YES     NO
                                     ↓       ↓
                                HomeScreen AuthScreen
```

### Session Persistence Behavior:

| Scenario | Expected Behavior | Result |
|----------|-------------------|---------|
| **First Login** | User enters credentials → Redirect to HomeScreen | ✅ Session Created |
| **App Minimize/Resume** | App checks existing session → Stay in HomeScreen | ✅ Session Maintained |
| **App Force Close** | User reopens app → Auto-login to HomeScreen | ✅ Session Restored |
| **Device Restart** | User opens app → Auto-login to HomeScreen | ✅ Session Persisted |
| **Manual Logout** | User taps logout → Redirect to AuthScreen | ✅ Session Cleared |
| **Token Expiry** | Firebase detects invalid token → Redirect to AuthScreen | ✅ Auto-handled |

---

## 🧪 Session Testing Guide

### Test Case 1: Login Persistence
1. **Login** with valid credentials
2. **Minimize** the app (don't force close)
3. **Resume** the app
4. **Expected**: App stays on HomeScreen

### Test Case 2: App Restart Persistence  
1. **Login** with valid credentials
2. **Force close** the app completely
3. **Reopen** the app
4. **Expected**: App automatically shows HomeScreen (no login required)

### Test Case 3: Device Restart Persistence
1. **Login** with valid credentials
2. **Restart** your device
3. **Open** the app after restart
4. **Expected**: App automatically shows HomeScreen

### Test Case 4: Logout Functionality
1. **Login** and reach HomeScreen
2. **Tap logout** button
3. **Expected**: App redirects to AuthScreen
4. **Force close** and reopen
5. **Expected**: App shows AuthScreen (session cleared)

---

## 📁 Code Structure

## 📁 Code Structure

```
craftconnect/
├── lib/
│   ├── main.dart                    # Entry point with authStateChanges() StreamBuilder
│   ├── firebase_options.dart        # Firebase configuration
│   ├── screens/
│   │   ├── splash_screen.dart       # Loading screen during auth state check
│   │   ├── auth_screen.dart         # Enhanced login/signup with form validation
│   │   ├── home_screen.dart         # Protected screen showing user info
│   │   └── ...                      # Other app screens
│   ├── widgets/                     # Reusable UI components
│   ├── models/                      # Data models
│   └── services/                    # Authentication services
├── android/app/google-services.json # Firebase Android configuration
├── ios/Runner/GoogleService-Info.plist # Firebase iOS configuration
└── pubspec.yaml                     # Dependencies including Firebase
```

### Key Files for Session Persistence:

1. **[main.dart](craftconnect/lib/main.dart)** - Core auth state management
2. **[splash_screen.dart](craftconnect/lib/screens/splash_screen.dart)** - Professional loading experience
3. **[auth_screen.dart](craftconnect/lib/screens/auth_screen.dart)** - Enhanced authentication UI
4. **[home_screen.dart](craftconnect/lib/screens/home_screen.dart)** - Protected user dashboard

---

## 🎨 Enhanced UI Features

### Splash Screen
- **Professional Loading**: Custom branded splash screen
- **Smooth Transitions**: Eliminates jarring auth state checks
- **Visual Feedback**: Loading indicators during session validation

### Authentication Screen  
- **Form Validation**: Email format and password strength validation
- **Better UX**: Toggle password visibility, clear error messages
- **Session Info**: User notification about persistent login
- **Error Handling**: Specific Firebase error messages

### Home Screen
- **Session Information**: Display user metadata and login status
- **Logout Confirmation**: Prevents accidental logouts
- **Visual Indicators**: Clear session persistence messaging

---

## 🛠 Technical Implementation Details

### Firebase Dependencies
```yaml
dependencies:
  firebase_core: ^4.4.0      # Firebase initialization
  firebase_auth: ^6.1.4      # Authentication services
  cloud_firestore: ^6.1.2    # Database (future features)
```

### Session Handling Logic

```dart
// Stream listens to auth state changes
FirebaseAuth.instance.authStateChanges().listen((User? user) {
  if (user == null) {
    // No user logged in - show AuthScreen
    print('User is currently signed out!');
  } else {
    // User is logged in - show HomeScreen  
    print('User is signed in!');
  }
});
```

### Logout Implementation
```dart
void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              FirebaseAuth.instance.signOut(); // This triggers authStateChanges()
            },
            child: const Text("Logout"),
          ),
        ],
      );
    },
  );
}
```

---

## 🔍 Reflection

### Why Persistent Login is Essential

1. **Modern User Expectations**: Users expect to remain logged in across sessions
2. **Improved Engagement**: Reduces friction in app usage
3. **Better Conversion**: Eliminates login barriers for returning users
4. **Professional Experience**: Matches industry-standard app behavior

### How Firebase Makes Session Handling Easier

1. **Built-in Persistence**: No need for manual token storage
2. **Automatic Refresh**: Handles token expiry seamlessly  
3. **Cross-platform**: Same code works on all platforms
4. **Security**: Industry-standard encryption and storage
5. **Real-time**: Instant session state synchronization

### Challenges Faced & Solutions

**Challenge**: Initial auth state check caused brief loading
**Solution**: Implemented dedicated SplashScreen for professional UX

**Challenge**: Users confused about session persistence
**Solution**: Added informational UI elements explaining the feature

**Challenge**: Abrupt transitions between auth states
**Solution**: Added smooth loading states and transition animations

**Challenge**: Testing session persistence across scenarios
**Solution**: Created comprehensive test cases covering all use cases

### Future Improvements

1. **Biometric Authentication**: Add fingerprint/face recognition
2. **Social Login**: Google, Apple, Facebook authentication
3. **Session Analytics**: Track login patterns and session duration
4. **Offline Support**: Handle authentication when device is offline
5. **Multi-device Sync**: Sync sessions across user's devices

---

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK installed
- Firebase project created
- Android/iOS development environment

### Installation Steps
1. Clone the repository
2. Run `flutter pub get`
3. Configure Firebase (google-services.json / GoogleService-Info.plist)
4. Run `flutter run`

### Testing Session Persistence
1. Login with test credentials
2. Force close the app
3. Reopen - should auto-login to HomeScreen
4. Test logout functionality
5. Verify session is cleared after logout

---

## 📸 Screenshots

### Before Restart (Logged In)
![Home Screen](screenshots/home_screen_logged_in.png)

### After Restart (Auto-Login)
![Auto Login](screenshots/auto_login_after_restart.png)

### Logout Behavior  
![Auth Screen](screenshots/auth_screen_after_logout.png)

---

## 🎥 Demo Video

[View 1-2 Minute Demo](https://drive.google.com/your-demo-video-link)

The video demonstrates:
- ✅ Login flow
- ✅ App closure
- ✅ Auto-login on reopening
- ✅ Logout functionality
- ✅ Session persistence verification

---

## 👥 Team Members

- **Team Name**: Asgardians
- **Sprint**: #2 - Persistent Login State Implementation
- **Technology**: Flutter + Firebase Authentication

---

## 📋 Commit History

```bash
feat: implemented persistent user session handling with Firebase Auth
- Added authStateChanges() StreamBuilder in main.dart
- Created professional SplashScreen for loading states  
- Enhanced AuthScreen with form validation and UX improvements
- Updated HomeScreen with session information and logout confirmation
- Added comprehensive session persistence testing
- Updated README with implementation details and testing guide
```

---

*Built with ❤️ using Flutter & Firebase*  
- VS Code or Android Studio  
- Flutter and Dart extensions  
- Firebase project configured  

### Steps to Run
- Run flutter doctor to verify setup  
- Install dependencies using flutter pub get  
- Start the app using flutter run  

---

## 📸 App Demo
- Signup screen  
- Login success screen  
- Home screen after login  
- Firebase Authentication users list  
- Firestore users collection  

---

## 🧠 Reflection
Connecting Flutter with Firebase was initially challenging due to platform configuration issues. After proper setup, authentication and database features worked smoothly. Firebase enables secure login, real-time updates, and makes the application scalable for future growth.

---


## Understanding Widget Tree & Reactive UI (Sprint #2)

### 📌 Description
This task demonstrates Flutter’s widget tree structure and its reactive UI model. A simple demo screen was created to show how widgets are arranged in a hierarchy and how the UI updates automatically when the state changes.

---

### 🌳 Widget Tree Hierarchy

Scaffold  
 ┣ AppBar  
 ┗ Body  
    ┗ Center  
       ┗ Column  
          ┣ Text  
          ┣ Container  
          ┗ ElevatedButton  

---

### 🔄 Reactive UI Model
Flutter uses a reactive UI approach. When the state changes using setState(), Flutter automatically rebuilds only the affected widgets instead of the whole screen. This makes UI updates fast and efficient.

In this demo:
- Initial UI shows default text and color
- Clicking the button updates the state
- Text and container color change instantly
- Only the required widgets are rebuilt

---

### 🧠 Learning Outcome
Through this task, I understood how Flutter builds UI using a widget tree and how state changes trigger automatic UI updates. This helped me clearly understand Flutter’s reactive design pattern and efficient rendering system.


# Multi-Screen Navigation Using Navigator & Routes

## Description

This task demonstrates how multiple screens are connected in the app using Flutter’s Navigator and named routes. Navigation was added to move smoothly between different pages, making the app structure scalable and easy to manage.

## Navigation Setup
The app includes the following screens for navigation:

DevTools Demo Screen (start screen)
Home Screen
Second Screen

Named routes are defined in main.dart, and navigation is handled using Navigator.pushNamed() and Navigator.pop().

## Navigation Flow
App opens on the DevTools Demo Screen
User navigates to Home Screen
From Home Screen, user navigates to Second Screen
User can return to previous screens using back navigation

### Learning Outcome

I learned how Flutter manages multiple screens using a navigation stack and how named routes make navigation clean and scalable for larger applications.


# Responsive Layout Using Row, Column & Container

### Description
A responsive layout screen was built using Container, Row, Column, and Expanded widgets. The layout adapts based on screen width using MediaQuery.

### Layout Design
- Header section at top
- Content area changes based on screen size
- Column layout for small screens
- Row layout for large screens

### Reflection
Responsive design ensures the app looks good on all devices. The main challenge was managing layout proportions using Expanded and switching between Row and Column layouts. This approach improves usability across phones and tablets.


# Consistent Styling and Theme Implementation

### Description
A global theme was applied to the app using ThemeData to ensure consistent colors, text styles, and button designs across all screens.

### What Was Implemented
- Common color palette using primarySwatch
- Global AppBar styling
- TextTheme for headings and body text
- ElevatedButtonTheme for consistent buttons
- Shared background color for all screens

### Reflection
Using a global theme makes the app look professional and consistent. It also reduces repeated styling code and makes future UI updates easier. The main challenge was replacing hardcoded styles with theme-based styles.


# Reusable Custom Widgets

## Description

This task demonstrates how reusable custom widgets can be created in Flutter to reduce code duplication and maintain consistent UI design. Common UI elements were refactored into reusable widgets and used across multiple screens to make the app modular and scalable.

## Custom Widgets Created

The following reusable widgets were created:

CustomButton
A reusable button widget used for navigation and actions across different screens.

InfoCard
A reusable card widget used to display structured information such as title, subtitle, and icon.

## Reuse Implementation

The same CustomButton widget is used in both Home Screen and Second Screen with different actions.
The InfoCard widget is reused multiple times on the Home Screen with different data.
This approach keeps the UI consistent and reduces repeated code.

### Learning Outcome

I learned how to break large UI code into smaller reusable components, making the codebase cleaner, easier to maintain, and faster to scale for team-based development.


# Animations and Transitions

## Description

Animations were added to enhance user experience and make interactions feel smooth and engaging.

## Animations Implemented

Implicit Animations using AnimatedContainer and AnimatedOpacity
UI elements animate smoothly on user interaction
Animated page navigation using custom route transitions

### Reflection

Animations improve usability by guiding user attention and making interactions intuitive.
I learned the difference between implicit and explicit animations and how to apply them meaningfully without affecting performance.


# Firebase Project Setup & Flutter Integration

## Description:
This task verifies the successful setup and integration of Firebase with the CraftConnect Flutter application. Firebase acts as the backend foundation for authentication, database, and future cloud features.

## Initialization

Firebase is initialized at app startup using Firebase.initializeApp() to ensure all Firebase services are available before the UI loads.

## Verification

Application runs without Firebase configuration errors
App appears as active under Firebase Console → Project Settings → Your Apps
Firebase logs confirm successful initialization.

## Learning Outcome
This setup enables seamless integration of Firebase services like Authentication and Firestore in future features. Verifying the configuration helped reinforce understanding of one-time backend setup and how Flutter connects securely with cloud services.


# Firebase Authentication (Email & Password)

## Description

This task implements user authentication using Firebase Authentication with Email and Password in the CraftConnect Flutter application. Users can securely sign up for a new account or log in to an existing account, with all authentication handled by Firebase.

## Features Implemented

Email & Password authentication using Firebase Auth
User signup and login functionality
Toggle between Login and Signup modes
Error handling for invalid credentials
Authentication state synced with Firebase Console.

## Verification

Successfully registered users appear in Firebase Console → Authentication → Users
Login and signup actions work without backend configuration

### Reflection

Firebase Authentication simplifies user management by handling security, validation, and session management automatically. Compared to custom authentication systems, Firebase provides built-in security, scalability, and reliability. The main challenge was handling initialization order and managing authentication states correctly.


# Real-Time Sync with Firestore Snapshot Listeners

## ✅ Project Title
**CraftConnect – Real-Time Firestore Sync**

---

## 📡 Understanding Snapshot Listeners

Firestore snapshot listeners provide **live data synchronization**. Whenever a document or collection changes, the listener emits a new snapshot and the UI rebuilds instantly.

### ✅ Collection Snapshot Listener (Real-Time Collection Updates)
Listens to all documents in a collection and triggers whenever a document is added, updated, or deleted.

```dart
FirebaseFirestore.instance
  .collection('tasks')
  .snapshots();
```

### ✅ Document Snapshot Listener (Real-Time Single Document Updates)
Listens to a single document and triggers on field changes or server updates.

```dart
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .snapshots();
```

---

## ⚡ StreamBuilder for Real-Time UI

StreamBuilder rebuilds the UI automatically whenever Firestore emits a new snapshot.

### ✅ Collection Listener with StreamBuilder
```dart
StreamBuilder(
  stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Text('No tasks available');
    }

    final docs = snapshot.data!.docs;
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(docs[index]['title']));
      },
    );
  },
);
```

### ✅ Document Listener with StreamBuilder
```dart
StreamBuilder(
  stream: FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    final data = snapshot.data!.data()!;
    return Text("Name: ${data['name']}");
  },
);
```

---

## 🧩 App Implementation (Real-Time UI)

The Home Screen now includes:

- **Live profile updates** from `users/{uid}` using a document snapshot listener
- **Live task list updates** from `tasks` collection using a collection listener

These streams power real-time UI updates using `StreamBuilder` and `.snapshots()`.

---

## 📸 Screenshots

### Firestore Console Updates
![Firestore Console](screenshots/firestore_console_updates.png)

### App UI Updating Instantly
![Real-Time UI](screenshots/realtime_ui_updates.png)

---

## 🧠 Reflection

### Why Real-Time Sync Improves UX
- Users see changes instantly without manual refresh
- Feels modern and responsive (like chat or live dashboards)
- Improves engagement and trust in the app

### How Firestore’s `.snapshots()` Simplifies Live Updates
- No manual polling or refresh logic required
- StreamBuilder handles rebuilds automatically
- Easy to combine loading, empty, and error states

### Challenges Faced
- Ensuring UI handles empty data safely
- Avoiding crashes on missing fields
- Structuring Firestore docs for consistent rendering

---

## ✅ Testing Real-Time Sync

1. Open Firebase Console → Firestore
2. Add or edit a document inside `tasks`
3. Update fields inside `users/{uid}`
4. Watch the app update instantly without refresh

---







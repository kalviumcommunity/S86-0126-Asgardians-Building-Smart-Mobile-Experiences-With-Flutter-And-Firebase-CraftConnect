# Sprint #2 – Flutter & Dart Basics  
## CraftConnect Mobile Application

### Team Name
Asgardians

---

## 📱 Project Overview
CraftConnect is a mobile-first digital storefront designed for local artisans to showcase handmade products and connect directly with customers. Built using Flutter and Firebase, the app aims to simplify product listing and catalog sharing through a clean and intuitive mobile UI.

This Sprint #2 deliverable focuses on Flutter setup, UI structure, foundational app architecture, and Firebase integration.

---

## 📂 Folder Structure

lib/  
├── main.dart        – Entry point of the Flutter application  
├── screens/         – UI screens (Login, Signup, Responsive Home)  
├── widgets/         – Reusable UI components  
├── models/          – Data models (future use)  
├── services/        – Firebase Authentication and Firestore logic  

### Why This Structure?
- Encourages modular and scalable development  
- Separates UI, logic, and data layers  
- Makes future feature additions easier  

### Naming Conventions
- Files use snake_case  
- Classes and widgets use PascalCase  
- Variables and methods use camelCase  

---

## 🔥 Firebase Integration

### Features Implemented
- User signup and login using Firebase Authentication  
- Secure email/password authentication  
- Real-time data storage using Cloud Firestore  
- User data stored and retrieved from Firebase database  

---

## ⚙️ Setup Instructions

### Prerequisites
- Flutter SDK installed  
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







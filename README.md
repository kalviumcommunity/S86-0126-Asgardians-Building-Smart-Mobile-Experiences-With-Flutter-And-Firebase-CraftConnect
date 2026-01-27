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

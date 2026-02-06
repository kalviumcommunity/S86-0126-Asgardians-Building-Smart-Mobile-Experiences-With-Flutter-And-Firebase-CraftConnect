# Firestore Security Rules & Authentication - Implementation Guide

## Overview
This implementation demonstrates how to secure Cloud Firestore using Firebase Authentication and comprehensive security rules. By default, Firestore starts in "test mode" with open access—this guide ensures your app follows production-ready security best practices.

## 🔒 Why Firestore Security Matters

### Critical Security Concerns
- **Prevents unauthorized access** to user data
- **Blocks malicious writes**, spam, and data tampering
- **Enforces role-based permissions** (user vs. admin)
- **Protects private user information**
- **Required for production deployment**

### Without Security Rules
```javascript
// ❌ DANGEROUS - Open to everyone
allow read, write: if true;
```
Anyone can read, modify, or delete all your data!

## ✅ Implementation Checklist

### 1. Dependencies (Already Added)
- ✅ `firebase_core: ^4.4.0`
- ✅ `firebase_auth: ^6.1.4`
- ✅ `cloud_firestore: ^6.1.2`

### 2. Service Implementation
- ✅ Created `lib/services/secure_firestore_service.dart`
- ✅ All operations require authentication
- ✅ User-scoped data access
- ✅ Proper error handling for permission denied

### 3. Security Rules File
- ✅ Created `firestore.rules` with comprehensive security
- ✅ Authentication-based access control
- ✅ Owner-only modifications
- ✅ Admin privileges support
- ✅ Private data protection

### 4. Demo Screen
- ✅ Created `lib/screens/firestore_security_demo_screen.dart`
- ✅ Interactive security testing
- ✅ Live permission demonstrations
- ✅ Added route `/firestore-security`

## 🔧 Features Implemented

### SecureFirestoreService Features

#### User Profile Operations
```dart
// Create/update only YOUR profile
await service.createUserProfile(name: 'John Doe', bio: 'Developer');

// Read YOUR profile
DocumentSnapshot profile = await service.getUserProfile();

// Stream YOUR profile changes
Stream<DocumentSnapshot> stream = service.watchUserProfile();
```

#### Post Operations
```dart
// Create a post (authenticated required)
await service.createPost(
  title: 'My Post',
  content: 'Content here',
  tags: ['flutter', 'firebase'],
);

// Update YOUR post only
await service.updatePost(postId, {'title': 'Updated'});

// Delete YOUR post only
await service.deletePost(postId);

// Read all public posts
Stream<QuerySnapshot> posts = service.getAllPosts();
```

#### Private Data Operations
```dart
// Save private data (only you can access)
await service.savePrivateData('secretKey', 'secretValue');

// Read your private data
DocumentSnapshot data = await service.getPrivateData('secretKey');
```

#### Security Testing
```dart
// Test if security rules work
Map<String, bool> results = await service.testSecurityRules();

// Attempt unauthorized access (should fail)
try {
  await service.attemptUnauthorizedRead('other_user_id');
} catch (e) {
  print('✅ Security working: $e'); // Permission denied
}
```

## 🛡️ Security Rules Explained

### Basic User Profile Rule
```javascript
match /users/{userId} {
  // Anyone authenticated can read profiles (public data)
  allow read: if isAuthenticated();
  
  // Users can only create/update their OWN profile
  allow create, update: if isOwner(userId);
  
  // Only admins can delete profiles
  allow delete: if isAdmin();
}
```

### Private Data Rule
```javascript
match /users/{userId}/private/{document=**} {
  // ONLY the owner can read/write their private data
  allow read, write: if isOwner(userId);
}
```

### Post Rules
```javascript
match /posts/{postId} {
  // Anyone can read posts
  allow read: if isAuthenticated();
  
  // Must be authenticated and set authorId = your UID
  allow create: if isAuthenticated() && 
                  request.resource.data.authorId == request.auth.uid;
  
  // Only author can update their post
  allow update: if resource.data.authorId == request.auth.uid;
  
  // Author or admin can delete
  allow delete: if resource.data.authorId == request.auth.uid || isAdmin();
}
```

### Helper Functions
```javascript
function isAuthenticated() {
  return request.auth != null;
}

function isOwner(userId) {
  return isAuthenticated() && request.auth.uid == userId;
}

function isAdmin() {
  return isAuthenticated() && 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
}
```

## 🧪 Testing Security Rules

### Method 1: Using the Demo Screen

1. **Run the app** and sign in
2. **Navigate to "Firestore Security Demo"** from Home Screen
3. **Create your profile** - should work ✅
4. **Create a post** - should work ✅
5. **Click "Test Breach"** - should fail with permission denied ✅

### Method 2: Firebase Console Rules Playground

1. **Go to Firebase Console** → Firestore Database → Rules
2. **Click "Rules playground"**
3. **Simulate authenticated request:**
   ```
   Location: /users/USER_ID
   Type: get
   Auth: Authenticated (with UID)
   ```
4. **Expected Result:** Access granted if UID matches

5. **Simulate unauthorized request:**
   ```
   Location: /users/OTHER_USER_ID
   Auth: Authenticated (with different UID)
   ```
6. **Expected Result:** Permission denied ✅

### Method 3: Code Testing

```dart
final service = SecureFirestoreService();

// Should work
await service.createUserProfile(name: 'Test User');
await service.getUserProfile();

// Should fail with permission denied
try {
  await service.attemptUnauthorizedWrite('other_user_123');
} on FirebaseException catch (e) {
  if (e.code == 'permission-denied') {
    print('✅ Security is working!');
  }
}
```

## 📤 Deploying Security Rules

### Step 1: Deploy via Firebase CLI

```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project (if not done)
firebase init firestore

# Deploy security rules
firebase deploy --only firestore:rules
```

### Step 2: Deploy via Firebase Console

1. Go to **Firebase Console** → **Firestore Database** → **Rules**
2. Copy contents of `firestore.rules`
3. Paste into the editor
4. Click **Publish**

### Step 3: Verify Deployment

```bash
# View current rules
firebase firestore:rules:get
```

## 🔍 Common Security Patterns

### 1. Owner-Only Access
```javascript
match /documents/{docId} {
  allow read, write: if request.auth.uid == resource.data.ownerId;
}
```

### 2. Read Public, Write Authenticated
```javascript
match /posts/{postId} {
  allow read: if true;
  allow write: if isAuthenticated();
}
```

### 3. Admin-Only Operations
```javascript
match /admin/{document=**} {
  allow read, write: if isAdmin();
}
```

### 4. Field Validation
```javascript
match /products/{productId} {
  allow create: if request.resource.data.keys().hasAll(['name', 'price']) &&
                  request.resource.data.price > 0;
}
```

### 5. Rate Limiting (Basic)
```javascript
match /activities/{activityId} {
  allow create: if isAuthenticated() &&
                  request.resource.data.timestamp > request.time - duration.value(1, 'm');
}
```

## ❌ Common Security Mistakes

### Mistake 1: Open Rules in Production
```javascript
// ❌ NEVER use this in production
allow read, write: if true;
```

### Mistake 2: Forgetting to Check Authentication
```javascript
// ❌ Anyone can write
allow write: if request.resource.data.name != null;

// ✅ Correct
allow write: if isAuthenticated() && request.resource.data.name != null;
```

### Mistake 3: Not Validating Owner
```javascript
// ❌ Any authenticated user can modify any document
allow write: if isAuthenticated();

// ✅ Correct - owner check
allow write: if isAuthenticated() && request.auth.uid == resource.data.ownerId;
```

### Mistake 4: Trusting Client Data
```javascript
// ❌ Client could set isAdmin to true
allow write: if request.resource.data.isAdmin == true;

// ✅ Correct - check server-side admin status
allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
```

## 🐛 Troubleshooting

### Issue: PERMISSION_DENIED Error

**Cause:** Security rules are blocking the operation

**Solutions:**
1. Check if user is authenticated: `FirebaseAuth.instance.currentUser != null`
2. Verify UID matches the document owner
3. Test rules in Firebase Console Rules Playground
4. Check if rules are deployed: `firebase firestore:rules:get`

### Issue: Rules Not Taking Effect

**Cause:** Rules not deployed or cached

**Solutions:**
1. Deploy rules: `firebase deploy --only firestore:rules`
2. Wait 1-2 minutes for propagation
3. Refresh the app
4. Check deployment timestamp in Firebase Console

### Issue: "get() is not defined"

**Cause:** Trying to use get() in create operations

**Solution:** Use `get()` only in update/delete operations, not create:
```javascript
// ✅ Works in update
allow update: if get(/databases/.../users/$(request.auth.uid)).data.isAdmin;

// ❌ Fails in create (document doesn't exist yet)
allow create: if get(/databases/.../posts/$(postId)).data.exists;
```

### Issue: Testing Fails with "User not authenticated"

**Solutions:**
1. Ensure user is signed in: Check Auth State
2. Reload app after authentication
3. Check `FirebaseAuth.instance.currentUser != null`

## 📊 Security Rules Structure

```
firestore.rules
├─ Helper Functions
│  ├─ isAuthenticated()
│  ├─ isOwner(userId)
│  └─ isAdmin()
│
├─ User Profiles
│  ├─ Read: Authenticated
│  ├─ Write: Owner only
│  └─ Private Subcollection: Owner only
│
├─ Posts
│  ├─ Read: Authenticated
│  ├─ Create: Authenticated + authorId validation
│  ├─ Update: Author only
│  └─ Delete: Author or Admin
│
├─ Admin Collections
│  └─ Read/Write: Admin only
│
└─ Public Collections
   ├─ Read: Anyone
   └─ Write: Admin only
```

## 🎯 Best Practices

### 1. Always Require Authentication
```javascript
// Default rule
allow read, write: if isAuthenticated();
```

### 2. Validate Owner on Write
```javascript
allow write: if isAuthenticated() && 
               request.resource.data.ownerId == request.auth.uid;
```

### 3. Use Helper Functions
```javascript
function isOwner(userId) {
  return request.auth.uid == userId;
}
```

### 4. Validate Data Types & Required Fields
```javascript
allow create: if request.resource.data.keys().hasAll(['name', 'email']) &&
                request.resource.data.name is string &&
                request.resource.data.email is string;
```

### 5. Test Rules Before Deploying
- Use Rules Playground
- Write unit tests
- Test unauthorized access attempts

### 6. Log Security Events (via Cloud Functions)
```javascript
// Detect suspicious activity
exports.logSecurityEvents = functions.firestore
  .document('{collection}/{docId}')
  .onWrite(async (change, context) => {
    // Log writes for audit trail
  });
```

## 📚 Additional Resources

- [Firestore Security Rules Official Docs](https://firebase.google.com/docs/firestore/security/get-started)
- [Security Rules Reference](https://firebase.google.com/docs/rules/rules-language)
- [Rules Simulator](https://firebase.google.com/docs/rules/simulator)
- [Firebase Auth + Firestore Integration](https://firebase.flutter.dev/docs/firestore/usage/)
- [Common Security Patterns](https://firebase.google.com/docs/firestore/security/rules-conditions)

## 🚀 Next Steps

1. **Run the app**: `flutter run`
2. **Sign in** with your account
3. **Navigate to "Firestore Security Demo"**
4. **Test security operations:**
   - Create profile ✅
   - Create post ✅
   - Test unauthorized access ❌
5. **Deploy rules**: `firebase deploy --only firestore:rules`
6. **Monitor security** in Firebase Console

## 🎓 Learning Outcomes

After completing this implementation, you understand:
- ✅ Why Firestore security is critical
- ✅ How to write secure Firestore rules
- ✅ Authentication-based access control
- ✅ Owner-only data modifications
- ✅ Admin privilege patterns
- ✅ Testing security rules effectively
- ✅ Common security mistakes to avoid
- ✅ Deploying and monitoring security rules

---

**Implementation Status**: ✅ Complete and Production-Ready

**Security Level**: 🔒 High - Ready for Real Users

**Last Updated**: February 6, 2026

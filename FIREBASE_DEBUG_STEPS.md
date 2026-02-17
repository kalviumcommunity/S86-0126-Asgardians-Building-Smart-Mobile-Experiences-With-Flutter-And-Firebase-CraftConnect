# Firebase Authentication Debug Steps

## The app is running! Now let's fix the authentication error:

### Step 1: Check Browser Console
1. Open Chrome DevTools (Press F12)
2. Go to the **Console** tab
3. Try to register/login again
4. Look for red error messages
5. Share the exact error message you see

### Step 2: Verify Firebase Configuration

#### Check if Firebase is initialized:
1. In the browser console, type: `firebase.apps.length`
2. You should see a number > 0

#### Common Error Messages and Solutions:

**Error: "Firebase: Error (auth/operation-not-allowed)"**
- Solution: Enable Email/Password authentication in Firebase Console
- Go to: Firebase Console > Authentication > Sign-in method
- Enable "Email/Password" provider

**Error: "Firebase: Error (auth/invalid-api-key)"**
- Solution: Check your `firebase_options.dart` file
- Make sure API keys match your Firebase project

**Error: "Firebase: Error (auth/network-request-failed)"**
- Solution: Check your internet connection
- Verify Firebase project exists and is active

**Error: "Firebase: No Firebase App '[DEFAULT]' has been created"**
- Solution: Firebase not initialized properly
- Check if `Firebase.initializeApp()` is called in `main.dart`

### Step 3: Enable Email/Password Authentication in Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **craftconnect_demo**
3. Click **Authentication** in the left menu
4. Go to **Sign-in method** tab
5. Click on **Email/Password**
6. Toggle **Enable** to ON
7. Click **Save**

### Step 4: Check Firebase Rules (if needed)

If you get permission errors, check Firestore rules:
1. Go to Firebase Console > Firestore Database > Rules
2. For testing, use these rules (TEMPORARY - NOT FOR PRODUCTION):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Step 5: Quick Test Commands

Open browser console and run these to test Firebase:

```javascript
// Check if Firebase is loaded
console.log('Firebase loaded:', typeof firebase !== 'undefined');

// Check current user
console.log('Current user:', firebase.auth().currentUser);

// Test registration (replace with real email/password)
firebase.auth().createUserWithEmailAndPassword('test@example.com', 'password123')
  .then(user => console.log('Success:', user))
  .catch(error => console.error('Error:', error.code, error.message));
```

## What to share with me:

Please copy and paste:
1. The exact error message from the browser console (in red)
2. Screenshot of Firebase Console > Authentication > Sign-in method page
3. Any other errors you see in the console

This will help me fix the exact issue!

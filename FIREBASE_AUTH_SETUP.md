# Firebase Authentication Setup Guide

## Issue: Authentication Failed Error

You're getting an "Authentication failed: Error" message because Firebase Authentication is not properly configured.

## Steps to Fix:

### 1. Enable Firebase Authentication

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **craft-connect-3**
3. Click on **Authentication** in the left sidebar
4. Click **Get Started** (if not already enabled)

### 2. Enable Email/Password Sign-In Method

1. In the Authentication page, click on the **Sign-in method** tab
2. Find **Email/Password** in the list
3. Click on it
4. Toggle **Enable** to ON
5. Click **Save**

### 3. Configure Authorized Domains (for Web)

1. Still in the **Sign-in method** tab, scroll down to **Authorized domains**
2. Make sure `localhost` is in the list (it should be by default)
3. If running on a different domain, add it here

### 4. Verify Firebase Configuration

Your current Firebase config in `firebase_options.dart`:
```
Project ID: craft-connect-3
API Key: AIzaSyDJfpPfs5U7hOTEDkBf5eVzm9CX5UMkMY4
App ID: 1:1063137654489:web:019900cd74c1f1c257b0c8
```

Make sure these values match your Firebase project.

### 5. Test Authentication

After enabling Email/Password authentication:

1. **Hot reload** the app (press `r` in the terminal where Flutter is running)
2. Or **restart** the app completely: `flutter run -d chrome`
3. Try to register again with:
   - Any valid email (e.g., `test@test.com`)
   - Password with at least 6 characters

### 6. Check Browser Console for Errors

If it still fails:
1. Open browser DevTools (F12)
2. Go to the **Console** tab
3. Look for red error messages
4. The error will tell you exactly what's wrong

### Common Errors and Solutions:

#### "operation-not-allowed"
- **Cause**: Email/Password auth not enabled in Firebase Console
- **Fix**: Follow step 2 above

#### "invalid-api-key"
- **Cause**: Wrong API key in firebase_options.dart
- **Fix**: Regenerate config from Firebase Console

#### "auth/network-request-failed"
- **Cause**: No internet connection or Firebase can't be reached
- **Fix**: Check internet connection

#### CORS errors
- **Cause**: Domain not authorized
- **Fix**: Add domain to Authorized domains list (Step 3)

### 7. Enable Firestore Database

Since the app also saves user data to Firestore:

1. Go to **Firestore Database** in Firebase Console
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a region close to you
5. Click **Enable**

### Test Mode Firestore Rules:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2026, 3, 1);
    }
  }
}
```

**Note**: These rules allow anyone to read/write. Change them to production rules before deploying!

## Debug Output

I've added debug print statements to the code. When you try to register, check the terminal output for messages like:
- `AuthService: Starting sign up for email: ...`
- `AuthService: User created successfully: ...`
- `AuthService: FirebaseAuthException - Code: ...`

This will help identify exactly where the error occurs.

## Still Having Issues?

1. Make sure you're using the correct Firebase project
2. Verify your internet connection
3. Check the browser console for detailed error messages
4. Share the full error message from the console or terminal

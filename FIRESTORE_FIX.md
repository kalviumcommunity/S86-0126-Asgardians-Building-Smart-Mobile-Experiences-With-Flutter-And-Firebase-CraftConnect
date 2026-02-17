# Fix Firestore "Stuck on Saving" Issue

## Quick Fix (Manual - Do this NOW):

### Option 1: Deploy Rules via Firebase Console (FASTEST)

1. Go to: https://console.firebase.google.com/project/craft-connect-3/firestore/rules
2. Replace the rules with this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null;
    }
    
    // Allow authenticated users to read/write shops
    match /shops/{shopId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Allow authenticated users to read/write products
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Allow authenticated users to read/write orders
    match /orders/{orderId} {
      allow read, write: if request.auth != null;
    }
    
    // Temporary: Allow all during development
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. Click **"Publish"** button
4. Wait 10 seconds
5. Try registering again in your app

### Option 2: Deploy via Firebase CLI

```bash
cd "D:\Kalvium\SimulationDec\Sprint #2\craftconnect_demo"
firebase deploy --only firestore:rules
```

## Also Check:

### 1. Make sure Firestore Database exists:
- Go to: https://console.firebase.google.com/project/craft-connect-3/firestore
- If you see "Create database", click it and select:
  - **Start in test mode** (for now)
  - Location: Choose closest to you
  - Click **Enable**

### 2. Check browser console for errors:
- Press F12
- Look for any red errors about Firestore
- Share them if you see any

### 3. Test Firestore connection:

Open browser console and run:
```javascript
firebase.firestore().collection('test').add({hello: 'world'})
  .then(() => console.log('Firestore write SUCCESS!'))
  .catch(err => console.error('Firestore write FAILED:', err));
```

If this fails, it means Firestore rules or setup is the issue.

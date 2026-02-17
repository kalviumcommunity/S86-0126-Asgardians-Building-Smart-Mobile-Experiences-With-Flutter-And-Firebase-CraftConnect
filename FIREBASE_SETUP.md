# Firebase Setup Guide for CraftConnect

To get your CraftConnect application running with a live database and authentication, follow these steps:

## 1. Create a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add Project** and name it `CraftConnect`.
3. (Optional) Enable Google Analytics and click **Create Project**.

## 2. Enable Services
In the Firebase Console, enable the following services:

### A. Authentication
1. Go to **Authentication** > **Get Started**.
2. Go to **Sign-in method** and enable:
   - **Email/Password**
   - **Google** (Optional, for future use)

### B. Cloud Firestore
1. Go to **Cloud Firestore** > **Create database**.
2. Select **Start in test mode** (for initial development).
3. Choose a location close to you and click **Enable**.

### C. Firebase Storage
1. Go to **Storage** > **Get Started**.
2. Select **Start in test mode**.
3. Choose a location and click **Done**.

## 3. Register Apps and Get Credentials

### For Android:
1. Click the **Android** icon in project overview.
2. Android package name: `com.craftconnect.app` (or check `android/app/build.gradle`).
3. Download `google-services.json` and place it in `android/app/`.

### For Web (Optional but recommended for testing):
1. Click the **Web** icon (`</>`).
2. Register the app as `CraftConnect Web`.
3. Copy the `firebaseConfig` object.

## 4. Update Flutter Configuration
1. Open `lib/firebase_options.dart`.
2. Replace the placeholder values in the `web`, `android`, and `ios` sections with the credentials you got from the Firebase Console.
   - `apiKey`
   - `appId`
   - `messagingSenderId`
   - `projectId`
   - `storageBucket`

## 5. Deployment of Rules
Ensure your Firestore and Storage rules allow read/write access during testing.

**Firestore Rule (Test Mode):**
```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // Only for testing!
    }
  }
}
```

**Storage Rule (Test Mode):**
```text
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true; // Only for testing!
    }
  }
}
```

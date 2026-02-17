# Application Run Guide

Follow these steps to run the CraftConnect application on your local machine.

## Prerequisites
1. **Flutter SDK**: Ensure you have Flutter installed. Run `flutter --version` to check.
2. **Java JDK**: Required for Android builds.
3. **Android Studio / VS Code**: With Flutter and Dart plugins installed.

## Setup Steps

### 1. Install Dependencies
Open your terminal in the project root and run:
```bash
flutter pub get
```

### 2. Generate Localization Files
The app supports English, Hindi, and Telugu. Generate the translation files by running:
```bash
flutter gen-l10n
```

### 3. Firebase Configuration
Ensure you have followed the steps in `FIREBASE_SETUP.md` and updated `lib/firebase_options.dart`.

### 4. Run the Application

#### To run on an Emulator/Device:
```bash
flutter run
```

#### To run on Windows Desktop (if enabled):
```bash
flutter run -d windows
```

#### To run on Web:
```bash
flutter run -d chrome
```

## Troubleshooting

### Localization Errors
If you see errors related to `AppLocalizations`, make sure you have run `flutter gen-l10n`.

### Firebase Errors
- Ensure `google-services.json` is in `android/app/`.
- Check that your `projectId` in `firebase_options.dart` matches your Firebase console project.

### Missing Assets
If the app shows errors about missing assets, ensure you have created the directory:
```bash
mkdir -p assets/images assets/icons
```
And added at least one dummy file or updated the `pubspec.yaml` to match your actual asset structure.

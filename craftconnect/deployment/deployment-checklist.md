# 📋 CraftConnect Deployment Checklist

## Pre-Deployment Preparation

### ✅ Development Environment
- [ ] Flutter SDK is installed and up to date (`flutter --version`)
- [ ] Android Studio/VS Code with Flutter extensions
- [ ] Git repository is set up and code is committed
- [ ] All team members have access to necessary accounts

### ✅ Code Quality
- [ ] All features are implemented and tested
- [ ] Code review completed by team members
- [ ] No TODO/FIXME comments in production code
- [ ] Flutter analyze passes without errors (`flutter analyze`)
- [ ] All tests pass (`flutter test`)
- [ ] Performance testing completed on target devices

### ✅ App Configuration
- [ ] App name is finalized in `pubspec.yaml`
- [ ] Version number updated (`version: 1.0.0+1`)
- [ ] App description is written
- [ ] Application ID is set (e.g., `com.yourcompany.craftconnect`)
- [ ] App icons are created for all densities
- [ ] Splash screen is configured

### ✅ Firebase Setup (if applicable)
- [ ] Firebase project created
- [ ] `google-services.json` added to `android/app/`
- [ ] `GoogleService-Info.plist` added to `ios/Runner/`
- [ ] Firebase configuration completed (`flutterfire configure`)
- [ ] Firestore security rules configured
- [ ] Authentication methods enabled
- [ ] Cloud Functions deployed (if any)

## Security & Compliance

### ✅ Security Configuration
- [ ] No hardcoded API keys or secrets in code
- [ ] Environment variables or secure storage used for sensitive data
- [ ] Network security configuration reviewed
- [ ] Permissions in AndroidManifest.xml are minimal and necessary
- [ ] ProGuard/R8 obfuscation enabled for release builds

### ✅ Privacy & Legal
- [ ] Privacy policy created and hosted
- [ ] Terms of service created (if required)
- [ ] GDPR compliance checked (if applicable)
- [ ] Data collection practices documented
- [ ] Third-party libraries reviewed for compliance

## Build Configuration

### ✅ Android Release Setup
- [ ] Release keystore generated and secured
  ```bash
  keytool -genkey -v -keystore app-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias app-release-key
  ```
- [ ] `android/key.properties` file created with keystore details
- [ ] `build.gradle.kts` configured for release signing
- [ ] ProGuard rules file created (`android/app/proguard-rules.pro`)
- [ ] Target SDK set to 34 (Android 14)
- [ ] Minimum SDK appropriate for target audience (recommended: 21)

### ✅ Build Artifacts
- [ ] Release APK builds successfully (`flutter build apk --release`)
- [ ] Release App Bundle builds successfully (`flutter build appbundle --release`)
- [ ] Build sizes are reasonable (< 150MB for large apps)
- [ ] All required permissions are declared

## Testing & Quality Assurance

### ✅ Device Testing
- [ ] Tested on multiple Android devices
- [ ] Tested on different screen sizes (phone, tablet)
- [ ] Tested on different Android versions
- [ ] Performance tested on low-end devices
- [ ] Network conditions tested (slow, offline)
- [ ] Battery usage verified to be reasonable

### ✅ Functional Testing
- [ ] All user flows work end-to-end
- [ ] Authentication works properly
- [ ] Data synchronization works
- [ ] Push notifications work (if implemented)
- [ ] Deep links work (if implemented)
- [ ] App handles errors gracefully
- [ ] Loading states and empty states work properly

### ✅ UI/UX Testing
- [ ] App follows Material Design guidelines
- [ ] Dark mode works properly (if implemented)
- [ ] Text is readable on all screen sizes
- [ ] Touch targets are appropriately sized
- [ ] Navigation is intuitive
- [ ] Accessibility features tested

## Google Play Console Setup

### ✅ Play Console Account
- [ ] Google Play Console account created/accessed
- [ ] Developer account fee paid ($25 one-time)
- [ ] Identity verification completed
- [ ] App created in Play Console

### ✅ Store Listing
- [ ] App title chosen (30 character limit)
- [ ] Short description written (80 character limit)
- [ ] Full description written (4000 character limit)
- [ ] Screenshots captured for all required sizes:
  - [ ] Phone screenshots (2-8 images)
  - [ ] 7" tablet screenshots (if supporting tablets)
  - [ ] 10" tablet screenshots (if supporting tablets)
- [ ] Feature graphic created (1024 x 500 pixels)
- [ ] App icon uploaded (512 x 512 pixels)

### ✅ Content Rating
- [ ] Content rating questionnaire completed
- [ ] Age rating received and reviewed
- [ ] Content descriptors reviewed

### ✅ App Pricing & Distribution
- [ ] Pricing set (free or paid)
- [ ] Country/region distribution selected
- [ ] Device categories selected (phone, tablet, Android Auto, etc.)

## Release Management

### ✅ Release Tracks
- [ ] Internal testing track set up
- [ ] Closed testing track configured (if needed)
- [ ] Open testing track configured (if needed)
- [ ] Production track prepared

### ✅ App Bundle Upload
- [ ] App Bundle (AAB) uploaded to chosen track
- [ ] Release notes written for the version
- [ ] Rollout percentage set (start with 5-10% for production)

### ✅ Pre-Launch Testing
- [ ] Internal testing completed with team
- [ ] Closed testing with external testers (optional)
- [ ] Pre-launch report reviewed (automatic testing by Google)
- [ ] Any critical issues resolved

## Production Deployment

### ✅ Final Checks
- [ ] All previous checklist items completed
- [ ] App tested on release build (not debug)
- [ ] Backup of keystore and passwords stored securely
- [ ] Team notified of pending release
- [ ] Monitoring tools set up (Firebase Analytics, Crashlytics)

### ✅ Release Execution
- [ ] App Bundle uploaded to Production track
- [ ] Release notes finalized
- [ ] Rollout started with small percentage (5-10%)
- [ ] Release announcement prepared for users

## Post-Deployment

### ✅ Monitoring & Support
- [ ] App performance monitored in Play Console
- [ ] Crash reports monitored (Firebase Crashlytics)
- [ ] User reviews monitored and responded to
- [ ] Analytics data reviewed
- [ ] Support channels set up for user issues

### ✅ Gradual Rollout
- [ ] Monitor for 24-48 hours at initial rollout percentage
- [ ] Increase rollout percentage gradually (20%, 50%, 100%)
- [ ] Watch for spikes in crashes or negative reviews
- [ ] Be prepared to halt rollout if issues arise

### ✅ Success Metrics
- [ ] Download numbers tracked
- [ ] User engagement metrics monitored
- [ ] Crash-free user percentage monitored (target: >99.5%)
- [ ] App performance metrics reviewed
- [ ] User feedback collected and analyzed

## Emergency Procedures

### ✅ Rollback Plan
- [ ] Previous APK/AAB versions backed up
- [ ] Rollback procedure documented
- [ ] Team knows how to halt rollout
- [ ] Emergency contact list prepared
- [ ] Communication plan for critical issues

## Documentation

### ✅ Team Documentation
- [ ] Deployment process documented
- [ ] Keystore management process documented
- [ ] Emergency procedures documented
- [ ] Access credentials documented (securely)
- [ ] Lessons learned documented for future releases

---

## Quick Deployment Commands

### Validation
```bash
# Run pre-deployment validation
./deployment/validate_deployment.sh

# Quick validation only
./deployment/validate_deployment.sh quick
```

### Building
```bash
# Build both APK and AAB
./deployment/build_release.sh

# Build APK only
./deployment/build_release.sh apk

# Build AAB only
./deployment/build_release.sh aab
```

### Testing
```bash
# Install APK on connected device
adb install build/app/outputs/flutter-apk/app-release.apk

# Test app bundle locally (requires bundletool)
java -jar bundletool.jar build-apks --bundle=app-release.aab --output=app.apks
java -jar bundletool.jar install-apks --apks=app.apks
```

---

## Important Notes

⚠️ **NEVER commit keystore files to version control**
⚠️ **Always test on physical devices before release**
⚠️ **Start with a small rollout percentage for production releases**
⚠️ **Keep keystore and passwords in a secure location**
⚠️ **Monitor the app closely for the first 24-48 hours after release**

## Support Resources

- [Google Play Console Help](https://support.google.com/googleplay/android-developer/)
- [Flutter Deployment Guide](https://docs.flutter.dev/deployment/android)
- [Firebase Console](https://console.firebase.google.com/)
- [Material Design Guidelines](https://material.io/design)

---

**Last Updated:** $(date '+%Y-%m-%d')
**Version:** 1.0.0
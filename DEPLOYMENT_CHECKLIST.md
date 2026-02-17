# 🚀 PRE-DEPLOYMENT CHECKLIST

## ⚡ Quick Deployment Guide for CraftConnect

---

## 🔴 CRITICAL - Must Do Before ANY Deployment

### 1. Set Admin User IDs
**Files to Edit:**
- [ ] `firestore.rules` (line 50)
- [ ] `storage.rules` (line 30)

**Action:**
Replace `'ADMIN_UID_1'` and `'ADMIN_UID_2'` with actual Firebase user UIDs of admin accounts.

**How to get UIDs:**
1. Create admin accounts in Firebase Console → Authentication
2. Copy their UID values
3. Paste into the rules files

**Deploy Rules:**
```bash
firebase deploy --only firestore:rules,storage
```

---

## 🟡 IMPORTANT - Required for Play Store Release

### 2. Generate Release Keystore

```bash
keytool -genkey -v -keystore ~/craftconnect-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias craftconnect
```

**Remember:**
- Store password
- Key password  
- Alias name
- Keep .jks file SAFE and BACKED UP

### 3. Configure Signing

Edit `android/app/build.gradle.kts`:

Replace lines 37-44 with your actual keystore info:
```kotlin
create("release") {
    keyAlias = "craftconnect"  // Your alias
    keyPassword = "YOUR_KEY_PASSWORD"
    storeFile = file("/path/to/craftconnect-release.jks")
    storePassword = "YOUR_STORE_PASSWORD"
}
```

⚠️ **SECURITY:** Never commit passwords to Git. Use environment variables or key.properties file.

---

## 🟢 RECOMMENDED - Better User Experience

### 4. Create App Banner
- [ ] Open `assets/images/banner.svg` in design tool
- [ ] Export as PNG (800x400 pixels)
- [ ] Save as `assets/images/banner.png`
- [ ] Use your app's branding colors

### 5. Test Release Build
```bash
flutter build apk --release
# Test the APK on real device
flutter install --release
```

---

## 📋 DEPLOYMENT STEPS

### For Firebase Hosting (Web)
```bash
flutter build web --release
firebase deploy --only hosting
```

### For Google Play Store (Android)
```bash
# Build app bundle (recommended)
flutter build appbundle --release

# Or build APK
flutter build apk --release

# Upload to Google Play Console
# File location: build/app/outputs/bundle/release/app-release.aab
```

### For Apple App Store (iOS)
```bash
flutter build ipa --release
# Open in Xcode and upload via Archive
```

---

## ✅ VERIFICATION CHECKLIST

Before submitting to stores:

### Functionality
- [ ] User registration works
- [ ] Login works (email & phone)
- [ ] Shop creation works
- [ ] Product upload works (with images)
- [ ] Orders can be placed
- [ ] Push notifications working
- [ ] Language switching works
- [ ] All screens load properly

### Technical
- [ ] No crashes on startup
- [ ] Firebase connection successful
- [ ] Image upload/download works
- [ ] Network error handling works
- [ ] App responds to deep links
- [ ] Back button works correctly

### Security
- [ ] Admin UIDs set in Firebase rules
- [ ] Firebase rules deployed
- [ ] Release keystore configured
- [ ] No API keys in source control

### Assets
- [ ] App icon visible
- [ ] Banner image (if used)
- [ ] All images load correctly

### Testing
- [ ] Tested on Android device
- [ ] Tested on iOS device (if applicable)
- [ ] Tested with slow network
- [ ] Tested offline scenarios

---

## 🎯 CURRENT STATUS

✅ **All Code Fixes Applied**
- Security rules implemented
- Debug code removed
- Permissions added
- Deprecated code fixed
- Build configuration ready

⚠️ **Manual Steps Required**
1. Set admin UIDs
2. Generate keystore  
3. Configure signing

📱 **Ready to Build:** YES
🔒 **Ready to Deploy:** After manual steps
🏪 **Store Ready:** After keystore setup

---

## 🆘 TROUBLESHOOTING

### "Firestore rules error"
→ Make sure you deployed rules: `firebase deploy --only firestore:rules,storage`

### "Signing error" during build
→ Check keystore path, passwords, and alias are correct

### "Permission denied" on device
→ Uninstall old version, install fresh

### Images not uploading
→ Check Firebase Storage rules are deployed
→ Verify storage bucket name in Firebase Console

### Build fails
→ Run `flutter clean && flutter pub get`
→ Check Flutter version: `flutter doctor`

---

## 📞 NEXT STEPS

1. ✅ Complete the 3 critical/important items above
2. ✅ Run through verification checklist
3. ✅ Build and test release version
4. ✅ Submit to app stores
5. 🎉 Launch CraftConnect!

---

**Your app is 95% ready for production!**  
Just complete the manual configuration steps above and you're good to go! 🚀

*Last Updated: February 16, 2026*

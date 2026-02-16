# 🚀 CraftConnect Deployment Tools

This directory contains a comprehensive set of tools and documentation for deploying CraftConnect to production on Google Play Store.

## 📋 Quick Start

### 1. Prepare for Deployment
```bash
# Navigate to project root
cd craftconnect

# Run pre-deployment validation
./deployment/validate_deployment.sh

# Review checklist
cat deployment/deployment-checklist.md
```

### 2. Build Release Artifacts
```bash
# Build both APK and AAB
./deployment/build_release.sh

# Or build specific format
./deployment/build_release.sh apk    # APK only
./deployment/build_release.sh aab    # App Bundle only
```

### 3. Deploy (Automated Process)
```bash
# Full deployment process
./deployment/deploy.sh

# Test deployment process (no actual changes)
./deployment/deploy.sh --dry-run

# Deploy to production with 10% rollout
./deployment/deploy.sh --track production --rollout 10
```

## 📁 Directory Structure

```
deployment/
├── README.md                          # This file
├── deployment-checklist.md            # Comprehensive deployment checklist
├── play-store-deployment-guide.md     # Detailed Google Play Store guide
├── validate_deployment.sh             # Pre-deployment validation script
├── build_release.sh                   # Release build automation (Linux/Mac)
├── build_release.bat                  # Release build automation (Windows)
├── deploy.sh                          # Complete deployment automation
├── logs/                              # Deployment logs (auto-created)
└── packages/                          # Release packages (auto-created)
```

## 🛠️ Available Tools

### 🔍 Pre-Deployment Validation (`validate_deployment.sh`)

Comprehensive validation of your app before deployment:

```bash
# Full validation suite
./deployment/validate_deployment.sh

# Quick validation (basic checks only)
./deployment/validate_deployment.sh quick

# Security validation only
./deployment/validate_deployment.sh security

# Firebase validation only
./deployment/validate_deployment.sh firebase
```

**What it checks:**
- Flutter environment and dependencies
- Project structure and configuration
- Build configuration and signing
- App metadata and versioning
- Security and privacy compliance
- Code quality and performance
- Firebase setup (if applicable)

### 🔨 Release Build Tools

#### Linux/macOS: `build_release.sh`
```bash
# Build both APK and AAB
./deployment/build_release.sh

# Build specific format
./deployment/build_release.sh apk
./deployment/build_release.sh aab

# Clean build artifacts
./deployment/build_release.sh clean

# Show help
./deployment/build_release.sh help
```

#### Windows: `build_release.bat`
```cmd
REM Build both APK and AAB
deployment\build_release.bat

REM Build specific format
deployment\build_release.bat apk
deployment\build_release.bat aab

REM Clean build artifacts
deployment\build_release.bat clean
```

**Features:**
- Automated project cleaning
- Version extraction from `pubspec.yaml`
- Release signing with keystore
- Build verification and checksums
- Detailed release notes generation
- Size optimization reporting

### 🚀 Complete Deployment Automation (`deploy.sh`)

End-to-end deployment process automation:

```bash
# Standard deployment to internal track
./deployment/deploy.sh

# Production deployment with custom rollout
./deployment/deploy.sh --track production --rollout 10

# Test the process without making changes
./deployment/deploy.sh --dry-run

# Skip validation and testing
./deployment/deploy.sh --no-validation --no-testing
```

**Available Options:**
- `--track`: Release track (internal|closed|open|production)
- `--rollout`: Initial rollout percentage (1-100)
- `--no-validation`: Skip pre-deployment validation
- `--no-testing`: Skip running tests
- `--dry-run`: Test process without making changes
- `--help`: Show help information

**Process Steps:**
1. 🔍 Prerequisites check
2. ✅ Pre-deployment validation
3. 🧪 Test execution
4. 🔨 Release build creation
5. 🔍 Final checks
6. 📦 Deployment package creation
7. 📋 Next steps guidance

## 📚 Documentation

### 📋 Deployment Checklist (`deployment-checklist.md`)
Interactive checklist covering:
- Pre-deployment preparation
- Security & compliance
- Build configuration
- Testing & quality assurance
- Google Play Console setup
- Release management
- Post-deployment monitoring

### 📖 Play Store Guide (`play-store-deployment-guide.md`)
Comprehensive guide including:
- Account setup and verification
- App creation and configuration
- Store listing optimization
- Privacy policy and legal requirements
- Release track management
- Monitoring and analytics
- Troubleshooting common issues

## 🔧 Prerequisites

### Development Environment
- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extensions
- Git (for version control)
- Java Development Kit (JDK 11 or higher)

### Build Requirements
- Release keystore (see guide for generation)
- `android/key.properties` file configured
- All dependencies up to date
- Valid Firebase configuration (if applicable)

### Google Play Console
- Google Developer Account ($25 one-time fee)
- Identity verification completed
- App created in Play Console
- Store listing information prepared

## 🚦 Deployment Workflow

### Phase 1: Preparation
1. Complete feature development
2. Update version in `pubspec.yaml`
3. Run validation: `./deployment/validate_deployment.sh`
4. Review checklist: `deployment/deployment-checklist.md`

### Phase 2: Testing
1. Run all tests: `flutter test`
2. Test on multiple devices
3. Performance and compatibility testing
4. Security review

### Phase 3: Build
1. Generate release keystore (one-time)
2. Configure `android/key.properties`
3. Build release: `./deployment/build_release.sh`
4. Verify build artifacts

### Phase 4: Upload
1. Manual upload to Google Play Console
2. Configure release settings
3. Set rollout percentage (start with 5-10%)
4. Submit for review

### Phase 5: Monitoring
1. Monitor crash reports
2. Track user feedback
3. Watch performance metrics
4. Gradually increase rollout

## 🔐 Security Considerations

### Keystore Management
- **NEVER** commit keystore files to version control
- Store keystore and passwords securely
- Create backup copies in secure locations
- Document keystore details for team access

### Sensitive Information
- Use environment variables for API keys
- Keep Firebase configuration files secure
- Review privacy policy requirements
- Implement proper authentication

### Build Security
- Enable ProGuard/R8 obfuscation
- Minimize required permissions
- Use network security configuration
- Regular security audits

## 📊 Monitoring & Analytics

### Build Monitoring
- Automated size tracking
- Performance metrics collection
- Crash reporting setup
- User engagement analytics

### Deployment Logs
All deployment activities are logged to `deployment/logs/`:
- Validation results
- Build outputs
- Deployment timestamps
- Error diagnostics

### Release Packages
Generated packages in `deployment/packages/`:
- Timestamped release directories
- Build artifacts (APK, AAB)
- Checksums and verification files
- Deployment documentation

## 🆘 Troubleshooting

### Common Issues

#### Build Failures
```bash
# Clean and retry
flutter clean
flutter pub get
./deployment/build_release.sh
```

#### Signing Issues
- Verify `android/key.properties` configuration
- Check keystore file path and passwords
- Ensure keystore compatibility

#### Validation Failures
```bash
# Run specific validation
./deployment/validate_deployment.sh quick
./deployment/validate_deployment.sh security

# Check Flutter doctor
flutter doctor -v
```

#### Upload Issues
- Verify AAB file integrity
- Check Google Play Console permissions
- Review content policy compliance

### Getting Help

1. **Check Logs**: Review `deployment/logs/` for detailed error information
2. **Validation**: Run `./deployment/validate_deployment.sh` for diagnostics
3. **Documentation**: Refer to `play-store-deployment-guide.md`
4. **Community**: Flutter and Google Play developer forums
5. **Support**: Google Play Console help center

## 🎯 Best Practices

### Version Management
- Use semantic versioning (x.y.z+build)
- Increment build number for each release
- Maintain changelog for user-facing changes
- Tag releases in version control

### Testing Strategy
- Automated unit and widget tests
- Manual testing on multiple devices
- Performance testing on low-end devices
- User acceptance testing

### Release Strategy
- Start with internal testing
- Gradual rollout to production
- Monitor metrics before full rollout
- Have rollback plan ready

### Documentation
- Keep deployment docs updated
- Document team procedures
- Maintain emergency contact list
- Record lessons learned

## 📅 Release Schedule Template

### Weekly Release Cycle
- **Monday**: Feature freeze, testing begins
- **Tuesday**: Quality assurance and bug fixes
- **Wednesday**: Release build and internal testing
- **Thursday**: Play Console upload and review
- **Friday**: Production rollout and monitoring

### Emergency Releases
- Hotfix procedure documented
- Streamlined approval process
- Direct to production capability
- Post-incident review required

---

## 📞 Support & Resources

- **Flutter Documentation**: https://docs.flutter.dev/deployment/android
- **Google Play Console**: https://support.google.com/googleplay/android-developer/
- **Firebase Console**: https://console.firebase.google.com/
- **Material Design**: https://material.io/design
- **Android Developer Guide**: https://developer.android.com/distribute

---

**Last Updated**: 2024-01-XX
**Version**: 1.0.0
**Maintainer**: CraftConnect Development Team
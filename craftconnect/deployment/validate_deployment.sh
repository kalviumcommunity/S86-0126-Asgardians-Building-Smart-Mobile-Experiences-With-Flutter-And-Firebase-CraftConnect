#!/bin/bash

# 🔍 CraftConnect - Pre-Deployment Validation Script
# This script validates all deployment requirements before releasing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Validation results
VALIDATION_PASSED=true
ERROR_COUNT=0
WARNING_COUNT=0

print_header() {
    echo -e "${BLUE}"
    echo "========================================"
    echo "🔍 CRAFTCONNECT DEPLOYMENT VALIDATION"
    echo "========================================"
    echo -e "${NC}"
}

print_section() {
    echo -e "${PURPLE}[SECTION]${NC} $1"
    echo "----------------------------------------"
}

print_check() {
    echo -e "${BLUE}[CHECK]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}✅ PASS:${NC} $1"
}

print_fail() {
    echo -e "${RED}❌ FAIL:${NC} $1"
    VALIDATION_PASSED=false
    ((ERROR_COUNT++))
}

print_warning() {
    echo -e "${YELLOW}⚠️  WARN:${NC} $1"
    ((WARNING_COUNT++))
}

print_info() {
    echo -e "${BLUE}ℹ️  INFO:${NC} $1"
}

# Validate Flutter Environment
validate_flutter_environment() {
    print_section "Flutter Environment Validation"
    
    print_check "Checking Flutter installation"
    if command -v flutter &> /dev/null; then
        FLUTTER_VERSION=$(flutter --version | head -n 1)
        print_pass "Flutter is installed: $FLUTTER_VERSION"
    else
        print_fail "Flutter is not installed or not in PATH"
    fi
    
    print_check "Checking Flutter doctor"
    if flutter doctor --machine > /tmp/flutter_doctor.json 2>/dev/null; then
        print_pass "Flutter doctor completed successfully"
        
        # Check for issues
        if grep -q '"type":"error"' /tmp/flutter_doctor.json; then
            print_fail "Flutter doctor reports errors. Run 'flutter doctor' for details"
        else
            print_pass "No Flutter doctor errors found"
        fi
    else
        print_fail "Flutter doctor check failed"
    fi
    
    echo ""
}

# Validate Project Structure
validate_project_structure() {
    print_section "Project Structure Validation"
    
    # Check essential files
    essential_files=(
        "pubspec.yaml"
        "lib/main.dart"
        "android/app/build.gradle.kts"
        "android/app/src/main/AndroidManifest.xml"
    )
    
    for file in "${essential_files[@]}"; do
        print_check "Checking $file"
        if [ -f "$file" ]; then
            print_pass "$file exists"
        else
            print_fail "$file is missing"
        fi
    done
    
    # Check if we have proper permissions in AndroidManifest.xml
    print_check "Checking AndroidManifest.xml permissions"
    if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
        if grep -q "android.permission.INTERNET" "android/app/src/main/AndroidManifest.xml"; then
            print_pass "Internet permission found"
        else
            print_warning "Internet permission not found - may be needed for Firebase"
        fi
    fi
    
    echo ""
}

# Validate Dependencies
validate_dependencies() {
    print_section "Dependencies Validation"
    
    print_check "Checking pubspec.yaml syntax"
    if flutter pub deps > /dev/null 2>&1; then
        print_pass "pubspec.yaml syntax is valid"
    else
        print_fail "pubspec.yaml has syntax errors"
    fi
    
    print_check "Checking for outdated dependencies"
    flutter pub outdated --json > /tmp/outdated.json 2>/dev/null || true
    if [ -f "/tmp/outdated.json" ]; then
        OUTDATED_COUNT=$(grep -c '"resolvable"' /tmp/outdated.json 2>/dev/null || echo "0")
        if [ "$OUTDATED_COUNT" -gt 0 ]; then
            print_warning "$OUTDATED_COUNT dependencies have updates available"
        else
            print_pass "All dependencies are up to date"
        fi
    fi
    
    # Check for critical dependencies
    print_check "Checking Firebase dependencies"
    if grep -q "firebase_" pubspec.yaml; then
        print_pass "Firebase dependencies found"
        
        # Check for google-services.json
        if [ -f "android/app/google-services.json" ]; then
            print_pass "google-services.json found"
        else
            print_fail "google-services.json is missing for Firebase"
        fi
    else
        print_info "No Firebase dependencies detected"
    fi
    
    echo ""
}

# Validate Build Configuration
validate_build_configuration() {
    print_section "Build Configuration Validation"
    
    print_check "Checking release signing configuration"
    if [ -f "android/key.properties" ]; then
        print_pass "key.properties file exists"
        
        # Check if keystore file exists
        if grep -q "storeFile=" android/key.properties; then
            KEYSTORE_PATH=$(grep "storeFile=" android/key.properties | cut -d'=' -f2)
            if [ -f "android/$KEYSTORE_PATH" ]; then
                print_pass "Keystore file found"
            else
                print_fail "Keystore file not found at: android/$KEYSTORE_PATH"
            fi
        fi
    else
        print_warning "key.properties not found - using debug signing"
    fi
    
    print_check "Checking build.gradle.kts configuration"
    if grep -q "signingConfigs" android/app/build.gradle.kts; then
        print_pass "Signing configuration found in build.gradle.kts"
    else
        print_warning "No signing configuration in build.gradle.kts"
    fi
    
    print_check "Checking ProGuard configuration"
    if grep -q "proguardFiles" android/app/build.gradle.kts; then
        print_pass "ProGuard configuration found"
        
        if [ -f "android/app/proguard-rules.pro" ]; then
            print_pass "ProGuard rules file exists"
        else
            print_warning "ProGuard rules file not found"
        fi
    else
        print_warning "ProGuard not configured"
    fi
    
    echo ""
}

# Validate App Metadata
validate_app_metadata() {
    print_section "App Metadata Validation"
    
    # Check version information
    print_check "Checking version information in pubspec.yaml"
    if grep -q "version:" pubspec.yaml; then
        VERSION=$(grep "version:" pubspec.yaml | cut -d' ' -f2)
        print_pass "Version found: $VERSION"
        
        # Validate version format
        if [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$ ]]; then
            print_pass "Version format is valid (x.y.z+build)"
        else
            print_fail "Version format is invalid. Expected: x.y.z+build"
        fi
    else
        print_fail "Version not specified in pubspec.yaml"
    fi
    
    # Check app name and description
    print_check "Checking app name"
    if grep -q "name:" pubspec.yaml; then
        APP_NAME=$(grep "name:" pubspec.yaml | cut -d' ' -f2)
        print_pass "App name: $APP_NAME"
    else
        print_fail "App name not specified"
    fi
    
    print_check "Checking app description"
    if grep -q "description:" pubspec.yaml; then
        print_pass "App description found"
    else
        print_warning "App description not specified"
    fi
    
    echo ""
}

# Validate Android Configuration
validate_android_configuration() {
    print_section "Android Configuration Validation"
    
    # Check target SDK
    print_check "Checking target SDK version"
    if grep -q "compileSdk.*34" android/app/build.gradle.kts; then
        print_pass "Target SDK 34 (Android 14) configured"
    else
        print_warning "Target SDK should be 34 for current Google Play requirements"
    fi
    
    # Check minimum SDK
    print_check "Checking minimum SDK version"
    if grep -q "minSdk.*21" android/app/build.gradle.kts; then
        print_pass "Minimum SDK 21 (Android 5.0) configured"
    else
        print_warning "Consider minimum SDK 21 for broader compatibility"
    fi
    
    # Check application ID
    print_check "Checking application ID"
    if grep -q "applicationId" android/app/build.gradle.kts; then
        APP_ID=$(grep "applicationId" android/app/build.gradle.kts | sed 's/.*"\([^"]*\)".*/\1/')
        print_pass "Application ID: $APP_ID"
        
        # Validate application ID format
        if [[ $APP_ID =~ ^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+$ ]]; then
            print_pass "Application ID format is valid"
        else
            print_fail "Application ID format is invalid"
        fi
    else
        print_fail "Application ID not configured"
    fi
    
    echo ""
}

# Validate Code Quality
validate_code_quality() {
    print_section "Code Quality Validation"
    
    print_check "Running Flutter analyze"
    if flutter analyze --no-pub > /tmp/analyze_output.txt 2>&1; then
        print_pass "No analysis issues found"
    else
        ISSUE_COUNT=$(grep -c "info\|warning\|error" /tmp/analyze_output.txt 2>/dev/null || echo "0")
        if [ "$ISSUE_COUNT" -gt 0 ]; then
            print_warning "$ISSUE_COUNT analysis issues found. Check with 'flutter analyze'"
        else
            print_pass "Code analysis passed"
        fi
    fi
    
    print_check "Checking for TODO comments"
    TODO_COUNT=$(find lib -name "*.dart" -exec grep -l "TODO\|FIXME\|HACK" {} \; 2>/dev/null | wc -l)
    if [ "$TODO_COUNT" -gt 0 ]; then
        print_warning "$TODO_COUNT files contain TODO/FIXME/HACK comments"
    else
        print_pass "No TODO/FIXME/HACK comments found"
    fi
    
    echo ""
}

# Validate Firebase Configuration (if applicable)
validate_firebase_configuration() {
    if grep -q "firebase" pubspec.yaml; then
        print_section "Firebase Configuration Validation"
        
        print_check "Checking Firebase configuration files"
        if [ -f "android/app/google-services.json" ]; then
            print_pass "Android google-services.json found"
        else
            print_fail "Android google-services.json is missing"
        fi
        
        if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
            print_pass "iOS GoogleService-Info.plist found"
        else
            print_warning "iOS GoogleService-Info.plist not found (iOS build will fail)"
        fi
        
        print_check "Checking Firebase project configuration"
        if [ -f "lib/firebase_options.dart" ]; then
            print_pass "Firebase options configuration found"
        else
            print_fail "Firebase options not configured. Run 'flutterfire configure'"
        fi
        
        echo ""
    fi
}

# Validate Security
validate_security() {
    print_section "Security Validation"
    
    print_check "Checking for hardcoded secrets"
    SECRET_PATTERNS=("password" "secret" "key" "token" "api_key")
    SECRET_FOUND=false
    
    for pattern in "${SECRET_PATTERNS[@]}"; do
        if grep -r -i "$pattern.*=" lib/ 2>/dev/null | grep -v "// ignore" | grep -q "="; then
            SECRET_FOUND=true
            break
        fi
    done
    
    if [ "$SECRET_FOUND" = true ]; then
        print_warning "Potential hardcoded secrets found. Review code for sensitive data"
    else
        print_pass "No obvious hardcoded secrets found"
    fi
    
    print_check "Checking network security configuration"
    if [ -f "android/app/src/main/res/xml/network_security_config.xml" ]; then
        print_pass "Network security configuration found"
    else
        print_info "No custom network security configuration (using defaults)"
    fi
    
    echo ""
}

# Validate Performance
validate_performance() {
    print_section "Performance Validation"
    
    # Check for common performance issues
    print_check "Checking for potential performance issues"
    
    # Check for setState in loops
    if grep -r "setState.*for\|for.*setState" lib/ 2>/dev/null | grep -q "."; then
        print_warning "Potential setState in loops found - review for performance"
    else
        print_pass "No setState in loops detected"
    fi
    
    # Check image optimization
    print_check "Checking image assets"
    if [ -d "assets/images" ]; then
        LARGE_IMAGES=$(find assets/images -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" 2>/dev/null | xargs ls -la 2>/dev/null | awk '$5 > 1048576 {print $9}' | wc -l)
        if [ "$LARGE_IMAGES" -gt 0 ]; then
            print_warning "$LARGE_IMAGES images larger than 1MB found - consider optimization"
        else
            print_pass "No large images detected"
        fi
    fi
    
    echo ""
}

# Generate validation report
generate_report() {
    print_section "Validation Summary"
    
    # Print results
    if [ "$VALIDATION_PASSED" = true ]; then
        if [ "$WARNING_COUNT" -eq 0 ]; then
            print_pass "✅ ALL VALIDATIONS PASSED - Ready for deployment!"
        else
            print_warning "✅ Validations passed with $WARNING_COUNT warnings"
        fi
    else
        print_fail "❌ VALIDATION FAILED - $ERROR_COUNT errors found"
    fi
    
    echo ""
    echo "Summary:"
    echo "- Errors: $ERROR_COUNT"
    echo "- Warnings: $WARNING_COUNT"
    
    # Create detailed report file
    REPORT_FILE="deployment/validation_report_$(date +%Y%m%d_%H%M%S).txt"
    mkdir -p deployment
    
    {
        echo "CraftConnect Deployment Validation Report"
        echo "Generated: $(date)"
        echo "========================================"
        echo ""
        echo "Validation Results:"
        echo "- Total Errors: $ERROR_COUNT"
        echo "- Total Warnings: $WARNING_COUNT"
        echo "- Status: $([ "$VALIDATION_PASSED" = true ] && echo "PASSED" || echo "FAILED")"
        echo ""
        echo "Next Steps:"
        if [ "$VALIDATION_PASSED" = true ]; then
            echo "✅ Your app is ready for deployment!"
            echo "1. Run './deployment/build_release.sh' to create production builds"
            echo "2. Test the APK on physical devices"
            echo "3. Upload AAB to Google Play Console"
        else
            echo "❌ Fix the following issues before deployment:"
            echo "1. Address all error messages above"
            echo "2. Consider fixing warning messages"
            echo "3. Re-run validation script"
        fi
    } > "$REPORT_FILE"
    
    echo ""
    echo "Detailed report saved to: $REPORT_FILE"
    echo ""
}

# Main validation function
main() {
    print_header
    
    # Check if we're in the right directory
    if [ ! -f "pubspec.yaml" ]; then
        print_fail "Not in a Flutter project directory"
        exit 1
    fi
    
    # Run all validations
    validate_flutter_environment
    validate_project_structure
    validate_dependencies
    validate_build_configuration
    validate_app_metadata
    validate_android_configuration
    validate_code_quality
    validate_firebase_configuration
    validate_security
    validate_performance
    
    # Generate final report
    generate_report
    
    # Return appropriate exit code
    if [ "$VALIDATION_PASSED" = true ]; then
        exit 0
    else
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    "quick")
        print_header
        validate_flutter_environment
        validate_project_structure
        validate_build_configuration
        generate_report
        ;;
    "security")
        print_header
        validate_security
        generate_report
        ;;
    "firebase")
        print_header
        validate_firebase_configuration
        generate_report
        ;;
    "help"|"-h"|"--help")
        echo "CraftConnect Pre-Deployment Validation Script"
        echo ""
        echo "Usage: ./validate_deployment.sh [command]"
        echo ""
        echo "Commands:"
        echo "  (no args)  Run full validation suite"
        echo "  quick      Run quick validation (basic checks)"
        echo "  security   Run security validation only"
        echo "  firebase   Run Firebase validation only"
        echo "  help       Show this help message"
        ;;
    *)
        main
        ;;
esac
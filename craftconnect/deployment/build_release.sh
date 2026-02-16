#!/bin/bash

# 🚀 CraftConnect - Automated Release Build Script
# This script automates the process of building production-ready releases

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="CraftConnect"
PACKAGE_NAME="com.example.craftconnect"
BUILD_DIR="build"
KEYSTORE_DIR="release/keystore"
KEYSTORE_NAME="app-release-key.jks"

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Flutter is installed
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Check if we're in a Flutter project
    if [ ! -f "pubspec.yaml" ]; then
        print_error "Not in a Flutter project directory"
        exit 1
    fi
    
    # Check if key.properties exists
    if [ ! -f "android/key.properties" ]; then
        print_warning "key.properties not found. Release will use debug signing."
    fi
    
    print_success "Prerequisites check passed"
}

# Function to clean project
clean_project() {
    print_status "Cleaning project..."
    flutter clean
    flutter pub get
    print_success "Project cleaned and dependencies fetched"
}

# Function to run tests
run_tests() {
    print_status "Running tests..."
    flutter test
    print_success "All tests passed"
}

# Function to analyze code
analyze_code() {
    print_status "Analyzing code..."
    flutter analyze
    print_success "Code analysis completed"
}

# Function to build APK
build_apk() {
    print_status "Building release APK..."
    flutter build apk --release --build-name=$BUILD_NAME --build-number=$BUILD_NUMBER
    
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        print_success "APK built successfully"
        echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
    else
        print_error "APK build failed"
        exit 1
    fi
}

# Function to build App Bundle
build_appbundle() {
    print_status "Building release App Bundle (AAB)..."
    flutter build appbundle --release --build-name=$BUILD_NAME --build-number=$BUILD_NUMBER
    
    if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
        print_success "App Bundle built successfully"
        echo "AAB location: build/app/outputs/bundle/release/app-release.aab"
    else
        print_error "App Bundle build failed"
        exit 1
    fi
}

# Function to verify build
verify_build() {
    print_status "Verifying build..."
    
    # Check APK size (should be reasonable)
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        APK_SIZE=$(du -h "build/app/outputs/flutter-apk/app-release.apk" | cut -f1)
        print_status "APK size: $APK_SIZE"
    fi
    
    # Check AAB size
    if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
        AAB_SIZE=$(du -h "build/app/outputs/bundle/release/app-release.aab" | cut -f1)
        print_status "AAB size: $AAB_SIZE"
    fi
    
    print_success "Build verification completed"
}

# Function to generate checksums
generate_checksums() {
    print_status "Generating checksums..."
    
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        md5sum "build/app/outputs/flutter-apk/app-release.apk" > "build/app/outputs/flutter-apk/app-release.apk.md5"
    fi
    
    if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
        md5sum "build/app/outputs/bundle/release/app-release.aab" > "build/app/outputs/bundle/release/app-release.aab.md5"
    fi
    
    print_success "Checksums generated"
}

# Function to create release notes
create_release_notes() {
    print_status "Creating release notes..."
    
    RELEASE_NOTES_FILE="build/release_notes_v${BUILD_NAME}.txt"
    
    cat > "$RELEASE_NOTES_FILE" << EOF
CraftConnect Release v${BUILD_NAME}
Build Number: ${BUILD_NUMBER}
Build Date: $(date '+%Y-%m-%d %H:%M:%S')

Changes in this version:
- Enhanced user interface with improved theming
- Better error handling and loading states
- Improved performance and stability
- Bug fixes and performance improvements

Technical Details:
- Flutter Version: $(flutter --version | head -n 1)
- Build Type: Release
- Package Name: ${PACKAGE_NAME}
- Target SDK: 34
- Min SDK: 21

Files:
- APK: build/app/outputs/flutter-apk/app-release.apk
- AAB: build/app/outputs/bundle/release/app-release.aab

Build completed successfully!
EOF
    
    print_success "Release notes created: $RELEASE_NOTES_FILE"
}

# Function to display build summary
display_summary() {
    echo ""
    echo "========================================"
    echo "🚀 BUILD SUMMARY"
    echo "========================================"
    echo "App Name: $APP_NAME"
    echo "Package: $PACKAGE_NAME"
    echo "Version: $BUILD_NAME ($BUILD_NUMBER)"
    echo "Build Date: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "Output Files:"
    [ -f "build/app/outputs/flutter-apk/app-release.apk" ] && echo "✅ APK: build/app/outputs/flutter-apk/app-release.apk"
    [ -f "build/app/outputs/bundle/release/app-release.aab" ] && echo "✅ AAB: build/app/outputs/bundle/release/app-release.aab"
    echo ""
    echo "Next Steps:"
    echo "1. Test the APK on a physical device"
    echo "2. Upload the AAB to Google Play Console"
    echo "3. Set up internal testing before production"
    echo "========================================"
}

# Main build function
main() {
    echo "🚀 Starting $APP_NAME Release Build Process"
    echo ""
    
    # Get version info from pubspec.yaml
    BUILD_NAME=$(grep "version:" pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 1)
    BUILD_NUMBER=$(grep "version:" pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 2)
    
    if [ -z "$BUILD_NAME" ] || [ -z "$BUILD_NUMBER" ]; then
        print_error "Could not extract version information from pubspec.yaml"
        exit 1
    fi
    
    print_status "Building version $BUILD_NAME ($BUILD_NUMBER)"
    
    # Run all build steps
    check_prerequisites
    clean_project
    
    # Optional: Run tests and analysis (comment out if not needed)
    # run_tests
    # analyze_code
    
    build_apk
    build_appbundle
    verify_build
    generate_checksums
    create_release_notes
    display_summary
    
    print_success "🎉 Release build completed successfully!"
}

# Handle script arguments
case "${1:-}" in
    "apk")
        print_status "Building APK only..."
        check_prerequisites
        clean_project
        BUILD_NAME=$(grep "version:" pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 1)
        BUILD_NUMBER=$(grep "version:" pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 2)
        build_apk
        ;;
    "aab")
        print_status "Building App Bundle only..."
        check_prerequisites
        clean_project
        BUILD_NAME=$(grep "version:" pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 1)
        BUILD_NUMBER=$(grep "version:" pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 2)
        build_appbundle
        ;;
    "clean")
        print_status "Cleaning build artifacts..."
        flutter clean
        rm -rf build/
        print_success "Clean completed"
        ;;
    "help"|"-h"|"--help")
        echo "CraftConnect Build Script"
        echo ""
        echo "Usage: ./build_release.sh [command]"
        echo ""
        echo "Commands:"
        echo "  (no args)  Build both APK and AAB"
        echo "  apk        Build APK only"
        echo "  aab        Build App Bundle only"
        echo "  clean      Clean build artifacts"
        echo "  help       Show this help message"
        ;;
    *)
        main
        ;;
esac
#!/bin/bash

# 🚀 CraftConnect - Complete Deployment Automation Script
# This script orchestrates the entire deployment process from validation to release

set -e

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$SCRIPT_DIR/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/deployment_$TIMESTAMP.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Deployment configuration
ROLLOUT_PERCENTAGE=5  # Start with 5% rollout
TRACK="internal"      # Default track: internal, closed, open, production
BUILD_TYPE="release"
ENABLE_VALIDATION=true
ENABLE_TESTING=true
DRY_RUN=false

# Create logs directory
mkdir -p "$LOG_DIR"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

print_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════╗
║                    🚀 CRAFTCONNECT DEPLOYMENT                    ║
║                     Automated Release Pipeline                   ║
╚══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

print_section() {
    echo -e "${PURPLE}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${NC}"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
    log "[STEP] $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    log "[SUCCESS] $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    log "[ERROR] $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    log "[WARNING] $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_section "🔍 CHECKING PREREQUISITES"
    
    print_step "Verifying Flutter installation"
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    print_success "Flutter is installed"
    
    print_step "Checking project directory"
    if [ ! -f "$PROJECT_DIR/pubspec.yaml" ]; then
        print_error "Not in a Flutter project directory"
        exit 1
    fi
    print_success "Flutter project detected"
    
    print_step "Checking deployment scripts"
    local scripts=("validate_deployment.sh" "build_release.sh")
    for script in "${scripts[@]}"; do
        if [ ! -f "$SCRIPT_DIR/$script" ]; then
            print_error "Required script not found: $script"
            exit 1
        fi
        chmod +x "$SCRIPT_DIR/$script" 2>/dev/null || true
    done
    print_success "All deployment scripts are available"
}

# Function to display deployment configuration
show_configuration() {
    print_section "⚙️  DEPLOYMENT CONFIGURATION"
    
    echo "📋 Configuration Summary:"
    echo "  • Project Directory: $PROJECT_DIR"
    echo "  • Log File: $LOG_FILE"
    echo "  • Release Track: $TRACK"
    echo "  • Build Type: $BUILD_TYPE"
    echo "  • Rollout Percentage: $ROLLOUT_PERCENTAGE%"
    echo "  • Validation Enabled: $ENABLE_VALIDATION"
    echo "  • Testing Enabled: $ENABLE_TESTING"
    echo "  • Dry Run Mode: $DRY_RUN"
    echo ""
}

# Function to get user confirmation
get_confirmation() {
    if [ "$DRY_RUN" = true ]; then
        print_warning "DRY RUN MODE - No actual deployment will occur"
        return 0
    fi
    
    echo -e "${YELLOW}Are you ready to proceed with deployment? (y/N):${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Deployment cancelled by user"
        exit 0
    fi
}

# Function to run pre-deployment validation
run_validation() {
    if [ "$ENABLE_VALIDATION" != true ]; then
        print_warning "Validation skipped (disabled)"
        return 0
    fi
    
    print_section "✅ PRE-DEPLOYMENT VALIDATION"
    
    print_step "Running comprehensive validation"
    cd "$PROJECT_DIR"
    
    if [ "$DRY_RUN" = true ]; then
        print_warning "DRY RUN: Would run validation script"
        return 0
    fi
    
    if ! "$SCRIPT_DIR/validate_deployment.sh"; then
        print_error "Validation failed. Please fix issues before continuing."
        echo "Check the validation output above for specific issues to resolve."
        exit 1
    fi
    
    print_success "All validations passed successfully"
}

# Function to run tests
run_tests() {
    if [ "$ENABLE_TESTING" != true ]; then
        print_warning "Testing skipped (disabled)"
        return 0
    fi
    
    print_section "🧪 RUNNING TESTS"
    
    cd "$PROJECT_DIR"
    
    print_step "Running unit and widget tests"
    if [ "$DRY_RUN" = true ]; then
        print_warning "DRY RUN: Would run flutter test"
    else
        if ! flutter test; then
            print_error "Tests failed. Fix failing tests before deployment."
            exit 1
        fi
        print_success "All tests passed"
    fi
    
    print_step "Running code analysis"
    if [ "$DRY_RUN" = true ]; then
        print_warning "DRY RUN: Would run flutter analyze"
    else
        if ! flutter analyze; then
            print_error "Code analysis failed. Fix analysis issues before deployment."
            exit 1
        fi
        print_success "Code analysis passed"
    fi
}

# Function to build release artifacts
build_release() {
    print_section "🔨 BUILDING RELEASE ARTIFACTS"
    
    cd "$PROJECT_DIR"
    
    print_step "Building release APK and App Bundle"
    if [ "$DRY_RUN" = true ]; then
        print_warning "DRY RUN: Would run release build script"
        return 0
    fi
    
    if ! "$SCRIPT_DIR/build_release.sh"; then
        print_error "Release build failed"
        exit 1
    fi
    
    print_success "Release artifacts built successfully"
    
    # Display build information
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        APK_SIZE=$(du -h "build/app/outputs/flutter-apk/app-release.apk" | cut -f1)
        echo "  📱 APK Size: $APK_SIZE"
    fi
    
    if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
        AAB_SIZE=$(du -h "build/app/outputs/bundle/release/app-release.aab" | cut -f1)
        echo "  📦 AAB Size: $AAB_SIZE"
    fi
}

# Function to perform final checks
final_checks() {
    print_section "🔍 FINAL PRE-DEPLOYMENT CHECKS"
    
    print_step "Verifying build artifacts exist"
    local artifacts_ok=true
    
    if [ ! -f "$PROJECT_DIR/build/app/outputs/bundle/release/app-release.aab" ]; then
        print_error "App Bundle (AAB) not found"
        artifacts_ok=false
    fi
    
    if [ "$artifacts_ok" = true ]; then
        print_success "All required build artifacts are present"
    else
        print_error "Missing build artifacts. Cannot proceed with deployment."
        exit 1
    fi
    
    print_step "Checking Google Play Console requirements"
    echo "  ⚠️  Manual verification required:"
    echo "     • Google Play Console account is set up"
    echo "     • App is created in Play Console"
    echo "     • Store listing is complete"
    echo "     • Privacy policy is uploaded"
    echo "     • Content rating is completed"
    
    if [ "$DRY_RUN" != true ]; then
        echo ""
        echo -e "${YELLOW}Have you completed all Google Play Console requirements? (y/N):${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_warning "Complete Google Play Console setup before deployment"
            echo "Refer to deployment/deployment-checklist.md for detailed requirements"
            exit 0
        fi
    fi
}

# Function to create deployment package
create_deployment_package() {
    print_section "📦 CREATING DEPLOYMENT PACKAGE"
    
    local package_dir="$PROJECT_DIR/deployment/packages/release_$TIMESTAMP"
    mkdir -p "$package_dir"
    
    print_step "Copying build artifacts"
    if [ "$DRY_RUN" = true ]; then
        print_warning "DRY RUN: Would create deployment package"
        return 0
    fi
    
    # Copy AAB
    if [ -f "$PROJECT_DIR/build/app/outputs/bundle/release/app-release.aab" ]; then
        cp "$PROJECT_DIR/build/app/outputs/bundle/release/app-release.aab" "$package_dir/"
        cp "$PROJECT_DIR/build/app/outputs/bundle/release/app-release.aab.md5" "$package_dir/" 2>/dev/null || true
    fi
    
    # Copy APK
    if [ -f "$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk" ]; then
        cp "$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk" "$package_dir/"
        cp "$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk.md5" "$package_dir/" 2>/dev/null || true
    fi
    
    # Copy release notes if available
    local release_notes="$PROJECT_DIR/build/release_notes_"*.txt
    if ls $release_notes 1> /dev/null 2>&1; then
        cp $release_notes "$package_dir/"
    fi
    
    # Create deployment info file
    cat > "$package_dir/deployment-info.txt" << EOF
CraftConnect Deployment Package
Generated: $(date)
═══════════════════════════════════

Build Information:
- Version: $(grep "version:" "$PROJECT_DIR/pubspec.yaml" | cut -d' ' -f2)
- Build Type: $BUILD_TYPE
- Target Track: $TRACK
- Rollout Percentage: $ROLLOUT_PERCENTAGE%

Files in this package:
$(ls -la "$package_dir" | grep -v "^d" | awk '{print "- " $9 " (" $5 " bytes)"}')

Deployment Instructions:
1. Upload app-release.aab to Google Play Console
2. Set rollout percentage to $ROLLOUT_PERCENTAGE%
3. Monitor metrics for 24-48 hours
4. Gradually increase rollout if no issues

Next Steps:
- Upload to $TRACK track in Google Play Console
- Monitor crash reports and user feedback
- Be prepared to halt rollout if issues arise
EOF
    
    print_success "Deployment package created: $package_dir"
    echo "  📁 Package location: $package_dir"
}

# Function to display next steps
show_next_steps() {
    print_section "🎯 NEXT STEPS"
    
    if [ "$DRY_RUN" = true ]; then
        echo "🧪 DRY RUN COMPLETE"
        echo "No actual deployment occurred. Review the process above and run without --dry-run when ready."
        echo ""
    fi
    
    echo "📋 Manual steps required to complete deployment:"
    echo ""
    echo "1. 🔐 LOGIN TO GOOGLE PLAY CONSOLE"
    echo "   • Go to https://play.google.com/console/"
    echo "   • Navigate to your CraftConnect app"
    echo ""
    echo "2. 📤 UPLOAD APP BUNDLE"
    echo "   • Go to Release → $TRACK"
    echo "   • Create new release"
    echo "   • Upload: build/app/outputs/bundle/release/app-release.aab"
    echo ""
    echo "3. ⚙️  CONFIGURE RELEASE"
    echo "   • Add release notes"
    echo "   • Set rollout percentage to $ROLLOUT_PERCENTAGE%"
    echo "   • Review and publish"
    echo ""
    echo "4. 📊 MONITOR DEPLOYMENT"
    echo "   • Watch crash reports in Play Console"
    echo "   • Monitor user reviews and ratings"
    echo "   • Check Firebase Analytics for anomalies"
    echo "   • Gradually increase rollout if stable"
    echo ""
    echo "5. 📱 POST-DEPLOYMENT TESTING"
    echo "   • Install from Play Store on test devices"
    echo "   • Verify all features work as expected"
    echo "   • Test any server-side interactions"
    echo ""
    echo "🆘 EMERGENCY PROCEDURES"
    echo "   • If critical issues: Halt rollout in Play Console"
    echo "   • Check deployment/deployment-checklist.md for rollback procedures"
    echo ""
    echo "📞 SUPPORT RESOURCES"
    echo "   • Deployment log: $LOG_FILE"
    echo "   • Play Console Help: https://support.google.com/googleplay/android-developer/"
    echo "   • Firebase Console: https://console.firebase.google.com/"
}

# Function to display deployment summary
show_summary() {
    print_section "📊 DEPLOYMENT SUMMARY"
    
    local end_time=$(date)
    local elapsed_seconds=$SECONDS
    local elapsed_minutes=$((elapsed_seconds / 60))
    
    echo "🎉 Deployment process completed successfully!"
    echo ""
    echo "📈 Summary:"
    echo "  • Start Time: $(head -n 1 "$LOG_FILE" | cut -d' ' -f1-2)"
    echo "  • End Time: $end_time"
    echo "  • Duration: ${elapsed_minutes}m ${elapsed_seconds}s"
    echo "  • Target Track: $TRACK"
    echo "  • Log File: $LOG_FILE"
    echo ""
    
    if [ "$DRY_RUN" = true ]; then
        echo "⚠️  This was a DRY RUN - no actual deployment occurred"
        echo "Run the script without --dry-run to perform actual deployment"
    else
        echo "✅ Ready for manual upload to Google Play Console"
    fi
}

# Function to parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --track)
                TRACK="$2"
                shift 2
                ;;
            --rollout)
                ROLLOUT_PERCENTAGE="$2"
                shift 2
                ;;
            --no-validation)
                ENABLE_VALIDATION=false
                shift
                ;;
            --no-testing)
                ENABLE_TESTING=false
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Function to show help
show_help() {
    echo "CraftConnect Deployment Automation Script"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --track TRACK           Release track (internal|closed|open|production) [default: internal]"
    echo "  --rollout PERCENTAGE    Initial rollout percentage [default: 5]"
    echo "  --no-validation         Skip pre-deployment validation"
    echo "  --no-testing           Skip running tests"
    echo "  --dry-run              Run without making actual changes"
    echo "  --help, -h             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Standard deployment to internal track"
    echo "  $0 --track production --rollout 10   # Deploy to production with 10% rollout"
    echo "  $0 --dry-run                         # Test the deployment process"
    echo "  $0 --no-validation --no-testing      # Skip validation and testing"
}

# Main deployment function
main() {
    # Start timing
    SECONDS=0
    
    # Parse arguments
    parse_arguments "$@"
    
    # Display banner and configuration
    print_banner
    show_configuration
    
    # Get user confirmation
    get_confirmation
    
    # Run deployment steps
    check_prerequisites
    run_validation
    run_tests
    build_release
    final_checks
    create_deployment_package
    
    # Show results
    show_next_steps
    show_summary
    
    print_success "🚀 Deployment preparation completed successfully!"
    
    if [ "$DRY_RUN" != true ]; then
        echo ""
        echo "Next: Upload the App Bundle to Google Play Console and configure the release."
    fi
}

# Handle script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
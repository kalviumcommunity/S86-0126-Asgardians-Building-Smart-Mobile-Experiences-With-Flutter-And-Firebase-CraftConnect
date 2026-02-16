@echo off
setlocal enabledelayedexpansion

REM 🚀 CraftConnect - Automated Release Build Script for Windows
REM This script automates the process of building production-ready releases

title CraftConnect Release Builder

REM Configuration
set "APP_NAME=CraftConnect"
set "PACKAGE_NAME=com.example.craftconnect"
set "BUILD_DIR=build"
set "KEYSTORE_DIR=release\keystore"
set "KEYSTORE_NAME=app-release-key.jks"

REM Colors (using PowerShell for colored output)
set "INFO_COLOR=Cyan"
set "SUCCESS_COLOR=Green" 
set "WARNING_COLOR=Yellow"
set "ERROR_COLOR=Red"

REM Print colored output functions
:print_status
echo [INFO] %~1
exit /b

:print_success
powershell -command "Write-Host '[SUCCESS] %~1' -ForegroundColor Green"
exit /b

:print_warning
powershell -command "Write-Host '[WARNING] %~1' -ForegroundColor Yellow"
exit /b

:print_error
powershell -command "Write-Host '[ERROR] %~1' -ForegroundColor Red"
exit /b

REM Function to check prerequisites
:check_prerequisites
call :print_status "Checking prerequisites..."

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    call :print_error "Flutter is not installed or not in PATH"
    pause
    exit /b 1
)

REM Check if we're in a Flutter project
if not exist "pubspec.yaml" (
    call :print_error "Not in a Flutter project directory"
    pause
    exit /b 1
)

REM Check if key.properties exists
if not exist "android\key.properties" (
    call :print_warning "key.properties not found. Release will use debug signing."
)

call :print_success "Prerequisites check passed"
exit /b

REM Function to clean project
:clean_project
call :print_status "Cleaning project..."
flutter clean
if errorlevel 1 (
    call :print_error "Flutter clean failed"
    pause
    exit /b 1
)

flutter pub get
if errorlevel 1 (
    call :print_error "Flutter pub get failed"
    pause
    exit /b 1
)

call :print_success "Project cleaned and dependencies fetched"
exit /b

REM Function to run tests
:run_tests
call :print_status "Running tests..."
flutter test
if errorlevel 1 (
    call :print_error "Tests failed"
    pause
    exit /b 1
)
call :print_success "All tests passed"
exit /b

REM Function to analyze code
:analyze_code
call :print_status "Analyzing code..."
flutter analyze
if errorlevel 1 (
    call :print_error "Code analysis failed"
    pause
    exit /b 1
)
call :print_success "Code analysis completed"
exit /b

REM Function to build APK
:build_apk
call :print_status "Building release APK..."
flutter build apk --release --build-name=%BUILD_NAME% --build-number=%BUILD_NUMBER%

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    call :print_success "APK built successfully"
    echo APK location: build\app\outputs\flutter-apk\app-release.apk
) else (
    call :print_error "APK build failed"
    pause
    exit /b 1
)
exit /b

REM Function to build App Bundle
:build_appbundle
call :print_status "Building release App Bundle (AAB)..."
flutter build appbundle --release --build-name=%BUILD_NAME% --build-number=%BUILD_NUMBER%

if exist "build\app\outputs\bundle\release\app-release.aab" (
    call :print_success "App Bundle built successfully"
    echo AAB location: build\app\outputs\bundle\release\app-release.aab
) else (
    call :print_error "App Bundle build failed"
    pause
    exit /b 1
)
exit /b

REM Function to verify build
:verify_build
call :print_status "Verifying build..."

REM Check APK size
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    for %%A in ("build\app\outputs\flutter-apk\app-release.apk") do (
        set "APK_SIZE=%%~zA"
        set /A "APK_SIZE_MB=!APK_SIZE!/1024/1024"
        call :print_status "APK size: !APK_SIZE_MB! MB"
    )
)

REM Check AAB size
if exist "build\app\outputs\bundle\release\app-release.aab" (
    for %%A in ("build\app\outputs\bundle\release\app-release.aab") do (
        set "AAB_SIZE=%%~zA"
        set /A "AAB_SIZE_MB=!AAB_SIZE!/1024/1024"
        call :print_status "AAB size: !AAB_SIZE_MB! MB"
    )
)

call :print_success "Build verification completed"
exit /b

REM Function to generate checksums
:generate_checksums
call :print_status "Generating checksums..."

REM Generate MD5 for APK
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    powershell -command "Get-FileHash -Algorithm MD5 'build\app\outputs\flutter-apk\app-release.apk' | Select-Object Hash | Out-File 'build\app\outputs\flutter-apk\app-release.apk.md5' -Encoding ASCII"
)

REM Generate MD5 for AAB
if exist "build\app\outputs\bundle\release\app-release.aab" (
    powershell -command "Get-FileHash -Algorithm MD5 'build\app\outputs\bundle\release\app-release.aab' | Select-Object Hash | Out-File 'build\app\outputs\bundle\release\app-release.aab.md5' -Encoding ASCII"
)

call :print_success "Checksums generated"
exit /b

REM Function to create release notes
:create_release_notes
call :print_status "Creating release notes..."

set "RELEASE_NOTES_FILE=build\release_notes_v%BUILD_NAME%.txt"

REM Get current date and time
for /f "tokens=1-4 delims=/ " %%a in ("%date%") do (
    set "BUILD_DATE=%%c-%%a-%%b"
)
for /f "tokens=1-3 delims=: " %%a in ("%time%") do (
    set "BUILD_TIME=%%a:%%b:%%c"
)

REM Create release notes
(
echo CraftConnect Release v%BUILD_NAME%
echo Build Number: %BUILD_NUMBER%
echo Build Date: %BUILD_DATE% %BUILD_TIME%
echo.
echo Changes in this version:
echo - Enhanced user interface with improved theming
echo - Better error handling and loading states
echo - Improved performance and stability
echo - Bug fixes and performance improvements
echo.
echo Technical Details:
flutter --version | findstr "Flutter" > temp_flutter_version.txt
set /p FLUTTER_VERSION=<temp_flutter_version.txt
del temp_flutter_version.txt
echo - Flutter Version: !FLUTTER_VERSION!
echo - Build Type: Release
echo - Package Name: %PACKAGE_NAME%
echo - Target SDK: 34
echo - Min SDK: 21
echo.
echo Files:
echo - APK: build\app\outputs\flutter-apk\app-release.apk
echo - AAB: build\app\outputs\bundle\release\app-release.aab
echo.
echo Build completed successfully!
) > "%RELEASE_NOTES_FILE%"

call :print_success "Release notes created: %RELEASE_NOTES_FILE%"
exit /b

REM Function to display build summary
:display_summary
echo.
echo ========================================
echo 🚀 BUILD SUMMARY
echo ========================================
echo App Name: %APP_NAME%
echo Package: %PACKAGE_NAME%
echo Version: %BUILD_NAME% (%BUILD_NUMBER%)
echo Build Date: %date% %time%
echo.
echo Output Files:
if exist "build\app\outputs\flutter-apk\app-release.apk" echo ✅ APK: build\app\outputs\flutter-apk\app-release.apk
if exist "build\app\outputs\bundle\release\app-release.aab" echo ✅ AAB: build\app\outputs\bundle\release\app-release.aab
echo.
echo Next Steps:
echo 1. Test the APK on a physical device
echo 2. Upload the AAB to Google Play Console
echo 3. Set up internal testing before production
echo ========================================
exit /b

REM Function to extract version from pubspec.yaml
:get_version_info
for /f "tokens=2 delims=: " %%a in ('findstr "version:" pubspec.yaml') do (
    set "VERSION_LINE=%%a"
)

REM Extract build name and number
for /f "tokens=1,2 delims=+" %%a in ("!VERSION_LINE!") do (
    set "BUILD_NAME=%%a"
    set "BUILD_NUMBER=%%b"
)

REM Trim whitespace
set "BUILD_NAME=!BUILD_NAME: =!"
set "BUILD_NUMBER=!BUILD_NUMBER: =!"

if "!BUILD_NAME!"=="" (
    call :print_error "Could not extract version information from pubspec.yaml"
    pause
    exit /b 1
)

if "!BUILD_NUMBER!"=="" (
    set "BUILD_NUMBER=1"
    call :print_warning "Build number not found, using default: 1"
)

exit /b

REM Main build function
:main
echo 🚀 Starting %APP_NAME% Release Build Process
echo.

REM Get version info
call :get_version_info

call :print_status "Building version !BUILD_NAME! (!BUILD_NUMBER!)"

REM Run build steps
call :check_prerequisites
if errorlevel 1 exit /b 1

call :clean_project
if errorlevel 1 exit /b 1

REM Optional: Uncomment to run tests and analysis
REM call :run_tests
REM if errorlevel 1 exit /b 1
REM call :analyze_code
REM if errorlevel 1 exit /b 1

call :build_apk
if errorlevel 1 exit /b 1

call :build_appbundle
if errorlevel 1 exit /b 1

call :verify_build
call :generate_checksums
call :create_release_notes
call :display_summary

call :print_success "🎉 Release build completed successfully!"
echo.
pause
exit /b

REM Handle script arguments
if "%1"=="apk" (
    call :print_status "Building APK only..."
    call :check_prerequisites
    call :clean_project
    call :get_version_info
    call :build_apk
    pause
    exit /b
)

if "%1"=="aab" (
    call :print_status "Building App Bundle only..."
    call :check_prerequisites
    call :clean_project
    call :get_version_info
    call :build_appbundle
    pause
    exit /b
)

if "%1"=="clean" (
    call :print_status "Cleaning build artifacts..."
    flutter clean
    if exist build rmdir /s /q build
    call :print_success "Clean completed"
    pause
    exit /b
)

if "%1"=="help" goto :help
if "%1"=="-h" goto :help
if "%1"=="--help" goto :help

if not "%1"=="" (
    echo Unknown command: %1
    echo.
    goto :help
)

REM Default: run main build
call :main
exit /b

:help
echo CraftConnect Build Script for Windows
echo.
echo Usage: build_release.bat [command]
echo.
echo Commands:
echo   (no args)  Build both APK and AAB
echo   apk        Build APK only
echo   aab        Build App Bundle only
echo   clean      Clean build artifacts
echo   help       Show this help message
echo.
pause
exit /b
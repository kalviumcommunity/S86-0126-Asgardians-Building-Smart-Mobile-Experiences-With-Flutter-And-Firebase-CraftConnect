@echo off
echo ========================================
echo NUCLEAR CLEAN - COMPLETE BUILD RESET
echo ========================================
echo.

echo [1/6] Killing ALL processes...
taskkill /F /IM dart.exe /T 2>nul
taskkill /F /IM java.exe /T 2>nul
taskkill /F /IM gradle.exe /T 2>nul
taskkill /F /IM flutter.exe /T 2>nul
taskkill /F /IM adb.exe /T 2>nul
timeout /t 2 /nobreak >nul
echo Done!
echo.

echo [2/6] Deleting build directories...
if exist build rmdir /s /q build
if exist android\build rmdir /s /q android\build
if exist android\.gradle rmdir /s /q android\.gradle
if exist .dart_tool rmdir /s /q .dart_tool
echo Done!
echo.

echo [3/6] Deleting Kotlin caches...
if exist build\share_plus\kotlin rmdir /s /q build\share_plus\kotlin
if exist build\firebase_analytics\kotlin rmdir /s /q build\firebase_analytics\kotlin
if exist build\shared_preferences_android\kotlin rmdir /s /q build\shared_preferences_android\kotlin
if exist build\firebase_auth\kotlin rmdir /s /q build\firebase_auth\kotlin
if exist build\firebase_core\kotlin rmdir /s /q build\firebase_core\kotlin
if exist build\firebase_messaging\kotlin rmdir /s /q build\firebase_messaging\kotlin
if exist build\firebase_storage\kotlin rmdir /s /q build\firebase_storage\kotlin
if exist build\cloud_firestore\kotlin rmdir /s /q build\cloud_firestore\kotlin
echo Done!
echo.

echo [4/6] Cleaning Flutter...
call flutter clean
echo Done!
echo.

echo [5/6] Stopping Gradle daemon...
cd android
call gradlew --stop
cd ..
echo Done!
echo.

echo [6/6] Getting dependencies...
call flutter pub get
echo Done!
echo.

echo ========================================
echo NUCLEAR CLEAN COMPLETE!
echo Now try: flutter run
echo ========================================
pause

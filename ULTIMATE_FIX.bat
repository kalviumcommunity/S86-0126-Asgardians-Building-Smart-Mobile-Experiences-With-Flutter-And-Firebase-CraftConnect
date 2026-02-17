@echo off
echo ========================================
echo ULTIMATE FIX FOR KOTLIN BUILD ERRORS
echo ========================================
echo.

echo [1/7] Killing ALL processes (including Kotlin daemon)...
taskkill /F /IM dart.exe /T 2>nul
taskkill /F /IM java.exe /T 2>nul
taskkill /F /IM gradle.exe /T 2>nul
taskkill /F /IM kotlin-compiler.jar /T 2>nul
timeout /t 3 /nobreak >nul
echo Done!
echo.

echo [2/7] Stopping Gradle daemon explicitly...
cd android
call gradlew --stop 2>nul
cd ..
timeout /t 2 /nobreak >nul
echo Done!
echo.

echo [3/7] Deleting ALL build artifacts...
if exist build rmdir /s /q build
if exist android\build rmdir /s /q android\build
if exist android\.gradle rmdir /s /q android\.gradle
if exist .dart_tool rmdir /s /q .dart_tool
echo Done!
echo.

echo [4/7] Running Flutter clean...
call flutter clean
echo Done!
echo.

echo [5/7] Refreshing pub cache...
call flutter pub cache repair
echo Done!
echo.

echo [6/7] Getting fresh dependencies...
call flutter pub get
echo Done!
echo.

echo [7/7] Starting build with clean Kotlin state...
echo.
echo ========================================
echo RUNNING: flutter run
echo ========================================
echo.
call flutter run

pause

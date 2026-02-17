@echo off
echo ========================================
echo CraftConnect - Clean and Build Script
echo ========================================
echo.

echo [Step 1/8] Killing Java/Gradle processes...
taskkill /F /IM java.exe 2>nul
taskkill /F /IM javaw.exe 2>nul
echo Waiting for file handles to release...
timeout /t 3 /nobreak > nul
echo Done!
echo.

echo [Step 2/8] Stopping Gradle Daemon...
cd android
call gradlew --stop 2>nul
cd ..
timeout /t 2 /nobreak > nul
echo Done!
echo.

echo [Step 3/8] Cleaning Flutter...
call flutter clean
echo Done!
echo.

echo [Step 4/8] Removing build directories...
if exist "build" (
    rmdir /s /q "build" 2>nul
    echo Removed build directory
)
if exist ".dart_tool" (
    rmdir /s /q ".dart_tool" 2>nul
    echo Removed .dart_tool directory
)
if exist "android\.gradle" (
    rmdir /s /q "android\.gradle" 2>nul
    echo Removed android\.gradle directory
)
if exist "android\build" (
    rmdir /s /q "android\build" 2>nul
    echo Removed android\build directory
)
if exist "android\app\build" (
    rmdir /s /q "android\app\build" 2>nul
    echo Removed android\app\build directory
)
echo Done!
echo.

echo [Step 5/8] Killing Java processes again...
taskkill /F /IM java.exe 2>nul
taskkill /F /IM javaw.exe 2>nul
timeout /t 3 /nobreak > nul
echo Done!
echo.

echo [Step 6/8] Cleaning Gradle cache...
if exist "%USERPROFILE%\.gradle\caches" (
    rmdir /s /q "%USERPROFILE%\.gradle\caches" 2>nul
    echo Cleared Gradle caches
)
if exist "%USERPROFILE%\.gradle\daemon" (
    rmdir /s /q "%USERPROFILE%\.gradle\daemon" 2>nul
    echo Cleared Gradle daemon
)
echo Done!
echo.

echo [Step 7/8] Getting Flutter dependencies...
call flutter pub get
echo Done!
echo.

echo [Step 8/8] Building and running the app...
echo This may take a few minutes...
call flutter run --no-daemon
echo.
echo ========================================
echo Build process completed!
echo ========================================

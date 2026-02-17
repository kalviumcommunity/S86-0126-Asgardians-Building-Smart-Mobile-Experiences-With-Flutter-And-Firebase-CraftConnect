@echo off
echo ========================================
echo EMERGENCY FIX - Kill Stuck Build
echo ========================================
echo.

echo [1/5] Killing Flutter and Gradle processes...
taskkill /F /IM dart.exe /T 2>nul
taskkill /F /IM flutter.exe /T 2>nul
taskkill /F /IM java.exe /T 2>nul
taskkill /F /IM javaw.exe /T 2>nul
taskkill /F /IM adb.exe /T 2>nul
echo Done!
echo.

echo [2/5] Waiting for file locks to clear...
timeout /t 5 /nobreak > nul
echo Done!
echo.

echo [3/5] Cleaning EVERYTHING...
flutter clean
rmdir /s /q build 2>nul
rmdir /s /q .dart_tool 2>nul
rmdir /s /q android\build 2>nul
rmdir /s /q android\.gradle 2>nul
rmdir /s /q android\app\build 2>nul
echo Done!
echo.

echo [4/5] Removing Gradle caches...
rmdir /s /q "%USERPROFILE%\.gradle\caches" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle\daemon" 2>nul
echo Done!
echo.

echo [5/5] Getting dependencies...
flutter pub get
echo Done!
echo.

echo ========================================
echo NOW RUN: flutter run -v
echo (The -v flag shows progress so you know it's working)
echo ========================================
pause

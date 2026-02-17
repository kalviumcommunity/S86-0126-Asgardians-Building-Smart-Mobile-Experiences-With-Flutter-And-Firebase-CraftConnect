@echo off
echo ========================================
echo Quick Cache Clean Script
echo ========================================
echo.

echo Killing Java/Gradle processes...
taskkill /F /IM java.exe 2>nul
taskkill /F /IM javaw.exe 2>nul
echo Waiting for file handles to release...
timeout /t 3 /nobreak > nul
echo.

echo Stopping Gradle Daemon...
cd android
call gradlew --stop 2>nul
cd ..
timeout /t 2 /nobreak > nul
echo.

echo Cleaning Flutter...
call flutter clean
echo.

echo Killing Java processes again...
taskkill /F /IM java.exe 2>nul
taskkill /F /IM javaw.exe 2>nul
timeout /t 3 /nobreak > nul
echo.

echo Removing build directories...
if exist "build" rmdir /s /q "build" 2>nul
if exist ".dart_tool" rmdir /s /q ".dart_tool" 2>nul
if exist "android\.gradle" rmdir /s /q "android\.gradle" 2>nul
if exist "android\build" rmdir /s /q "android\build" 2>nul
if exist "android\app\build" rmdir /s /q "android\app\build" 2>nul
echo.

echo Cleaning Gradle caches (this fixes Kotlin compilation errors)...
if exist "%USERPROFILE%\.gradle\caches" rmdir /s /q "%USERPROFILE%\.gradle\caches" 2>nul
if exist "%USERPROFILE%\.gradle\daemon" rmdir /s /q "%USERPROFILE%\.gradle\daemon" 2>nul
echo.

echo Getting dependencies...
call flutter pub get
echo.

echo ========================================
echo Cache clean complete!
echo Now you can run: flutter run
echo ========================================
pause

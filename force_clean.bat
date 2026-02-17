@echo off
echo ========================================
echo FORCE CLEAN - Aggressive Cache Cleanup
echo ========================================
echo.
echo This will forcefully kill all Java processes!
echo Press Ctrl+C to cancel, or
pause
echo.

echo [1/9] Killing all Java/Gradle processes...
taskkill /F /IM java.exe 2>nul
taskkill /F /IM javaw.exe 2>nul
echo Waiting for processes to release file handles...
timeout /t 3 /nobreak > nul
echo Done!
echo.

echo [2/9] Stopping Gradle Daemon (if any left)...
cd android
call gradlew --stop 2>nul
cd ..
timeout /t 2 /nobreak > nul
echo Done!
echo.

echo [3/9] Cleaning Flutter...
call flutter clean
echo Done!
echo.

echo [4/9] Removing project build directories...
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

echo [5/9] Killing Java processes again (in case Gradle restarted)...
taskkill /F /IM java.exe 2>nul
taskkill /F /IM javaw.exe 2>nul
timeout /t 3 /nobreak > nul
echo Done!
echo.

echo [6/9] Cleaning Gradle caches (this may show some errors - ignore them)...
if exist "%USERPROFILE%\.gradle\caches" (
    echo Removing Gradle caches...
    rmdir /s /q "%USERPROFILE%\.gradle\caches" 2>nul
    echo Gradle caches cleared!
)
if exist "%USERPROFILE%\.gradle\daemon" (
    echo Removing Gradle daemon...
    rmdir /s /q "%USERPROFILE%\.gradle\daemon" 2>nul
    echo Gradle daemon cleared!
)
echo Done!
echo.

echo [7/9] Cleaning Kotlin compiler caches...
if exist "%USERPROFILE%\.kotlin" (
    rmdir /s /q "%USERPROFILE%\.kotlin" 2>nul
    echo Kotlin caches cleared!
)
echo Done!
echo.

echo [8/9] Getting fresh Flutter dependencies...
call flutter pub get
echo Done!
echo.

echo [9/9] Cleaning Android project one more time...
cd android
call gradlew clean --no-daemon
cd ..
echo Done!
echo.

echo ========================================
echo FORCE CLEAN COMPLETE!
echo ========================================
echo.
echo All caches have been cleared!
echo You can now run: flutter run
echo.
pause

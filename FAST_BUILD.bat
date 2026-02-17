@echo off
echo ========================================
echo FAST BUILD FIX
echo ========================================
echo.

echo [1/4] Killing stuck processes...
taskkill /F /IM java.exe /T 2>nul
taskkill /F /IM dart.exe /T 2>nul
timeout /t 3 /nobreak > nul
echo Done!
echo.

echo [2/4] Quick clean...
flutter clean
rmdir /s /q build 2>nul
rmdir /s /q android\build 2>nul
echo Done!
echo.

echo [3/4] Getting dependencies...
flutter pub get
echo Done!
echo.

echo [4/4] Building with verbose output...
echo This should take 5-10 minutes (not 2 hours!)
echo You'll see progress in real-time...
echo.
flutter run -v --no-pub

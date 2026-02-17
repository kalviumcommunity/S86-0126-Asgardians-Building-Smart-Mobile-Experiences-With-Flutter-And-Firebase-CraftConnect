@echo off
color 0C
echo.
echo ============================================================
echo                   READ THIS CAREFULLY!
echo ============================================================
echo.
color 0E
echo The Gradle cache is LOCKED by Java processes.
echo.
echo OPTION 1 - EASIEST AND MOST RELIABLE:
echo ----------------------------------------
echo 1. RESTART YOUR COMPUTER
echo 2. After restart, run: force_clean.bat
echo 3. Then run: flutter run
echo.
echo.
echo OPTION 2 - IF YOU CANNOT RESTART:
echo ----------------------------------------
echo 1. Close this window
echo 2. Open Task Manager (Ctrl + Shift + Esc)
echo 3. Go to "Details" tab
echo 4. Find ALL "java.exe" and "javaw.exe" processes
echo 5. Right-click each one and select "End Task"
echo 6. Close Android Studio and VS Code
echo 7. Wait 10 seconds
echo 8. Run: force_clean.bat
echo 9. Then run: flutter run
echo.
echo.
color 0C
echo WHY THIS HAPPENED:
color 0F
echo Java processes are holding locks on Gradle cache files.
echo These locks prevent deletion even after "gradlew --stop".
echo A restart releases ALL file locks guaranteed.
echo.
echo.
color 0A
echo AFTER YOU FIX THIS:
color 0F
echo Your app should build and run without any errors!
echo Keep the force_clean.bat script for future cache issues.
echo.
echo.
color 0E
echo Press any key to open Task Manager...
pause > nul
taskmgr
echo.
echo After killing Java processes, run: force_clean.bat
echo.
pause

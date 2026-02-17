@echo off
echo Killing all Java processes...
taskkill /F /IM java.exe /T 2>nul
taskkill /F /IM javaw.exe /T 2>nul
echo.
echo Waiting 5 seconds for file locks to release...
timeout /t 5 /nobreak > nul
echo.
echo Deleting corrupted Gradle cache...
rmdir /s /q "%USERPROFILE%\.gradle\caches\8.14" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle\daemon" 2>nul
echo.
echo Cache cleared! Now you can run: flutter run
echo.
pause

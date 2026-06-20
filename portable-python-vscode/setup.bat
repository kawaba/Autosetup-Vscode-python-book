powershell.exe -ExecutionPolicy Bypass -Command "Unblock-File -Path '%~dp0setup.ps1'"
powershell.exe -ExecutionPolicy Bypass -File "%~dp0setup.ps1"

if errorlevel 1 exit /b 1

echo --- Script finished ---
pause

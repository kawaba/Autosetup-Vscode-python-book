powershell.exe -ExecutionPolicy Bypass -Command "Unblock-File -Path '%~dp0setup.ps1'"
powershell.exe -ExecutionPolicy Bypass -File "%~dp0setup.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo --- セットアップは中止されました ---
    pause
    exit /b %ERRORLEVEL%
)

echo --- Script finished ---
pause

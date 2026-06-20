@echo off
chcp 932 >nul
setlocal enabledelayedexpansion

rem ============================================================
rem  Path length check (Windows long path workaround)
rem ============================================================

set "SCRIPT_DIR=%~dp0"

set "S=%SCRIPT_DIR%"
set LEN=0
:count_loop
if defined S (
    set "S=!S:~1!"
    set /a LEN+=1
    goto count_loop
)

set THRESHOLD=60

echo [0/5] 実行パスを確認中...
echo   実行フォルダ: %SCRIPT_DIR%
echo   パスの文字数: %LEN% 文字
echo.

if %LEN% GTR %THRESHOLD% (
    echo   ★★★ 警告 ★★★
    echo   実行フォルダのパスが長すぎるおそれがあります。
    echo   Cドライブの直下など、短いパスで実行してください。
    echo   例: C:\py-setup
    echo   このまま進めると、Windowsの260文字制限を超えて
    echo   インストールに失敗することがあります。
    echo.
    echo   よくある原因:
    echo     ・Downloads フォルダ内で実行している
    echo     ・GitHubの「Download ZIP」でフォルダ名が二重になっている
    echo.
    set /p "ANSWER=  フォルダを移動するため中止しますか? (Y/N): "
    if /i "!ANSWER!"=="Y" (
        echo.
        echo   セットアップを中止しました。
        echo   フォルダを短いパスへ移動してから再実行してください。
        echo.
        pause
        exit /b 1
    )
    echo.
    echo   続行します。失敗する場合はフォルダを短いパスへ移動してください。
    echo.
)

rem ============================================================
rem  Run the PowerShell setup
rem ============================================================

powershell.exe -ExecutionPolicy Bypass -Command "Unblock-File -Path '%~dp0setup.ps1'"
powershell.exe -ExecutionPolicy Bypass -File "%~dp0setup.ps1"

if errorlevel 1 (
    echo --- セットアップは中止されました ---
    pause
    exit /b 1
)

echo --- Script finished ---
pause

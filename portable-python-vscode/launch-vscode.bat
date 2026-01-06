@echo off
REM ============================================================
REM Portable VS Code 起動スクリプト
REM ============================================================

REM Python環境のパスを設定
set PYTHON_PATH=%~dp0python
set PATH=%PYTHON_PATH%;%PYTHON_PATH%\Scripts;%PATH%

REM VS Code用のPythonインタプリタパスを設定（settings.jsonで参照される）
set PORTABLE_PYTHON_PATH=%PYTHON_PATH%\python.exe

REM 文字エンコーディング設定
set PYTHONIOENCODING=utf-8

REM VS Codeを起動
start "" "%~dp0vscode\Code.exe" --locale=ja --disable-workspace-trust "%~dp0workspace"
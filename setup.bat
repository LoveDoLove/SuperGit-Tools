@echo off
REM SuperGit-Tools v4 Setup Script for Windows

echo SuperGit-Tools v4 Setup
echo =======================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python 3.8+ is required but not installed
    echo Please install Python from https://www.python.org/downloads/
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('python --version') do echo ✓ Python found: %%i

REM Check if uv is installed
uv --version >nul 2>&1
if errorlevel 1 (
    echo WARNING: uv package manager not found
    echo Installing uv...
    pip install uv
    if errorlevel 1 (
        echo ERROR: Failed to install uv
        pause
        exit /b 1
    )
)

for /f "tokens=*" %%i in ('uv --version') do echo ✓ uv found: %%i

REM Install dependencies
echo.
echo Installing backend dependencies...
call uv sync
if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo ✓ Setup complete!
echo.
echo To run the GUI:
echo   powershell -NoProfile -ExecutionPolicy Bypass -File git-sync-gui-v4.ps1
echo.
echo To run the CLI:
echo   powershell -NoProfile -ExecutionPolicy Bypass -File git-sync.ps1 -ParentFolder "C:\path\to\repos"
echo.
pause

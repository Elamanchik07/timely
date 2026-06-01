@echo off
echo ======================================================
echo Timely Build Fixer
echo ======================================================
echo This script will map your project to drive T: to fix 
echo the "non-ASCII path" build error.
echo.

:: Clean up old mapping
subst T: /D >nul 2>&1

:: Create new mapping
subst T: "%CD%"

if errorlevel 1 (
    echo [ERROR] Could not map drive T:. Try running as Admin or choose another drive.
    pause
    exit /b
)

echo [SUCCESS] Project is now available at T:\
echo.
echo Running flutter...
echo.

:: Switch to drive T and run
T:
flutter run

:: Cleanup after closing (optional, but keep it for now)
:: subst T: /D

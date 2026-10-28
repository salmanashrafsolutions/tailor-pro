@echo off
echo ====================================================================
echo  TailorPro - Release AAB (Android App Bundle) Build
echo ====================================================================
echo.

set FLUTTER_BIN=D:\flutter\bin\flutter.bat
if not exist "%FLUTTER_BIN%" (
    set FLUTTER_BIN=flutter
)

echo [1/3] Running flutter analyze...
call "%FLUTTER_BIN%" analyze

echo [2/3] Running unit tests...
call "%FLUTTER_BIN%" test

echo [3/3] Building AAB bundle...
call "%FLUTTER_BIN%" build appbundle --release --obfuscate --split-debug-info=build/app/outputs/bundle-symbols

echo.
echo ====================================================================
echo  AAB Build Complete!
echo  Output: build\app\outputs\bundle\release\app-release.aab
echo ====================================================================
pause


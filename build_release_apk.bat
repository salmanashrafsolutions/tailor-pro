@echo off
echo ====================================================================
echo  TailorPro - Release APK Build Pipeline
echo ====================================================================
echo.

set FLUTTER_BIN=D:\flutter\bin\flutter.bat
if not exist "%FLUTTER_BIN%" (
    set FLUTTER_BIN=flutter
)

echo [1/3] Running flutter analyze...
call "%FLUTTER_BIN%" analyze
if errorlevel 1 (
    echo.
    echo [ERROR] Flutter analysis found issues.
    pause
    exit /b 1
)

echo.
echo [2/3] Building Split-per-ABI Release APKs (ARM32, ARM64, x86_64)...
call "%FLUTTER_BIN%" build apk --release --split-per-abi
set BUILD_SPLIT_ERR=%errorlevel%

echo.
echo [3/3] Building Universal Release APK...
call "%FLUTTER_BIN%" build apk --release
set BUILD_UNI_ERR=%errorlevel%

echo.
echo ====================================================================
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo  SUCCESS: APKs Built Successfully!
    echo.
    echo  APKs are located at:
    echo  - Universal APK: build\app\outputs\flutter-apk\app-release.apk
    echo  - ARM64 APK:    build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
    echo  - ARM32 APK:    build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk
    echo  - x86_64 APK:   build\app\outputs\flutter-apk\app-x86_64-release.apk
) else (
    echo  BUILD NOT COMPLETED: No APK files were created.
    echo.
    echo  Reason: Android SDK is not installed on this PC.
    echo  Flutter requires the Android SDK and Java to package APKs.
    echo.
    echo  To fix:
    echo  1. Download Android Studio from https://developer.android.com/studio
    echo  2. Open Android Studio and let it install the Android SDK.
    echo  3. Run this script again.
)
echo ====================================================================
pause

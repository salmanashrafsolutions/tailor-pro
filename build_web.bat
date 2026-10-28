@echo off
echo ====================================================================
echo  TailorPro (ٹیلر پرو) - Local Web / Laptop Preview Runner
echo ====================================================================
echo.

set FLUTTER_BIN=D:\flutter\bin\flutter.bat
if not exist "%FLUTTER_BIN%" (
    set FLUTTER_BIN=flutter
)

echo [1/2] Fetching dependencies...
call %FLUTTER_BIN% pub get

echo [2/2] Launching TailorPro in Chrome / Web Browser...
call %FLUTTER_BIN% run -d chrome --web-renderer canvaskit

pause


@echo off
echo ====================================================================
echo  TailorPro - Test Suite and Linter Gate
echo ====================================================================
echo.

set FLUTTER_BIN=D:\flutter\bin\flutter.bat
if not exist "%FLUTTER_BIN%" (
    set FLUTTER_BIN=flutter
)

echo [*] Running static code analysis (flutter analyze)...
call "%FLUTTER_BIN%" analyze
if errorlevel 1 (
    echo [FAIL] Code analysis found issues!
    exit /b 1
)
echo [PASS] Code analysis clean with 0 issues!

echo.
echo [*] Running automated unit test suite (flutter test)...
call "%FLUTTER_BIN%" test
if errorlevel 1 (
    echo [FAIL] Unit tests failed!
    exit /b 1
)
echo [PASS] All unit tests green!

echo.
echo ====================================================================
echo  All checks passed successfully!
echo ====================================================================


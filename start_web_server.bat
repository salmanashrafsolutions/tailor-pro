@echo off
echo ====================================================================
echo   TailorPro - Web and Laptop Preview Server
echo ====================================================================
echo.
echo Launching browser at http://localhost:8080 ...
start http://localhost:8080
echo Starting lightweight local HTTP server from build\web on port 8080...
python -m http.server 8080 --directory build\web
pause


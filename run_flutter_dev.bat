@echo off
echo.
echo ===============================================
echo   Starting Flutter App with CORS Fix
echo ===============================================
echo.

cd /d "%~dp0customer_app"

echo [1/3] Cleaning Flutter build cache...
call flutter clean >nul 2>&1

echo [2/3] Getting dependencies...
call flutter pub get

echo [3/3] Launching app with Chrome (CORS disabled for development)...
echo.
echo IMPORTANT: This launches Chrome with security disabled
echo This is ONLY for development testing!
echo.

flutter run -d chrome --web-browser-flag="--disable-web-security" --web-browser-flag="--disable-features=CrossSiteDocumentBlockingIfIsolating,CrossSiteDocumentBlockingAlways,IsolateOrigins,site-per-process" --web-browser-flag="--user-data-dir=%TEMP%\chrome-dev-indulink" --web-renderer html

pause

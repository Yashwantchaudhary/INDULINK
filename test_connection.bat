@echo off
echo ========================================
echo 🔧 Indulink Connection Test Script
echo ========================================
echo.

echo 📍 Your current IP addresses:
ipconfig | findstr /R /C:"IPv4 Address"
echo.

echo 🚀 Starting backend server...
cd backend
start cmd /k "npm start"
timeout /t 3 /nobreak > nul

echo.
echo 🔍 Testing backend connection...
curl -X GET http://localhost:5000/health
if %errorlevel% neq 0 (
    echo ❌ Localhost connection failed
) else (
    echo ✅ Localhost connection successful
)

echo.
echo 🔍 Testing network connection...
curl -X GET http://10.10.9.113:5000/health
if %errorlevel% neq 0 (
    echo ❌ Network connection failed
    echo 💡 Try these alternatives:
    echo    - 192.168.137.1
    echo    - 192.168.1.100
    echo    - Check your IP with: ipconfig
) else (
    echo ✅ Network connection successful
)

echo.
echo 📱 Update your Flutter app_config.dart with the working IP
echo 💡 Make sure both devices are on the same WiFi network
echo.
pause
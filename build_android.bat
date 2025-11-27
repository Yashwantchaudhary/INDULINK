@echo off
echo ========================================
echo 📱 Indulink Android APK Build Script
echo ========================================
echo.

echo 🔧 Step 1: Cleaning previous builds...
flutter clean
if %errorlevel% neq 0 (
    echo ❌ Clean failed
    pause
    exit /b 1
)

echo.
echo 📦 Step 2: Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Pub get failed
    pause
    exit /b 1
)

echo.
echo 🔍 Step 3: Running code analysis...
flutter analyze
if %errorlevel% neq 0 (
    echo ⚠️  Analysis found issues (continuing anyway)
)

echo.
echo 🏗️  Step 4: Building APK (Release)...
flutter build apk --release
if %errorlevel% neq 0 (
    echo ❌ APK build failed
    pause
    exit /b 1
)

echo.
echo ✅ Build completed successfully!
echo.
echo 📱 APK Location: customer_app\build\app\outputs\flutter-apk\app-release.apk
echo.
echo 🚀 Next steps:
echo 1. Transfer APK to your Android device
echo 2. Install APK (allow unknown sources if needed)
echo 3. Test the app functionality
echo.
echo 📋 Pre-installation checklist:
echo - [ ] Backend server running
echo - [ ] Same WiFi network
echo - [ ] Device storage has space
echo - [ ] Unknown sources enabled (if needed)
echo.
pause
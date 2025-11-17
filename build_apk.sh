#!/bin/bash

# Default to development build
BUILD_TYPE=${1:-development}

echo "============================================"
echo "Building Android APK ($BUILD_TYPE)"
echo "============================================"
echo ""

# Navigate to script directory
cd "$(dirname "$0")"

echo "Step 1: Cleaning previous builds..."
flutter clean
echo ""

echo "Step 2: Getting Flutter dependencies..."
flutter pub get
echo ""

echo "Step 3: Building $BUILD_TYPE APK..."

if [ "$BUILD_TYPE" = "production" ]; then
    # Production build with environment variables
    flutter build apk --release \
        --dart-define=API_BASE_URL=https://api.hostelfinder.com/api \
        --dart-define=SOCKET_BASE_URL=https://api.hostelfinder.com
else
    # Development build
    flutter build apk --release \
        --dart-define=API_BASE_URL=http://localhost:5001/api \
        --dart-define=SOCKET_BASE_URL=http://localhost:5001
fi

echo ""

if [ $? -eq 0 ]; then
    echo "============================================"
    echo "BUILD SUCCESSFUL!"
    echo "============================================"
    echo ""
    echo "APK Location: build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "To install on device:"
    echo "  flutter install"
    echo ""
    echo "To build App Bundle (for Play Store):"
    echo "  flutter build appbundle --release"
    echo ""
else
    echo "============================================"
    echo "BUILD FAILED!"
    echo "============================================"
    echo "Please check the error messages above."
fi


# 📱 Indulink App Installation Guide

## Prerequisites

### System Requirements
- [ ] **Flutter SDK**: Version 3.0 or higher
- [ ] **Android Studio**: With Android SDK API 21+
- [ ] **Java JDK**: Version 11 or higher
- [ ] **Android Device**: Physical device or emulator
- [ ] **Backend Server**: Running and accessible

### Network Requirements
- [ ] **Same WiFi Network**: Device and backend server
- [ ] **Port 5000 Open**: Backend server accessible
- [ ] **No VPN**: Disable VPN if active

## Phase 1: Pre-Build Testing

### Step 1: Start Backend Server
```bash
cd backend
npm start
```

### Step 2: Test Connection
```bash
# Run connection test
test_connection.bat

# Or test manually
curl http://10.10.9.113:5000/health
```

### Step 3: Verify Flutter Setup
```bash
# Check Flutter installation
flutter doctor

# Check connected devices
flutter devices
```

## Phase 2: Build APK

### Option A: Automated Build (Recommended)
```bash
# Run the automated build script
build_android.bat
```

### Option B: Manual Build
```bash
# Navigate to customer app
cd customer_app

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Analyze code (optional)
flutter analyze

# Build release APK
flutter build apk --release
```

### Build Output
- **APK Location**: `customer_app/build/app/outputs/flutter-apk/app-release.apk`
- **File Size**: ~15-25 MB (depending on assets)
- **Build Time**: 2-5 minutes

## Phase 3: Install on Android Device

### Step 1: Transfer APK
#### Method A: USB Cable
1. Connect Android device to PC
2. Enable USB debugging in Developer Options
3. Copy APK to device storage

#### Method B: Cloud Storage
1. Upload APK to Google Drive/Dropbox
2. Download on Android device

#### Method C: Direct Install (if device connected)
```bash
# Install directly if device is connected
flutter install --release
```

### Step 2: Enable Unknown Sources
1. Go to **Settings** → **Apps** → **Special access**
2. Tap **Install unknown apps**
3. Select your browser/file manager
4. Toggle **Allow from this source**

### Step 3: Install APK
1. Open file manager
2. Navigate to APK location
3. Tap the APK file
4. Tap **Install**
5. Wait for installation to complete

### Step 4: Launch App
1. Find **Indulink** app icon on home screen
2. Tap to launch
3. Grant requested permissions if prompted

## Phase 4: Post-Installation Testing

### Initial Setup
1. **Splash Screen**: Should display briefly
2. **Role Selection**: Choose Customer or Supplier
3. **Authentication**: Login or register

### Core Functionality Tests
- [ ] **Login/Signup**: Works with backend
- [ ] **Dashboard**: Loads real data
- [ ] **Navigation**: All screens accessible
- [ ] **Settings**: Language and theme switching

### Network Tests
- [ ] **API Calls**: All endpoints working
- [ ] **Image Loading**: Product images display
- [ ] **Real-time Updates**: Data refreshes properly

## Troubleshooting

### Build Issues

#### Flutter Clean Issues
```bash
# Force clean
flutter clean --force
rm -rf customer_app/build/
```

#### Dependency Issues
```bash
# Clear pub cache
flutter pub cache clean
flutter pub get
```

#### Android Build Issues
```bash
# Check Android licenses
flutter doctor --android-licenses

# Update Gradle
cd customer_app/android
./gradlew wrapper --gradle-version=7.6.1
```

### Installation Issues

#### APK Won't Install
- [ ] **Storage Space**: Ensure 100MB+ free space
- [ ] **Unknown Sources**: Enable in security settings
- [ ] **Corrupted APK**: Rebuild APK
- [ ] **Device Compatibility**: Check minimum Android version

#### App Won't Launch
- [ ] **Permissions**: Grant all requested permissions
- [ ] **Battery Optimization**: Exclude from battery optimization
- [ ] **Background Apps**: Close other apps
- [ ] **Restart Device**: Cold restart if needed

### Runtime Issues

#### Network Connection
- [ ] **Backend Running**: Verify server is accessible
- [ ] **IP Address**: Check `app_config.dart` has correct IP
- [ ] **Firewall**: Allow port 5000
- [ ] **WiFi Network**: Same network for device and server

#### Authentication Issues
- [ ] **Firebase Config**: Check `google-services.json`
- [ ] **Backend Auth**: Verify auth endpoints working
- [ ] **Token Storage**: Check shared preferences

#### Performance Issues
- [ ] **Memory**: Monitor device memory usage
- [ ] **Network**: Test on different networks
- [ ] **Cache**: Clear app cache and data

## Performance Optimization

### APK Size Reduction
```bash
# Build with size analysis
flutter build apk --release --analyze-size

# Enable split APKs for different architectures
flutter build apk --release --split-per-abi
```

### Runtime Performance
- [ ] **Enable ProGuard**: Reduces APK size
- [ ] **Tree Shaking**: Removes unused code
- [ ] **Image Optimization**: Compress images
- [ ] **Lazy Loading**: Implement pagination

## Deployment Checklist

### Pre-Deployment
- [ ] All tests passing
- [ ] APK built successfully
- [ ] Backend deployed
- [ ] Database configured
- [ ] CDN set up for assets

### Post-Deployment
- [ ] App installs without issues
- [ ] All features working
- [ ] Performance acceptable
- [ ] Crash reporting set up
- [ ] User feedback collection

## Support

### Common Issues & Solutions

#### Issue: "App not installed"
**Solution**: Enable "Unknown sources" in Android settings

#### Issue: "Network request failed"
**Solution**: Check IP address in `app_config.dart` and backend connectivity

#### Issue: "White screen on launch"
**Solution**: Check device logs with `flutter logs`

#### Issue: "Authentication failed"
**Solution**: Verify Firebase configuration and backend auth endpoints

### Getting Help
1. Check the testing checklist (`TESTING_CHECKLIST.md`)
2. Run connection tests (`test_connection.bat`)
3. Check Flutter doctor (`flutter doctor`)
4. Review build logs for errors
5. Test on emulator first before physical device

## Success Criteria

### Installation Success
- [ ] APK installs without errors
- [ ] App launches successfully
- [ ] Login/signup works
- [ ] Dashboard loads data
- [ ] All major features accessible

### Performance Success
- [ ] App launches in < 3 seconds
- [ ] Navigation is smooth
- [ ] No crashes during normal usage
- [ ] Memory usage < 200MB
- [ ] Battery drain acceptable

### Functionality Success
- [ ] All API calls work
- [ ] Real-time data updates
- [ ] Offline functionality works
- [ ] Push notifications received
- [ ] File uploads successful
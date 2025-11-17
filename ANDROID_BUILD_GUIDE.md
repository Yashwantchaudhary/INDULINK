# Android APK Build Guide - Android v2 Embedding

This guide explains how to build an Android APK for the Hostel Finder app using Android v2 embedding.

## ✅ Android v2 Embedding Configuration

The app is already configured for **Android v2 embedding**:

1. **MainActivity.kt** - Extends `FlutterActivity` from `io.flutter.embedding.android.FlutterActivity`
2. **AndroidManifest.xml** - Contains `io.flutter.embedding.android.NormalTheme` meta-data
3. **styles.xml** - Includes `NormalTheme` style for v2 embedding

## 🚀 Building the APK

### Option 1: Using Build Script (Recommended)

#### Windows:
```bash
cd hostel_finder_app
build_apk.bat
```

#### Linux/Mac:
```bash
cd hostel_finder_app
chmod +x build_apk.sh
./build_apk.sh
```

### Option 2: Using Flutter CLI

#### Build Release APK:
```bash
cd hostel_finder_app
flutter clean
flutter pub get
flutter build apk --release
```

#### Build Debug APK:
```bash
flutter build apk --debug
```

#### Build App Bundle (for Play Store):
```bash
flutter build appbundle --release
```

## 📱 APK Output Location

After building, the APK will be located at:
```
hostel_finder_app/build/app/outputs/flutter-apk/app-release.apk
```

## 🔧 Configuration Details

### Build Configuration (build.gradle.kts)

- **Compile SDK**: 34
- **Min SDK**: 21 (Android 5.0+)
- **Target SDK**: 34
- **Package Name**: com.hostelfinder.app
- **Version**: 1.0.0 (versionCode: 1)

### Signing Configuration

Currently, the release build uses **debug signing** for testing purposes. 

For production builds, you need to:
1. Create a keystore file
2. Update `android/app/build.gradle.kts` with your keystore details
3. Enable minification and resource shrinking

### Creating a Keystore for Production

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then update `build.gradle.kts`:
```kotlin
signingConfigs {
    create("release") {
        keyAlias = "upload"
        keyPassword = "your_key_password"
        storeFile = file("path/to/upload-keystore.jks")
        storePassword = "your_store_password"
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
    }
}
```

## 📋 Prerequisites

1. **Flutter SDK** installed and in PATH
2. **Android Studio** with Android SDK installed
3. **Java JDK** (version 8 or higher)
4. **Android SDK** (API level 34)
5. **Gradle** (included with Flutter)

## 🧪 Testing the APK

### Install on Connected Device:
```bash
flutter install
```

### Install APK Manually:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 🔍 Verifying Android v2 Embedding

The app uses Android v2 embedding, which is confirmed by:

1. **MainActivity** extends `FlutterActivity` (not `FlutterActivity` from v1)
2. **AndroidManifest.xml** contains:
   ```xml
   <meta-data
       android:name="io.flutter.embedding.android.NormalTheme"
       android:resource="@style/NormalTheme" />
   ```
3. **Activity** uses `android:exported="true"` (required for v2)

## 🐛 Troubleshooting

### Build Errors

1. **Gradle sync failed**: 
   - Run `flutter clean` and `flutter pub get`
   - Check `local.properties` has correct `flutter.sdk` path

2. **Missing dependencies**:
   - Run `flutter pub get`
   - Check `pubspec.yaml` for all dependencies

3. **Signing errors**:
   - Current setup uses debug signing for testing
   - For production, configure release signing (see above)

4. **ProGuard errors**:
   - Minification is currently disabled
   - Enable only after testing without minification

### Common Issues

- **"SDK location not found"**: Set `ANDROID_HOME` environment variable
- **"Gradle build failed"**: Update Gradle wrapper or Android SDK
- **"Package not found"**: Run `flutter pub get`

## 📦 Dependencies

Key Android dependencies:
- Google Sign-In (play-services-auth:20.7.0)
- Firebase (firebase-bom:32.7.0)
- Google Services (google-services:4.4.2)

## 🔗 Resources

- [Flutter Android Deployment](https://docs.flutter.dev/deployment/android)
- [Android v2 Embedding](https://docs.flutter.dev/release/breaking-changes/upgrade-kitkat-embedding)
- [Signing Your App](https://docs.flutter.dev/deployment/android#signing-the-app)


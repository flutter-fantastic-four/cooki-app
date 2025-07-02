# Android Setup Guide for Cooki App

## Overview
Your Cooki Flutter app now has full Android support! Here's what has been configured and what you need to know.

## ✅ What's Already Configured

### 1. **Build Configuration**
- **Gradle setup**: Updated to use latest Android Gradle Plugin
- **Target SDK**: Set to support modern Android versions
- **Min SDK**: Set to API 23 (Android 6.0) for broad compatibility
- **Java version**: Updated to Java 11 for better performance

### 2. **Permissions**
The following permissions have been added to `android/app/src/main/AndroidManifest.xml`:
- `INTERNET` - For network requests
- `READ_EXTERNAL_STORAGE` - For accessing gallery (API ≤ 32)
- `WRITE_EXTERNAL_STORAGE` - For saving images (API ≤ 32) 
- `READ_MEDIA_IMAGES` - For accessing gallery (API ≥ 33)
- `CAMERA` - For taking photos
- `ACCESS_NETWORK_STATE` - For checking network connectivity

### 3. **Firebase Integration**
- Google Services plugin configured
- Firebase Crashlytics enabled
- Proper Firebase configuration for Android

### 4. **Social Login Support**
- **Kakao Login**: Custom scheme configured
- **Google Sign-In**: OAuth integration ready
- **Apple Sign-In**: Cross-platform support

### 5. **Proguard Configuration**
- Release builds now use code minification
- Custom proguard rules for Flutter plugins
- Firebase and social login libraries protected

## 🔧 Required Setup Steps

### 1. **API Keys Configuration**
Update the `android/key.properties` file with your actual API keys:

```properties
# Replace with your actual Kakao API key
KAKAO_API_KEY=your_actual_kakao_api_key_here
```

### 2. **Firebase Configuration**
1. Download `google-services.json` from your Firebase Console
2. Place it in `android/app/` directory
3. Ensure your package name matches: `com.fantasticfour.cooki`

### 3. **App Signing (For Release)**
For production releases, create a proper signing configuration:

1. Generate a keystore:
```bash
keytool -genkey -v -keystore ~/cooki-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cooki
```

2. Update `android/key.properties`:
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=cooki
storeFile=/path/to/cooki-keystore.jks
KAKAO_API_KEY=your_actual_kakao_api_key_here
```

3. Update `android/app/build.gradle.kts` signing configuration (replace the debug signing).

## 📱 Building for Android

### Debug Build
```bash
flutter run
# or
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
# or for app bundle (recommended for Play Store)
flutter build appbundle --release
```

### Install on Device
```bash
flutter install
```

## 🎯 App Features on Android

### Supported Features
- ✅ Recipe generation with AI
- ✅ Image picker (camera/gallery)
- ✅ Social login (Kakao, Google, Apple)
- ✅ Firebase authentication
- ✅ Cloud Firestore database
- ✅ Image sharing
- ✅ Localization (Korean/English)
- ✅ Push notifications (via Firebase)

### Android-Specific Optimizations
- Adaptive icons configured
- Material 3 theming
- Network security config
- Backup rules configured
- Optimized for different screen sizes

## 🐛 Troubleshooting

### Common Issues

1. **Build fails with signing errors**
   - Ensure `key.properties` exists with valid keys
   - Check that your keystore path is correct

2. **Kakao login not working**
   - Verify KAKAO_API_KEY in `key.properties`
   - Check Firebase Remote Config has the correct key
   - Ensure package name matches in Kakao Developer Console

3. **Firebase connection issues**
   - Confirm `google-services.json` is in the correct location
   - Verify SHA-1 fingerprints in Firebase Console
   - Check internet permissions are granted

4. **Image picker crashes**
   - Ensure camera and storage permissions are granted
   - Test on different Android versions

### Useful Commands
```bash
# Check connected devices
flutter devices

# Run with verbose logging
flutter run -v

# Check Flutter doctor
flutter doctor

# Clear build cache
flutter clean

# Check Android SDK
flutter config --android-sdk /path/to/android/sdk
```

## 📦 Generated APK Location
After building, your APK will be located at:
- Debug: `build/app/outputs/flutter-apk/app-debug.apk`
- Release: `build/app/outputs/flutter-apk/app-release.apk`

## 🚀 Play Store Deployment

When ready for the Play Store:

1. Use app bundle format: `flutter build appbundle --release`
2. Upload `build/app/outputs/bundle/release/app-release.aab`
3. Configure Play Console with proper metadata
4. Set up Play App Signing for security

## 📋 Next Steps

1. **Test on real devices**: Test core functionality on various Android devices
2. **Performance testing**: Use `flutter build apk --profile` for performance analysis
3. **UI testing**: Verify layouts work on different screen sizes
4. **Integration testing**: Test all social login providers
5. **Play Store preparation**: Set up proper app signing and metadata

Your Android app is now ready for development and testing! 🎉 
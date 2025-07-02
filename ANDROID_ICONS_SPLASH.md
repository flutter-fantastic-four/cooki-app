# Android App Icon and Splash Screen Setup

This document describes the Android app icon and splash screen configuration for the Cooki app.

## App Icon Configuration

### Setup
- Added `flutter_launcher_icons: ^0.14.1` to `dev_dependencies` in `pubspec.yaml`
- Configured to use `assets/icons/app_icon.png` as the source image for legacy icons
- **NEW**: Added adaptive icon configuration that fills the entire circular space
- Generated icons for all Android density buckets (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)

### Configuration in pubspec.yaml
```yaml
flutter_launcher_icons:
  android: true
  ios: false  # iOS icons already configured separately
  image_path: "assets/icons/app_icon.png"  # Fallback/legacy icon
  min_sdk_android: 21
  adaptive_icon_background: "#1D8163"  # Cooki brand green background
  adaptive_icon_foreground: "assets/icons/cooki_logo_white_no_text.png"  # Logo fills the space
```

### Generated Files

#### Legacy Icons (for older Android versions)
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

#### Adaptive Icons (Android 8.0+ API 26+)
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml`
- `android/app/src/main/res/values/colors.xml` (background color definition)
- Foreground images in all density buckets:
  - `android/app/src/main/res/drawable-hdpi/ic_launcher_foreground.png`
  - `android/app/src/main/res/drawable-mdpi/ic_launcher_foreground.png`
  - `android/app/src/main/res/drawable-xhdpi/ic_launcher_foreground.png`
  - `android/app/src/main/res/drawable-xxhdpi/ic_launcher_foreground.png`
  - `android/app/src/main/res/drawable-xxxhdpi/ic_launcher_foreground.png`

### Adaptive Icon Benefits
- **Fills entire circular space**: The Cooki logo now fills the full icon area on modern Android devices
- **Consistent branding**: Green background with white logo matches your brand colors
- **Dynamic shapes**: Android can apply different shapes (circle, squircle, rounded square) while maintaining the design
- **Better visibility**: Logo stands out clearly against the solid green background
- **Modern Android experience**: Takes advantage of Android 8.0+ adaptive icon system
## Splash Screen Configuration

### Setup
- Uses existing `flutter_native_splash: ^2.4.6` package
- Added Android-specific configuration to match iOS splash screen
- Uses `assets/icons/cooki_logo_white.png` with `#1D8163` background color

### Configuration in pubspec.yaml
```yaml
flutter_native_splash:
  color: "#1D8163"
  image: "assets/icons/cooki_logo_white.png"
  color_ios: "#1D8163"
  color_android: "#1D8163"
  android_12:
    image: "assets/icons/cooki_logo_white.png"
    color: "#1D8163"
```

### Generated Assets

#### Legacy Android (API < 31)
- `android/app/src/main/res/drawable/launch_background.xml`
- `android/app/src/main/res/drawable-v21/launch_background.xml`
- Splash images in all density buckets (hdpi, mdpi, xhdpi, xxhdpi, xxxhdpi)
- Dark mode variants in `drawable-night-*` folders

#### Android 12+ (API 31+)
- `android/app/src/main/res/values-v31/styles.xml`
- `android/app/src/main/res/values-night-v31/styles.xml`
- Android 12+ splash images (`android12splash.png`) in all density buckets

### Styles Configuration
The splash screen is configured in Android styles with:
- Background color: `#1D8163` (Cooki brand green)
- Splash icon: Cooki white logo
- Support for both light and dark modes
- Compatibility with Android 12+ splash screen API

## Commands Used

### Generate App Icons
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

### Generate Splash Screen
```bash
flutter pub run flutter_native_splash:create
```

### Test Build
```bash
flutter build apk --debug
```

## Features
- ✅ **Adaptive icons fill entire circular space** on Android 8.0+ devices
- ✅ App icon matches iOS version using same brand assets
- ✅ Splash screen matches iOS with brand colors and logo
- ✅ Android 12+ splash screen API support
- ✅ Dark mode support for splash screen
- ✅ All density buckets covered (mdpi through xxxhdpi)
- ✅ Backward compatibility with older Android versions

## Notes
- **Modern Android devices (8.0+)**: Will show the adaptive icon with the Cooki logo filling the entire circular/shaped icon area with green background
- **Older Android devices**: Will show the traditional square icon with the app_icon.png
- The configuration maintains consistency across platforms while taking advantage of modern Android features
- Android 12+ users will see the new adaptive splash screen
- Legacy Android users will see the traditional splash screen with the same visual design
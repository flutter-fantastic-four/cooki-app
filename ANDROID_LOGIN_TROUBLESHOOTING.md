# Android Login Troubleshooting Guide

## Common Login Issues on Android

### Issue 1: Google Sign-In Not Working

**Symptoms:**
- Google login button does nothing
- Error: "Sign in failed" or "Network error"
- Console shows: "Status: SIGN_IN_FAILED"

**Solutions:**

1. **Check SHA-1 Fingerprint**
   ```bash
   # Get your debug keystore SHA-1
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # Add this SHA-1 to Firebase Console > Project Settings > Your Android App
   ```

2. **Verify google-services.json**
   - Ensure `android/app/google-services.json` exists
   - Download latest version from Firebase Console
   - Verify package name matches: `com.fantasticfour.cooki`

3. **Check App ID in google-services.json**
   ```json
   {
     "client": [
       {
         "client_info": {
           "mobilesdk_app_id": "should-match-your-app"
         }
       }
     ]
   }
   ```

### Issue 2: Kakao Login Not Working

**Symptoms:**
- Kakao login opens browser but fails to redirect back
- Error: "Redirect URI mismatch"
- KakaoTalk app not opening

**Solutions:**

1. **Update android/key.properties**
   ```properties
   KAKAO_API_KEY=your_actual_kakao_native_app_key
   ```

2. **Verify Android Manifest**
   - Check `android/app/src/main/AndroidManifest.xml`
   - Ensure the Kakao scheme is correct:
   ```xml
   <data android:scheme="${KAKAO_API_KEY}" android:host="oauth"/>
   ```

3. **Register Package Name in Kakao Console**
   - Go to Kakao Developers Console
   - Add package name: `com.fantasticfour.cooki`
   - Add key hash (SHA-1 converted to base64)

4. **Update Firebase Remote Config**
   - Set `kakao_native_key` in Firebase Remote Config
   - Ensure it matches your Kakao app's native key

### Issue 3: Apple Sign-In Not Working

**Symptoms:**
- Apple login crashes or shows error
- "Configuration error" message
- Web view doesn't open properly

**Solutions:**

1. **Update .env file**
   ```env
   APPLE_REDIRECT_URI=https://your-domain.com/auth/apple/callback
   APPLE_CLIENT_ID=your.apple.client.id
   ```

2. **For Android Apple Sign-In**
   - Apple Sign-In on Android requires web authentication
   - Configure proper redirect URI in Apple Developer Console
   - Ensure your domain handles the redirect properly

### Issue 4: Firebase Authentication Issues

**Symptoms:**
- All logins fail with "Firebase not initialized"
- Network timeout errors
- "Custom token" errors for Kakao

**Solutions:**

1. **Check Firebase Initialization**
   ```dart
   // In main.dart, ensure Firebase is initialized
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   ```

2. **Verify Firebase Functions**
   - Ensure `kakaoCustomAuth` cloud function is deployed
   - Check Firebase Functions logs for errors
   - Verify the function region matches: `asia-northeast3`

3. **Check Network Connectivity**
   - Ensure device has internet connection
   - Test on different networks (WiFi vs mobile)
   - Check firewall/proxy settings

### Issue 5: Build Configuration Issues

**Symptoms:**
- App won't build
- "Configuration with name 'implementation' not found"
- Gradle sync errors

**Solutions:**

1. **Clean and Rebuild**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --debug
   ```

2. **Check build.gradle.kts syntax**
   - Ensure proper formatting in `android/app/build.gradle.kts`
   - Verify all brackets and braces are matched

3. **Update Dependencies**
   ```bash
   cd android
   ./gradlew --refresh-dependencies
   ```

## Debug Steps

### 1. Enable Debug Logging

The app now includes debug logging. Look for these logs:

```
LOGIN ATTEMPT - Provider: Google, Status: Starting
LOGIN ATTEMPT - Provider: Google, Status: Success
```

### 2. Test Each Provider Individually

1. **Test Google Sign-In First**
   - Simplest to configure
   - Good for verifying basic Firebase setup

2. **Test Kakao Sign-In**
   - Requires more configuration
   - Check both KakaoTalk app and web login

3. **Test Apple Sign-In Last**
   - Most complex on Android
   - Requires web authentication setup

### 3. Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `SIGN_IN_FAILED` | Google configuration issue | Check SHA-1 fingerprint |
| `CANCELED` | User cancelled | Normal behavior |
| `NETWORK_ERROR` | Internet/Firebase issue | Check connectivity |
| `INVALID_AUDIENCE` | Wrong OAuth client | Verify google-services.json |
| `Configuration error` | Missing env variables | Check .env file |

## Testing Commands

```bash
# Run with verbose logging
flutter run -v

# Build debug APK for testing
flutter build apk --debug

# Install on connected device
flutter install

# Check Firebase connection
flutter packages pub run firebase_tools:configure
```

## Final Checklist

- [ ] `google-services.json` exists in `android/app/`
- [ ] SHA-1 fingerprint added to Firebase Console
- [ ] Package name matches in all services: `com.fantasticfour.cooki`
- [ ] `android/key.properties` has correct KAKAO_API_KEY
- [ ] `.env` file has Apple credentials (if using Apple Sign-In)
- [ ] Firebase Remote Config has `kakao_native_key`
- [ ] Internet permissions enabled in AndroidManifest.xml
- [ ] App builds successfully: `flutter build apk --debug`

## Still Having Issues?

1. Check the device logs: `flutter logs`
2. Test on different Android devices/versions
3. Verify all API keys are correct and active
4. Ensure all services (Firebase, Kakao, Apple) are properly configured
5. Try creating a minimal test app with just login functionality

The debug logging added to the app will help identify exactly where the login process is failing. 
import 'dart:developer';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class LoginDebugHelper {
  static Future<void> checkAndroidLoginConfiguration() async {
    log('=== Android Login Configuration Check ===');

    // Check platform
    log('Platform: ${Platform.operatingSystem}');

    // Check Firebase initialization
    try {
      final apps = Firebase.apps;
      log('Firebase apps initialized: ${apps.length}');
      if (apps.isNotEmpty) {
        log('Firebase app name: ${apps.first.name}');
      }
    } catch (e) {
      log('Firebase check failed: $e');
    }

    // Check environment variables
    try {
      final appleClientId = dotenv.env['APPLE_CLIENT_ID'];
      final appleRedirectUri = dotenv.env['APPLE_REDIRECT_URI'];

      log(
        'Apple Client ID configured: ${appleClientId != null ? 'YES' : 'NO'}',
      );
      log(
        'Apple Redirect URI configured: ${appleRedirectUri != null ? 'YES' : 'NO'}',
      );
    } catch (e) {
      log('Environment variables check failed: $e');
    }

    // Check Firebase Remote Config for Kakao
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      final kakaoKey = remoteConfig.getString('kakao_native_key');
      log(
        'Kakao native key from Remote Config: ${kakaoKey.isNotEmpty ? 'YES' : 'NO'}',
      );
    } catch (e) {
      log('Firebase Remote Config check failed: $e');
    }

    log('=== End Configuration Check ===');
  }

  static void logLoginAttempt(String provider, String status, [String? error]) {
    log(
      'LOGIN ATTEMPT - Provider: $provider, Status: $status${error != null ? ', Error: $error' : ''}',
    );

    // Interpret specific Google Sign-In error codes
    if (provider == 'Google' &&
        error != null &&
        error.contains('ApiException: 10')) {
      log('🚨 GOOGLE SIGN-IN ERROR CODE 10 (DEVELOPER_ERROR):');
      log(
        '   - This means SHA-1 fingerprint is missing or incorrect in Firebase Console',
      );
      log(
        '   - Your SHA-1: 46:EA:C7:A8:29:1E:0A:19:C4:E9:45:58:D1:A3:BC:85:C5:FF:12:C9',
      );
      log(
        '   - Add this SHA-1 to Firebase Console → Project Settings → Android App',
      );
      log(
        '   - Download updated google-services.json and replace android/app/google-services.json',
      );
    }

    if (provider == 'Google' &&
        error != null &&
        error.contains('ApiException: 12500')) {
      log('🚨 GOOGLE SIGN-IN ERROR CODE 12500 (SIGN_IN_CANCELLED):');
      log('   - User cancelled the sign-in process');
    }

    if (provider == 'Google' &&
        error != null &&
        error.contains('ApiException: 7')) {
      log('🚨 GOOGLE SIGN-IN ERROR CODE 7 (NETWORK_ERROR):');
      log('   - Check internet connection');
      log('   - Try different network (WiFi vs mobile data)');
    }
  }
}

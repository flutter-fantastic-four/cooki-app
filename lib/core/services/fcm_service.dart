import 'dart:convert';
import 'dart:developer';
import 'package:cooki/core/utils/logger.dart';
import 'package:cooki/presentation/pages/reviews/reviews_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/repository/user_repository.dart';

class FCMService {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static String? _fcmToken;

  static BuildContext? _context;

  static Future<void> initialize(BuildContext context) async {
    _context = context;

    // Request permission for notifications
    await _requestPermission();
    await _initializeLocalNotifications();

    // Wait for APNs token to be available (iOS only)
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      String? apnsToken;
      int retries = 0;

      while (apnsToken == null && retries < 5) {
        apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken == null) {
          log('FCM: APNs token not yet available, retrying...');
          await Future.delayed(const Duration(seconds: 1));
          retries++;
        }
      }

      if (apnsToken != null) {
        log('FCM: APNs token ready: $apnsToken');
      } else {
        log('FCM: APNs token still null after retries');
      }
    }

    // Now safe to get FCM token
    await _getToken();
    _setupMessageHandlers();

    // Handle notification when app is opened from terminated state
    _handleInitialMessage();
  }

  static Future<void> _requestPermission() async {
    // Request notification permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('FCM: User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('FCM: User granted provisional permission');
    } else {
      log('FCM: User declined or has not accepted permission');
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const channel = AndroidNotificationChannel(
      'review_notifications',
      'Review Notifications',
      description: 'Notifications for new reviews on your recipes',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _getToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      log('FCM Token: $_fcmToken');
    } catch (e, stack) {
      logError(e, stack, reason: 'FCM: Error getting token');
    }
  }

  static void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages when app is opened
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      log('FCM: Token refreshed: $newToken');
      _fcmToken = newToken;
      // TODO: Update the FCM token in user's Firestore document here
    });
  }

  static Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      log('FCM: App opened from terminated state via notification');
      _handleNotificationNavigation(initialMessage.data);
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('FCM: Received foreground message: ${message.messageId}');

    // Show local notification when app is in foreground
    const androidDetails = AndroidNotificationDetails(
      'review_notifications',
      'Review Notifications',
      channelDescription: 'Notifications for new reviews on your recipes',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'New Review',
      message.notification?.body ?? 'You have a new review on your recipe',
      details,
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    log('FCM: App opened from background via notification');
    _handleNotificationNavigation(message.data);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    log('FCM: Local notification tapped');
    if (response.payload != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        _handleNotificationNavigation(data);
      } catch (e, stack) {
        logError(e, stack, reason: 'FCM: Error parsing notification payload');
      }
    }
  }

  static void _handleNotificationNavigation(Map<String, dynamic> data) {
    if (_context == null || !_context!.mounted) return;

    final String? type = data['type'];
    final String? recipeId = data['recipeId'];

    if (type == 'review_added' && recipeId != null) {
      Navigator.of(_context!).push(
        MaterialPageRoute(
          builder:
              (context) => ReviewsPage(
                recipeId: recipeId,
                recipeName: data['recipeName'],
              ),
        ),
      );
    }
  }

  static String? get fcmToken => _fcmToken;

  static Future<void> updateTokenInFirestore({
    required String userId,
    required UserRepository userRepository,
  }) async {
    if (_fcmToken == null) return;

    try {
      await userRepository.updateUserFcmToken(userId, _fcmToken!);
      log('FCM: Token updated in Firestore');
    } catch (e, stack) {
      logError(e, stack, reason: 'FCM: Error updating token in Firestore');
    }
  }
}

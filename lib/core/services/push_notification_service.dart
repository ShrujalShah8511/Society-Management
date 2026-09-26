import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Top-level background message handler for Firebase Cloud Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[PushNotificationService] Background message received: ${message.messageId}');
}

/// Production Push Notification Service backed by Firebase Cloud Messaging
class PushNotificationService {
  static final PushNotificationService instance = PushNotificationService._();
  PushNotificationService._();

  FirebaseMessaging? _messaging;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initializes Firebase Cloud Messaging if Firebase is configured
  Future<void> initialize() async {
    if (!AppConfig.isFirebaseConfigured) {
      debugPrint('[PushNotificationService] Firebase unconfigured. Operating in offline notification mode.');
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: AppConfig.firebaseApiKey,
            appId: AppConfig.firebaseAppId,
            messagingSenderId: AppConfig.firebaseMessagingSenderId,
            projectId: AppConfig.firebaseProjectId,
            authDomain: AppConfig.firebaseAuthDomain,
            storageBucket: AppConfig.firebaseStorageBucket,
            measurementId: AppConfig.firebaseMeasurementId,
          ),
        );
      }

      _messaging = FirebaseMessaging.instance;
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request notification permissions
      final settings = await _messaging?.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('[PushNotificationService] Permission status: ${settings?.authorizationStatus}');

      // Retrieve FCM Token
      if (kIsWeb) {
        _fcmToken = await _messaging?.getToken(
          vapidKey: AppConfig.firebaseVapidKey.isNotEmpty ? AppConfig.firebaseVapidKey : null,
        );
      } else {
        _fcmToken = await _messaging?.getToken();
      }

      debugPrint('[PushNotificationService] FCM Token: $_fcmToken');

      // Listen to foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[PushNotificationService] Foreground notification received: ${message.notification?.title}');
      });

      // Token refresh listener
      _messaging?.onTokenRefresh.listen((String newToken) {
        _fcmToken = newToken;
        debugPrint('[PushNotificationService] FCM Token refreshed: $newToken');
      });
    } catch (e) {
      debugPrint('[PushNotificationService] Initialization error: $e');
    }
  }

  /// Subscribe to society-wide notification topics
  Future<void> subscribeToSociety(String societyId) async {
    if (_messaging == null || kIsWeb) return;
    try {
      await _messaging?.subscribeToTopic('society_$societyId');
      debugPrint('[PushNotificationService] Subscribed to topic: society_$societyId');
    } catch (e) {
      debugPrint('[PushNotificationService] Failed to subscribe to topic: $e');
    }
  }
}

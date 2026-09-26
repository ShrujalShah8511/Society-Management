import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Production Analytics Service backed by Firebase Analytics
class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._();
  AnalyticsService._();

  FirebaseAnalytics? _analytics;

  /// Initializes Firebase Analytics if Firebase is configured
  Future<void> initialize() async {
    if (!AppConfig.isFirebaseConfigured) {
      if (kDebugMode) debugPrint('[AnalyticsService] Firebase unconfigured. Operating in offline analytics mode.');
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

      _analytics = FirebaseAnalytics.instance;
      await _analytics?.setAnalyticsCollectionEnabled(true);
      if (kDebugMode) debugPrint('[AnalyticsService] Firebase Analytics initialized.');
    } catch (e) {
      if (kDebugMode) debugPrint('[AnalyticsService] Initialization error: $e');
    }
  }

  /// Log User Login
  Future<void> logLogin(String method) async {
    try {
      await _analytics?.logLogin(loginMethod: method);
    } catch (e) {
      if (kDebugMode) debugPrint('[AnalyticsService] logLogin error: $e');
    }
  }

  /// Log Screen View
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics?.logScreenView(screenName: screenName);
    } catch (e) {
      if (kDebugMode) debugPrint('[AnalyticsService] logScreenView error: $e');
    }
  }

  /// Log Society Switching
  Future<void> logSocietySwitched(String societyId, String societyName) async {
    try {
      await _analytics?.logEvent(
        name: 'society_switched',
        parameters: {
          'society_id': societyId,
          'society_name': societyName,
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[AnalyticsService] logSocietySwitched error: $e');
    }
  }

  /// Log Flat CRUD Event
  Future<void> logFlatAction(String action, String flatNumber, String societyId) async {
    try {
      await _analytics?.logEvent(
        name: 'flat_action',
        parameters: {
          'action': action,
          'flat_number': flatNumber,
          'society_id': societyId,
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[AnalyticsService] logFlatAction error: $e');
    }
  }
}

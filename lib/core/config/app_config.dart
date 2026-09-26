import 'dart:convert';

/// Centralized Application Configuration
/// Handles environment variables passed via `--dart-define` or `.env`
/// Supports Cloudflare Pages, Supabase, and Firebase integration
class AppConfig {
  AppConfig._();

  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://cssbdibkljyvawivoaiw.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzc2JkaWJrbGp5dmF3aXZvYWl3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAzNTg3MDYsImV4cCI6MjEwNTkzNDcwNn0.QeSEK_Vq1J2B3zU_D_mvbYqGWfFpCxPGutsUEyGCyfY',
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  // Firebase Web Configuration
  static const String _envApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String _fallbackKeyBase64 = 'QUl6YVN5Q3RVaFROMjVpTzN6SnZ5dWFoTS1UX2lvaHFiVTk3OGRj';

  static String get firebaseApiKey {
    if (_envApiKey.isNotEmpty) return _envApiKey;
    return utf8.decode(base64.decode(_fallbackKeyBase64));
  }

  static const String firebaseAuthDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'society-management-c7642.firebaseapp.com',
  );

  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'society-management-c7642',
  );

  static const String firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'society-management-c7642.firebasestorage.app',
  );

  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '545312537010',
  );

  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:545312537010:web:1e3ec170d99625d1d0ccab',
  );

  static const String firebaseMeasurementId = String.fromEnvironment(
    'FIREBASE_MEASUREMENT_ID',
    defaultValue: 'G-ES5P2MYD0N',
  );

  static const String firebaseVapidKey = String.fromEnvironment(
    'FIREBASE_VAPID_KEY',
    defaultValue: '',
  );

  static bool get isFirebaseConfigured =>
      firebaseApiKey.isNotEmpty && firebaseProjectId.isNotEmpty;

  // Environment Mode
  static const bool isProduction = bool.fromEnvironment(
    'dart.vm.product',
    defaultValue: false,
  );
}

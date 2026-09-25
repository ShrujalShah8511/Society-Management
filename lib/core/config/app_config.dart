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
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyCtUhTN25iO3zJvyuahM-T_iohqbU978dc',
  );

  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'society-management-c7642',
  );

  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '545312537010',
  );

  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:545312537010:web:1e3ec170d99625d1d0ccab',
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

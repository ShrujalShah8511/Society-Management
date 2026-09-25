import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

/// Singleton manager for the Supabase Client Lifecycle
class SupabaseClientManager {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  /// Initializes Supabase if credentials are provided in AppConfig
  static Future<void> initialize() async {
    if (!AppConfig.isSupabaseConfigured) {
      debugPrint('[SupabaseClientManager] Supabase credentials not found. Operating in local mock mode.');
      return;
    }

    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      _isInitialized = true;
      debugPrint('[SupabaseClientManager] Supabase initialized successfully.');
    } catch (e) {
      debugPrint('[SupabaseClientManager] Failed to initialize Supabase: $e');
    }
  }

  /// Returns the active SupabaseClient if initialized, otherwise null
  static SupabaseClient? get client {
    if (!_isInitialized) return null;
    return Supabase.instance.client;
  }
}

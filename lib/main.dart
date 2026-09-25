import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'app/providers.dart';

import 'core/network/supabase_client_manager.dart';
import 'core/services/analytics_service.dart';
import 'core/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Cloud Backend, Push Notifications, and Analytics
  await SupabaseClientManager.initialize();
  await PushNotificationService.instance.initialize();
  await AnalyticsService.instance.initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const SocietyManagementApp(),
    ),
  );
}

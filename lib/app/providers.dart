import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage/file_storage_service.dart';
import '../core/storage/session_storage.dart';
import '../features/authentication/data/auth_mock_data_source.dart';
import '../features/authentication/data/auth_repository_impl.dart';
import '../features/authentication/domain/auth_repository.dart';
import '../features/dashboard/data/dashboard_repository_impl.dart';
import '../features/dashboard/domain/dashboard_repository.dart';
import '../features/settings/data/settings_repository_impl.dart';
import '../features/settings/domain/settings_repository.dart';
import '../features/society/data/flat_repository_impl.dart';
import '../features/society/data/floor_repository_impl.dart';
import '../features/society/data/society_mock_data_source.dart';
import '../features/society/data/society_repository_impl.dart';
import '../features/society/data/tower_repository_impl.dart';
import '../features/society/domain/flat_repository.dart';
import '../features/society/domain/floor_repository.dart';
import '../features/society/domain/society_repository.dart';
import '../features/society/domain/tower_repository.dart';

// Storage & Infrastructure Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FlutterSessionStorage(preferences: prefs);
});

final fileStorageServiceProvider = Provider<FileStorageService>((ref) {
  return MockFileStorageService();
});

// Mock Data Source Singleton Provider
final societyMockDataSourceProvider = Provider<SocietyMockDataSource>((ref) {
  return SocietyMockDataSource();
});

final authMockDataSourceProvider = Provider<AuthMockDataSource>((ref) {
  return AuthMockDataSource();
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authMockDataSourceProvider);
  final storage = ref.watch(sessionStorageProvider);
  return AuthRepositoryImpl(dataSource: dataSource, sessionStorage: storage);
});

final societyRepositoryProvider = Provider<SocietyRepository>((ref) {
  final dataSource = ref.watch(societyMockDataSourceProvider);
  return SocietyRepositoryImpl(dataSource);
});

final towerRepositoryProvider = Provider<TowerRepository>((ref) {
  final dataSource = ref.watch(societyMockDataSourceProvider);
  return TowerRepositoryImpl(dataSource);
});

final floorRepositoryProvider = Provider<FloorRepository>((ref) {
  final dataSource = ref.watch(societyMockDataSourceProvider);
  return FloorRepositoryImpl(dataSource);
});

final flatRepositoryProvider = Provider<FlatRepository>((ref) {
  final dataSource = ref.watch(societyMockDataSourceProvider);
  return FlatRepositoryImpl(dataSource);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dataSource = ref.watch(societyMockDataSourceProvider);
  return DashboardRepositoryImpl(dataSource);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepositoryImpl(prefs);
});

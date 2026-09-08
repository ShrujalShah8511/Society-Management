import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

abstract class SessionStorage {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveUserData(String userJson);
  Future<String?> getUserData();
  Future<void> clear();
}

class FlutterSessionStorage implements SessionStorage {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _preferences;

  FlutterSessionStorage({
    FlutterSecureStorage? secureStorage,
    required SharedPreferences preferences,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _preferences = preferences;

  @override
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: StorageKeys.authToken, value: token);
    } catch (_) {
      // Fallback for environments where secure storage is unavailable (e.g. some web platforms)
      await _preferences.setString(StorageKeys.authToken, token);
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: StorageKeys.authToken);
      if (token != null) return token;
    } catch (_) {}
    return _preferences.getString(StorageKeys.authToken);
  }

  @override
  Future<void> saveUserData(String userJson) async {
    await _preferences.setString(StorageKeys.currentUserJson, userJson);
  }

  @override
  Future<String?> getUserData() async {
    return _preferences.getString(StorageKeys.currentUserJson);
  }

  @override
  Future<void> clear() async {
    try {
      await _secureStorage.delete(key: StorageKeys.authToken);
    } catch (_) {}
    await _preferences.remove(StorageKeys.authToken);
    await _preferences.remove(StorageKeys.currentUserJson);
    await _preferences.remove(StorageKeys.currentUserId);
  }
}

class InMemorySessionStorage implements SessionStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> saveToken(String token) async {
    _storage[StorageKeys.authToken] = token;
  }

  @override
  Future<String?> getToken() async {
    return _storage[StorageKeys.authToken];
  }

  @override
  Future<void> saveUserData(String userJson) async {
    _storage[StorageKeys.currentUserJson] = userJson;
  }

  @override
  Future<String?> getUserData() async {
    return _storage[StorageKeys.currentUserJson];
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }
}

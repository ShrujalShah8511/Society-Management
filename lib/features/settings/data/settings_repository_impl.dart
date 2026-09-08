import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/storage_keys.dart';
import '../domain/settings_model.dart';
import '../domain/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences? _preferences;
  ThemeMode _inMemoryMode = ThemeMode.system;

  SettingsRepositoryImpl([this._preferences]);

  @override
  Future<SettingsModel> getSettings() async {
    if (_preferences != null) {
      final savedMode = _preferences!.getString(StorageKeys.themeMode);
      if (savedMode == 'light') {
        _inMemoryMode = ThemeMode.light;
      } else if (savedMode == 'dark') {
        _inMemoryMode = ThemeMode.dark;
      } else {
        _inMemoryMode = ThemeMode.system;
      }
    }
    return SettingsModel(themeMode: _inMemoryMode);
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    _inMemoryMode = mode;
    if (_preferences != null) {
      String value = 'system';
      if (mode == ThemeMode.light) value = 'light';
      if (mode == ThemeMode.dark) value = 'dark';
      await _preferences!.setString(StorageKeys.themeMode, value);
    }
  }
}

import 'package:flutter/material.dart';
import 'settings_model.dart';

abstract class SettingsRepository {
  Future<SettingsModel> getSettings();
  Future<void> setThemeMode(ThemeMode mode);
}

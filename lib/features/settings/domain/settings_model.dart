import 'package:flutter/material.dart';

class SettingsModel {
  final ThemeMode themeMode;

  const SettingsModel({
    this.themeMode = ThemeMode.system,
  });

  SettingsModel copyWith({
    ThemeMode? themeMode,
  }) {
    return SettingsModel(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/security/tiered_storage_service.dart';
import '../../../core/di/providers/providers.dart';

import '../../../core/presentation/themes/app_theme.dart';

@immutable
class ThemeState {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final ThemeMode themeMode;

  const ThemeState({
    required this.lightTheme,
    required this.darkTheme,
    required this.themeMode,
  });

  ThemeState copyWith({
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    ThemeMode? themeMode,
  }) {
    return ThemeState(
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeKey = 'theme_mode';
  final TieredStorageService _storage;

  ThemeNotifier(this._storage)
    : super(
        ThemeState(
          lightTheme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
        ),
      ) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final savedTheme = await _storage.read(_themeKey, DataSensitivity.low);
      if (savedTheme != null) {
        final themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedTheme,
          orElse: () => ThemeMode.system,
        );
        state = state.copyWith(themeMode: themeMode);
      }
    } catch (e) {
      // Fallback to system theme if error occurs
      state = state.copyWith(themeMode: ThemeMode.system);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      await _storage.store(_themeKey, mode.toString(), DataSensitivity.low);
      state = state.copyWith(themeMode: mode);
    } catch (e) {
      // Handle error silently, keep current theme
    }
  }

  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    setThemeMode(newMode);
  }

  bool get isDarkMode => state.themeMode == ThemeMode.dark;
  bool get isLightMode => state.themeMode == ThemeMode.light;
  bool get isSystemMode => state.themeMode == ThemeMode.system;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final tieredStorage = ref.watch(tieredStorageServiceProvider);
  return ThemeNotifier(tieredStorage);
});

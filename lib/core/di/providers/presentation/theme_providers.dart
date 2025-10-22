// =============================================================================
// PRESENTATION THEME PROVIDERS - RIVERPOD MIGRATION
// =============================================================================

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/providers/theme_provider.dart';

part 'theme_providers.g.dart';

// =============================================================================
// THEME CONFIGURATION PROVIDERS
// =============================================================================

/// Main theme provider - delegates to existing ThemeProvider
/// KEEPALIVE JUSTIFIED: Theme state must persist across the entire app lifecycle
@Riverpod(keepAlive: true)
ThemeState theme(Ref ref) {
  // FIXED: Use service_provider themeProvider from StateNotifierProvider directly
  return ref.watch(themeProvider.select((state) => state));
}

/// Current theme mode provider
/// KEEPALIVE JUSTIFIED: Theme mode must persist across all screens
@Riverpod(keepAlive: true)
ThemeMode currentThemeMode(Ref ref) {
  return ref.watch(themeProvider).themeMode;
}

/// Is dark mode active provider
/// KEEPALIVE JUSTIFIED: Dark mode state must persist for consistent UI
@Riverpod(keepAlive: true)
bool isDarkMode(Ref ref) {
  final themeMode = ref.watch(currentThemeModeProvider);
  return themeMode == ThemeMode.dark;
}

/// Current theme data provider (for widget access)
final currentThemeDataProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeProvider);

  // Default to light theme if no context available
  switch (themeState.themeMode) {
    case ThemeMode.dark:
      return themeState.darkTheme;
    case ThemeMode.light:
      return themeState.lightTheme;
    case ThemeMode.system:
      return themeState.lightTheme; // Default fallback
  }
});

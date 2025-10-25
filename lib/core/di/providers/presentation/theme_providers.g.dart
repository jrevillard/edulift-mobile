// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themeHash() => r'81a74de82a5f3c15a4af72f8acf7acdeca3f9479';

/// Main theme provider - delegates to existing ThemeProvider
/// KEEPALIVE JUSTIFIED: Theme state must persist across the entire app lifecycle
///
/// Copied from [theme].
@ProviderFor(theme)
final themeProvider = Provider<ThemeState>.internal(
  theme,
  name: r'themeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ThemeRef = ProviderRef<ThemeState>;
String _$currentThemeModeHash() => r'5f5f843f124d0ecdff3b47383f8fb8f031281bd8';

/// Current theme mode provider
/// KEEPALIVE JUSTIFIED: Theme mode must persist across all screens
///
/// Copied from [currentThemeMode].
@ProviderFor(currentThemeMode)
final currentThemeModeProvider = Provider<ThemeMode>.internal(
  currentThemeMode,
  name: r'currentThemeModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentThemeModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentThemeModeRef = ProviderRef<ThemeMode>;
String _$isDarkModeHash() => r'e945b157ad3688046801288e81da9bbf7198e28d';

/// Is dark mode active provider
/// KEEPALIVE JUSTIFIED: Dark mode state must persist for consistent UI
///
/// Copied from [isDarkMode].
@ProviderFor(isDarkMode)
final isDarkModeProvider = Provider<bool>.internal(
  isDarkMode,
  name: r'isDarkModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isDarkModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsDarkModeRef = ProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

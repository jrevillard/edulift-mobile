// EduLift Mobile - Configuration Providers
// Riverpod providers for dependency injection of configuration objects

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/base_config.dart';
import '../../../config/environment_config.dart';

part 'config_providers.g.dart';

/// Provider for the application configuration
///
/// This is the foundation provider that all other providers depend on.
/// It reads the environment from dart-define and returns the appropriate config.
///
/// This provider is created once at app startup and used throughout the app.
@Riverpod(keepAlive: true)
BaseConfig appConfig(Ref ref) {
  // Get configuration based on dart-define FLAVOR
  final config = EnvironmentConfig.getConfig();
  // The config is cached by Riverpod and will not be recreated
  return config;
}

/// Convenience providers for accessing specific config values
/// These make it easy to inject individual configuration values

@Riverpod(keepAlive: true)
String apiBaseUrl(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return config.apiBaseUrl;
}

@Riverpod(keepAlive: true)
String websocketUrl(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return config.websocketUrl;
}

@Riverpod(keepAlive: true)
String mailpitApiUrl(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return config.mailpitApiUrl;
}

@Riverpod(keepAlive: true)
Duration connectTimeout(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return config.connectTimeout;
}

@Riverpod(keepAlive: true)
Duration receiveTimeout(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return config.receiveTimeout;
}

@Riverpod(keepAlive: true)
Duration sendTimeout(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return config.sendTimeout;
}

@Riverpod(keepAlive: true)
bool debugEnabled(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return config.debugEnabled;
}

@Riverpod(keepAlive: true)
bool firebaseEnabled(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return config.firebaseEnabled;
}

@Riverpod(keepAlive: true)
Map<String, String> defaultHeaders(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return config.defaultHeaders;
}

@Riverpod(keepAlive: true)
String appName(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return config.appName;
}

@Riverpod(keepAlive: true)
String environmentName(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return config.environmentName;
}

// Network Mocking for Golden Tests
// Provides network override functions for golden tests to prevent real network calls

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/core/di/providers/foundation/config_providers.dart';
import 'package:edulift/core/config/base_config.dart';

/// Mock configuration for golden tests
/// This prevents EnvironmentConfig.getConfig() from being called,
/// which would initialize real network services (Dio, TokenRefreshService)
class _MockGoldenTestConfig implements BaseConfig {
  @override
  String get apiBaseUrl => 'https://mock-api.test/api/v1';

  @override
  String get websocketUrl => 'wss://mock-api.test';

  @override
  String get mailpitWebUrl => 'http://mock-mailpit.test';

  @override
  String get mailpitApiUrl => 'http://mock-mailpit.test/api';

  @override
  Duration get connectTimeout => const Duration(seconds: 30);

  @override
  Duration get receiveTimeout => const Duration(seconds: 30);

  @override
  Duration get sendTimeout => const Duration(seconds: 30);

  @override
  bool get debugEnabled => false; // Disable debug logging in tests

  @override
  String get appName => 'EduLift Test';

  @override
  String get environmentName => 'test';

  @override
  bool get firebaseEnabled => false;

  @override
  Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  bool validate() => true;

  @override
  Map<String, dynamic> get configSummary => {
    'environment': environmentName,
    'appName': appName,
    'apiBaseUrl': apiBaseUrl,
    'websocketUrl': websocketUrl,
    'debugEnabled': debugEnabled,
    'firebaseEnabled': firebaseEnabled,
  };
}

/// Get all network mock overrides for golden tests
///
/// CRITICAL: This prevents ALL real network initialization in golden tests by:
/// 1. Overriding appConfigProvider to return a mock config
/// 2. This prevents EnvironmentConfig.getConfig() from being called
/// 3. Which prevents Dio and TokenRefreshService from initializing with real URLs
///
/// ALL golden tests MUST include this in their provider overrides!
List<Override> getAllNetworkMockOverrides() {
  return [
    // Override the base config provider to prevent real environment initialization
    appConfigProvider.overrideWith((ref) => _MockGoldenTestConfig()),
  ];
}

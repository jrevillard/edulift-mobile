// EduLift Mobile - Environment Configuration Factory
// Factory that creates the appropriate configuration based on dart-define FLAVOR
// This is the single source of truth for environment detection

import 'package:flutter/foundation.dart';
import 'base_config.dart';
import 'app_config.dart';
import 'environment.dart';

/// Environment configuration factory
///
/// Reads the FLAVOR from String.fromEnvironment (set via --dart-define)
/// and returns the appropriate configuration instance.
///
/// Usage:
/// - Development: flutter run --dart-define=FLAVOR=development (or default)
/// - Staging: flutter run --dart-define=FLAVOR=staging
/// - E2E Tests: patrol test (automatically detects E2E context)
/// - Production: flutter build apk --dart-define=FLAVOR=production
class EnvironmentConfig {
  /// The dart-define key used to specify the environment
  static const String _flavorKey = 'FLAVOR';

  // CACHE: Prevent infinite provider rebuilds during E2E tests
  static BaseConfig? _cachedConfig;

  /// Check if we're running in Patrol test context
  ///
  /// Patrol automatically defines PATROL_TEST_SERVER_PORT when running E2E tests,
  /// which we can use to detect that we should use E2E configuration.
  static bool _isPatrolContext() {
    const patrolPort = String.fromEnvironment('PATROL_TEST_SERVER_PORT');
    return patrolPort.isNotEmpty;
  }

  /// Get the appropriate configuration for the current environment
  ///
  /// This method:
  /// 1. Checks if we're in Patrol context (E2E tests) - uses 'e2e' automatically
  /// 2. Otherwise reads FLAVOR from String.fromEnvironment (dart-define)
  /// 3. Returns the matching configuration instance
  /// 4. Uses 'development' as default if no FLAVOR is specified
  ///
  /// This is compile-time safe and allows tree-shaking of unused configurations.
  static BaseConfig getConfig() {
    // Return cached config if available to prevent rebuild loops
    if (_cachedConfig != null) {
      return _cachedConfig!;
    }

    // Detect flavor: Patrol context overrides explicit FLAVOR
    final flavor = _isPatrolContext()
        ? 'e2e'
        : const String.fromEnvironment(_flavorKey, defaultValue: 'development');

    if (kDebugMode) {
      debugPrint('🎯 EnvironmentConfig: Detected flavor: $flavor');
      if (_isPatrolContext()) {
        debugPrint('🚀 Patrol E2E context detected - using E2E configuration');
      }
    }

    // Create the appropriate configuration based on flavor
    final config = _createConfig(flavor);

    // Validate the configuration
    final isValid = config.validate();
    if (kDebugMode) {
      if (isValid) {
        debugPrint('✅ EnvironmentConfig: Configuration validated successfully');
        debugPrint('📱 App: ${config.appName}');
        debugPrint('🔗 API: ${config.apiBaseUrl}');
        debugPrint('🌐 WebSocket: ${config.websocketUrl}');
        if (config.environmentName == 'e2e') {
          debugPrint('📧 Mailpit: ${config.mailpitWebUrl}');
        }
      } else {
        debugPrint('⚠️  EnvironmentConfig: Configuration validation failed');
      }
    }

    // Cache the config to prevent rebuild loops
    _cachedConfig = config;
    return config;
  }

  /// Create configuration instance based on flavor string
  static BaseConfig _createConfig(String flavor) {
    final environment = Environment.fromString(flavor);

    if (environment == null) {
      throw ArgumentError.value(
        flavor,
        'flavor',
        'Unsupported environment flavor. Supported flavors: ${Environment.allSupportedNames.join(', ')}. '
            'Use --dart-define=FLAVOR=<environment> to specify the environment.',
      );
    }

    switch (environment) {
      case Environment.development:
        return DevelopmentConfig();
      case Environment.staging:
        return StagingConfig();
      case Environment.e2e:
        return E2EConfig();
      case Environment.production:
        return ProductionConfig();
    }
  }

  /// Get list of canonical environment names
  static List<String> get supportedEnvironments => Environment.canonicalNames;

  /// Get list of all supported environment names (including aliases)
  static List<String> get allSupportedEnvironments =>
      Environment.allSupportedNames;

  /// Check if a flavor name is supported
  static bool isSupported(String flavor) {
    return Environment.isSupported(flavor);
  }
}

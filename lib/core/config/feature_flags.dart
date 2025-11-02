// EduLift Mobile - Feature Flags Configuration
// Centralized feature flag management based on Flutter Flavors
//
// This class provides flavor-based feature flags that automatically
// configure application behavior based on the current environment.
// All flags are determined by the active flavor rather than individual
// environment variables for cleaner, more maintainable configuration.

import 'package:flutter/foundation.dart';
import 'environment_config.dart';
import '../utils/app_logger.dart';

/// Feature flags configuration based on current flavor
///
/// Provides centralized feature flag management that automatically
/// adjusts application behavior based on the active environment.
/// Flags are computed dynamically from the current flavor state.
class FeatureFlags {
  // Private constructor to prevent instantiation
  FeatureFlags._();

  /// Debug mode enabled
  ///
  /// Enables additional logging, debug widgets, and development tools.
  /// Only disabled in production for optimal performance.
  static bool get debugMode =>
      EnvironmentConfig.getConfig().environmentName == 'development';

  /// Analytics and tracking enabled
  ///
  /// Controls whether user analytics, crash reporting, and usage
  /// tracking should be enabled. Disabled in development to avoid
  /// polluting production data with test interactions.
  static bool get analyticsEnabled =>
      EnvironmentConfig.getConfig().environmentName != 'development';

  /// Crash reporting enabled
  ///
  /// Controls Firebase Crashlytics and other crash reporting services.
  /// Enabled in production and staging for debugging purposes.
  static bool get crashReporting {
    final env = EnvironmentConfig.getConfig().environmentName;
    return env == 'production' || env == 'staging';
  }

  /// Firebase services enabled
  ///
  /// Controls initialization of Firebase services (Crashlytics, Analytics).
  /// Disabled in development and E2E to avoid side effects during testing.
  static bool get firebaseEnabled =>
      EnvironmentConfig.getConfig().firebaseEnabled;

  // REMOVED: verboseLogging - Use standard log levels instead (debug, info, warning, error)
  // Logging is now managed by AppLogger which respects environment-based log levels
  // This eliminates the architectural inconsistency between feature flags and log levels

  /// Performance profiling enabled
  ///
  /// Enables Flutter Inspector, performance overlays, and timing logs.
  /// Useful for development and staging performance analysis.
  static bool get performanceProfiling {
    final env = EnvironmentConfig.getConfig().environmentName;
    return env == 'development' || env == 'staging';
  }

  /// Mock services enabled
  ///
  /// Controls whether to use mock data services instead of real API calls.
  /// Can be useful for UI development and certain types of testing.
  static bool get mockServicesEnabled => false; // Disabled by default

  /// Network logging enabled
  ///
  /// Controls whether HTTP requests/responses are logged for debugging.
  /// Enabled in non-production environments for API debugging.
  static bool get networkLogging =>
      EnvironmentConfig.getConfig().environmentName != 'production';

  /// Extended timeouts for E2E
  ///
  /// Uses longer network timeouts for E2E tests to account for
  /// slower test execution and Docker network latency.
  static bool get useExtendedTimeouts =>
      EnvironmentConfig.getConfig().environmentName == 'e2e';

  /// Disable infinite animations during testing
  ///
  /// Prevents infinite UI animations that block test framework stability.
  /// Critical for E2E test pumpAndSettle compatibility.
  static bool get disableInfiniteAnimations =>
      EnvironmentConfig.getConfig().environmentName == 'e2e';

  /// Secure storage enabled (FlutterSecureStorage for encryption keys)
  ///
  /// Controls whether to use platform secure storage (Keychain/Keystore).
  /// Disabled in development to avoid keyring unlock issues on Linux.
  /// When disabled, uses in-memory encryption key (data lost on restart).
  static bool get useSecureStorage =>
      EnvironmentConfig.getConfig().environmentName != 'development';

  /// Feature flag summary for debugging
  ///
  /// Returns a map of all feature flags and their current states.
  /// Useful for debugging configuration issues.
  static Map<String, bool> get flagSummary => {
    'debugMode': debugMode,
    'analyticsEnabled': analyticsEnabled,
    'crashReporting': crashReporting,
    'firebaseEnabled': firebaseEnabled,
    'performanceProfiling': performanceProfiling,
    'mockServicesEnabled': mockServicesEnabled,
    'networkLogging': networkLogging,
    'useExtendedTimeouts': useExtendedTimeouts,
    'disableInfiniteAnimations': disableInfiniteAnimations,
    'useSecureStorage': useSecureStorage,
  };

  /// Log current feature flag configuration
  ///
  /// Outputs the current state of all feature flags to debug console.
  /// Only logs in debug mode to avoid production log pollution.
  static void logConfiguration() {
    if (kDebugMode) {
      AppLogger.info(
        '🚀 FeatureFlags Configuration (${EnvironmentConfig.getConfig().environmentName}):',
      );
      flagSummary.forEach((flag, enabled) {
        final icon = enabled ? '✅' : '❌';
        AppLogger.info('   $icon $flag: $enabled');
      });
    }
  }
}

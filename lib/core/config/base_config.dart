// EduLift Mobile - Base Configuration Interface
// Defines the contract that all environment configurations must implement
// This ensures type safety and consistency across all environments

/// Abstract base configuration interface
///
/// All environment-specific configurations (Development, Staging, E2E, Production)
/// must implement this interface to ensure consistency and type safety.
abstract class BaseConfig {
  /// API Base URL for backend services
  String get apiBaseUrl;

  /// WebSocket URL for real-time communications
  String get websocketUrl;

  /// Mailpit Web URL for email testing (development/E2E only)
  String get mailpitWebUrl;

  /// Mailpit API URL for email testing operations
  String get mailpitApiUrl;

  /// HTTP connection timeout duration
  Duration get connectTimeout;

  /// HTTP receive timeout duration
  Duration get receiveTimeout;

  /// HTTP send timeout duration
  Duration get sendTimeout;

  /// Whether debug mode is enabled (logging, dev tools, etc.)
  bool get debugEnabled;

  /// Application display name
  String get appName;

  /// Environment name (development, staging, e2e, production)
  String get environmentName;

  /// Firebase project configuration enabled
  bool get firebaseEnabled;

  /// Default HTTP headers for API requests
  Map<String, String> get defaultHeaders;

  /// Validate that this configuration has all required values
  /// Returns true if configuration is valid, false otherwise
  bool validate();

  /// Get a summary of configuration for debugging purposes
  Map<String, dynamic> get configSummary;
}

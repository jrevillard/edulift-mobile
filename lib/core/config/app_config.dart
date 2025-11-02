// EduLift Mobile - Environment-Specific Configurations
// Concrete implementations of BaseConfig for each environment
// These define the exact settings for development, staging, E2E, and production
//
// Configuration values are loaded from --dart-define-from-file at build time
// Fallback defaults are provided for development convenience

import 'package:logger/logger.dart';
import 'base_config.dart';

/// Development environment configuration
/// Used for local development with localhost services
///
/// Load from JSON: flutter run --dart-define-from-file=config/development.json
/// Or use defaults: flutter run
class DevelopmentConfig implements BaseConfig {
  @override
  String get apiBaseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3001/api/v1',
  );

  @override
  String get websocketUrl => const String.fromEnvironment(
    'WEBSOCKET_URL',
    defaultValue: 'ws://localhost:3001',
  );

  @override
  String get mailpitWebUrl => const String.fromEnvironment(
    'MAILPIT_WEB_URL',
    defaultValue: 'http://localhost:8025',
  );

  @override
  String get mailpitApiUrl => const String.fromEnvironment(
    'MAILPIT_API_URL',
    defaultValue: 'http://localhost:8025/api/v1',
  );

  @override
  Duration get connectTimeout => const Duration(
    seconds: int.fromEnvironment('CONNECT_TIMEOUT_SECONDS', defaultValue: 10),
  );

  @override
  Duration get receiveTimeout => const Duration(
    seconds: int.fromEnvironment('RECEIVE_TIMEOUT_SECONDS', defaultValue: 15),
  );

  @override
  Duration get sendTimeout => const Duration(
    seconds: int.fromEnvironment('SEND_TIMEOUT_SECONDS', defaultValue: 10),
  );

  @override
  String get logLevel =>
      const String.fromEnvironment('LOG_LEVEL', defaultValue: 'debug');

  @override
  Level get loggerLogLevel {
    switch (logLevel.toLowerCase()) {
      case 'trace':
        return Level.trace;
      case 'debug':
        return Level.debug;
      case 'info':
        return Level.info;
      case 'warning':
        return Level.warning;
      case 'error':
        return Level.error;
      case 'fatal':
        return Level.fatal;
      default:
        return Level.debug; // Default to debug for development
    }
  }

  @override
  String get appName =>
      const String.fromEnvironment('APP_NAME', defaultValue: 'EduLift Dev');

  @override
  String get environmentName => const String.fromEnvironment(
    'ENVIRONMENT_NAME',
    defaultValue: 'development',
  );

  @override
  bool get firebaseEnabled => const bool.fromEnvironment('FIREBASE_ENABLED');

  @override
  Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'API-Version': 'v1',
  };

  @override
  bool validate() {
    try {
      final apiUri = Uri.tryParse(apiBaseUrl);
      final wsUri = Uri.tryParse(websocketUrl);
      final mailpitUri = Uri.tryParse(mailpitWebUrl);

      return apiUri != null &&
          wsUri != null &&
          mailpitUri != null &&
          ['http', 'https'].contains(apiUri.scheme) &&
          ['ws', 'wss'].contains(wsUri.scheme) &&
          ['http', 'https'].contains(mailpitUri.scheme);
    } catch (e) {
      return false;
    }
  }

  @override
  Map<String, dynamic> get configSummary => {
    'environment': environmentName,
    'appName': appName,
    'apiBaseUrl': apiBaseUrl,
    'websocketUrl': websocketUrl,
    'mailpitWebUrl': mailpitWebUrl,
    'mailpitApiUrl': mailpitApiUrl,
    'logLevel': logLevel,
    'firebaseEnabled': firebaseEnabled,
    'connectTimeout': connectTimeout.inSeconds,
    'receiveTimeout': receiveTimeout.inSeconds,
    'sendTimeout': sendTimeout.inSeconds,
  };
}

/// Staging environment configuration
/// Used for pre-production testing (currently points to production backend)
///
/// Load from JSON: flutter build apk --dart-define-from-file=config/staging.json
class StagingConfig implements BaseConfig {
  @override
  String get apiBaseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://transport.tanjama.fr/api',
  );

  @override
  String get websocketUrl => const String.fromEnvironment(
    'WEBSOCKET_URL',
    defaultValue: 'wss://transport.tanjama.fr/api',
  );

  @override
  String get mailpitWebUrl => const String.fromEnvironment(
    'MAILPIT_WEB_URL',
    defaultValue: 'http://localhost:8025',
  );

  @override
  String get mailpitApiUrl => const String.fromEnvironment(
    'MAILPIT_API_URL',
    defaultValue: 'http://localhost:8025/api/v1',
  );

  @override
  Duration get connectTimeout => const Duration(
    seconds: int.fromEnvironment('CONNECT_TIMEOUT_SECONDS', defaultValue: 5),
  );

  @override
  Duration get receiveTimeout => const Duration(
    seconds: int.fromEnvironment('RECEIVE_TIMEOUT_SECONDS', defaultValue: 10),
  );

  @override
  Duration get sendTimeout => const Duration(
    seconds: int.fromEnvironment('SEND_TIMEOUT_SECONDS', defaultValue: 10),
  );

  @override
  String get logLevel =>
      const String.fromEnvironment('LOG_LEVEL', defaultValue: 'info');

  @override
  Level get loggerLogLevel {
    switch (logLevel.toLowerCase()) {
      case 'trace':
        return Level.trace;
      case 'debug':
        return Level.debug;
      case 'info':
        return Level.info;
      case 'warning':
        return Level.warning;
      case 'error':
        return Level.error;
      case 'fatal':
        return Level.fatal;
      default:
        return Level.info; // Default to info for staging
    }
  }

  @override
  String get appName =>
      const String.fromEnvironment('APP_NAME', defaultValue: 'EduLift Staging');

  @override
  String get environmentName =>
      const String.fromEnvironment('ENVIRONMENT_NAME', defaultValue: 'staging');

  @override
  bool get firebaseEnabled =>
      const bool.fromEnvironment('FIREBASE_ENABLED', defaultValue: true);

  @override
  Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'API-Version': 'v1',
  };

  @override
  bool validate() {
    try {
      final apiUri = Uri.tryParse(apiBaseUrl);
      final wsUri = Uri.tryParse(websocketUrl);

      return apiUri != null &&
          wsUri != null &&
          ['https'].contains(apiUri.scheme) &&
          ['wss'].contains(wsUri.scheme);
    } catch (e) {
      return false;
    }
  }

  @override
  Map<String, dynamic> get configSummary => {
    'environment': environmentName,
    'appName': appName,
    'apiBaseUrl': apiBaseUrl,
    'websocketUrl': websocketUrl,
    'logLevel': logLevel,
    'firebaseEnabled': firebaseEnabled,
    'connectTimeout': connectTimeout.inSeconds,
    'receiveTimeout': receiveTimeout.inSeconds,
    'sendTimeout': sendTimeout.inSeconds,
  };
}

/// E2E testing environment configuration
/// Used for automated integration testing with Docker services on Android emulator
///
/// Load from JSON: flutter build apk --dart-define-from-file=config/e2e.json
/// Android emulator uses 10.0.2.2 to access host machine's localhost
class E2EConfig implements BaseConfig {
  @override
  String get apiBaseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8030/api/v1',
  );

  @override
  String get websocketUrl => const String.fromEnvironment(
    'WEBSOCKET_URL',
    defaultValue: 'ws://10.0.2.2:8030',
  );

  @override
  String get mailpitWebUrl => const String.fromEnvironment(
    'MAILPIT_WEB_URL',
    defaultValue: 'http://10.0.2.2:8031',
  );

  @override
  String get mailpitApiUrl => const String.fromEnvironment(
    'MAILPIT_API_URL',
    defaultValue: 'http://10.0.2.2:8031/api/v1',
  );

  @override
  Duration get connectTimeout => const Duration(
    seconds: int.fromEnvironment('CONNECT_TIMEOUT_SECONDS', defaultValue: 5),
  );

  @override
  Duration get receiveTimeout => const Duration(
    seconds: int.fromEnvironment('RECEIVE_TIMEOUT_SECONDS', defaultValue: 8),
  );

  @override
  Duration get sendTimeout => const Duration(
    seconds: int.fromEnvironment('SEND_TIMEOUT_SECONDS', defaultValue: 5),
  );

  @override
  String get logLevel =>
      const String.fromEnvironment('LOG_LEVEL', defaultValue: 'debug');

  @override
  Level get loggerLogLevel {
    switch (logLevel.toLowerCase()) {
      case 'trace':
        return Level.trace;
      case 'debug':
        return Level.debug;
      case 'info':
        return Level.info;
      case 'warning':
        return Level.warning;
      case 'error':
        return Level.error;
      case 'fatal':
        return Level.fatal;
      default:
        return Level.debug; // Default to debug for E2E testing
    }
  }

  @override
  String get appName =>
      const String.fromEnvironment('APP_NAME', defaultValue: 'EduLift E2E');

  @override
  String get environmentName =>
      const String.fromEnvironment('ENVIRONMENT_NAME', defaultValue: 'e2e');

  @override
  bool get firebaseEnabled => const bool.fromEnvironment('FIREBASE_ENABLED');

  @override
  Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'API-Version': 'v1',
  };

  @override
  bool validate() {
    try {
      final apiUri = Uri.tryParse(apiBaseUrl);
      final wsUri = Uri.tryParse(websocketUrl);
      final mailpitUri = Uri.tryParse(mailpitWebUrl);

      return apiUri != null &&
          wsUri != null &&
          mailpitUri != null &&
          ['http'].contains(apiUri.scheme) && // E2E uses HTTP (not HTTPS)
          ['ws'].contains(wsUri.scheme) && // E2E uses WS (not WSS)
          ['http'].contains(mailpitUri.scheme);
    } catch (e) {
      return false;
    }
  }

  @override
  Map<String, dynamic> get configSummary => {
    'environment': environmentName,
    'appName': appName,
    'apiBaseUrl': apiBaseUrl,
    'websocketUrl': websocketUrl,
    'mailpitWebUrl': mailpitWebUrl,
    'mailpitApiUrl': mailpitApiUrl,
    'logLevel': logLevel,
    'firebaseEnabled': firebaseEnabled,
    'connectTimeout': connectTimeout.inSeconds,
    'receiveTimeout': receiveTimeout.inSeconds,
    'sendTimeout': sendTimeout.inSeconds,
  };
}

/// Production environment configuration
/// Used for the live application with production services
///
/// Load from JSON: flutter build apk --dart-define-from-file=config/production.json
/// Production values: API at https://transport.tanjama.fr/api
class ProductionConfig implements BaseConfig {
  @override
  String get apiBaseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://transport.tanjama.fr/api',
  );

  @override
  String get websocketUrl => const String.fromEnvironment(
    'WEBSOCKET_URL',
    defaultValue: 'wss://transport.tanjama.fr/api',
  );

  @override
  String get mailpitWebUrl => const String.fromEnvironment(
    'MAILPIT_WEB_URL',
    defaultValue: 'http://localhost:8025',
  );

  @override
  String get mailpitApiUrl => const String.fromEnvironment(
    'MAILPIT_API_URL',
    defaultValue: 'http://localhost:8025/api/v1',
  );

  @override
  Duration get connectTimeout => const Duration(
    seconds: int.fromEnvironment('CONNECT_TIMEOUT_SECONDS', defaultValue: 5),
  );

  @override
  Duration get receiveTimeout => const Duration(
    seconds: int.fromEnvironment('RECEIVE_TIMEOUT_SECONDS', defaultValue: 10),
  );

  @override
  Duration get sendTimeout => const Duration(
    seconds: int.fromEnvironment('SEND_TIMEOUT_SECONDS', defaultValue: 10),
  );

  @override
  String get logLevel =>
      const String.fromEnvironment('LOG_LEVEL', defaultValue: 'warning');

  @override
  Level get loggerLogLevel {
    switch (logLevel.toLowerCase()) {
      case 'trace':
        return Level.trace;
      case 'debug':
        return Level.debug;
      case 'info':
        return Level.info;
      case 'warning':
        return Level.warning;
      case 'error':
        return Level.error;
      case 'fatal':
        return Level.fatal;
      default:
        return Level.warning; // Default to warning for production
    }
  }

  @override
  String get appName =>
      const String.fromEnvironment('APP_NAME', defaultValue: 'EduLift');

  @override
  String get environmentName => const String.fromEnvironment(
    'ENVIRONMENT_NAME',
    defaultValue: 'production',
  );

  @override
  bool get firebaseEnabled =>
      const bool.fromEnvironment('FIREBASE_ENABLED', defaultValue: true);

  @override
  Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'API-Version': 'v1',
  };

  @override
  bool validate() {
    try {
      final apiUri = Uri.tryParse(apiBaseUrl);
      final wsUri = Uri.tryParse(websocketUrl);

      return apiUri != null &&
          wsUri != null &&
          ['https'].contains(apiUri.scheme) &&
          ['wss'].contains(wsUri.scheme);
    } catch (e) {
      return false;
    }
  }

  @override
  Map<String, dynamic> get configSummary => {
    'environment': environmentName,
    'appName': appName,
    'apiBaseUrl': apiBaseUrl,
    'websocketUrl': websocketUrl,
    'logLevel': logLevel,
    'firebaseEnabled': firebaseEnabled,
    'connectTimeout': connectTimeout.inSeconds,
    'receiveTimeout': receiveTimeout.inSeconds,
    'sendTimeout': sendTimeout.inSeconds,
  };
}

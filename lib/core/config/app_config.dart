// EduLift Mobile - Environment-Specific Configurations
// Concrete implementations of BaseConfig for each environment
// These define the exact settings for development, staging, E2E, and production

import 'base_config.dart';

/// Development environment configuration
/// Used for local development with localhost services
class DevelopmentConfig implements BaseConfig {
  @override
  String get apiBaseUrl => 'http://localhost:3001/api/v1';

  @override
  String get websocketUrl => 'ws://localhost:3001';

  @override
  String get mailpitWebUrl => 'http://localhost:8025';

  @override
  String get mailpitApiUrl => '$mailpitWebUrl/api/v1';

  @override
  Duration get connectTimeout => const Duration(seconds: 10);

  @override
  Duration get receiveTimeout => const Duration(seconds: 15);

  @override
  Duration get sendTimeout => const Duration(seconds: 10);

  @override
  bool get debugEnabled => true;

  @override
  String get appName => 'EduLift Dev';

  @override
  String get environmentName => 'development';

  @override
  bool get firebaseEnabled => false;

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
    'debugEnabled': debugEnabled,
    'firebaseEnabled': firebaseEnabled,
    'connectTimeout': connectTimeout.inSeconds,
    'receiveTimeout': receiveTimeout.inSeconds,
  };
}

/// Staging environment configuration
/// Used for pre-production testing with staging services
class StagingConfig implements BaseConfig {
  @override
  String get apiBaseUrl => 'https://staging-api.edulift.com/api/v1';

  @override
  String get websocketUrl => 'wss://staging-api.edulift.com';

  @override
  String get mailpitWebUrl => 'http://localhost:8025'; // Not used in staging

  @override
  String get mailpitApiUrl => '$mailpitWebUrl/api/v1';

  @override
  Duration get connectTimeout => const Duration(seconds: 10);

  @override
  Duration get receiveTimeout => const Duration(seconds: 15);

  @override
  Duration get sendTimeout => const Duration(seconds: 10);

  @override
  bool get debugEnabled => true;

  @override
  String get appName => 'EduLift Staging';

  @override
  String get environmentName => 'staging';

  @override
  bool get firebaseEnabled => true;

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
    'debugEnabled': debugEnabled,
    'firebaseEnabled': firebaseEnabled,
    'connectTimeout': connectTimeout.inSeconds,
    'receiveTimeout': receiveTimeout.inSeconds,
  };
}

/// E2E testing environment configuration
/// Used for automated integration testing with Docker services on Android emulator
class E2EConfig implements BaseConfig {
  @override
  String get apiBaseUrl => 'http://10.0.2.2:8030/api/v1'; // Android emulator special IP to host

  @override
  String get websocketUrl => 'ws://10.0.2.2:8030'; // Android emulator special IP to host

  @override
  String get mailpitWebUrl => 'http://10.0.2.2:8031'; // Android emulator special IP to host

  @override
  String get mailpitApiUrl => '$mailpitWebUrl/api/v1';

  @override
  Duration get connectTimeout => const Duration(seconds: 5);
  @override
  Duration get receiveTimeout => const Duration(seconds: 8);

  @override
  Duration get sendTimeout => const Duration(seconds: 5);

  @override
  bool get debugEnabled => true;

  @override
  String get appName => 'EduLift E2E';

  @override
  String get environmentName => 'e2e';

  @override
  bool get firebaseEnabled => false; // Skip Firebase in E2E tests

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
    'debugEnabled': debugEnabled,
    'firebaseEnabled': firebaseEnabled,
    'connectTimeout': connectTimeout.inSeconds,
    'receiveTimeout': receiveTimeout.inSeconds,
  };
}

/// Production environment configuration
/// Used for the live application with production services
class ProductionConfig implements BaseConfig {
  @override
  String get apiBaseUrl => 'https://api.edulift.com/api/v1';

  @override
  String get websocketUrl => 'wss://api.edulift.com';

  @override
  String get mailpitWebUrl => 'http://localhost:8025'; // Not used in production

  @override
  String get mailpitApiUrl => '$mailpitWebUrl/api/v1';

  @override
  Duration get connectTimeout => const Duration(seconds: 10);

  @override
  Duration get receiveTimeout => const Duration(seconds: 15);

  @override
  Duration get sendTimeout => const Duration(seconds: 10);

  @override
  bool get debugEnabled => false; // No debug in production

  @override
  String get appName => 'EduLift';

  @override
  String get environmentName => 'production';

  @override
  bool get firebaseEnabled => true;

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
    'debugEnabled': debugEnabled,
    'firebaseEnabled': firebaseEnabled,
    'connectTimeout': connectTimeout.inSeconds,
    'receiveTimeout': receiveTimeout.inSeconds,
  };
}

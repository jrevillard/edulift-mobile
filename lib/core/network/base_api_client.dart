// EduLift Mobile - Base API Client (Pure Abstraction)
// CLEAN ARCHITECTURE ABSTRACTION LAYER
// NO infrastructure dependencies

import 'api_client_interface.dart';

/// Base API client providing shared functionality for all domain-specific clients
/// Pure abstraction - no infrastructure dependencies
abstract class BaseApiClient implements ApiClientInterface {
  /// Base URL for all API requests
  String get baseUrl;

  /// Common headers for all requests
  Map<String, String> get defaultHeaders;

  /// Initialize the client with configuration
  Future<void> initialize();

  /// Clean up resources
  Future<void> dispose();

  /// Check if client is authenticated
  bool get isAuthenticated;
}

/// Abstract configuration for API clients
abstract class ApiConfiguration {
  String get baseUrl;
  Duration get timeout;
  Map<String, String> get defaultHeaders;
  bool get enableLogging;
}

/// Abstract error handler for API responses
abstract class ApiErrorHandler {
  Exception handleError(int statusCode, String message);
  bool shouldRetry(Exception error);
}

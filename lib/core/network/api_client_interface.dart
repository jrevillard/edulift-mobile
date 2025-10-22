// EduLift Mobile - API Client Interface (Pure Abstraction)
// CLEAN ARCHITECTURE DOMAIN INTERFACE
// NO infrastructure dependencies - pure interface

/// Abstract interface for API clients
/// Domain layer can depend on this without importing infrastructure packages
abstract class ApiClientInterface {
  /// Performs a GET request
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? params});

  /// Performs a POST request
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data});

  /// Performs a PUT request
  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? data});

  /// Performs a DELETE request
  Future<Map<String, dynamic>> delete(String path);
}

/// Abstract interface for authentication tokens
abstract class TokenProvider {
  Future<String?> getAccessToken();
  Future<void> setAccessToken(String token);
  Future<void> clearTokens();
}

/// Abstract interface for request interceptors
abstract class RequestInterceptor {
  void onRequest(Map<String, dynamic> requestData);
  void onResponse(Map<String, dynamic> responseData);
  void onError(Exception error);
}

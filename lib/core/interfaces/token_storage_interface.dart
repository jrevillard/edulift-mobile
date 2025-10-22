// EduLift Mobile - Token Storage Interface (Core/Interfaces Layer)
// Shared interface that can be used by both domain and infrastructure layers

/// Token storage interface for authentication tokens
/// Defined in core/interfaces to be usable by both domain and infrastructure
abstract interface class TokenStorageInterface {
  /// Store authentication token securely
  Future<void> storeToken(String token);

  /// Retrieve stored authentication token
  Future<String?> getToken();

  /// Clear stored authentication token
  Future<void> clearToken();

  /// Check if authentication token exists
  Future<bool> hasToken();
}

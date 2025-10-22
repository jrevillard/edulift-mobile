// EduLift Mobile - Secure Storage Service (Domain Layer)
// Abstract interface for secure storage operations

import 'dart:async';

/// Secure storage service interface for sensitive data
/// This belongs in the domain layer as it defines business rules for secure storage
abstract class SecureStorageService {
  /// Store a secure value
  Future<void> store(String key, String value);

  /// Retrieve a secure value
  Future<String?> retrieve(String key);

  /// Delete a secure value
  Future<void> delete(String key);

  /// Clear all secure values
  Future<void> clear();

  /// Check if a key exists
  Future<bool> containsKey(String key);
}

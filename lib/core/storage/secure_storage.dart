/// Abstract interface for secure storage operations
///
/// This abstraction allows us to:
/// - Unit test code that depends on secure storage
/// - Switch implementations if needed
/// - Mock storage behavior in tests
abstract class SecureStorage {
  /// Read a value from secure storage
  Future<String?> read({required String key});

  /// Write a value to secure storage
  Future<void> write({required String key, required String value});

  /// Delete a value from secure storage
  Future<void> delete({required String key});

  /// Clear all values from secure storage
  Future<void> deleteAll();
}

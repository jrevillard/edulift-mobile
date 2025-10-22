import 'package:edulift/core/storage/secure_storage.dart';

// This is a fake/helper file, not a test file
void main() {
  // Fake implementations - no tests in this file
}

/// Fake implementation of SecureStorage for testing
///
/// This provides an in-memory implementation that behaves like real secure storage
/// but doesn't require platform channels. Perfect for unit tests.
class FakeSecureStorage implements SecureStorage {
  final Map<String, String> _storage = {};

  /// Optional error simulation - if set, read operations will throw this error
  Exception? _simulatedError;

  @override
  Future<String?> read({required String key}) async {
    if (_simulatedError != null) {
      throw _simulatedError!;
    }
    return _storage[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    if (_simulatedError != null) {
      throw _simulatedError!;
    }
    _storage[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    if (_simulatedError != null) {
      throw _simulatedError!;
    }
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    if (_simulatedError != null) {
      throw _simulatedError!;
    }
    _storage.clear();
  }

  // Test helpers

  /// Clear all stored values (for test setup/teardown)
  void clear() {
    _storage.clear();
    _simulatedError = null;
  }

  /// Simulate storage errors for testing error handling
  void simulateError(Exception error) {
    _simulatedError = error;
  }

  /// Stop simulating errors
  void clearError() {
    _simulatedError = null;
  }

  /// Check if a key exists (useful for test assertions)
  bool containsKey(String key) {
    return _storage.containsKey(key);
  }

  /// Get all stored keys (useful for test assertions)
  Set<String> get keys => _storage.keys.toSet();
}

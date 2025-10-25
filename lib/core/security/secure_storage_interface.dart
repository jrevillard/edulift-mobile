/// Interface for secure storage operations with comprehensive documentation
///
/// This interface defines the contract for secure storage services, providing
/// type-safe operations with proper error handling using the Result pattern.
///
/// Design Principles:
/// - All operations return Result<T, StorageException> for type-safe error handling
/// - Methods are clearly categorized by functionality (tokens, user data, biometrics, etc.)
/// - Interface segregation principle applied for focused responsibilities
/// - Comprehensive documentation for all public methods
/// - Async operations for non-blocking I/O

import '../utils/result.dart';
import '../errors/exceptions.dart';

/// Primary interface for secure storage operations
///
/// Implementations should provide:
/// - Encrypted storage for sensitive data
/// - Secure key management
/// - Cross-platform compatibility
/// - Atomic operations where possible
/// - Proper error context in exceptions
abstract class SecureStorageInterface {
  // ========== TOKEN MANAGEMENT ==========

  /// Store authentication token securely with encryption
  ///
  /// The token is encrypted using the device's master encryption key
  /// and stored atomically to prevent partial failures.
  ///
  /// Returns:
  /// - [Result.ok] on successful storage
  /// - [Result.err] with [StorageException] on failure
  Future<Result<void, StorageException>> storeToken(String token);

  /// Retrieve the stored token
  ///
  /// Automatically decrypts the token if encryption is enabled.
  /// Returns null if no token is stored or decryption fails.
  ///
  /// Returns:
  /// - [Result.ok] with token string or null if not found
  /// - [Result.err] with [StorageException] on storage errors
  Future<Result<String?, StorageException>> getToken();

  /// Clear stored authentication token
  ///
  /// This operation is atomic.
  ///
  /// Returns:
  /// - [Result.ok] on successful clearing
  /// - [Result.err] with [StorageException] on failure
  Future<Result<void, StorageException>> clearToken();

  /// Check if authentication token is stored
  ///
  /// This is a convenience method for authentication state checking.
  ///
  /// Returns:
  /// - [Result.ok] with true if token exists, false otherwise
  /// - [Result.err] with [StorageException] on storage errors
  Future<Result<bool, StorageException>> hasStoredToken();

  // ========== USER DATA MANAGEMENT ==========

  /// Store user data with encryption
  ///
  /// User data is automatically encrypted before storage.
  /// Pass null to clear existing user data.
  ///
  /// Parameters:
  /// - [userData]: JSON string or null to clear
  ///
  /// Returns:
  /// - [Result.ok] on successful storage
  /// - [Result.err] with [StorageException] on failure
  Future<Result<void, StorageException>> storeUserData(String? userData);

  /// Retrieve stored user data
  ///
  /// Automatically decrypts the data if encryption is enabled.
  /// Returns null if no data is stored or decryption fails.
  ///
  /// Returns:
  /// - [Result.ok] with user data string or null if not found
  /// - [Result.err] with [StorageException] on storage errors
  Future<Result<String?, StorageException>> getUserData();

  /// Clear all stored user data
  ///
  /// This includes both primary user data and legacy data entries.
  ///
  /// Returns:
  /// - [Result.ok] on successful clearing
  /// - [Result.err] with [StorageException] on failure
  Future<Result<void, StorageException>> clearUserData();

  /// Get stored user ID
  ///
  /// Convenience method for retrieving the user's ID from legacy storage.
  ///
  /// Returns:
  /// - [Result.ok] with user ID string or null if not found
  /// - [Result.err] with [StorageException] on storage errors
  Future<Result<String?, StorageException>> getUserId();

  // ========== BIOMETRIC SETTINGS ==========

  /// Set biometric authentication enabled flag
  ///
  /// This preference controls whether biometric authentication is available
  /// for the user in the application.
  ///
  /// Parameters:
  /// - [enabled]: true to enable biometric auth, false to disable
  ///
  /// Returns:
  /// - [Result.ok] on successful storage
  /// - [Result.err] with [StorageException] on failure
  Future<Result<void, StorageException>> setBiometricEnabled(bool enabled);

  /// Get biometric authentication enabled flag
  ///
  /// Returns the current biometric authentication preference.
  /// Defaults to false if not previously set.
  ///
  /// Returns:
  /// - [Result.ok] with boolean preference
  /// - [Result.err] with [StorageException] on storage errors
  Future<Result<bool, StorageException>> getBiometricEnabled();

  /// Store email for biometric authentication
  ///
  /// This email is used for biometric login scenarios.
  /// The email is encrypted before storage.
  ///
  /// Parameters:
  /// - [email]: user's email address
  ///
  /// Returns:
  /// - [Result.ok] on successful storage
  /// - [Result.err] with [StorageException] on failure
  Future<Result<void, StorageException>> storeEmail(String email);

  /// Get stored email for biometric authentication
  ///
  /// Retrieves and decrypts the stored email address.
  ///
  /// Returns:
  /// - [Result.ok] with email string or null if not found
  /// - [Result.err] with [StorageException] on storage errors
  Future<Result<String?, StorageException>> getStoredEmail();

  // ========== GENERIC STORAGE OPERATIONS ==========

  /// Store arbitrary data with encryption
  ///
  /// Generic storage method for any key-value data.
  /// Data is automatically encrypted before storage.
  ///
  /// Parameters:
  /// - [key]: storage key identifier
  /// - [value]: data to store
  ///
  /// Returns:
  /// - [Result.ok] on successful storage
  /// - [Result.err] with [StorageException] on failure
  Future<Result<void, StorageException>> store(String key, String value);

  /// Read arbitrary data with decryption
  ///
  /// Generic retrieval method for any stored data.
  /// Data is automatically decrypted after retrieval.
  ///
  /// Parameters:
  /// - [key]: storage key identifier
  ///
  /// Returns:
  /// - [Result.ok] with data string or null if not found
  /// - [Result.err] with [StorageException] on storage errors
  Future<Result<String?, StorageException>> read(String key);

  /// Delete data by key
  ///
  /// Removes the specified key-value pair from storage.
  ///
  /// Parameters:
  /// - [key]: storage key identifier
  ///
  /// Returns:
  /// - [Result.ok] on successful deletion
  /// - [Result.err] with [StorageException] on failure
  Future<Result<void, StorageException>> delete(String key);

  /// Check if a key exists in storage
  ///
  /// This method checks for key existence without retrieving the value.
  ///
  /// Parameters:
  /// - [key]: storage key identifier
  ///
  /// Returns:
  /// - [Result.ok] with true if key exists, false otherwise
  /// - [Result.err] with [StorageException] on storage errors
  Future<Result<bool, StorageException>> containsKey(String key);

  /// Clear all stored data
  ///
  /// WARNING: This operation removes ALL data from secure storage.
  /// Use with extreme caution.
  ///
  /// Returns:
  /// - [Result.ok] on successful clearing
  /// - [Result.err] with [StorageException] on failure
  Future<Result<void, StorageException>> clearAll();

  /// Get all stored keys and values
  ///
  /// Returns a map of all stored data. Values are decrypted automatically.
  /// This method should be used sparingly due to performance implications.
  ///
  /// Returns:
  /// - [Result.ok] with Map<String, String> of all data
  /// - [Result.err] with [StorageException] on storage errors
  Future<Result<Map<String, String>, StorageException>> readAll();

  // ========== UTILITY METHODS ==========

  /// Check if secure storage is available and functional
  ///
  /// This method performs a basic functionality test to ensure
  /// the storage system is working correctly.
  ///
  /// Returns:
  /// - [Result.ok] with true if storage is available, false otherwise
  /// - [Result.err] with [StorageException] on system errors
  Future<Result<bool, StorageException>> isStorageAvailable();

  /// Get storage performance metrics
  ///
  /// Returns basic performance information about the storage system.
  /// This can be useful for monitoring and optimization.
  ///
  /// Returns:
  /// - [Result.ok] with performance metrics map
  /// - [Result.err] with [StorageException] on errors
  Future<Result<Map<String, dynamic>, StorageException>>
      getPerformanceMetrics();
}

/// Interface for managing storage-related settings and configuration
///
/// This interface provides methods for configuring the storage system
/// behavior and preferences.
abstract class StorageConfigInterface {
  /// Set encryption enabled/disabled
  ///
  /// This controls whether new data should be encrypted.
  /// Existing encrypted data remains encrypted regardless of this setting.
  ///
  /// Parameters:
  /// - [enabled]: true to enable encryption for new data
  ///
  /// Returns:
  /// - [Result.ok] on successful configuration
  /// - [Result.err] with [StorageException] on failure
  Future<Result<void, StorageException>> setEncryptionEnabled(bool enabled);

  /// Check if encryption is currently enabled
  ///
  /// Returns:
  /// - [Result.ok] with current encryption setting
  /// - [Result.err] with [StorageException] on errors
  Future<Result<bool, StorageException>> isEncryptionEnabled();

  /// Configure storage-specific options
  ///
  /// Allows setting platform-specific storage options such as:
  /// - iOS keychain accessibility levels
  /// - Android encryption requirements
  /// - Custom storage paths
  ///
  /// Parameters:
  /// - [options]: Map of configuration options
  ///
  /// Returns:
  /// - [Result.ok] on successful configuration
  /// - [Result.err] with [StorageException] on failure
  Future<Result<void, StorageException>> configureOptions(
    Map<String, dynamic> options,
  );
}

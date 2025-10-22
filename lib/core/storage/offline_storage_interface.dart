/// Storage interface for offline sync operations
/// Abstracts the underlying storage implementation (Hive, SQLite, etc.)
abstract class OfflineStorageInterface {
  /// Store a change in the offline queue
  Future<void> storeChange(String id, String changeData);

  /// Retrieve a specific change by ID
  Future<String?> getChange(String id);

  /// Get all stored changes
  Future<Map<String, String>> getAllChanges();

  /// Remove a change from storage
  Future<void> removeChange(String id);

  /// Clear all changes
  Future<void> clearAllChanges();

  /// Store metadata (last sync time, etc.)
  Future<void> storeMetadata(String key, String value);

  /// Retrieve metadata
  Future<String?> getMetadata(String key);

  /// Check if storage is available and initialized
  Future<bool> isInitialized();
}

/// Metadata storage interface for sync-related settings
abstract class MetadataStorageInterface {
  /// Store a metadata value
  Future<void> store(String key, String value);

  /// Retrieve a metadata value
  Future<String?> retrieve(String key);

  /// Check if key exists
  Future<bool> contains(String key);

  /// Remove a metadata entry
  Future<void> remove(String key);
}

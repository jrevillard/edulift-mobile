import 'package:hive_ce_flutter/hive_flutter.dart';
import 'offline_storage_interface.dart';

/// Production implementation of OfflineStorageInterface using Hive

class HiveOfflineStorage implements OfflineStorageInterface {
  late Box<String> _changesBox;
  late Box<String> _metadataBox;
  bool _isInitialized = false;

  /// Initialize Hive boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    _changesBox = await Hive.openBox<String>('offline_sync');
    _metadataBox = await Hive.openBox<String>('settings');
    _isInitialized = true;
  }

  @override
  Future<void> storeChange(String id, String changeData) async {
    await _ensureInitialized();
    await _changesBox.put(id, changeData);
  }

  @override
  Future<String?> getChange(String id) async {
    await _ensureInitialized();
    return _changesBox.get(id);
  }

  @override
  Future<Map<String, String>> getAllChanges() async {
    await _ensureInitialized();
    final changes = <String, String>{};

    for (final key in _changesBox.keys) {
      final value = _changesBox.get(key);
      if (value != null) {
        changes[key.toString()] = value;
      }
    }

    return changes;
  }

  @override
  Future<void> removeChange(String id) async {
    await _ensureInitialized();
    await _changesBox.delete(id);
  }

  @override
  Future<void> clearAllChanges() async {
    await _ensureInitialized();
    await _changesBox.clear();
  }

  @override
  Future<void> storeMetadata(String key, String value) async {
    await _ensureInitialized();
    await _metadataBox.put(key, value);
  }

  @override
  Future<String?> getMetadata(String key) async {
    await _ensureInitialized();
    return _metadataBox.get(key);
  }

  @override
  Future<bool> isInitialized() async {
    return _isInitialized;
  }

  /// Ensure boxes are initialized before operations
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
}

/// Production implementation of MetadataStorageInterface using Hive

class HiveMetadataStorage implements MetadataStorageInterface {
  late Box<String> _metadataBox;
  bool _isInitialized = false;

  /// Initialize Hive box
  Future<void> initialize() async {
    if (_isInitialized) return;

    _metadataBox = await Hive.openBox<String>('sync_metadata');
    _isInitialized = true;
  }

  @override
  Future<void> store(String key, String value) async {
    await _ensureInitialized();
    await _metadataBox.put(key, value);
  }

  @override
  Future<String?> retrieve(String key) async {
    await _ensureInitialized();
    return _metadataBox.get(key);
  }

  @override
  Future<bool> contains(String key) async {
    await _ensureInitialized();
    return _metadataBox.containsKey(key);
  }

  @override
  Future<void> remove(String key) async {
    await _ensureInitialized();
    await _metadataBox.delete(key);
  }

  /// Ensure box is initialized before operations
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
}

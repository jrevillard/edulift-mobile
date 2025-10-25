// EduLift Mobile - HiveOrchestrator Foundation
// Strangler Fig Pattern Step 1: Centralized Hive management with domain-specific boxes
// Following 2024 best practices for multiple Hive boxes with clean lifecycle management

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform, Directory;
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../security/secure_key_manager.dart';

/// Domain-specific box names following expert recommendations
class HiveBoxNames {
  static const String familyBox = 'family_box';
  static const String childrenBox = 'children_box';
  static const String vehicleBox = 'vehicle_box';
  static const String scheduleBox = 'schedule_box';
  static const String syncBox = 'sync_box';
  static const String idMappingsBox = 'id_mappings_box';
}

/// Centralized Hive orchestrator implementing Strangler Fig Pattern
/// Manages all domain-specific boxes with clean initialization and lifecycle management

class HiveOrchestrator {
  // Domain-specific boxes
  Box<Map>? _familyBox;
  Box<Map>? _childrenBox;
  Box<Map>? _vehicleBox;
  Box<Map>? _scheduleBox;
  Box<Map>? _syncBox;
  Box<Map>? _idMappingsBox;

  bool _isInitialized = false;
  final Completer<void> _initCompleter = Completer<void>();
  final SecureKeyManager _keyManager;

  HiveOrchestrator(this._keyManager);

  /// Initialize Hive with fallback for Linux development environments
  Future<void> _initializeHiveWithFallback() async {
    try {
      await Hive.initFlutter();
    } catch (e) {
      developer.log(
        'Hive.initFlutter() failed: $e. Using fallback directory.',
        name: 'HiveOrchestrator',
      );

      // Fallback: Use a local directory for development
      String fallbackPath;
      if (Platform.isLinux || Platform.isMacOS) {
        // Use home directory fallback for Linux/macOS development
        final homeDir = Platform.environment['HOME'] ?? '/tmp';
        fallbackPath = '$homeDir/.mobile_app_hive';
      } else if (Platform.isWindows) {
        final homeDir =
            Platform.environment['USERPROFILE'] ??
            Platform.environment['HOMEPATH'] ??
            'C:\\temp';
        fallbackPath = '$homeDir\\.mobile_app_hive';
      } else {
        fallbackPath = '/tmp/mobile_app_hive';
      }

      // Create directory if it doesn't exist
      final dir = Directory(fallbackPath);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      developer.log(
        'Using fallback Hive directory: $fallbackPath',
        name: 'HiveOrchestrator',
      );

      Hive.init(fallbackPath);
    }
  }

  /// Initialize Hive and all domain-specific boxes
  /// Following expert guidance: Start with regular Box, consider LazyBox for large datasets later
  Future<void> initialize({
    String? customPath,
    bool enableEncryption = true,
  }) async {
    if (_isInitialized) {
      await _initCompleter.future;
      return;
    }

    try {
      developer.log(
        'Initializing HiveOrchestrator with ${enableEncryption ? 'encryption enabled' : 'encryption disabled'}',
        name: 'HiveOrchestrator',
      );

      // Initialize Hive with proper path and Linux fallback
      if (customPath != null) {
        Hive.init(customPath);
      } else {
        await _initializeHiveWithFallback();
      }

      // Register TypeAdapters centrally
      await _registerTypeAdapters();

      // Open domain-specific boxes with proper error boundaries
      await _openDomainBoxes(enableEncryption);

      // Setup ID mappings box with TTL capability
      await _setupIdMappingsBox();

      _isInitialized = true;
      _initCompleter.complete();

      developer.log(
        'HiveOrchestrator initialization completed successfully',
        name: 'HiveOrchestrator',
      );
    } catch (error, stackTrace) {
      developer.log(
        'HiveOrchestrator initialization failed',
        name: 'HiveOrchestrator',
        error: error,
        stackTrace: stackTrace,
      );
      _initCompleter.completeError(error, stackTrace);
      rethrow;
    }
  }

  /// Register all TypeAdapters centrally
  /// Following 2024 best practices for centralized adapter management
  Future<void> _registerTypeAdapters() async {
    // TODO: Register domain-specific TypeAdapters here
    // This will be implemented in subsequent phases of the Strangler Fig Pattern
    // Examples:
    // if (!Hive.isAdapterRegistered(0)) {
    //   Hive.registerAdapter(FamilyAdapter());
    // }
    // if (!Hive.isAdapterRegistered(1)) {
    //   Hive.registerAdapter(ChildAdapter());
    // }
    developer.log(
      'TypeAdapter registration placeholder - will be implemented in phase 2',
      name: 'HiveOrchestrator',
    );
  }

  /// Open all domain-specific boxes with proper error handling
  Future<void> _openDomainBoxes(bool enableEncryption) async {
    final encryptionKey = enableEncryption
        ? await _keyManager.getDeviceEncryptionKey()
        : null;

    try {
      // Family domain - family entities, members, permissions
      _familyBox = await Hive.openBox<Map>(
        HiveBoxNames.familyBox,
        encryptionCipher: encryptionKey != null
            ? HiveAesCipher(encryptionKey)
            : null,
      );

      // Children domain - child profiles, assignments, medical info
      _childrenBox = await Hive.openBox<Map>(
        HiveBoxNames.childrenBox,
        encryptionCipher: encryptionKey != null
            ? HiveAesCipher(encryptionKey)
            : null,
      );

      // Vehicle domain - vehicle information, schedules, availability
      _vehicleBox = await Hive.openBox<Map>(
        HiveBoxNames.vehicleBox,
        encryptionCipher: encryptionKey != null
            ? HiveAesCipher(encryptionKey)
            : null,
      );

      // Schedule domain - time slots, appointments, conflicts
      _scheduleBox = await Hive.openBox<Map>(
        HiveBoxNames.scheduleBox,
        encryptionCipher: encryptionKey != null
            ? HiveAesCipher(encryptionKey)
            : null,
      );

      // Sync domain - pending changes, offline operations
      _syncBox = await Hive.openBox<Map>(
        HiveBoxNames.syncBox,
        encryptionCipher: encryptionKey != null
            ? HiveAesCipher(encryptionKey)
            : null,
      );

      // ID mappings domain - temporary entity mappings (30-day TTL)
      _idMappingsBox = await Hive.openBox<Map>(
        HiveBoxNames.idMappingsBox,
        encryptionCipher: encryptionKey != null
            ? HiveAesCipher(encryptionKey)
            : null,
      );

      developer.log(
        'All domain boxes opened successfully',
        name: 'HiveOrchestrator',
      );
    } catch (error) {
      developer.log(
        'Failed to open domain boxes',
        name: 'HiveOrchestrator',
        error: error,
      );
      rethrow;
    }
  }

  /// Setup ID mappings box with TTL capability for temporary entity mappings
  Future<void> _setupIdMappingsBox() async {
    if (_idMappingsBox == null) return;

    try {
      // Clean up expired mappings (30-day TTL)
      final now = DateTime.now().millisecondsSinceEpoch;
      final expiredKeys = <String>[];

      for (final key in _idMappingsBox!.keys) {
        final mapping = _idMappingsBox!.get(key);
        if (mapping != null) {
          final timestamp = mapping['timestamp'] as int?;
          if (timestamp != null &&
              now - timestamp > const Duration(days: 30).inMilliseconds) {
            expiredKeys.add(key.toString());
          }
        }
      }

      // Remove expired mappings
      for (final key in expiredKeys) {
        await _idMappingsBox!.delete(key);
      }

      if (expiredKeys.isNotEmpty) {
        developer.log(
          'Cleaned up ${expiredKeys.length} expired ID mappings',
          name: 'HiveOrchestrator',
        );
      }
    } catch (error) {
      developer.log(
        'Failed to setup ID mappings box',
        name: 'HiveOrchestrator',
        error: error,
      );
    }
  }

  /// Type-safe access to family box
  Box<Map> get familyBox {
    _ensureInitialized();
    return _familyBox!;
  }

  /// Type-safe access to children box
  Box<Map> get childrenBox {
    _ensureInitialized();
    return _childrenBox!;
  }

  /// Type-safe access to vehicle box
  Box<Map> get vehicleBox {
    _ensureInitialized();
    return _vehicleBox!;
  }

  /// Type-safe access to schedule box
  Box<Map> get scheduleBox {
    _ensureInitialized();
    return _scheduleBox!;
  }

  /// Type-safe access to sync box
  Box<Map> get syncBox {
    _ensureInitialized();
    return _syncBox!;
  }

  /// Type-safe access to ID mappings box
  Box<Map> get idMappingsBox {
    _ensureInitialized();
    return _idMappingsBox!;
  }

  /// Ensure HiveOrchestrator is properly initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'HiveOrchestrator not initialized. Call initialize() first.',
      );
    }
  }

  /// Get box by domain name for dynamic access
  Box<Map>? getBoxByDomain(String domain) {
    switch (domain) {
      case 'family':
        return _familyBox;
      case 'children':
        return _childrenBox;
      case 'vehicle':
        return _vehicleBox;
      case 'schedule':
        return _scheduleBox;
      case 'sync':
        return _syncBox;
      case 'idMappings':
        return _idMappingsBox;
      default:
        return null;
    }
  }

  /// Get all available domain names
  List<String> get availableDomains => [
    'family',
    'children',
    'vehicle',
    'schedule',
    'sync',
    'idMappings',
  ];

  /// Get initialization status
  bool get isInitialized => _isInitialized;

  /// Graceful lifecycle management - close all boxes
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      developer.log(
        'Disposing HiveOrchestrator - closing all boxes',
        name: 'HiveOrchestrator',
      );

      // Close all boxes gracefully
      await Future.wait([
        _familyBox?.close() ?? Future.value(),
        _childrenBox?.close() ?? Future.value(),
        _vehicleBox?.close() ?? Future.value(),
        _scheduleBox?.close() ?? Future.value(),
        _syncBox?.close() ?? Future.value(),
        _idMappingsBox?.close() ?? Future.value(),
      ]);

      _isInitialized = false;

      developer.log(
        'HiveOrchestrator disposed successfully',
        name: 'HiveOrchestrator',
      );
    } catch (error) {
      developer.log(
        'Error during HiveOrchestrator disposal',
        name: 'HiveOrchestrator',
        error: error,
      );
    }
  }

  /// Compact all boxes for storage optimization
  Future<void> compactAll() async {
    _ensureInitialized();

    try {
      developer.log(
        'Compacting all Hive boxes for storage optimization',
        name: 'HiveOrchestrator',
      );

      await Future.wait([
        _familyBox?.compact() ?? Future.value(),
        _childrenBox?.compact() ?? Future.value(),
        _vehicleBox?.compact() ?? Future.value(),
        _scheduleBox?.compact() ?? Future.value(),
        _syncBox?.compact() ?? Future.value(),
        _idMappingsBox?.compact() ?? Future.value(),
      ]);

      developer.log(
        'All boxes compacted successfully',
        name: 'HiveOrchestrator',
      );
    } catch (error) {
      developer.log(
        'Error during box compaction',
        name: 'HiveOrchestrator',
        error: error,
      );
    }
  }

  /// Clear all data from all boxes (for testing or reset scenarios)
  Future<void> clearAll() async {
    _ensureInitialized();

    try {
      developer.log(
        'Clearing all data from Hive boxes',
        name: 'HiveOrchestrator',
      );

      await Future.wait([
        _familyBox?.clear() ?? Future.value(),
        _childrenBox?.clear() ?? Future.value(),
        _vehicleBox?.clear() ?? Future.value(),
        _scheduleBox?.clear() ?? Future.value(),
        _syncBox?.clear() ?? Future.value(),
        _idMappingsBox?.clear() ?? Future.value(),
      ]);

      developer.log('All boxes cleared successfully', name: 'HiveOrchestrator');
    } catch (error) {
      developer.log(
        'Error during box clearing',
        name: 'HiveOrchestrator',
        error: error,
      );
    }
  }
}

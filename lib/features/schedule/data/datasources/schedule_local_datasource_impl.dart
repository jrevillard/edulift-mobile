// EduLift Mobile - Schedule Local Data Source Implementation
// Clean Architecture local storage implementation for schedule management
// Pattern: Follows persistent_local_datasource.dart pattern with CacheEntry + DTOs

import 'dart:convert';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../../core/storage/hive_encryption_manager.dart';
import '../../../../core/network/models/schedule/schedule_slot_dto.dart';
import '../../../../core/network/models/schedule/schedule_config_dto.dart';
import '../../../../core/network/models/schedule/vehicle_assignment_dto.dart';
import '../../../../core/network/models/family/schedule_slot_child_dto.dart';
import '../../../../core/utils/error_logger.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/core/domain/entities/family.dart';
import 'schedule_local_datasource.dart';

/// Cache metadata wrapper for versioning and TTL
class CacheEntry<T> {
  final T data;
  final DateTime cachedAt;
  final int version;

  const CacheEntry({
    required this.data,
    required this.cachedAt,
    this.version = 1,
  });

  Map<String, dynamic> toJson() => {
    'data': data,
    'cachedAt': cachedAt.toIso8601String(),
    'version': version,
  };

  static CacheEntry<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(dynamic) fromData,
  ) => CacheEntry(
    data: fromData(json['data']),
    cachedAt: DateTime.parse(json['cachedAt']),
    version: json['version'] ?? 1,
  );

  bool isExpired(Duration ttl) => DateTime.now().difference(cachedAt) > ttl;
}

/// Implementation of ScheduleLocalDataSource using Hive Box<Map> storage
/// Follows project pattern from PersistentLocalDataSource with CacheEntry + DTOs
class ScheduleLocalDataSourceImpl implements ScheduleLocalDataSource {
  // Box name
  static const String _scheduleBoxName = 'schedule_cache';

  // TTL configurations
  static const _scheduleTtl = Duration(hours: 1);
  static const _configTtl = Duration(hours: 24);

  // Box (lazy initialized)
  late Box _scheduleBox;

  bool _initialized = false;

  // NO constructor parameters - self-contained
  ScheduleLocalDataSourceImpl();

  /// Initialize Hive box with encryption
  /// NEVER throws - gracefully degrades to disabled cache on failure
  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    try {
      final cipher = await HiveEncryptionManager().getCipher();

      // Open schedule box with encryption
      _scheduleBox = await Hive.openBox(
        _scheduleBoxName,
        encryptionCipher: cipher,
      );

      _initialized = true;
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        context: 'ScheduleLocalDataSourceImpl._ensureInitialized',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'message': 'Failed to initialize encrypted cache'},
      );

      // Self-healing: Delete corrupted box and recreate with encryption
      try {
        await Hive.deleteBoxFromDisk(_scheduleBoxName);

        final cipher = await HiveEncryptionManager().getCipher();
        _scheduleBox = await Hive.openBox(
          _scheduleBoxName,
          encryptionCipher: cipher,
        );

        _initialized = true;
        ErrorLogger.logError(
          context: 'ScheduleLocalDataSourceImpl._ensureInitialized',
          error: 'Successfully recovered with clean encrypted box',
        );
      } catch (recoveryError, recoveryStackTrace) {
        ErrorLogger.logError(
          context: 'ScheduleLocalDataSourceImpl._ensureInitialized',
          error: recoveryError,
          stackTrace: recoveryStackTrace,
          additionalData: {
            'message':
                'Cannot recover cache - cache disabled, app will use API only',
          },
        );
        _initialized = false; // Cache disabled - graceful degradation
      }
    }
  }

  // ========================================
  // SCHEDULE SLOT CACHING OPERATIONS
  // ========================================

  @override
  Future<List<ScheduleSlot>?> getCachedWeeklySchedule(
    String groupId,
    String week,
  ) async {
    await _ensureInitialized();
    if (!_initialized) return null; // Cache disabled - graceful degradation

    try {
      final key = 'weekly_${groupId}_$week';
      final cached = _scheduleBox.get(key);
      if (cached == null) return null;

      // Use CacheEntry wrapper
      final entry = CacheEntry.fromJson<String>(
        Map<String, dynamic>.from(cached),
        (data) => data.toString(),
      );

      // Check TTL
      if (entry.isExpired(_scheduleTtl)) {
        await _scheduleBox.delete(key);
        return null;
      }

      // Deserialize: JSON String → List of DTOs → List of Domain
      final jsonData = jsonDecode(entry.data) as Map<String, dynamic>;
      final slots = (jsonData['slots'] as List)
          .map((e) => ScheduleSlotDto.fromJson(e).toDomain())
          .toList();

      return slots;
    } catch (e, stackTrace) {
      // Graceful degradation
      ErrorLogger.logError(
        context:
            'ScheduleLocalDataSourceImpl.getCachedWeeklySchedule - Corrupted cache',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'groupId': groupId, 'week': week},
      );
      final key = 'weekly_${groupId}_$week';
      await _scheduleBox.delete(key); // Self-healing
      return null;
    }
  }

  @override
  Future<void> cacheWeeklySchedule(
    String groupId,
    String week,
    List<ScheduleSlot> scheduleSlots,
  ) async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    try {
      final key = 'weekly_${groupId}_$week';

      // Domain → DTOs → JSON
      final dtos = scheduleSlots
          .map((slot) => ScheduleSlotDto.fromDomain(slot).toJson())
          .toList();
      final jsonData = {'slots': dtos, 'groupId': groupId, 'week': week};
      final jsonString = jsonEncode(jsonData);

      // Wrap in CacheEntry
      final entry = CacheEntry(data: jsonString, cachedAt: DateTime.now());
      await _scheduleBox.put(key, entry.toJson());
    } catch (e) {
      // Silently fail cache write (don't block app)
    }
  }

  @override
  Future<ScheduleSlot?> getCachedScheduleSlot(String slotId) async {
    await _ensureInitialized();
    if (!_initialized) return null; // Cache disabled - graceful degradation

    try {
      final key = 'slot_$slotId';
      final cached = _scheduleBox.get(key);
      if (cached == null) return null;

      // Use CacheEntry wrapper
      final entry = CacheEntry.fromJson<String>(
        Map<String, dynamic>.from(cached),
        (data) => data.toString(),
      );

      // Check TTL
      if (entry.isExpired(_scheduleTtl)) {
        await _scheduleBox.delete(key);
        return null;
      }

      // Deserialize: JSON String → DTO → Domain
      final jsonData = jsonDecode(entry.data) as Map<String, dynamic>;
      final slot = ScheduleSlotDto.fromJson(jsonData).toDomain();

      return slot;
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        context:
            'ScheduleLocalDataSourceImpl.getCachedScheduleSlot - Corrupted cache',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'slotId': slotId},
      );
      await _scheduleBox.delete('slot_$slotId');
      return null;
    }
  }

  @override
  Future<void> cacheScheduleSlot(ScheduleSlot slot) async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    try {
      final key = 'slot_${slot.id}';

      // Domain → DTO → JSON String
      final dto = ScheduleSlotDto.fromDomain(slot);
      final jsonString = jsonEncode(dto.toJson());

      // Wrap in CacheEntry
      final entry = CacheEntry(data: jsonString, cachedAt: DateTime.now());
      await _scheduleBox.put(key, entry.toJson());
    } catch (e) {
      // Silently fail cache write
    }
  }

  @override
  Future<void> updateCachedScheduleSlot(ScheduleSlot slot) async {
    await _ensureInitialized();
    // Same as cache for Box<Map> - put overwrites
    await cacheScheduleSlot(slot);
  }

  @override
  Future<void> removeScheduleSlot(String slotId) async {
    await _ensureInitialized();
    try {
      final key = 'slot_$slotId';
      await _scheduleBox.delete(key);
    } catch (e) {
      // Silently fail delete
    }
  }

  @override
  Future<void> clearWeekScheduleSlots(String groupId, String week) async {
    await _ensureInitialized();
    try {
      final key = 'weekly_${groupId}_$week';
      await _scheduleBox.delete(key);
    } catch (e) {
      // Silently fail delete
    }
  }

  // ========================================
  // SCHEDULE CONFIGURATION CACHING
  // ========================================

  @override
  Future<ScheduleConfig?> getCachedScheduleConfig(String groupId) async {
    await _ensureInitialized();
    if (!_initialized) return null; // Cache disabled - graceful degradation

    try {
      final key = 'config_$groupId';
      final cached = _scheduleBox.get(key);
      if (cached == null) return null;

      // Use CacheEntry wrapper
      final entry = CacheEntry.fromJson<String>(
        Map<String, dynamic>.from(cached),
        (data) => data.toString(),
      );

      // Check TTL
      if (entry.isExpired(_configTtl)) {
        await _scheduleBox.delete(key);
        return null;
      }

      // Deserialize: JSON String → DTO → Domain
      final jsonData = jsonDecode(entry.data) as Map<String, dynamic>;
      final config = ScheduleConfigDto.fromJson(jsonData).toDomain();

      return config;
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        context:
            'ScheduleLocalDataSourceImpl.getCachedScheduleConfig - Corrupted cache',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'groupId': groupId},
      );
      await _scheduleBox.delete('config_$groupId');
      return null;
    }
  }

  @override
  Future<void> cacheScheduleConfig(ScheduleConfig config) async {
    await _ensureInitialized();
    try {
      final key = 'config_${config.groupId}';

      // Domain → DTO → JSON String
      final dto = ScheduleConfigDto.fromDomain(config);
      final jsonString = jsonEncode(dto.toJson());

      // Wrap in CacheEntry
      final entry = CacheEntry(data: jsonString, cachedAt: DateTime.now());
      await _scheduleBox.put(key, entry.toJson());
    } catch (e) {
      // Silently fail cache write
    }
  }

  @override
  Future<void> updateCachedScheduleConfig(ScheduleConfig config) async {
    await _ensureInitialized();
    // Same as cache for Box<Map>
    await cacheScheduleConfig(config);
  }

  // ========================================
  // VEHICLE ASSIGNMENT CACHING
  // ========================================

  @override
  Future<void> cacheVehicleAssignment(
    String slotId,
    VehicleAssignment assignment,
  ) async {
    await _ensureInitialized();
    try {
      final key = 'vehicle_assignments_$slotId';
      final existing = _scheduleBox.get(key);

      final List<Map<String, dynamic>> assignments;
      if (existing != null) {
        // Deserialize existing with CacheEntry
        final entry = CacheEntry.fromJson<String>(
          Map<String, dynamic>.from(existing),
          (data) => data.toString(),
        );
        final jsonData = jsonDecode(entry.data) as Map<String, dynamic>;
        final existingAssignments = (jsonData['assignments'] as List)
            .cast<Map<String, dynamic>>();

        // Add or update
        final assignmentDto = VehicleAssignmentDto.fromDomain(assignment);
        final index = existingAssignments.indexWhere(
          (a) => a['id'] == assignment.id,
        );
        if (index >= 0) {
          existingAssignments[index] = assignmentDto.toJson();
        } else {
          existingAssignments.add(assignmentDto.toJson());
        }
        assignments = existingAssignments;
      } else {
        final assignmentDto = VehicleAssignmentDto.fromDomain(assignment);
        assignments = [assignmentDto.toJson()];
      }

      // Serialize with CacheEntry
      final jsonData = {'assignments': assignments, 'slotId': slotId};
      final jsonString = jsonEncode(jsonData);
      final entry = CacheEntry(data: jsonString, cachedAt: DateTime.now());
      await _scheduleBox.put(key, entry.toJson());
    } catch (e) {
      // Silently fail cache write
    }
  }

  @override
  Future<void> updateCachedVehicleAssignment(
    VehicleAssignment assignment,
  ) async {
    await _ensureInitialized();
    await cacheVehicleAssignment(assignment.scheduleSlotId, assignment);
  }

  @override
  Future<void> removeCachedVehicleAssignment(
    String slotId,
    String vehicleAssignmentId,
  ) async {
    await _ensureInitialized();
    try {
      final key = 'vehicle_assignments_$slotId';
      final existing = _scheduleBox.get(key);
      if (existing == null) return;

      // Deserialize with CacheEntry
      final entry = CacheEntry.fromJson<String>(
        Map<String, dynamic>.from(existing),
        (data) => data.toString(),
      );
      final jsonData = jsonDecode(entry.data) as Map<String, dynamic>;
      final assignments = (jsonData['assignments'] as List)
          .cast<Map<String, dynamic>>()
          .where((a) => a['id'] != vehicleAssignmentId)
          .toList();

      // Serialize with CacheEntry
      final updatedData = {'assignments': assignments, 'slotId': slotId};
      final jsonString = jsonEncode(updatedData);
      final updatedEntry = CacheEntry(
        data: jsonString,
        cachedAt: DateTime.now(),
      );
      await _scheduleBox.put(key, updatedEntry.toJson());
    } catch (e) {
      // Silently fail delete
    }
  }

  @override
  Future<List<VehicleAssignment>?> getCachedVehicleAssignments(
    String slotId,
  ) async {
    await _ensureInitialized();
    try {
      final key = 'vehicle_assignments_$slotId';
      final cached = _scheduleBox.get(key);
      if (cached == null) return null;

      // Use CacheEntry wrapper
      final entry = CacheEntry.fromJson<String>(
        Map<String, dynamic>.from(cached),
        (data) => data.toString(),
      );

      // Check TTL
      if (entry.isExpired(_scheduleTtl)) {
        await _scheduleBox.delete(key);
        return null;
      }

      // Deserialize using DTO
      final jsonData = jsonDecode(entry.data) as Map<String, dynamic>;
      final assignments = (jsonData['assignments'] as List)
          .map((e) => VehicleAssignmentDto.fromJson(e).toDomain())
          .toList();

      return assignments;
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        context:
            'ScheduleLocalDataSourceImpl.getCachedVehicleAssignments - Corrupted cache',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'slotId': slotId},
      );
      await _scheduleBox.delete('vehicle_assignments_$slotId');
      return null;
    }
  }

  // ========================================
  // CHILD ASSIGNMENT CACHING
  // ========================================

  @override
  Future<void> cacheChildAssignment(
    String vehicleAssignmentId,
    ChildAssignment assignment,
  ) async {
    await _ensureInitialized();
    try {
      final key = 'child_assignment_${assignment.id}';

      // Domain → DTO → JSON String
      final dto = ScheduleSlotChildDto.fromDomain(assignment);
      final jsonData = {
        ...dto.toJson(),
        'vehicleAssignmentId': vehicleAssignmentId,
      };
      final jsonString = jsonEncode(jsonData);

      // Wrap in CacheEntry
      final entry = CacheEntry(data: jsonString, cachedAt: DateTime.now());
      await _scheduleBox.put(key, entry.toJson());
    } catch (e) {
      // Silently fail cache write
    }
  }

  @override
  Future<void> updateCachedChildAssignmentStatus(
    String assignmentId,
    String status,
  ) async {
    await _ensureInitialized();
    try {
      final key = 'child_assignment_$assignmentId';
      final existing = _scheduleBox.get(key);
      if (existing == null) return;

      // Deserialize with CacheEntry
      final entry = CacheEntry.fromJson<String>(
        Map<String, dynamic>.from(existing),
        (data) => data.toString(),
      );
      final jsonData = jsonDecode(entry.data) as Map<String, dynamic>;

      // Update status field
      jsonData['status'] = status;
      final jsonString = jsonEncode(jsonData);

      // Save with new CacheEntry
      final updatedEntry = CacheEntry(
        data: jsonString,
        cachedAt: DateTime.now(),
      );
      await _scheduleBox.put(key, updatedEntry.toJson());
    } catch (e) {
      // Silently fail update
    }
  }

  @override
  Future<void> removeCachedChildAssignment(
    String vehicleAssignmentId,
    String childAssignmentId,
  ) async {
    await _ensureInitialized();
    try {
      final key = 'child_assignment_$childAssignmentId';
      await _scheduleBox.delete(key);
    } catch (e) {
      // Silently fail delete
    }
  }

  // ========================================
  // PRIVATE CACHE MANAGEMENT (Internal Use Only)
  // ========================================

  @override
  Future<Map<String, dynamic>?> getCacheMetadata(String groupId) async {
    await _ensureInitialized();
    try {
      final key = 'metadata_$groupId';
      final cached = _scheduleBox.get(key);
      if (cached == null) return null;

      // Use CacheEntry wrapper
      final entry = CacheEntry.fromJson<String>(
        Map<String, dynamic>.from(cached),
        (data) => data.toString(),
      );

      // Deserialize
      final jsonData = jsonDecode(entry.data) as Map<String, dynamic>;
      return jsonData;
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        context:
            'ScheduleLocalDataSourceImpl.getCacheMetadata - Corrupted cache',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'groupId': groupId},
      );
      await _scheduleBox.delete('metadata_$groupId');
      return null;
    }
  }

  /// Update cache metadata - PRIVATE method
  Future<void> updateCacheMetadata(
    String groupId,
    Map<String, dynamic> metadata,
  ) async {
    await _ensureInitialized();
    try {
      final key = 'metadata_$groupId';
      final existing = _scheduleBox.get(key);

      Map<String, dynamic> updated;
      if (existing != null) {
        final entry = CacheEntry.fromJson<String>(
          Map<String, dynamic>.from(existing),
          (data) => data.toString(),
        );
        final existingData = jsonDecode(entry.data) as Map<String, dynamic>;
        updated = {...existingData, ...metadata};
      } else {
        updated = metadata;
      }

      // Save with CacheEntry
      final jsonString = jsonEncode(updated);
      final entry = CacheEntry(data: jsonString, cachedAt: DateTime.now());
      await _scheduleBox.put(key, entry.toJson());
    } catch (e) {
      // Silently fail update
    }
  }

  /// Clear expired cache entries - PRIVATE method
  Future<void> clearExpiredCache() async {
    await _ensureInitialized();
    try {
      final keysToDelete = <String>[];

      for (final key in _scheduleBox.keys) {
        try {
          final cached = _scheduleBox.get(key);
          if (cached == null) continue;

          final entry = CacheEntry.fromJson<String>(
            Map<String, dynamic>.from(cached),
            (data) => data.toString(),
          );

          // Determine TTL based on key prefix
          var ttl = _scheduleTtl;
          final keyStr = key.toString();
          if (keyStr.startsWith('config_')) {
            ttl = _configTtl;
          }

          if (entry.isExpired(ttl)) {
            keysToDelete.add(keyStr);
          }
        } catch (e) {
          // Corrupted entry - delete it
          keysToDelete.add(key.toString());
        }
      }

      await _scheduleBox.deleteAll(keysToDelete);
    } catch (e) {
      // Silently fail cleanup
    }
  }

  /// Get cache size information - PRIVATE method
  Future<Map<String, int>> getCacheSizeInfo() async {
    await _ensureInitialized();
    try {
      final totalEntries = _scheduleBox.length;
      var weeklySchedules = 0;
      var slots = 0;
      var configs = 0;
      var vehicleAssignments = 0;
      var childAssignments = 0;
      var metadata = 0;

      for (final key in _scheduleBox.keys) {
        final keyStr = key.toString();
        if (keyStr.startsWith('weekly_')) {
          weeklySchedules++;
        } else if (keyStr.startsWith('slot_')) {
          slots++;
        } else if (keyStr.startsWith('config_')) {
          configs++;
        } else if (keyStr.startsWith('vehicle_assignments_')) {
          vehicleAssignments++;
        } else if (keyStr.startsWith('child_assignment_')) {
          childAssignments++;
        } else if (keyStr.startsWith('metadata_')) {
          metadata++;
        }
      }

      return {
        'totalEntries': totalEntries,
        'weeklySchedules': weeklySchedules,
        'slots': slots,
        'configs': configs,
        'vehicleAssignments': vehicleAssignments,
        'childAssignments': childAssignments,
        'metadata': metadata,
      };
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> storePendingOperation(Map<String, dynamic> operation) async {
    await _ensureInitialized();
    try {
      const key = 'pending_operations';
      final existing = _scheduleBox.get(key);

      List<Map<String, dynamic>> operations;
      if (existing != null) {
        final entry = CacheEntry.fromJson<String>(
          Map<String, dynamic>.from(existing),
          (data) => data.toString(),
        );
        final jsonData = jsonDecode(entry.data) as Map<String, dynamic>;
        operations = (jsonData['operations'] as List)
            .cast<Map<String, dynamic>>();
      } else {
        operations = [];
      }

      operations.add(operation);

      final updatedData = {'operations': operations};
      final jsonString = jsonEncode(updatedData);
      final entry = CacheEntry(data: jsonString, cachedAt: DateTime.now());
      await _scheduleBox.put(key, entry.toJson());
    } catch (e) {
      // Silently fail store operation
    }
  }
}

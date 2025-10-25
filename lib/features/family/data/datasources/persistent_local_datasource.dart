// EduLift Mobile - Persistent Local Data Source Implementation
// Clean Architecture compliant - Uses existing API DTOs for cache

import 'dart:async';
import 'dart:convert';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../../../../core/storage/hive_encryption_manager.dart';
import '../../../../core/utils/error_logger.dart';

import '../../../../core/network/models/family/family_dto.dart';
import '../../../../core/network/models/child/child_dto.dart';
import '../../../../core/network/models/vehicle/vehicle_dto.dart';
import '../../../../core/network/models/family/family_invitation_dto.dart';
import 'package:edulift/core/domain/entities/family.dart';
import 'family_local_datasource.dart';

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
  ) =>
      CacheEntry(
        data: fromData(json['data']),
        cachedAt: DateTime.parse(json['cachedAt']),
        version: json['version'] ?? 1,
      );

  bool isExpired(Duration ttl) => DateTime.now().difference(cachedAt) > ttl;
}

/// Production-grade Hive cache using existing API DTOs
class PersistentLocalDataSource implements FamilyLocalDataSource {
  // Box names
  static const String _familyBoxName = 'families';
  static const String _childrenBoxName = 'children';
  static const String _vehiclesBoxName = 'vehicles';
  static const String _invitationsBoxName = 'invitations';
  static const String _metadataBoxName = 'metadata';

  // TTL
  static const _defaultTtl = Duration(hours: 24);
  static const _invitationTtl = Duration(days: 7);

  // Boxes
  late Box _familyBox;
  late Box _childrenBox;
  late Box _vehiclesBox;
  late Box _invitationsBox;
  late Box _metadataBox;

  bool _initialized = false;

  /// Initialize all Hive boxes with encryption
  /// NEVER throws - gracefully degrades to disabled cache on failure
  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    try {
      final cipher = await HiveEncryptionManager().getCipher();

      // Open all boxes with encryption
      _familyBox = await Hive.openBox(_familyBoxName, encryptionCipher: cipher);
      _childrenBox = await Hive.openBox(
        _childrenBoxName,
        encryptionCipher: cipher,
      );
      _vehiclesBox = await Hive.openBox(
        _vehiclesBoxName,
        encryptionCipher: cipher,
      );
      _invitationsBox = await Hive.openBox(
        _invitationsBoxName,
        encryptionCipher: cipher,
      );
      _metadataBox = await Hive.openBox(_metadataBoxName);

      // Check version and migrate if needed
      await _checkVersionAndMigrate();

      _initialized = true;
    } catch (e, stackTrace) {
      ErrorLogger.logProviderError(
        providerName: 'PersistentLocalDataSource',
        operation: '_ensureInitialized',
        error: 'Failed to initialize encrypted cache',
        stackTrace: stackTrace,
      );

      // Self-healing: Delete corrupted boxes and recreate with encryption
      try {
        await Hive.deleteBoxFromDisk(_familyBoxName);
        await Hive.deleteBoxFromDisk(_childrenBoxName);
        await Hive.deleteBoxFromDisk(_vehiclesBoxName);
        await Hive.deleteBoxFromDisk(_invitationsBoxName);
        await Hive.deleteBoxFromDisk(_metadataBoxName);

        final cipher = await HiveEncryptionManager().getCipher();

        _familyBox = await Hive.openBox(
          _familyBoxName,
          encryptionCipher: cipher,
        );
        _childrenBox = await Hive.openBox(
          _childrenBoxName,
          encryptionCipher: cipher,
        );
        _vehiclesBox = await Hive.openBox(
          _vehiclesBoxName,
          encryptionCipher: cipher,
        );
        _invitationsBox = await Hive.openBox(
          _invitationsBoxName,
          encryptionCipher: cipher,
        );
        _metadataBox = await Hive.openBox(_metadataBoxName);

        await _checkVersionAndMigrate();

        _initialized = true;
        ErrorLogger.logProviderError(
          providerName: 'PersistentLocalDataSource',
          operation: '_ensureInitialized',
          error: 'Successfully recovered with clean encrypted boxes',
        );
      } catch (recoveryError, recoveryStackTrace) {
        ErrorLogger.logProviderError(
          providerName: 'PersistentLocalDataSource',
          operation: '_ensureInitialized',
          error: 'Cannot recover cache - cache disabled, app will use API only',
          stackTrace: recoveryStackTrace,
        );
        _initialized = false; // Cache disabled - graceful degradation
      }
    }
  }

  /// Check version and migrate data if needed
  Future<void> _checkVersionAndMigrate() async {
    const currentVersion = 1;
    final storedVersion = _metadataBox.get('version', defaultValue: 0);

    if (storedVersion < currentVersion) {
      // Perform migration if needed
      await _metadataBox.put('version', currentVersion);
      await _metadataBox.put(
        'migration_date',
        DateTime.now().toIso8601String(),
      );
    }
  }

  // ===========================================
  // INTERFACE IMPLEMENTATION
  // ===========================================

  @override
  Future<Family?> getCurrentFamily() async {
    await _ensureInitialized();
    if (!_initialized) return null; // Cache disabled - graceful degradation

    final cached = _familyBox.get('current');
    if (cached == null) return null;

    try {
      final entry = CacheEntry.fromJson<String>(
        Map<String, dynamic>.from(cached),
        (data) => data.toString(),
      );

      if (entry.isExpired(_defaultTtl)) {
        await _familyBox.delete('current');
        return null;
      }

      // STATE OF ART: Hive → JSON String → DTO → Domain
      final jsonMap = jsonDecode(entry.data) as Map<String, dynamic>;
      final familyDto = FamilyDto.fromJson(jsonMap);
      return familyDto.toDomain();
    } catch (e, stackTrace) {
      // Graceful degradation: Log + cleanup + continue
      ErrorLogger.logProviderError(
        providerName: 'PersistentLocalDataSource',
        operation: 'getCurrentFamily',
        error: 'Cache entry corrupted',
        stackTrace: stackTrace,
        state: {'cachedDataType': cached.runtimeType.toString()},
      );

      // Self-healing: Remove corrupted entry
      await _familyBox.delete('current');

      // Graceful degradation: Return null (fallback to API)
      return null;
    }
  }

  @override
  Future<void> cacheCurrentFamily(Family family) async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    // STATE OF ART: Domain → DTO → JSON String → Hive
    final familyDto = FamilyDto.fromDomain(family);
    final jsonMap = familyDto.toJson();
    final jsonString = jsonEncode(jsonMap);

    final entry = CacheEntry(data: jsonString, cachedAt: DateTime.now());
    await _familyBox.put('current', entry.toJson());
  }

  @override
  Future<void> clearCurrentFamily() async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    await _familyBox.delete('current');
  }

  @override
  Future<void> clearCache() async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    await Future.wait([
      _familyBox.clear(),
      _childrenBox.clear(),
      _vehiclesBox.clear(),
      _invitationsBox.clear(),
    ]);
  }

  @override
  Future<List<FamilyInvitation>> getInvitations() async {
    await _ensureInitialized();
    if (!_initialized) return []; // Cache disabled - return empty list

    final invitations = <FamilyInvitation>[];

    for (final key in _invitationsBox.keys) {
      final cached = _invitationsBox.get(key);
      if (cached == null) continue;

      try {
        final entry = CacheEntry.fromJson<String>(
          Map<String, dynamic>.from(cached),
          (data) => data as String,
        );

        if (entry.isExpired(_invitationTtl)) {
          await _invitationsBox.delete(key);
          continue;
        }

        // Decode JSON string to Map
        final invitationJson = jsonDecode(entry.data) as Map<String, dynamic>;
        final invitationDto = FamilyInvitationDto.fromJson(invitationJson);
        final invitation = invitationDto.toDomain();

        // Check if it's actually pending
        if (invitation.status == InvitationStatus.pending) {
          invitations.add(invitation);
        }
      } catch (e, stackTrace) {
        // Graceful degradation: Log + cleanup + continue
        final cached = _invitationsBox.get(key);
        ErrorLogger.logProviderError(
          providerName: 'PersistentLocalDataSource',
          operation: 'getPendingInvitations',
          error: 'Corrupted invitation cache entry',
          stackTrace: stackTrace,
          state: {
            'corruptedKey': key.toString(),
            'cachedType': cached?.runtimeType.toString(),
            'cachedValue': cached.toString().substring(0, 200),
            'errorType': e.runtimeType.toString(),
            'errorMessage': e.toString(),
          },
        );

        // Self-healing: Remove corrupted entry
        await _invitationsBox.delete(key);
        // Continue processing other invitations
      }
    }

    return invitations;
  }

  @override
  Future<List<Map<String, dynamic>>> getInvitationHistory({
    String? type,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
  }) async {
    throw UnimplementedError('Generic invitation history not implemented');
  }

  @override
  Future<Map<String, dynamic>?> getInvitation(String invitationId) async {
    throw UnimplementedError('Generic invitation retrieval not implemented');
  }

  @override
  Future<void> cacheFamilyInvitation(FamilyInvitation invitation) async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    // STATE OF ART: Domain → DTO → JSON String → Hive
    final invitationDto = FamilyInvitationDto.fromDomain(invitation);
    final jsonMap = invitationDto.toJson();
    final jsonString = jsonEncode(jsonMap);

    final entry = CacheEntry(data: jsonString, cachedAt: DateTime.now());
    await _invitationsBox.put(invitation.id, entry.toJson());
  }

  @override
  Future<void> cacheInvitations(List<FamilyInvitation> invitations) async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    final batch = <String, Map<String, dynamic>>{};

    for (final invitation in invitations) {
      // STATE OF ART: Domain → DTO → JSON String → Hive
      final invitationDto = FamilyInvitationDto.fromDomain(invitation);
      final jsonMap = invitationDto.toJson();
      final jsonString = jsonEncode(jsonMap);

      final entry = CacheEntry(data: jsonString, cachedAt: DateTime.now());
      batch[invitation.id] = entry.toJson();
    }

    await _invitationsBox.putAll(batch);
  }

  @override
  Future<void> cacheInvitation(Invitation invitation) async {
    throw UnimplementedError('Invitation caching not implemented');
  }

  @override
  Future<void> cacheInvitationCode(
    String code,
    Map<String, dynamic> invitation,
  ) async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    final entry = CacheEntry(data: invitation, cachedAt: DateTime.now());
    await _invitationsBox.put('code_$code', entry.toJson());
  }

  @override
  Future<void> cacheChild(Child child) async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    // STATE OF ART: Domain → DTO → JSON String → Hive
    final childDto = ChildDto.fromDomain(child);
    final jsonMap = childDto.toJson();
    final jsonString = jsonEncode(jsonMap);

    final entry = CacheEntry(data: jsonString, cachedAt: DateTime.now());
    await _childrenBox.put(child.id, entry.toJson());
  }

  @override
  Future<void> cacheVehicle(Vehicle vehicle) async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    // STATE OF ART: Domain → DTO → JSON String → Hive
    final vehicleDto = VehicleDto.fromDomain(vehicle);
    final jsonMap = vehicleDto.toJson();
    final jsonString = jsonEncode(jsonMap);

    final entry = CacheEntry(data: jsonString, cachedAt: DateTime.now());
    await _vehiclesBox.put(vehicle.id, entry.toJson());
  }

  @override
  Future<void> removeChild(String childId) async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    await _childrenBox.delete(childId);
  }

  @override
  Future<void> removeVehicle(String vehicleId) async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    await _vehiclesBox.delete(vehicleId);
  }

  @override
  Future<void> clearExpiredCache() async {
    await _ensureInitialized();
    if (!_initialized) return; // Cache disabled - silent fail

    // Clean expired invitations
    final expiredInvitations = <String>[];
    for (final key in _invitationsBox.keys) {
      final cached = _invitationsBox.get(key);
      if (cached != null) {
        try {
          final entry = CacheEntry.fromJson<String>(
            Map<String, dynamic>.from(cached),
            (data) => data as String,
          );
          if (entry.isExpired(_invitationTtl)) {
            expiredInvitations.add(key);
          }
        } catch (e, stackTrace) {
          // Graceful degradation: Log corrupted entry
          ErrorLogger.logProviderError(
            providerName: 'PersistentLocalDataSource',
            operation: 'clearExpiredCache',
            error: 'Corrupted cache entry during cleanup',
            stackTrace: stackTrace,
            state: {'corruptedKey': key.toString()},
          );

          // Self-healing: Mark corrupted entry for deletion
          expiredInvitations.add(key);
        }
      }
    }

    for (final key in expiredInvitations) {
      await _invitationsBox.delete(key);
    }
  }
}

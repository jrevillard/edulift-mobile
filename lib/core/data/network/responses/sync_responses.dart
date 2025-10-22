// EduLift Mobile - Sync Response Models
// Matches backend /api/sync/* endpoints

/// Sync result response model
class SyncResultResponse {
  final bool success;
  final int processedChanges;
  final int pendingChanges;
  final List<SyncConflictResponse> conflicts;
  final DateTime syncedAt;
  final String? nextSyncToken;
  final Map<String, dynamic>? metadata;

  const SyncResultResponse({
    required this.success,
    required this.processedChanges,
    required this.pendingChanges,
    required this.conflicts,
    required this.syncedAt,
    this.nextSyncToken,
    this.metadata,
  });

  factory SyncResultResponse.fromJson(Map<String, dynamic> json) {
    return SyncResultResponse(
      success: json['success'] as bool,
      processedChanges: json['processedChanges'] as int? ?? 0,
      pendingChanges: json['pendingChanges'] as int? ?? 0,
      conflicts: (json['conflicts'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                SyncConflictResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      syncedAt: DateTime.parse(json['syncedAt'] as String),
      nextSyncToken: json['nextSyncToken'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Sync conflict response model
class SyncConflictResponse {
  final String id;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final DateTime conflictDetectedAt;
  final String conflictType;
  final ConflictResolutionResponse? resolution;
  final List<String> possibleResolutions;

  const SyncConflictResponse({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.localData,
    required this.remoteData,
    required this.conflictDetectedAt,
    required this.conflictType,
    this.resolution,
    required this.possibleResolutions,
  });

  factory SyncConflictResponse.fromJson(Map<String, dynamic> json) {
    return SyncConflictResponse(
      id: json['id'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      localData: json['localData'] as Map<String, dynamic>,
      remoteData: json['remoteData'] as Map<String, dynamic>,
      conflictDetectedAt: DateTime.parse(json['conflictDetectedAt'] as String),
      conflictType: json['conflictType'] as String? ?? 'data_mismatch',
      resolution: json['resolution'] != null
          ? ConflictResolutionResponse.fromJson(
              json['resolution'] as Map<String, dynamic>,
            )
          : null,
      possibleResolutions: List<String>.from(
        json['possibleResolutions'] as List? ?? [],
      ),
    );
  }
}

/// Conflict resolution response model
class ConflictResolutionResponse {
  final String strategy;
  final Map<String, dynamic> resolvedData;
  final DateTime resolvedAt;
  final String resolvedBy;
  final bool isAutomatic;
  final String? notes;

  const ConflictResolutionResponse({
    required this.strategy,
    required this.resolvedData,
    required this.resolvedAt,
    required this.resolvedBy,
    required this.isAutomatic,
    this.notes,
  });

  factory ConflictResolutionResponse.fromJson(Map<String, dynamic> json) {
    return ConflictResolutionResponse(
      strategy: json['strategy'] as String,
      resolvedData: json['resolvedData'] as Map<String, dynamic>,
      resolvedAt: DateTime.parse(json['resolvedAt'] as String),
      resolvedBy: json['resolvedBy'] as String,
      isAutomatic: json['isAutomatic'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }
}

/// Incremental sync response model
class IncrementalSyncResponse {
  final List<Map<String, dynamic>> changedEntities;
  final List<String> deletedEntityIds;
  final DateTime lastSyncTime;
  final DateTime nextSyncTime;
  final bool hasMoreChanges;
  final String? continuationToken;

  const IncrementalSyncResponse({
    required this.changedEntities,
    required this.deletedEntityIds,
    required this.lastSyncTime,
    required this.nextSyncTime,
    required this.hasMoreChanges,
    this.continuationToken,
  });

  factory IncrementalSyncResponse.fromJson(Map<String, dynamic> json) {
    return IncrementalSyncResponse(
      changedEntities: List<Map<String, dynamic>>.from(
        json['changedEntities'] as List? ?? [],
      ),
      deletedEntityIds: List<String>.from(
        json['deletedEntityIds'] as List? ?? [],
      ),
      lastSyncTime: DateTime.parse(json['lastSyncTime'] as String),
      nextSyncTime: DateTime.parse(json['nextSyncTime'] as String),
      hasMoreChanges: json['hasMoreChanges'] as bool? ?? false,
      continuationToken: json['continuationToken'] as String?,
    );
  }
}

// EduLift Mobile - Sync Request Models
// Matches backend /api/sync/* endpoints

import 'package:equatable/equatable.dart';

/// Main sync request model
class SyncRequest extends Equatable {
  final DateTime? lastSyncTimestamp;
  final List<String>? includeTables;
  final bool fullSync;

  const SyncRequest({
    this.lastSyncTimestamp,
    this.includeTables,
    this.fullSync = false,
  });

  factory SyncRequest.fromJson(Map<String, dynamic> json) {
    return SyncRequest(
      lastSyncTimestamp: json['lastSyncTimestamp'] != null
          ? DateTime.parse(json['lastSyncTimestamp'])
          : null,
      includeTables: json['includeTables'] != null
          ? List<String>.from(json['includeTables'])
          : null,
      fullSync: json['fullSync'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    if (lastSyncTimestamp != null)
      'lastSyncTimestamp': lastSyncTimestamp!.toIso8601String(),
    if (includeTables != null) 'includeTables': includeTables,
    'fullSync': fullSync,
  };

  @override
  List<Object?> get props => [lastSyncTimestamp, includeTables, fullSync];
}

/// Incremental sync request model
class IncrementalSyncRequest extends Equatable {
  final DateTime lastSyncTimestamp;
  final List<String>? changedTables;

  const IncrementalSyncRequest({
    required this.lastSyncTimestamp,
    this.changedTables,
  });

  factory IncrementalSyncRequest.fromJson(Map<String, dynamic> json) {
    return IncrementalSyncRequest(
      lastSyncTimestamp: DateTime.parse(json['lastSyncTimestamp']),
      changedTables: json['changedTables'] != null
          ? List<String>.from(json['changedTables'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'lastSyncTimestamp': lastSyncTimestamp.toIso8601String(),
    if (changedTables != null) 'changedTables': changedTables,
  };

  @override
  List<Object?> get props => [lastSyncTimestamp, changedTables];
}

/// Resolve sync conflict request model
class ResolveSyncConflictRequest extends Equatable {
  final String conflictId;
  final String resolution;
  final Map<String, dynamic> resolvedData;

  const ResolveSyncConflictRequest({
    required this.conflictId,
    required this.resolution,
    required this.resolvedData,
  });

  factory ResolveSyncConflictRequest.fromJson(Map<String, dynamic> json) {
    return ResolveSyncConflictRequest(
      conflictId: json['conflictId'],
      resolution: json['resolution'],
      resolvedData: json['resolvedData'],
    );
  }

  Map<String, dynamic> toJson() => {
    'conflictId': conflictId,
    'resolution': resolution,
    'resolvedData': resolvedData,
  };

  @override
  List<Object?> get props => [conflictId, resolution, resolvedData];
}

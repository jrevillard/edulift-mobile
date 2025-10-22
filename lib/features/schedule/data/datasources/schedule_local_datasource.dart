// EduLift Mobile - Schedule Local Data Source Interface
// Clean Architecture local storage abstraction for schedule management

import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/core/domain/entities/family.dart';

/// Abstract interface for schedule local data source
/// Defines all local storage operations for offline functionality
abstract class ScheduleLocalDataSource {
  // ========================================
  // SCHEDULE SLOT CACHING OPERATIONS
  // ========================================

  /// Get weekly schedule from local storage
  Future<List<ScheduleSlot>?> getCachedWeeklySchedule(
    String groupId,
    String week,
  );

  /// Cache weekly schedule locally
  Future<void> cacheWeeklySchedule(
    String groupId,
    String week,
    List<ScheduleSlot> scheduleSlots,
  );

  /// Get specific schedule slot from local storage
  Future<ScheduleSlot?> getCachedScheduleSlot(String slotId);

  /// Cache single schedule slot locally
  Future<void> cacheScheduleSlot(ScheduleSlot slot);

  /// Update cached schedule slot
  Future<void> updateCachedScheduleSlot(ScheduleSlot slot);

  /// Remove schedule slot from local storage
  Future<void> removeScheduleSlot(String slotId);

  /// Clear all schedule slots for a specific week
  Future<void> clearWeekScheduleSlots(String groupId, String week);
  // ========================================
  // SCHEDULE CONFIGURATION CACHING
  // ========================================

  /// Get cached schedule configuration
  Future<ScheduleConfig?> getCachedScheduleConfig(String groupId);

  /// Cache schedule configuration locally
  Future<void> cacheScheduleConfig(ScheduleConfig config);

  /// Update cached schedule configuration
  Future<void> updateCachedScheduleConfig(ScheduleConfig config);
  // ========================================
  // VEHICLE ASSIGNMENT CACHING
  // ========================================

  /// Cache vehicle assignment locally
  Future<void> cacheVehicleAssignment(
    String slotId,
    VehicleAssignment assignment,
  );

  /// Update cached vehicle assignment
  Future<void> updateCachedVehicleAssignment(VehicleAssignment assignment);

  /// Remove vehicle assignment from cache
  Future<void> removeCachedVehicleAssignment(
    String slotId,
    String vehicleAssignmentId,
  );

  /// Get cached vehicle assignments for a slot
  Future<List<VehicleAssignment>?> getCachedVehicleAssignments(String slotId);
  // ========================================
  // CHILD ASSIGNMENT CACHING
  // ========================================

  /// Cache child assignment locally
  Future<void> cacheChildAssignment(
    String vehicleAssignmentId,
    ChildAssignment assignment,
  );

  /// Update cached child assignment status
  Future<void> updateCachedChildAssignmentStatus(
    String assignmentId,
    String status,
  );

  /// Remove child assignment from cache
  Future<void> removeCachedChildAssignment(
    String vehicleAssignmentId,
    String childAssignmentId,
  );

  // ========================================
  // CACHE MANAGEMENT
  // ========================================

  /// Get cache metadata (timestamps, sync info)
  Future<Map<String, dynamic>?> getCacheMetadata(String groupId);

  /// Store pending operation for offline sync
  Future<void> storePendingOperation(Map<String, dynamic> operation);
}

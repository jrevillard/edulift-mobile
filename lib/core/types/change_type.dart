// EduLift Mobile - Unified Change Type
// Comprehensive change type enum for both family and schedule domains

/// Unified enumeration representing different types of changes across all domains
enum ChangeType {
  // Family operations
  updateFamily('update_family', 'Update Family'),
  addChild('add_child', 'Add Child'),
  updateChild('update_child', 'Update Child'),
  deleteChild('delete_child', 'Delete Child'),
  addVehicle('add_vehicle', 'Add Vehicle'),
  updateVehicle('update_vehicle', 'Update Vehicle'),
  deleteVehicle('delete_vehicle', 'Delete Vehicle'),
  addFamilyMember('add_family_member', 'Add Family Member'),
  removeFamilyMember('remove_family_member', 'Remove Family Member'),
  updateMember('update_member', 'Update Member'),

  // Invitation operations
  createInvitation('create_invitation', 'Create Invitation'),
  acceptInvitation('accept_invitation', 'Accept Invitation'),
  rejectInvitation('reject_invitation', 'Reject Invitation'),

  // Schedule operations
  createSchedule('create_schedule', 'Create Schedule'),
  updateSchedule('update_schedule', 'Update Schedule'),
  deleteSchedule('delete_schedule', 'Delete Schedule'),

  // Assignment operations
  assignVehicle('assign_vehicle', 'Assign Vehicle'),
  assignChildren('assign_children', 'Assign Children'),
  updateAssignment('update_assignment', 'Update Assignment'),
  removeAssignment('remove_assignment', 'Remove Assignment'),

  // Time slot operations
  createTimeSlot('create_time_slot', 'Create Time Slot'),
  updateTimeSlot('update_time_slot', 'Update Time Slot'),
  deleteTimeSlot('delete_time_slot', 'Delete Time Slot'),

  // Configuration operations
  createScheduleConfig('create_schedule_config', 'Create Schedule Config'),
  updateScheduleConfig('update_schedule_config', 'Update Schedule Config'),
  deleteScheduleConfig('delete_schedule_config', 'Delete Schedule Config'),

  // Bulk operations
  bulkUpdateSchedules('bulk_update_schedules', 'Bulk Update Schedules'),
  bulkDeleteSchedules('bulk_delete_schedules', 'Bulk Delete Schedules'),

  // Sync operations
  syncSchedules('sync_schedules', 'Sync Schedules'),
  syncConflicts('sync_conflicts', 'Sync Conflicts'),

  // Other operations
  optimizeSchedule('optimize_schedule', 'Optimize Schedule'),
  resolveConflict('resolve_conflict', 'Resolve Conflict');

  const ChangeType(this.key, this.displayName);

  final String key;
  final String displayName;

  /// Get change type from string key
  /// Throws ArgumentError if the key is not found
  static ChangeType fromKey(String key) {
    for (final type in ChangeType.values) {
      if (type.key == key) {
        return type;
      }
    }
    throw ArgumentError('Unknown ChangeType key: $key');
  }

  /// Get change type from name
  /// Throws ArgumentError if the name is not found
  static ChangeType fromName(String name) {
    for (final type in ChangeType.values) {
      if (type.name == name) {
        return type;
      }
    }
    throw ArgumentError('Unknown ChangeType name: $name');
  }

  /// Check if this is a create operation
  bool get isCreate {
    return [
      ChangeType.createSchedule,
      ChangeType.createTimeSlot,
      ChangeType.createScheduleConfig,
      ChangeType.createInvitation,
      ChangeType.addChild,
      ChangeType.addVehicle,
      ChangeType.addFamilyMember,
    ].contains(this);
  }

  /// Check if this is an update operation
  bool get isUpdate {
    return [
      ChangeType.updateSchedule,
      ChangeType.updateTimeSlot,
      ChangeType.updateScheduleConfig,
      ChangeType.updateAssignment,
      ChangeType.bulkUpdateSchedules,
      ChangeType.updateFamily,
      ChangeType.updateChild,
      ChangeType.updateVehicle,
      ChangeType.updateMember,
    ].contains(this);
  }

  /// Check if this is a delete operation
  bool get isDelete {
    return [
      ChangeType.deleteSchedule,
      ChangeType.deleteTimeSlot,
      ChangeType.deleteScheduleConfig,
      ChangeType.removeAssignment,
      ChangeType.bulkDeleteSchedules,
      ChangeType.deleteChild,
      ChangeType.deleteVehicle,
      ChangeType.removeFamilyMember,
    ].contains(this);
  }

  /// Check if this is an assignment operation
  bool get isAssignment {
    return [
      ChangeType.assignVehicle,
      ChangeType.assignChildren,
      ChangeType.updateAssignment,
      ChangeType.removeAssignment,
    ].contains(this);
  }

  /// Check if this is a bulk operation
  bool get isBulk {
    return [
      ChangeType.bulkUpdateSchedules,
      ChangeType.bulkDeleteSchedules,
    ].contains(this);
  }

  /// Check if this is a sync operation
  bool get isSync {
    return [ChangeType.syncSchedules, ChangeType.syncConflicts].contains(this);
  }

  /// Check if this is a family operation
  bool get isFamily {
    return [
      ChangeType.updateFamily,
      ChangeType.addChild,
      ChangeType.updateChild,
      ChangeType.deleteChild,
      ChangeType.addVehicle,
      ChangeType.updateVehicle,
      ChangeType.deleteVehicle,
      ChangeType.addFamilyMember,
      ChangeType.removeFamilyMember,
      ChangeType.updateMember,
    ].contains(this);
  }

  /// Check if this is a schedule operation
  bool get isSchedule {
    return [
      ChangeType.createSchedule,
      ChangeType.updateSchedule,
      ChangeType.deleteSchedule,
      ChangeType.createTimeSlot,
      ChangeType.updateTimeSlot,
      ChangeType.deleteTimeSlot,
      ChangeType.createScheduleConfig,
      ChangeType.updateScheduleConfig,
      ChangeType.deleteScheduleConfig,
      ChangeType.optimizeSchedule,
    ].contains(this);
  }

  /// Check if this is an invitation operation
  bool get isInvitation {
    return [
      ChangeType.createInvitation,
      ChangeType.acceptInvitation,
      ChangeType.rejectInvitation,
    ].contains(this);
  }

  /// Get the priority level for this change type
  int get priority {
    if (isDelete) return 4; // Highest priority
    if (isCreate) return 3; // High priority
    if (isUpdate) return 2; // Medium priority
    if (isSync) return 1; // Low priority
    return 2; // Default medium priority
  }

  /// Check if this change type requires network connectivity
  bool get requiresNetwork => !isSync; // Sync operations can be queued

  /// Get the domain this change type belongs to
  String get domain {
    if (isFamily) return 'family';
    if (isSchedule) return 'schedule';
    if (isInvitation) return 'invitation';
    return 'general';
  }

  @override
  String toString() => displayName;
}

// Export all family entities
export 'family/assignments/index.dart';
export 'family/child_assignment.dart';
export 'family/child_assignment_data.dart';
// NOTE: child_assignment_simple.dart is excluded to avoid ambiguous export with child_assignment.dart
export 'family/child.dart';
export 'family/core_assignment.dart';
export 'family/driver_license.dart';
export 'family/family_assignment_context.dart';
export 'family/family_core.dart';
export 'family/family.dart';
// NOTE: family_decomposed.dart is excluded due to missing interface dependencies
export 'family/family_invitation.dart';
export 'family/family_member.dart';
export 'family/family_permissions.dart';
export 'family/group_invitation.dart';
export 'family/interfaces/assignment_interfaces.dart';
export 'family/interfaces/family_member_operations.dart';
export 'family/interfaces/family_children_operations.dart';
export 'family/interfaces/family_vehicle_operations.dart';
export 'family/member_status.dart';
export 'family/transportation_assignment.dart';
// NOTE: vehicle_assignment.dart is DEPRECATED - use schedule/vehicle_assignment.dart instead
export 'family/vehicle.dart';

// Export invitations (keeping existing)
export 'invitations/invitation.dart';

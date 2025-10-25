import 'package:equatable/equatable.dart';

/// Core Family Permissions domain entity
class FamilyPermissions extends Equatable {
  final String id;
  final String familyId;
  final String userId;
  final bool canManageFamily;
  final bool canInviteMembers;
  final bool canManageMembers;
  final bool canManageChildren;
  final bool canManageVehicles;
  final bool canManageSchedule;
  final bool canViewReports;
  final bool isAdmin;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FamilyPermissions({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.canManageFamily,
    required this.canInviteMembers,
    required this.canManageMembers,
    required this.canManageChildren,
    required this.canManageVehicles,
    required this.canManageSchedule,
    required this.canViewReports,
    required this.isAdmin,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  FamilyPermissions copyWith({
    String? id,
    String? familyId,
    String? userId,
    bool? canManageFamily,
    bool? canInviteMembers,
    bool? canManageMembers,
    bool? canManageChildren,
    bool? canManageVehicles,
    bool? canManageSchedule,
    bool? canViewReports,
    bool? isAdmin,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FamilyPermissions(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      userId: userId ?? this.userId,
      canManageFamily: canManageFamily ?? this.canManageFamily,
      canInviteMembers: canInviteMembers ?? this.canInviteMembers,
      canManageMembers: canManageMembers ?? this.canManageMembers,
      canManageChildren: canManageChildren ?? this.canManageChildren,
      canManageVehicles: canManageVehicles ?? this.canManageVehicles,
      canManageSchedule: canManageSchedule ?? this.canManageSchedule,
      canViewReports: canViewReports ?? this.canViewReports,
      isAdmin: isAdmin ?? this.isAdmin,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        familyId,
        userId,
        canManageFamily,
        canInviteMembers,
        canManageMembers,
        canManageChildren,
        canManageVehicles,
        canManageSchedule,
        canViewReports,
        isAdmin,
        role,
        createdAt,
        updatedAt,
      ];
}

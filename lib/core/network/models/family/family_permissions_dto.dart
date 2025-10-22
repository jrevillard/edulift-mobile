import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/converters/domain_converter.dart';
import 'package:edulift/core/domain/entities/family.dart';

part 'family_permissions_dto.freezed.dart';
part 'family_permissions_dto.g.dart';

/// Family Permissions Data Transfer Object
/// Mirrors backend FamilyPermissions API response structure exactly
@freezed
abstract class FamilyPermissionsDto
    with _$FamilyPermissionsDto
    implements DomainConverter<FamilyPermissions> {
  const factory FamilyPermissionsDto({
    required String id,
    required String familyId,
    required String userId,
    required bool canManageFamily,
    required bool canInviteMembers,
    required bool canManageMembers,
    required bool canManageChildren,
    required bool canManageVehicles,
    required bool canManageSchedule,
    required bool canViewReports,
    required bool isAdmin,
    required String role,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FamilyPermissionsDto;

  factory FamilyPermissionsDto.fromJson(Map<String, dynamic> json) =>
      _$FamilyPermissionsDtoFromJson(json);

  const FamilyPermissionsDto._();

  @override
  FamilyPermissions toDomain() {
    return FamilyPermissions(
      id: id,
      familyId: familyId,
      userId: userId,
      canManageFamily: canManageFamily,
      canInviteMembers: canInviteMembers,
      canManageMembers: canManageMembers,
      canManageChildren: canManageChildren,
      canManageVehicles: canManageVehicles,
      canManageSchedule: canManageSchedule,
      canViewReports: canViewReports,
      isAdmin: isAdmin,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create DTO from domain model
  factory FamilyPermissionsDto.fromDomain(FamilyPermissions permissions) {
    return FamilyPermissionsDto(
      id: permissions.id,
      familyId: permissions.familyId,
      userId: permissions.userId,
      canManageFamily: permissions.canManageFamily,
      canInviteMembers: permissions.canInviteMembers,
      canManageMembers: permissions.canManageMembers,
      canManageChildren: permissions.canManageChildren,
      canManageVehicles: permissions.canManageVehicles,
      canManageSchedule: permissions.canManageSchedule,
      canViewReports: permissions.canViewReports,
      isAdmin: permissions.isAdmin,
      role: permissions.role,
      createdAt: permissions.createdAt,
      updatedAt: permissions.updatedAt,
    );
  }
}

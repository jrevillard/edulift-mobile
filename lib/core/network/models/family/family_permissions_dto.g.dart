// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_permissions_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FamilyPermissionsDto _$FamilyPermissionsDtoFromJson(
  Map<String, dynamic> json,
) =>
    _FamilyPermissionsDto(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      userId: json['userId'] as String,
      canManageFamily: json['canManageFamily'] as bool,
      canInviteMembers: json['canInviteMembers'] as bool,
      canManageMembers: json['canManageMembers'] as bool,
      canManageChildren: json['canManageChildren'] as bool,
      canManageVehicles: json['canManageVehicles'] as bool,
      canManageSchedule: json['canManageSchedule'] as bool,
      canViewReports: json['canViewReports'] as bool,
      isAdmin: json['isAdmin'] as bool,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FamilyPermissionsDtoToJson(
  _FamilyPermissionsDto instance,
) =>
    <String, dynamic>{
      'id': instance.id,
      'familyId': instance.familyId,
      'userId': instance.userId,
      'canManageFamily': instance.canManageFamily,
      'canInviteMembers': instance.canInviteMembers,
      'canManageMembers': instance.canManageMembers,
      'canManageChildren': instance.canManageChildren,
      'canManageVehicles': instance.canManageVehicles,
      'canManageSchedule': instance.canManageSchedule,
      'canViewReports': instance.canViewReports,
      'isAdmin': instance.isAdmin,
      'role': instance.role,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

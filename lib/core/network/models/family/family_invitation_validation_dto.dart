import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_invitation_validation_dto.freezed.dart';
part 'family_invitation_validation_dto.g.dart';

@freezed
abstract class FamilyInvitationValidationDto
    with _$FamilyInvitationValidationDto {
  const factory FamilyInvitationValidationDto({
    required bool valid,
    String? familyId,
    String? familyName,
    String? inviterName,
    String? role,
    DateTime? expiresAt,
    String? error,
    String? errorCode,
    bool? requiresAuth,
    bool? alreadyMember,
  }) = _FamilyInvitationValidationDto;

  factory FamilyInvitationValidationDto.fromJson(Map<String, dynamic> json) =>
      FamilyInvitationValidationDto(
        valid: json['valid'] as bool,
        familyId: (json['family_id'] ?? json['familyId']) as String?,
        familyName: (json['family_name'] ?? json['familyName']) as String?,
        inviterName: (json['inviter_name'] ?? json['inviterName']) as String?,
        role: json['role'] as String?,
        expiresAt: json['expires_at'] != null
            ? DateTime.parse(json['expires_at'] as String)
            : null,
        error: json['error'] as String?,
        errorCode: json['errorCode'] as String?,
        requiresAuth: (json['requires_auth'] ?? json['requiresAuth']) as bool?,
        alreadyMember:
            (json['already_member'] ?? json['alreadyMember']) as bool?,
      );
}

@freezed
abstract class PermissionsDto with _$PermissionsDto {
  const factory PermissionsDto({
    required List<String> permissions,
    required String role,
  }) = _PermissionsDto;

  factory PermissionsDto.fromJson(Map<String, dynamic> json) =>
      _$PermissionsDtoFromJson(json);
}

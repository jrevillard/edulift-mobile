import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/converters/domain_converter.dart';
import 'package:edulift/core/domain/entities/family.dart';

part 'family_invitation_dto.freezed.dart';
part 'family_invitation_dto.g.dart';

/// Nested user object in FamilyInvitation API response
@freezed
abstract class InvitedByUser with _$InvitedByUser {
  const factory InvitedByUser({
    required String id,
    required String name,
    required String email,
  }) = _InvitedByUser;

  factory InvitedByUser.fromJson(Map<String, dynamic> json) =>
      _$InvitedByUserFromJson(json);
}

/// Family Invitation Data Transfer Object
/// Mirrors backend FamilyInvitation API response structure exactly
@freezed
abstract class FamilyInvitationDto
    with _$FamilyInvitationDto
    implements DomainConverter<FamilyInvitation> {
  const FamilyInvitationDto._();
  const factory FamilyInvitationDto({
    required String id,
    required String familyId,
    String? email, // Nullable as per backend schema
    required String role,
    String? personalMessage,
    required String invitedBy,
    required String createdBy,
    String? acceptedBy,
    required String status,
    required String inviteCode,
    required DateTime expiresAt,
    DateTime? acceptedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    required InvitedByUser invitedByUser,
  }) = _FamilyInvitationDto;

  factory FamilyInvitationDto.fromJson(Map<String, dynamic> json) =>
      _$FamilyInvitationDtoFromJson(json);

  // Override toDomain to return FamilyInvitation instead of generic Invitation
  @override
  FamilyInvitation toDomain() {
    return FamilyInvitation(
      id: id,
      familyId: familyId,
      email: email ?? '',
      role: role,
      invitedBy: invitedBy,
      invitedByName: invitedByUser.name,
      createdBy: createdBy,
      createdAt: createdAt,
      expiresAt: expiresAt,
      status: InvitationStatus.fromString(status),
      personalMessage: personalMessage,
      inviteCode: inviteCode,
      acceptedAt: acceptedAt,
      acceptedBy: acceptedBy,
      respondedAt:
          acceptedAt, // Use acceptedAt as respondedAt (DTO doesn't have separate field)
      updatedAt: updatedAt,
      // metadata defaults to null - no need to specify
    );
  }

  /// Create DTO from FamilyInvitation domain model
  factory FamilyInvitationDto.fromDomain(FamilyInvitation invitation) {
    return FamilyInvitationDto(
      id: invitation.id,
      familyId: invitation.familyId,
      email: invitation.email,
      role: invitation.role,
      personalMessage: invitation.personalMessage,
      invitedBy: invitation.invitedBy,
      createdBy: invitation.createdBy,
      status: invitation.status.value,
      inviteCode: invitation.inviteCode,
      expiresAt: invitation.expiresAt,
      createdAt: invitation.createdAt,
      updatedAt: invitation.updatedAt,
      invitedByUser: InvitedByUser(
        id: invitation.invitedBy,
        name: invitation.invitedByName,
        email: '', // FamilyInvitation doesn't have inviter email
      ),
    );
  }
}

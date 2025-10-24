// EduLift Mobile - WebSocket DTOs
// Minimal WebSocket-specific types and extensions

import '../family/family_invitation_dto.dart';

/// Invitation type DTO for WebSocket communication
enum InvitationTypeDto { family, group }

/// Invitation status DTO for WebSocket communication
enum InvitationStatusDto { pending, accepted, declined, expired, cancelled }

/// Extensions for WebSocket compatibility with official DTOs
extension FamilyInvitationWebSocketExtension on FamilyInvitationDto {
  /// Convert to WebSocket-friendly format
  Map<String, dynamic> toWebSocketJson() {
    return {
      'id': id,
      'type': 'family',
      'status': status,
      'inviterId': invitedBy,
      'inviterName': invitedByUser.name,
      'inviterEmail': invitedByUser.email,
      'recipientEmail': email ?? '',
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'respondedAt': acceptedAt?.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'familyId': familyId,
      'role': role,
      'message': personalMessage,
    };
  }

  /// Create from WebSocket event data
  static FamilyInvitationDto? fromWebSocketJson(Map<String, dynamic> json) {
    try {
      return FamilyInvitationDto(
        id: json['id'] as String,
        familyId: json['familyId'] as String,
        email: json['recipientEmail'] as String?,
        role: json['role'] as String? ?? 'member',
        personalMessage: json['message'] as String?,
        invitedBy: json['inviterId'] as String,
        createdBy: json['inviterId'] as String,
        status: json['status'] as String,
        inviteCode: json['inviteCode'] as String? ?? '',
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        acceptedAt: json['acceptedAt'] != null
            ? DateTime.parse(json['acceptedAt'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(
          json['updatedAt'] as String? ?? json['createdAt'] as String,
        ),
        invitedByUser: InvitedByUser(
          id: json['inviterId'] as String,
          name: json['inviterName'] as String,
          email: json['inviterEmail'] as String,
        ),
      );
    } catch (e) {
      return null;
    }
  }
}

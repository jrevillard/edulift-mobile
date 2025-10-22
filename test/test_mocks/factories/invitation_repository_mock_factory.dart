// EduLift Mobile - Invitation Repository Mock Factory
// Phase 2.3: Separate factory per repository as required by execution plan

import 'package:mockito/mockito.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/domain/entities/family.dart';

// Generated mocks
import '../generated_mocks.dart';

/// Invitation Repository Mock Factory
/// TRUTH: Provides consistent invitation mock behavior for BOTH invitation repositories
class InvitationRepositoryMockFactory {
  // General Invitation Repository
  static MockInvitationRepository createInvitationRepository({
    bool shouldSucceed = true,
    List<FamilyInvitation>? mockInvitations,
  }) {
    final mock = MockInvitationRepository();
    final invitations = mockInvitations ?? [_createMockInvitation()];

    if (shouldSucceed) {
      when(
        mock.getPendingInvitations(familyId: anyNamed('familyId')),
      ).thenAnswer((_) async => Result.ok(invitations));
      when(
        mock.declineInvitation(
          invitationId: anyNamed('invitationId'),
          reason: anyNamed('reason'),
        ),
      ).thenAnswer((_) async => Result.ok(invitations.first));
    } else {
      when(mock.getPendingInvitations(familyId: anyNamed('familyId'))).thenAnswer(
        (_) async =>
            const Result.err(ApiFailure(message: 'Invitation fetch failed')),
      );
    }

    return mock;
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  static FamilyInvitation _createMockInvitation() {
    return FamilyInvitation(
      id: 'test-invitation-id',
      familyId: 'test-family-id',
      email: 'test@example.com',
      role: 'member',
      invitedBy: 'test-inviter-id',
      invitedByName: 'Test Inviter',
      createdBy: 'test-inviter-id',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        1640995200000,
      ), // 2022-01-01
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        1641600000000,
      ), // 2022-01-08
      status: InvitationStatus.pending,
      inviteCode: 'TEST-CODE-123',
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        1640995200000,
      ), // 2022-01-01
    );
  }
}

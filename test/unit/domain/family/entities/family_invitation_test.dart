import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/family.dart';

import '../../../../test_mocks/test_mocks.dart';

void main() {
  setUpAll(() {
    setupMockFallbacks();
  });

  group('FamilyInvitation Entity', () {
    late FamilyInvitation tFamilyInvitation;
    late DateTime tCreatedAt;
    late DateTime tExpiresAt;

    setUp(() {
      tCreatedAt = DateTime(2024, 1, 15, 10);
      tExpiresAt = DateTime(2024, 1, 22, 10);

      tFamilyInvitation = FamilyInvitation(
        id: 'invitation-123',
        familyId: 'family-456',
        email: 'john@example.com',
        role: 'MEMBER',
        invitedBy: 'user-789',
        invitedByName: 'Jane Smith',
        createdBy: 'user-789',
        createdAt: tCreatedAt,
        expiresAt: tExpiresAt,
        status: InvitationStatus.pending,
        inviteCode: 'TEST-INVITE-CODE',
        updatedAt: tCreatedAt,
      );
    });

    group('Construction and Property Validation', () {
      test('should create family invitation with all required properties', () {
        // assert
        expect(tFamilyInvitation.id, equals('invitation-123'));
        expect(tFamilyInvitation.familyId, equals('family-456'));
        expect(tFamilyInvitation.email, equals('john@example.com'));
        expect(tFamilyInvitation.role, equals('MEMBER'));
        expect(tFamilyInvitation.invitedBy, equals('user-789'));
        expect(tFamilyInvitation.invitedByName, equals('Jane Smith'));
        expect(tFamilyInvitation.createdAt, equals(tCreatedAt));
        expect(tFamilyInvitation.expiresAt, equals(tExpiresAt));
        expect(tFamilyInvitation.status, equals(InvitationStatus.pending));
      });

      test('should create family invitation with optional properties', () {
        // arrange
        final invitation = FamilyInvitation(
          id: 'invitation-123',
          familyId: 'family-456',
          email: 'john@example.com',
          role: 'MEMBER',
          invitedBy: 'user-789',
          invitedByName: 'Jane Smith',
          createdBy: 'user-789',
          createdAt: tCreatedAt,
          expiresAt: tExpiresAt,
          status: InvitationStatus.pending,
          personalMessage: 'Welcome to our family!',
          inviteCode: 'ABC123XYZ',
          acceptedAt: DateTime(2024, 1, 16, 12),
          acceptedBy: 'user-999',
          respondedAt: DateTime(2024, 1, 16, 12),
          updatedAt: DateTime(2024, 1, 16, 12),
          metadata: const {'source': 'mobile_app'},
        );

        // assert
        expect(invitation.personalMessage, equals('Welcome to our family!'));
        expect(invitation.inviteCode, equals('ABC123XYZ'));
        expect(invitation.acceptedAt, equals(DateTime(2024, 1, 16, 12)));
        expect(invitation.acceptedBy, equals('user-999'));
        expect(invitation.respondedAt, equals(DateTime(2024, 1, 16, 12)));
        expect(invitation.updatedAt, equals(DateTime(2024, 1, 16, 12)));
        expect(invitation.metadata, equals({'source': 'mobile_app'}));
      });

      test('should allow null optional properties', () {
        // arrange & assert
        expect(tFamilyInvitation.personalMessage, isNull);
        expect(tFamilyInvitation.inviteCode, isNull);
        expect(tFamilyInvitation.acceptedAt, isNull);
        expect(tFamilyInvitation.acceptedBy, isNull);
        expect(tFamilyInvitation.respondedAt, isNull);
        expect(tFamilyInvitation.updatedAt, isNull);
        expect(tFamilyInvitation.metadata, isNull);
      });
    });

    group('Expiration Logic', () {
      test('isExpired should return false for future expiration date', () {
        // arrange
        final futureInvitation = tFamilyInvitation.copyWith(
          expiresAt: DateTime.now().add(const Duration(days: 7)),
          status: InvitationStatus.pending,
        );

        // act & assert
        expect(futureInvitation.isExpired, isFalse);
      });

      test('isExpired should return true for past expiration date', () {
        // arrange
        final pastInvitation = tFamilyInvitation.copyWith(
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
          status: InvitationStatus.pending,
        );

        // act & assert
        expect(pastInvitation.isExpired, isTrue);
      });

      test(
        'isExpired should return true for expired status regardless of date',
        () {
          // arrange
          final expiredInvitation = tFamilyInvitation.copyWith(
            expiresAt: DateTime.now().add(const Duration(days: 7)),
            status: InvitationStatus.expired,
          );

          // act & assert
          expect(expiredInvitation.isExpired, isTrue);
        },
      );

      test(
        'isPendingAndValid should return true for valid pending invitation',
        () {
          // arrange
          final validInvitation = tFamilyInvitation.copyWith(
            expiresAt: DateTime.now().add(const Duration(days: 7)),
            status: InvitationStatus.pending,
          );

          // act & assert
          expect(validInvitation.isPendingAndValid, isTrue);
        },
      );

      test('isPendingAndValid should return false for expired invitation', () {
        // arrange
        final expiredInvitation = tFamilyInvitation.copyWith(
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
          status: InvitationStatus.pending,
        );

        // act & assert
        expect(expiredInvitation.isPendingAndValid, isFalse);
      });

      test('isPendingAndValid should return false for accepted invitation', () {
        // arrange
        final acceptedInvitation = tFamilyInvitation.copyWith(
          expiresAt: DateTime.now().add(const Duration(days: 7)),
          status: InvitationStatus.accepted,
        );

        // act & assert
        expect(acceptedInvitation.isPendingAndValid, isFalse);
      });

      test('timeUntilExpiration should return null for expired invitation', () {
        // arrange
        final expiredInvitation = tFamilyInvitation.copyWith(
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
          status: InvitationStatus.pending,
        );

        // act & assert
        expect(expiredInvitation.timeUntilExpiration, isNull);
      });

      test(
        'timeUntilExpiration should return duration for valid invitation',
        () {
          // arrange
          final futureTime = DateTime.now().add(const Duration(hours: 5));
          final validInvitation = tFamilyInvitation.copyWith(
            expiresAt: futureTime,
            status: InvitationStatus.pending,
          );

          // act
          final timeRemaining = validInvitation.timeUntilExpiration;

          // assert
          expect(timeRemaining, isNotNull);
          expect(
            timeRemaining!.inHours,
            equals(4),
          ); // allowing for some time passage
        },
      );
    });

    group('Display Text Formatting', () {
      test(
        'expirationDisplayText should return "Expired" for expired invitation',
        () {
          // arrange
          final expiredInvitation = tFamilyInvitation.copyWith(
            expiresAt: DateTime.now().subtract(const Duration(days: 1)),
            status: InvitationStatus.pending,
          );

          // act & assert
          expect(expiredInvitation.expirationDisplayText, equals('Expired'));
        },
      );

      test('expirationDisplayText should format days remaining correctly', () {
        // arrange
        final invitationIn3Days = tFamilyInvitation.copyWith(
          expiresAt: DateTime.now().add(const Duration(days: 3, hours: 12)),
          status: InvitationStatus.pending,
        );

        // act & assert
        expect(
          invitationIn3Days.expirationDisplayText,
          equals('3 days remaining'),
        );
      });

      test(
        'expirationDisplayText should format single day remaining correctly',
        () {
          // arrange
          final invitationIn1Day = tFamilyInvitation.copyWith(
            expiresAt: DateTime.now().add(const Duration(days: 1, hours: 12)),
            status: InvitationStatus.pending,
          );

          // act & assert
          expect(
            invitationIn1Day.expirationDisplayText,
            equals('1 day remaining'),
          );
        },
      );

      test('expirationDisplayText should format hours remaining correctly', () {
        // arrange
        final invitationIn5Hours = tFamilyInvitation.copyWith(
          expiresAt: DateTime.now().add(const Duration(hours: 5, minutes: 30)),
          status: InvitationStatus.pending,
        );

        // act & assert
        expect(
          invitationIn5Hours.expirationDisplayText,
          equals('5 hours remaining'),
        );
      });

      test(
        'expirationDisplayText should format single hour remaining correctly',
        () {
          // arrange
          final invitationIn1Hour = tFamilyInvitation.copyWith(
            expiresAt: DateTime.now().add(
              const Duration(hours: 1, minutes: 30),
            ),
            status: InvitationStatus.pending,
          );

          // act & assert
          expect(
            invitationIn1Hour.expirationDisplayText,
            equals('1 hour remaining'),
          );
        },
      );

      test(
        'expirationDisplayText should format minutes remaining correctly',
        () {
          // arrange
          final invitationIn30Mins = tFamilyInvitation.copyWith(
            expiresAt: DateTime.now().add(
              const Duration(minutes: 30, seconds: 30),
            ),
            status: InvitationStatus.pending,
          );

          // act
          final displayText = invitationIn30Mins.expirationDisplayText;

          // assert - should be either 30 or 31 minutes depending on timing
          expect(
            displayText,
            anyOf(
              equals('30 minutes remaining'),
              equals('31 minutes remaining'),
            ),
          );
        },
      );
    });

    group('Copy With Method', () {
      test('should copy with new status', () {
        // arrange & act
        final copied = tFamilyInvitation.copyWith(
          status: InvitationStatus.accepted,
        );

        // assert
        expect(copied.status, equals(InvitationStatus.accepted));
        expect(copied.id, equals(tFamilyInvitation.id));
        expect(copied.familyId, equals(tFamilyInvitation.familyId));
      });

      test('should copy with new acceptedAt and acceptedBy', () {
        // arrange
        final acceptedAt = DateTime(2024, 1, 16, 15, 30);

        // act
        final copied = tFamilyInvitation.copyWith(
          acceptedAt: acceptedAt,
          acceptedBy: 'user-accepted-123',
        );

        // assert
        expect(copied.acceptedAt, equals(acceptedAt));
        expect(copied.acceptedBy, equals('user-accepted-123'));
        expect(copied.status, equals(tFamilyInvitation.status)); // unchanged
      });

      test('should preserve original values when no changes provided', () {
        // arrange & act
        final copied = tFamilyInvitation.copyWith();

        // assert
        expect(copied, equals(tFamilyInvitation));
      });

      test('should copy with metadata updates', () {
        // arrange
        final newMetadata = {'updated': true, 'version': '2.0'};

        // act
        final copied = tFamilyInvitation.copyWith(metadata: newMetadata);

        // assert
        expect(copied.metadata, equals(newMetadata));
        expect(copied.id, equals(tFamilyInvitation.id));
      });
    });

    group('Equality and Hash Code', () {
      test('should be equal when all properties match', () {
        // arrange
        final invitation2 = FamilyInvitation(
          id: 'invitation-123',
          familyId: 'family-456',
          email: 'john@example.com',
          role: 'MEMBER',
          invitedBy: 'user-789',
          invitedByName: 'Jane Smith',
          createdBy: 'user-789',
          createdAt: tCreatedAt,
          expiresAt: tExpiresAt,
          status: InvitationStatus.pending,
          inviteCode: 'TEST-INVITE-CODE',
          updatedAt: tCreatedAt,
        );

        // act & assert
        expect(tFamilyInvitation, equals(invitation2));
        expect(tFamilyInvitation.hashCode, equals(invitation2.hashCode));
      });

      test('should not be equal when id differs', () {
        // arrange
        final invitation2 = tFamilyInvitation.copyWith(id: 'different-id');

        // act & assert
        expect(tFamilyInvitation, isNot(equals(invitation2)));
      });

      test('should not be equal when status differs', () {
        // arrange
        final invitation2 = tFamilyInvitation.copyWith(
          status: InvitationStatus.accepted,
        );

        // act & assert
        expect(tFamilyInvitation, isNot(equals(invitation2)));
      });

      test('should not be equal when email differs', () {
        // arrange
        final invitation2 = tFamilyInvitation.copyWith(
          email: 'different@example.com',
        );

        // act & assert
        expect(tFamilyInvitation, isNot(equals(invitation2)));
      });
    });

    group('ToString Method', () {
      test('should provide meaningful string representation', () {
        // act
        final stringRep = tFamilyInvitation.toString();

        // assert
        expect(stringRep, contains('FamilyInvitation'));
        expect(stringRep, contains('invitation-123'));
        expect(stringRep, contains('Smith Family'));
        expect(stringRep, contains('john@example.com'));
        expect(stringRep, contains('Pending'));
      });
    });

    group('Edge Cases and Business Logic', () {
      test('should handle special characters in email', () {
        // arrange
        const specialEmail = 'user+test@example.co.uk';
        final invitation = tFamilyInvitation.copyWith(email: specialEmail);

        // act & assert
        expect(invitation.email, equals(specialEmail));
      });

      test('should handle unicode characters in personal message', () {
        // arrange
        const unicodeMessage = 'Welcome! 🎉 Bienvenido! 欢迎!';
        final invitation = tFamilyInvitation.copyWith(
          personalMessage: unicodeMessage,
        );

        // act & assert
        expect(invitation.personalMessage, equals(unicodeMessage));
      });

      test('should handle empty metadata properly', () {
        // arrange
        final invitation = tFamilyInvitation.copyWith(
          metadata: <String, dynamic>{},
        );

        // act & assert
        expect(invitation.metadata, isEmpty);
        expect(invitation.metadata, isNotNull);
      });

      test('should handle null metadata properly', () {
        // arrange
        final invitation = tFamilyInvitation.copyWith();

        // act & assert
        expect(invitation.metadata, isNull);
      });
    });
  });

  group('FamilyInvitationValidation Entity', () {
    group('Success Factory', () {
      test('should create successful validation result', () {
        // arrange & act
        final validation = FamilyInvitationValidation.success(
          familyId: 'family-123',
          familyName: 'Test Family',
          role: 'MEMBER',
          email: 'test@example.com',
          inviterEmail: 'admin@example.com',
          existingUser: true,
          invitedByName: 'Admin User',
        );

        // assert
        expect(validation.valid, isTrue);
        expect(validation.familyId, equals('family-123'));
        expect(validation.familyName, equals('Test Family'));
        expect(validation.role, equals('MEMBER'));
        expect(validation.email, equals('test@example.com'));
        expect(validation.inviterEmail, equals('admin@example.com'));
        expect(validation.existingUser, isTrue);
        expect(validation.invitedByName, equals('Admin User'));
        expect(validation.error, isNull);
        expect(validation.errorCode, isNull);
      });
    });

    group('Failure Factory', () {
      test('should create failed validation result', () {
        // arrange & act
        final validation = FamilyInvitationValidation.failure(
          error: 'Invalid invitation code',
          errorCode: 'INVALID_CODE',
        );

        // assert
        expect(validation.valid, isFalse);
        expect(validation.error, equals('Invalid invitation code'));
        expect(validation.errorCode, equals('INVALID_CODE'));
        expect(validation.familyId, isNull);
        expect(validation.familyName, isNull);
        expect(validation.role, isNull);
      });
    });

    group('Copy With Method', () {
      test('should copy with updated fields', () {
        // arrange
        final original = FamilyInvitationValidation.success(
          familyId: 'family-123',
          familyName: 'Original Family',
          role: 'MEMBER',
        );

        // act
        final copied = original.copyWith(
          familyName: 'Updated Family',
          role: 'ADMIN',
        );

        // assert
        expect(copied.valid, isTrue);
        expect(copied.familyId, equals('family-123'));
        expect(copied.familyName, equals('Updated Family'));
        expect(copied.role, equals('ADMIN'));
      });
    });

    group('Equality and Hash Code', () {
      test('should be equal when all properties match', () {
        // arrange
        final validation1 = FamilyInvitationValidation.success(
          familyId: 'family-123',
          familyName: 'Test Family',
          role: 'MEMBER',
        );
        final validation2 = FamilyInvitationValidation.success(
          familyId: 'family-123',
          familyName: 'Test Family',
          role: 'MEMBER',
        );

        // act & assert
        expect(validation1, equals(validation2));
        expect(validation1.hashCode, equals(validation2.hashCode));
      });

      test('should not be equal when valid status differs', () {
        // arrange
        final success = FamilyInvitationValidation.success(
          familyId: 'family-123',
          familyName: 'Test Family',
          role: 'MEMBER',
        );
        final failure = FamilyInvitationValidation.failure(error: 'Error');

        // act & assert
        expect(success, isNot(equals(failure)));
      });
    });

    group('ToString Method', () {
      test('should provide meaningful string representation for success', () {
        // arrange
        final validation = FamilyInvitationValidation.success(
          familyId: 'family-123',
          familyName: 'Test Family',
          role: 'MEMBER',
        );

        // act
        final stringRep = validation.toString();

        // assert
        expect(stringRep, contains('FamilyInvitationValidation'));
        expect(stringRep, contains('valid: true'));
        expect(stringRep, contains('familyId: family-123'));
        expect(stringRep, contains('familyName: Test Family'));
        expect(stringRep, contains('error: null'));
      });

      test('should provide meaningful string representation for failure', () {
        // arrange
        final validation = FamilyInvitationValidation.failure(
          error: 'Invalid code',
        );

        // act
        final stringRep = validation.toString();

        // assert
        expect(stringRep, contains('FamilyInvitationValidation'));
        expect(stringRep, contains('valid: false'));
        expect(stringRep, contains('error: Invalid code'));
      });
    });
  });
}

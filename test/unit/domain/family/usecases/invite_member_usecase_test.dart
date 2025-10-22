import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:edulift/features/family/domain/usecases/invite_member_usecase.dart';
import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';

import '../../../../test_mocks/test_mocks.dart';

void main() {
  // Setup Mockito dummy values for Result types
  setUpAll(() {
    setupMockFallbacks();
  });

  group('InviteMemberUsecase', () {
    late InviteMemberUsecase usecase;
    late MockInvitationRepository mockRepository;

    setUp(() {
      mockRepository = MockInvitationRepository();
      reset(mockRepository);
      usecase = InviteMemberUsecase(mockRepository);
    });

    tearDown(() {
      clearInteractions(mockRepository);
    });

    group('Construction', () {
      test('should create usecase with repository dependency', () {
        // Arrange & Act
        final usecase = InviteMemberUsecase(mockRepository);

        // Assert
        expect(usecase, isA<InviteMemberUsecase>());
      });
    });

    group('Success Cases', () {
      test('should invite member successfully', () async {
        // Arrange
        const params = InviteMemberParams(
          familyId: 'family-123',
          email: 'john@example.com',
          role: FamilyRole.member,
          personalMessage: 'Join our family!',
        );

        final expectedInvitation = FamilyInvitation(
          id: 'invitation-789',
          familyId: 'family-123',
          email: 'john@example.com',
          role: FamilyRole.member.value,
          invitedBy: 'user-123',
          invitedByName: 'Test User',
          createdBy: 'user-123',
          createdAt: DateTime(2024),
          expiresAt: DateTime(2024, 1, 8),
          status: InvitationStatus.pending,
          personalMessage: 'Join our family!',
          inviteCode: 'TEST-INVITE-789',
          updatedAt: DateTime(2024),
        );

        when(
          mockRepository.sendFamilyInvitation(
            familyId: anyNamed('familyId'),
            email: anyNamed('email'),
            role: anyNamed('role'),
            message: anyNamed('message'),
          ),
        ).thenAnswer((_) async => Result.ok(expectedInvitation));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value, equals(expectedInvitation));
        verify(
          mockRepository.sendFamilyInvitation(
            familyId: 'family-123',
            email: 'john@example.com',
            role: FamilyRole.member.value,
            message: 'Join our family!',
          ),
        ).called(1);
      });

      test('should invite member without personal message', () async {
        // Arrange
        const params = InviteMemberParams(
          familyId: 'family-123',
          email: 'jane@example.com',
          role: FamilyRole.admin,
        );

        final expectedInvitation = FamilyInvitation(
          id: 'invitation-890',
          familyId: 'family-123',
          email: 'jane@example.com',
          role: FamilyRole.admin.value,
          invitedBy: 'admin-123',
          invitedByName: 'Admin User',
          createdBy: 'admin-123',
          createdAt: DateTime(2024),
          expiresAt: DateTime(2024, 1, 8),
          status: InvitationStatus.pending,
          inviteCode: 'TEST-INVITE-890',
          updatedAt: DateTime(2024),
        );

        when(
          mockRepository.sendFamilyInvitation(
            familyId: anyNamed('familyId'),
            email: anyNamed('email'),
            role: anyNamed('role'),
            message: anyNamed('message'),
          ),
        ).thenAnswer((_) async => Result.ok(expectedInvitation));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isSuccess, true);
        verify(
          mockRepository.sendFamilyInvitation(
            familyId: 'family-123',
            email: 'jane@example.com',
            role: FamilyRole.admin.value,
          ),
        ).called(1);
      });
    });

    group('Validation Errors', () {
      test('should fail when family ID is empty', () async {
        // Arrange
        const params = InviteMemberParams(
          familyId: '',
          email: 'john@example.com',
          role: FamilyRole.member,
        );

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, true);
        expect(result.error, isA<ApiFailure>());
        expect(result.error!.message, 'Family ID is required');
        verifyNever(
          mockRepository.sendFamilyInvitation(
            familyId: anyNamed('familyId'),
            email: anyNamed('email'),
            role: anyNamed('role'),
            message: anyNamed('message'),
          ),
        );
      });

      test('should fail when email is empty', () async {
        // Arrange
        const params = InviteMemberParams(
          familyId: 'family-123',
          email: '',
          role: FamilyRole.member,
        );

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, true);
        expect(result.error, isA<ApiFailure>());
        expect(result.error!.message, 'Email is required');
        verifyNever(
          mockRepository.sendFamilyInvitation(
            familyId: anyNamed('familyId'),
            email: anyNamed('email'),
            role: anyNamed('role'),
            message: anyNamed('message'),
          ),
        );
      });

      test('should fail when email format is invalid', () async {
        // Arrange
        const params = InviteMemberParams(
          familyId: 'family-123',
          email: 'invalid-email',
          role: FamilyRole.member,
        );

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, true);
        expect(result.error, isA<ApiFailure>());
        expect(result.error!.message, 'Invalid email format');
      });

      test('should accept valid email formats', () async {
        final validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'firstname+lastname@company.org',
          '123@numbers.net',
        ];

        for (final email in validEmails) {
          // Arrange
          final params = InviteMemberParams(
            familyId: 'family-123',
            email: email,
            role: FamilyRole.member,
          );

          final invitation = FamilyInvitation(
            id: 'invitation-test',
            familyId: 'family-123',
            email: email,
            role: FamilyRole.member.value,
            invitedBy: 'admin-123',
            invitedByName: 'Admin User',
            createdBy: 'admin-123',
            createdAt: DateTime.now(),
            expiresAt: DateTime.now().add(const Duration(days: 7)),
            status: InvitationStatus.pending,
            inviteCode: 'TEST-INVITE-${email.hashCode}',
            updatedAt: DateTime.now(),
          );

          when(
            mockRepository.sendFamilyInvitation(
              familyId: anyNamed('familyId'),
              email: anyNamed('email'),
              role: anyNamed('role'),
              message: anyNamed('message'),
            ),
          ).thenAnswer((_) async => Result.ok(invitation));

          // Act
          final result = await usecase.call(params);

          // Assert
          expect(
            result.isSuccess,
            true,
            reason: 'Email $email should be valid',
          );
        }
      });
    });

    group('Repository Errors', () {
      test('should handle unauthorized error from repository', () async {
        // Arrange
        const params = InviteMemberParams(
          familyId: 'family-123',
          email: 'john@example.com',
          role: FamilyRole.member,
        );

        when(
          mockRepository.sendFamilyInvitation(
            familyId: anyNamed('familyId'),
            email: anyNamed('email'),
            role: anyNamed('role'),
            message: anyNamed('message'),
          ),
        ).thenAnswer((_) async => Result.err(ApiFailure.unauthorized()));

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, true);
        expect(result.error, isA<ApiFailure>());
        expect(result.error!.statusCode, 401);
      });

      test('should handle bad request error', () async {
        // Arrange
        const params = InviteMemberParams(
          familyId: 'family-123',
          email: 'john@example.com',
          role: FamilyRole.member,
        );

        when(
          mockRepository.sendFamilyInvitation(
            familyId: anyNamed('familyId'),
            email: anyNamed('email'),
            role: anyNamed('role'),
            message: anyNamed('message'),
          ),
        ).thenAnswer(
          (_) async =>
              Result.err(ApiFailure.badRequest(message: 'Invalid role')),
        );

        // Act
        final result = await usecase.call(params);

        // Assert
        expect(result.isError, true);
        expect(result.error, isA<ApiFailure>());
        expect(result.error!.message, 'Invalid role');
      });
    });

    group('InviteMemberParams', () {
      test('should have correct equality and hashCode', () {
        // Arrange
        const params1 = InviteMemberParams(
          familyId: 'family-123',
          email: 'john@example.com',
          role: FamilyRole.member,
          personalMessage: 'Hello',
        );
        const params2 = InviteMemberParams(
          familyId: 'family-123',
          email: 'john@example.com',
          role: FamilyRole.member,
          personalMessage: 'Hello',
        );
        const params3 = InviteMemberParams(
          familyId: 'family-124',
          email: 'john@example.com',
          role: FamilyRole.member,
          personalMessage: 'Hello',
        );

        // Assert
        expect(params1, equals(params2));
        expect(params1.hashCode, equals(params2.hashCode));
        expect(params1, isNot(equals(params3)));
        expect(params1.hashCode, isNot(equals(params3.hashCode)));
      });
    });
  });
}

// CONSOLIDATED MOCK FACTORIES
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// This file provides factory methods for all consolidated mocks.
// Use this instead of individual factory files for better maintainability.

import 'package:mockito/mockito.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/domain/failures/invitation_failure.dart';
import 'package:edulift/features/family/domain/errors/family_invitation_error.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/security/biometric_service.dart';

// Import the consolidated generated mocks
import 'generated_mocks.dart';

/// CONSOLIDATED MOCK FACTORIES - All repository and service mock configurations
/// Replaces individual factory files for better maintainability

/// Auth Repository and Service Mock Factory
class AuthRepositoryMockFactory {
  static MockAuthRepository createAuthRepository({
    bool shouldSucceed = true,
    User? mockUser,
  }) {
    final mock = MockAuthRepository();
    final user = mockUser ?? _createMockUser();

    if (shouldSucceed) {
      when(mock.getCurrentUser()).thenAnswer((_) async => Result.ok(user));
      when(
        mock.isAuthenticated(),
      ).thenAnswer((_) async => const Result.ok(true));
    } else {
      when(mock.getCurrentUser()).thenAnswer(
        (_) async =>
            const Result.err(ApiFailure(message: 'Authentication failed')),
      );
    }

    return mock;
  }

  static MockAuthService createAuthService({
    bool isAuthenticated = true,
    User? mockUser,
  }) {
    final mock = MockAuthService();
    final user = mockUser ?? _createMockUser();

    when(
      mock.isAuthenticated(),
    ).thenAnswer((_) async => Result.ok(isAuthenticated));
    when(mock.getCurrentUser()).thenAnswer((_) async => Result.ok(user));
    when(mock.currentUser).thenReturn(isAuthenticated ? user : null);

    return mock;
  }

  static User _createMockUser() {
    return User(
      id: 'test-user-id',
      email: 'test@example.com',
      name: 'Test User',
      /* familyId removed - use FamilyMember entity */
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

/// Family Repository Mock Factory
class FamilyRepositoryMockFactory {
  static void configureSuccessFlow(MockFamilyRepository mock) {
    when(mock.createFamily(name: anyNamed('name'))).thenAnswer((
      invocation,
    ) async {
      final name = invocation.namedArguments[const Symbol('name')] as String;
      return Result.ok(TestDataFactory.createTestFamily(name: name));
    });

    when(
      mock.getCurrentFamily(),
    ).thenAnswer((_) async => Result.ok(TestDataFactory.createTestFamily()));
    when(
      mock.updateFamilyName(
        familyId: anyNamed('familyId'),
        name: anyNamed('name'),
      ),
    ).thenAnswer((_) async => Result.ok(TestDataFactory.createTestFamily()));
    when(
      mock.leaveFamily(familyId: anyNamed('familyId')),
    ).thenAnswer((_) async => const Result.ok(null));
  }

  static void configureCreationFailure(MockFamilyRepository mock) {
    when(mock.createFamily(name: anyNamed('name'))).thenAnswer(
      (_) async =>
          const Result.err(ApiFailure(message: 'Family creation failed')),
    );
  }
}

/// Group Repository Mock Factory
class GroupRepositoryMockFactory {
  static void configureSuccessFlow(MockGroupRepository mock) {
    when(
      mock.getGroups(),
    ).thenAnswer((_) async => Result.ok([TestDataFactory.createTestGroup()]));
    when(
      mock.createGroup(any),
    ).thenAnswer((_) async => Result.ok(TestDataFactory.createTestGroup()));
    when(
      mock.updateGroup(any, any),
    ).thenAnswer((_) async => Result.ok(TestDataFactory.createTestGroup()));
    when(mock.deleteGroup(any)).thenAnswer((_) async => const Result.ok(null));
  }

  static void configureFailureFlow(MockGroupRepository mock) {
    when(mock.getGroups()).thenAnswer(
      (_) async =>
          const Result.err(ApiFailure(message: 'Failed to load groups')),
    );
  }
}

/// Invitation Repository Mock Factory
class InvitationRepositoryMockFactory {
  static void configureSuccessFlow(MockInvitationRepository mock) {
    when(
      mock.inviteMember(
        familyId: anyNamed('familyId'),
        email: anyNamed('email'),
        role: anyNamed('role'),
        personalMessage: anyNamed('personalMessage'),
      ),
    ).thenAnswer(
      (_) async => Result.ok(TestDataFactory.createTestInvitation()),
    );

    when(
      mock.declineInvitation(
        invitationId: anyNamed('invitationId'),
        reason: anyNamed('reason'),
      ),
    ).thenAnswer(
      (_) async => Result.ok(TestDataFactory.createTestInvitation()),
    );

    when(
      mock.getPendingInvitations(familyId: anyNamed('familyId')),
    ).thenAnswer((_) async => const Result.ok([]));
  }

  static void configureFailureFlow(MockInvitationRepository mock) {
    when(
      mock.inviteMember(
        familyId: anyNamed('familyId'),
        email: anyNamed('email'),
        role: anyNamed('role'),
        personalMessage: anyNamed('personalMessage'),
      ),
    ).thenAnswer(
      (_) async => const Result.err(
        InvitationFailure(
          error: InvitationError.inviteOperationFailed,
          message: 'Failed to send invitation',
        ),
      ),
    );
  }
}

/// Schedule Repository Mock Factory
class ScheduleRepositoryMockFactory {
  static void configureSuccessFlow(MockGroupScheduleRepository mock) {
    when(
      mock.getWeeklySchedule(any, any),
    ).thenAnswer((_) async => const Result.ok([]));
    when(mock.getScheduleConfig(any)).thenAnswer(
      (_) async => Result.ok(TestDataFactory.createTestScheduleConfig()),
    );
    when(mock.upsertScheduleSlot(any, any, any, any)).thenAnswer(
      (_) async => Result.ok(TestDataFactory.createTestScheduleSlot()),
    );
  }

  static void configureFailureFlow(MockGroupScheduleRepository mock) {
    when(mock.getWeeklySchedule(any, any)).thenAnswer(
      (_) async =>
          const Result.err(ApiFailure(message: 'Failed to load schedule')),
    );
  }
}

// OnboardingRepositoryMockFactory removed - onboarding feature simplified without repository layer
// SeatOverrideRepositoryMockFactory removed - dead code (100% mock, no backend API)

/// MockConfigurator - Central mock configuration utility
class MockConfigurator {
  /// Reset all mock instances to clean state
  static void resetAll() {
    // Reset all mock instances - add specific resets as needed
    reset(MockAuthService());
    reset(MockAuthRepository());
    reset(MockFamilyRepository());
    reset(MockGroupRepository());
    reset(MockInvitationRepository());
    reset(MockGroupScheduleRepository());
    // MockOnboardingRepository removed - onboarding simplified
    // MockSeatOverrideRepository removed - dead code
    reset(MockBiometricService());
    reset(MockAdaptiveStorageService());
  }

  /// Configure all mocks for happy path scenarios
  static void configureHappyPath() {
    // Configure basic happy path for all major services
    // Individual tests can override specific behaviors as needed
  }
}

/// Core Services Mock Factory
class CoreServicesMockFactory {
  static void configureAuthService(
    MockAuthService mock, {
    bool isAuthenticated = true,
  }) {
    when(
      mock.isAuthenticated(),
    ).thenAnswer((_) async => Result.ok(isAuthenticated));
    when(mock.getCurrentUser()).thenAnswer(
      (_) async => Result.ok(AuthRepositoryMockFactory._createMockUser()),
    );
  }

  static void configureBiometricService(
    MockBiometricService mock, {
    bool isEnabled = true,
  }) {
    when(mock.isAvailable()).thenAnswer((_) async => isEnabled);
    when(
      mock.authenticate(
        reason: anyNamed('reason'),
        useErrorDialogs: anyNamed('useErrorDialogs'),
        stickyAuth: anyNamed('stickyAuth'),
        sensitiveTransaction: anyNamed('sensitiveTransaction'),
      ),
    ).thenAnswer(
      (_) async => isEnabled
          ? LegacyBiometricAuthResult.success()
          : LegacyBiometricAuthResult.error(message: 'Authentication failed'),
    );
  }

  static void configureStorageService(MockAdaptiveStorageService mock) {
    when(mock.write(any, any)).thenAnswer((_) async {});
    when(mock.read(any)).thenAnswer((_) async => null);
    when(mock.delete(any)).thenAnswer((_) async {});
    when(mock.clear()).thenAnswer((_) async {});
  }
}

// Test Dependency Injection Initializer
// Provides clean test setup and teardown utilities

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/domain/entities/family.dart'
    as family_entities;
import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/features/auth/domain/repositories/auth_repository.dart';

// Import all the services we need to mock - USING CORRECT DOMAIN SERVICE INTERFACES
import 'package:edulift/core/domain/services/auth_service.dart';
import 'package:edulift/core/services/user_status_service.dart';
import 'package:edulift/core/services/adaptive_storage_service.dart';
import 'package:edulift/core/security/biometric_service.dart';
import 'package:edulift/core/domain/services/localization_service.dart';
// Removed: ValidationService and UnifiedInvitationService no longer exist
import 'package:edulift/features/family/domain/repositories/family_repository.dart';
// Removed obsolete children_repository import
import 'package:edulift/features/family/domain/repositories/family_invitation_repository.dart';
import 'package:edulift/features/family/domain/usecases/get_family_usecase.dart';
// REMOVED: AddChildUsecase, UpdateChildUsecase, RemoveChildUsecase per consolidation plan
// These have been replaced with ChildrenService
import 'package:edulift/core/network/error_handler_service.dart';

// Import the comprehensive dummy value setup from test_mocks
import '../test_mocks/test_mocks.dart';

// Mock classes are defined in centralized test_mocks.mocks.dart
// REMOVED: MockGetFamilyUsecase - using consolidated version from generated_mocks.dart

// REMOVED: Mock classes for AddChildUsecase, UpdateChildUsecase, RemoveChildUsecase
// These have been replaced with ChildrenService per consolidation plan

class TestDIInitializer {
  static ProviderContainer? _testContainer;
  static final Map<Type, Mock> _mocks = {};

  static ProviderContainer initialize({List<Override>? overrides}) {
    _configureDummyValues();
    // Initialize test dependencies with provider container
    _testContainer?.dispose();
    _testContainer = _createTestContainer(overrides);
    return _testContainer!;
  }

  /// Create a new test container with mock overrides
  static ProviderContainer _createTestContainer(
    List<Override>? additionalOverrides,
  ) {
    _createMockServices();
    final overrides = <Override>[
      // Add provider overrides here when providers are available
      ...additionalOverrides ?? [],
    ];
    return ProviderContainer(overrides: overrides);
  }

  static void _configureDummyValues() {
    // Import the comprehensive dummy value setup from test_mocks
    // This provides ALL Result<T, E> dummy values needed for mockito
    setupMockFallbacks();

    // Additional dummy values specific to TestDI that aren't covered by setupMockitoForTest
    // These are legacy values that may still be needed
    provideDummy(
      const Err<family_entities.Family, ApiFailure>(
        ApiFailure(message: 'dummy', statusCode: 0),
      ),
    );
    provideDummy(
      const Err<Child, ApiFailure>(ApiFailure(message: 'dummy', statusCode: 0)),
    );
    provideDummy(const Ok<List<Child>, ApiFailure>(<Child>[]));
    provideDummy(
      const Err<void, ApiFailure>(ApiFailure(message: 'dummy', statusCode: 0)),
    );

    // Add missing dummy values identified from test failures
    provideDummy(
      const Err<void, Failure>(ApiFailure(message: 'dummy', statusCode: 0)),
    );
    provideDummy(
      const Err<AuthResult, Failure>(
        ApiFailure(message: 'dummy', statusCode: 0),
      ),
    );
    provideDummy(
      const Err<User, Failure>(ApiFailure(message: 'dummy', statusCode: 0)),
    );
    provideDummy(
      const Err<String?, ApiFailure>(
        ApiFailure(message: 'dummy', statusCode: 0),
      ),
    );

    // Add additional Result type variants that may be needed
    provideDummy(const Ok<void, Failure>(null));
    provideDummy(const Ok<void, ApiFailure>(null));
    provideDummy(const Ok<String?, ApiFailure>('dummy-token'));

    // CRITICAL FIX: Add Result<User, Failure> dummy for AuthService mocking
    provideDummy(
      Result.ok(
        User(
          id: 'dummy-user',
          email: 'dummy@test.com',
          name: 'Dummy User',
          timezone: 'UTC',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      ),
    );

    // CRITICAL FIX: Add AuthenticationResult dummy for auth repository tests
    provideDummy(
      Result<AuthenticationResult, ApiFailure>.ok(
        AuthenticationResult(
          accessToken: 'dummy-access-token',
          refreshToken: 'dummy-refresh-token',
          user: User(
            id: 'dummy-user-id',
            email: 'dummy@example.com',
            name: 'Dummy User',
            timezone: 'UTC',
            createdAt: DateTime(2024),
            updatedAt: DateTime(2024),
          ),
          expiresAt: DateTime(2024),
        ),
      ),
    );

    // Add error variant for AuthenticationResult
    provideDummy(
      const Result<AuthenticationResult, ApiFailure>.err(
        ApiFailure(message: 'Authentication failed', statusCode: 401),
      ),
    );

    // CRITICAL FIX: Add Vehicle and Vehicle List dummy values for form testing
    provideDummy(
      Result<Vehicle, ApiFailure>.ok(
        Vehicle(
          id: 'dummy-vehicle-id',
          name: 'Dummy Vehicle',
          capacity: 5,
          description: 'Test vehicle',
          familyId: 'dummy-family-id',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      ),
    );

    provideDummy(
      const Result<Vehicle, ApiFailure>.err(
        ApiFailure(message: 'Vehicle operation failed', statusCode: 400),
      ),
    );

    provideDummy(const Result<List<Vehicle>, ApiFailure>.ok(<Vehicle>[]));

    provideDummy(
      const Result<List<Vehicle>, ApiFailure>.err(
        ApiFailure(message: 'Failed to load vehicles', statusCode: 500),
      ),
    );

    // Add String result dummy values for auth operations
    provideDummy(const Result<String, ApiFailure>.ok('Success message'));

    provideDummy(
      const Result<String, ApiFailure>.err(
        ApiFailure(message: 'Operation failed', statusCode: 400),
      ),
    );

    // Add boolean result dummy values
    provideDummy(const Result<bool, ApiFailure>.ok(true));

    provideDummy(
      const Result<bool, ApiFailure>.err(
        ApiFailure(message: 'Validation failed', statusCode: 400),
      ),
    );

    // Add AuthConfig dummy values
    provideDummy(
      const Result<AuthConfig, ApiFailure>.ok(
        AuthConfig(
          isMagicLinkEnabled: true,
          isBiometricEnabled: false,
          tokenExpiryMinutes: 60,
        ),
      ),
    );

    // CRITICAL FIX: Add ErrorHandlingResult dummy to prevent FakeUsedError
    provideDummy(
      const ErrorHandlingResult(
        classification: ErrorClassification(
          category: ErrorCategory.unexpected,
          severity: ErrorSeverity.minor,
          isRetryable: false,
          requiresUserAction: false,
          analysisData: {},
        ),
        userMessage: UserErrorMessage(
          titleKey: 'error.test.title',
          messageKey: 'error.test.message',
          severity: ErrorSeverity.minor,
        ),
        wasLogged: true,
        wasReported: false,
      ),
    );

    // CRITICAL FIX: Add missing Invitation Result dummy values
    final dummyInvitation = Invitation(
      id: 'dummy-invitation-id',
      type: InvitationType.family,
      status: InvitationStatus.pending,
      direction: InvitationDirection.sent,
      inviterId: 'dummy-inviter-id',
      inviterName: 'Dummy Inviter',
      inviterEmail: 'inviter@example.com',
      recipientEmail: 'recipient@example.com',
      recipientId: 'dummy-recipient-id',
      role: 'member',
      familyId: 'dummy-family-id',
      familyName: 'Dummy Family',
      message: 'Welcome to our family!',
      inviteCode: 'DUMMY123',
      createdAt: DateTime(2024),
      expiresAt: DateTime(2024).add(const Duration(days: 7)),
      metadata: const {'source': 'test'},
    );

    // Result<Invitation, ApiFailure> variations
    provideDummy(Result<Invitation, ApiFailure>.ok(dummyInvitation));
    provideDummy(
      const Result<Invitation, ApiFailure>.err(
        ApiFailure(message: 'Invitation operation failed', statusCode: 400),
      ),
    );

    // Result<List<Invitation>, ApiFailure> variations
    provideDummy(const Result<List<Invitation>, ApiFailure>.ok(<Invitation>[]));
    provideDummy(Result<List<Invitation>, ApiFailure>.ok([dummyInvitation]));
    provideDummy(
      const Result<List<Invitation>, ApiFailure>.err(
        ApiFailure(message: 'Failed to load invitations', statusCode: 500),
      ),
    );

    // Result<Invitation, Failure> variations (in case they're used)
    provideDummy(Result<Invitation, Failure>.ok(dummyInvitation));
    provideDummy(
      const Result<Invitation, Failure>.err(
        ApiFailure(message: 'Invitation operation failed', statusCode: 400),
      ),
    );

    // Result<List<Invitation>, Failure> variations
    provideDummy(const Result<List<Invitation>, Failure>.ok(<Invitation>[]));
    provideDummy(Result<List<Invitation>, Failure>.ok([dummyInvitation]));
    provideDummy(
      const Result<List<Invitation>, Failure>.err(
        ApiFailure(message: 'Failed to load invitations', statusCode: 500),
      ),
    );

    // MockTail handles Future types automatically when the inner type is registered
  }

  static Future<void> tearDown() async {
    // Clean up test dependencies
    _testContainer?.dispose();
    _testContainer = null;
    _mocks.clear();
  }

  static T getMock<T>() {
    return _mocks[T] as T;
  }

  /// Get the current test container
  static ProviderContainer? getTestContainer() {
    return _testContainer;
  }

  static void resetMocks() {
    for (final mock in _mocks.values) {
      reset(mock);
    }
  }

  /// Create mock services and store them for later access
  static Map<String, Mock> _createMockServices() {
    // Create mock services
    final authService = MockAuthService();
    final userStatusService = MockUserStatusService();
    final storageService = MockAdaptiveStorageService();
    final biometricService = MockBiometricService();
    final localizationService = MockLocalizationService();
    final familyRepository = MockFamilyRepository();
    // Note: Children operations are now part of FamilyRepository
    final invitationRepository = MockInvitationRepository();
    final getFamilyUsecase = MockGetFamilyUsecase();

    // Store mocks for later access
    _mocks[AuthService] = authService;
    _mocks[UserStatusService] = userStatusService;
    _mocks[AdaptiveStorageService] = storageService;
    _mocks[BiometricService] = biometricService;
    _mocks[LocalizationService] = localizationService;
    _mocks[FamilyRepository] = familyRepository;
    // Note: Children operations are now part of FamilyRepository
    _mocks[InvitationRepository] = invitationRepository;
    _mocks[GetFamilyUsecase] = getFamilyUsecase;

    // Return mocks for provider overrides
    return {
      'authService': authService,
      'userStatusService': userStatusService,
      'storageService': storageService,
      'biometricService': biometricService,
      'localizationService': localizationService,
      'familyRepository': familyRepository,
      // Note: Children operations are now part of FamilyRepository
      'invitationRepository': invitationRepository,
      'getFamilyUsecase': getFamilyUsecase,
    };
  }
}

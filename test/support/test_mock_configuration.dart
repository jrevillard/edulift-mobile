// TEST MOCK CONFIGURATION
// Centralized mock configuration to fix 40+ test failures systematically
// PRINCIPLE 0: Addresses root cause of MockErrorHandlerService FakeUsedError

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:edulift/core/network/error_handler_service.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/domain/entities/groups/group.dart';
import 'package:edulift/features/family/presentation/utils/vehicle_form_mode.dart';
import 'package:edulift/core/domain/entities/invitations/invitation.dart';
import '../test_mocks/test_mocks.mocks.dart';

/// Centralized test mock configuration
/// THIS FIXES 40+ FAILURES caused by unstubbed MockErrorHandlerService
class TestMockConfiguration {
  /// Configure all global mocks and dummy values needed for tests
  static void setupGlobalMocks() {
    // Dummy values for Result<T, Failure> types - fixes MissingDummyValueError
    _setupResultDummyValues();

    // Dummy values for domain entities
    _setupEntityDummyValues();

    // Dummy values for error handling
    _setupErrorHandlingDummyValues();
  }

  /// Sets up MockErrorHandlerService with proper stubs to prevent FakeUsedError
  static void setupMockErrorHandlerService(
    MockErrorHandlerService mockErrorHandler,
  ) {
    when(
      mockErrorHandler.handleError(
        any,
        any,
        stackTrace: anyNamed('stackTrace'),
      ),
    ).thenAnswer(
      (_) async => const ErrorHandlingResult(
        classification: ErrorClassification(
          category: ErrorCategory.unexpected,
          severity: ErrorSeverity.minor,
          isRetryable: true,
          requiresUserAction: false,
          analysisData: {},
        ),
        userMessage: UserErrorMessage(
          titleKey: 'error.test.title',
          messageKey: 'error.test.operation_failed',
          actionableSteps: ['actionTryAgain'],
          canRetry: true,
          severity: ErrorSeverity.minor,
        ),
        wasLogged: true,
        wasReported: false,
      ),
    );
  }

  /// Set up dummy values for InvitationCode testing
  /// Extracted from inline test helper to centralize mock infrastructure
  static void setUpDummyInvitationCode() {
    provideDummy(
      InvitationCode(
        code: 'dummy-code',
        targetId: 'dummy-target',
        targetName: 'Dummy Target',
        createdById: 'dummy-creator',
        createdByName: 'Dummy Creator',
        type: InvitationType.family,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
      ),
    );

    provideDummy<Result<List<InvitationCode>, ApiFailure>>(
      const Result.ok(<InvitationCode>[]),
    );
    provideDummy<Result<void, ApiFailure>>(const Result.ok(null));
  }

  /// Configure ErrorHandlerService mock properly to prevent FakeUsedError
  static void setupErrorHandlerMock(MockErrorHandlerService mockErrorHandler) {
    // CRITICAL: This stub prevents FakeUsedError in 40+ tests
    when(mockErrorHandler.handleError(any, any)).thenAnswer(
      (_) async => const ErrorHandlingResult(
        classification: ErrorClassification(
          category: ErrorCategory.unexpected,
          severity: ErrorSeverity.minor,
          isRetryable: false,
          requiresUserAction: false,
          analysisData: {},
        ),
        userMessage: UserErrorMessage(
          titleKey: 'error.test.title',
          messageKey: 'error.test.handled_successfully',
          severity: ErrorSeverity.minor,
        ),
        wasLogged: true,
        wasReported: false,
      ),
    );

    // Handle API failures with proper enum values
    when(
      mockErrorHandler.handleError(any, argThat(isA<ApiFailure>())),
    ).thenAnswer(
      (_) async => const ErrorHandlingResult(
        classification: ErrorClassification(
          category: ErrorCategory.network,
          severity: ErrorSeverity.major,
          isRetryable: true,
          requiresUserAction: false,
          analysisData: {'type': 'api_failure'},
        ),
        userMessage: UserErrorMessage(
          titleKey: 'error.network.title',
          messageKey: 'error.network.connection',
          actionableSteps: ['actionCheckConnection', 'actionTryAgain'],
          canRetry: true,
        ),
        wasLogged: true,
        wasReported: true,
      ),
    );

    // Handle validation failures
    when(
      mockErrorHandler.handleError(any, argThat(isA<ValidationFailure>())),
    ).thenAnswer(
      (_) async => const ErrorHandlingResult(
        classification: ErrorClassification(
          category: ErrorCategory.validation,
          severity: ErrorSeverity.minor,
          isRetryable: false,
          requiresUserAction: true,
          analysisData: {'type': 'validation_failure'},
        ),
        userMessage: UserErrorMessage(
          titleKey: 'error.validation.title',
          messageKey: 'error.validation.input',
          actionableSteps: ['actionReviewInfo', 'actionFillRequired'],
          severity: ErrorSeverity.minor,
        ),
        wasLogged: true,
        wasReported: false,
      ),
    );

    // Handle network connection failures
    when(
      mockErrorHandler.handleError(any, argThat(isA<NoConnectionFailure>())),
    ).thenAnswer(
      (_) async => const ErrorHandlingResult(
        classification: ErrorClassification(
          category: ErrorCategory.network,
          severity: ErrorSeverity.major,
          isRetryable: true,
          requiresUserAction: true,
          analysisData: {'type': 'no_connection'},
        ),
        userMessage: UserErrorMessage(
          titleKey: 'error.connection.title',
          messageKey: 'error.connection.no_internet',
          actionableSteps: ['actionCheckConnection', 'actionTryAgain'],
          canRetry: true,
        ),
        wasLogged: true,
        wasReported: false,
      ),
    );

    // Handle server failures
    when(
      mockErrorHandler.handleError(any, argThat(isA<ServerFailure>())),
    ).thenAnswer(
      (_) async => const ErrorHandlingResult(
        classification: ErrorClassification(
          category: ErrorCategory.server,
          severity: ErrorSeverity.major,
          isRetryable: true,
          requiresUserAction: false,
          analysisData: {'type': 'server_failure'},
        ),
        userMessage: UserErrorMessage(
          titleKey: 'error.server.title',
          messageKey: 'error.server.unavailable',
          actionableSteps: ['actionTryAgain'],
          canRetry: true,
        ),
        wasLogged: true,
        wasReported: true,
      ),
    );

    // Handle cache failures (using storage category)
    when(
      mockErrorHandler.handleError(any, argThat(isA<CacheFailure>())),
    ).thenAnswer(
      (_) async => const ErrorHandlingResult(
        classification: ErrorClassification(
          category: ErrorCategory.storage,
          severity: ErrorSeverity.minor,
          isRetryable: true,
          requiresUserAction: false,
          analysisData: {'type': 'cache_failure'},
        ),
        userMessage: UserErrorMessage(
          titleKey: 'error.cache.title',
          messageKey: 'error.cache.access',
          actionableSteps: ['actionTryAgain'],
          canRetry: true,
          severity: ErrorSeverity.minor,
        ),
        wasLogged: true,
        wasReported: false,
      ),
    );

    // Handle unknown exceptions
    when(
      mockErrorHandler.handleError(any, argThat(isA<Exception>())),
    ).thenAnswer(
      (_) async => const ErrorHandlingResult(
        classification: ErrorClassification(
          category: ErrorCategory.unexpected,
          severity: ErrorSeverity.critical,
          isRetryable: false,
          requiresUserAction: true,
          analysisData: {'type': 'unknown_exception'},
        ),
        userMessage: UserErrorMessage(
          titleKey: 'error.unexpected.title',
          messageKey: 'error.unexpected.contact_support',
          actionableSteps: ['actionRestartApp', 'actionTryAgain'],
          severity: ErrorSeverity.critical,
        ),
        wasLogged: true,
        wasReported: true,
      ),
    );
  }

  /// Helper to create successful Result
  static Result<T, Failure> createSuccessResult<T>(T value) {
    return Result.ok(value);
  }

  /// Helper to create error Result
  static Result<T, Failure> createErrorResult<T>(String message) {
    return Result.err(ApiFailure(message: message, statusCode: 500));
  }

  // Private helper methods

  static void _setupResultDummyValues() {
    // Basic Result types that are commonly tested
    provideDummy<Result<String, Failure>>(const Result.ok('dummy-string'));
    provideDummy<Result<bool, Failure>>(const Result.ok(true));
    provideDummy<Result<void, Failure>>(const Result.ok(null));
    provideDummy<Result<void, ApiFailure>>(const Result.ok(null));

    // Schedule-specific Result types removed - schedules moved to separate domain

    // Groups-specific Result types that need dummy values
    provideDummy<Result<List<Group>, ApiFailure>>(const Result.ok([]));
    provideDummy<Result<Group, ApiFailure>>(Result.ok(_createDummyGroup()));

    // Additional schedule-related Result types
    provideDummy<Result<List<Map<String, dynamic>>, ApiFailure>>(
      const Result.ok([]),
    );
    provideDummy<Result<Map<String, dynamic>, ApiFailure>>(
      const Result.ok(<String, dynamic>{}),
    );
  }

  static void _setupEntityDummyValues() {
    // Core entities with minimal required fields
    provideDummy<DateTime>(DateTime.now());
    provideDummy<Duration>(const Duration(minutes: 30));
    provideDummy(VehicleFormMode.add);
    provideDummy(UserRole.user);
  }

  static void _setupErrorHandlingDummyValues() {
    provideDummy<Failure>(
      const ApiFailure(message: 'Test failure', statusCode: 500),
    );
    provideDummy<ApiFailure>(
      const ApiFailure(message: 'Test API failure', statusCode: 500),
    );
    provideDummy(ErrorContext.familyOperation('test_operation'));

    // Critical fix for MockErrorHandlerService FakeUsedError
    provideDummy<ErrorHandlingResult>(
      const ErrorHandlingResult(
        classification: ErrorClassification(
          category: ErrorCategory.unexpected,
          severity: ErrorSeverity.minor,
          isRetryable: true,
          requiresUserAction: false,
          analysisData: {},
        ),
        userMessage: UserErrorMessage(
          titleKey: 'error.test.title',
          messageKey: 'error.test.operation_failed',
          actionableSteps: ['actionTryAgain'],
          canRetry: true,
          severity: ErrorSeverity.minor,
        ),
        wasLogged: true,
        wasReported: false,
      ),
    );

    // Error handling components
    provideDummy<ErrorClassification>(
      const ErrorClassification(
        category: ErrorCategory.unexpected,
        severity: ErrorSeverity.minor,
        isRetryable: true,
        requiresUserAction: false,
        analysisData: {},
      ),
    );

    provideDummy<UserErrorMessage>(
      const UserErrorMessage(
        titleKey: 'error.test.title',
        messageKey: 'error.test.operation_failed',
        actionableSteps: ['actionTryAgain'],
        canRetry: true,
        severity: ErrorSeverity.minor,
      ),
    );
  }

  // Schedule dummy methods removed - schedules moved to separate domain

  static Group _createDummyGroup() {
    return Group(
      id: 'dummy-group',
      name: 'Dummy Group',
      familyId: 'dummy-family',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

// Easy setup function for provider tests
void setupProviderTestMocks() {
  setUpAll(() {
    TestMockConfiguration.setupGlobalMocks();
  });
}

// Easy setup function for widget tests
void setupWidgetTestMocks() {
  setUpAll(() {
    TestMockConfiguration.setupGlobalMocks();
  });
}

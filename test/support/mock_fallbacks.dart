// Mock Fallbacks for Common Provider Issues
// This file provides a centralized place to set up dummy values
// for complex types that Mockito needs help with.

import 'package:mockito/mockito.dart';

import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/services/user_status_service.dart';
import 'package:edulift/core/network/error_handler_service.dart';
import '../test_mocks/generated_mocks.dart';
import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/features/family/domain/usecases/get_family_usecase.dart';

/// Sets up all common mock fallbacks for testing
void setupMockFallbacks() {
  // Result types with common generic parameters
  provideDummy<Result<void, Failure>>(const Result.ok(null));
  provideDummy<Result<String, Failure>>(const Result.ok('test'));
  provideDummy<Result<bool, Failure>>(const Result.ok(true));
  provideDummy<Result<int, Failure>>(const Result.ok(0));

  // Common failure types
  provideDummy(const ApiFailure(message: 'Test failure', statusCode: 400));
  provideDummy(const NetworkFailure(message: 'Network error'));
  provideDummy(const CacheFailure(message: 'Cache error'));
  provideDummy(const ValidationFailure(message: 'Validation error'));

  // UserStatus for auth tests
  provideDummy(
    const UserStatus(
      exists: false,
      hasProfile: false,
      requiresName: true,
      email: 'test@example.com',
    ),
  );

  // Domain entities commonly used in tests
  provideDummy(
    Family(
      id: 'test-family-id',
      name: 'Test Family',
      createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
      updatedAt: DateTime.parse('2025-01-01T10:00:00Z'),
    ),
  );

  provideDummy(
    Child(
      id: 'test-child-id',
      name: 'Test Child',
      familyId: 'test-family-id',
      age: 8,
      createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
      updatedAt: DateTime.parse('2025-01-01T10:00:00Z'),
    ),
  );

  provideDummy(
    Vehicle(
      id: 'test-vehicle-id',
      name: 'Test Vehicle',
      capacity: 5,
      familyId: 'test-family-id',
      createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
      updatedAt: DateTime.parse('2025-01-01T10:00:00Z'),
    ),
  );

  provideDummy(
    FamilyMember(
      id: 'dummy-member-id',
      familyId: 'dummy-family-id',
      userId: 'dummy-user-id',
      role: FamilyRole.member,
      status: 'ACTIVE',
      joinedAt: DateTime.parse('2025-01-01T10:00:00Z'),
    ),
  );

  // Specific Result<FamilyMember, Failure> dummy
  provideDummy<Result<FamilyMember, Failure>>(
    Result.ok(
      FamilyMember(
        id: 'dummy-member-id',
        familyId: 'dummy-family-id',
        userId: 'dummy-user-id',
        role: FamilyRole.member,
        status: 'ACTIVE',
        joinedAt: DateTime.parse('2025-01-01T10:00:00Z'),
      ),
    ),
  );

  provideDummy(
    FamilyInvitation(
      id: 'test-invitation-id',
      familyId: 'test-family-id',
      email: 'invited@test.com',
      role: 'member',
      invitedBy: 'test-user-id',
      invitedByName: 'Test User',
      createdBy: 'test-user-id',
      createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
      expiresAt: DateTime.parse(
        '2025-01-01T10:00:00Z',
      ).add(const Duration(days: 7)),
      status: InvitationStatus.pending,
      inviteCode: 'TEST-INVITE-CODE',
      updatedAt: DateTime.parse('2025-01-01T10:00:00Z'),
    ),
  );

  // Lists of domain entities
  provideDummy<List<Child>>([]);
  provideDummy<List<Vehicle>>([]);
  provideDummy<List<FamilyMember>>([]);

  // FamilyData entity for GetFamilyUsecase tests
  provideDummy(
    const FamilyData(family: null, children: [], vehicles: [], members: []),
  );

  // Result types with domain entities
  provideDummy<Result<Family, Failure>>(
    Result.ok(
      Family(
        id: 'test-family-id',
        name: 'Test Family',
        createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
        updatedAt: DateTime.parse('2025-01-01T10:00:00Z'),
      ),
    ),
  );

  // FamilyData result type for GetFamilyUsecase
  provideDummy<Result<FamilyData, ApiFailure>>(
    const Result.ok(
      FamilyData(family: null, children: [], vehicles: [], members: []),
    ),
  );

  // Result<Family?, ApiFailure> for nullable family queries
  provideDummy<Result<Family?, ApiFailure>>(
    Result.ok(
      Family(
        id: 'test-family-id',
        name: 'Test Family',
        createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
        updatedAt: DateTime.parse('2025-01-01T10:00:00Z'),
      ),
    ),
  );

  provideDummy<Result<Child, Failure>>(
    Result.ok(
      Child(
        id: 'test-child-id',
        name: 'Test Child',
        familyId: 'test-family-id',
        age: 8,
        createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
        updatedAt: DateTime.parse('2025-01-01T10:00:00Z'),
      ),
    ),
  );

  provideDummy<Result<Vehicle, Failure>>(
    Result.ok(
      Vehicle(
        id: 'test-vehicle-id',
        name: 'Test Vehicle',
        capacity: 5,
        familyId: 'test-family-id',
        createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
        updatedAt: DateTime.parse('2025-01-01T10:00:00Z'),
      ),
    ),
  );

  provideDummy<Result<List<Child>, Failure>>(const Result.ok([]));
  provideDummy<Result<List<Vehicle>, Failure>>(const Result.ok([]));
  provideDummy<Result<List<FamilyMember>, Failure>>(const Result.ok([]));
  provideDummy<Result<FamilyMember, ApiFailure>>(
    Result.ok(
      FamilyMember(
        id: 'dummy-member-id',
        familyId: 'dummy-family-id',
        userId: 'dummy-user-id',
        role: FamilyRole.member,
        status: 'ACTIVE',
        joinedAt: DateTime.parse('2025-01-01T10:00:00Z'),
      ),
    ),
  );

  // FamilyInvitation result type that was missing
  provideDummy<Result<FamilyInvitation, ApiFailure>>(
    Result.ok(
      FamilyInvitation(
        id: 'test-invitation-id',
        familyId: 'test-family-id',
        email: 'invited@test.com',
        role: 'member',
        invitedBy: 'test-user-id',
        invitedByName: 'Test User',
        createdBy: 'test-user-id',
        createdAt: DateTime.parse('2025-01-01T10:00:00Z'),
        expiresAt: DateTime.parse(
          '2025-01-01T10:00:00Z',
        ).add(const Duration(days: 7)),
        status: InvitationStatus.pending,
        inviteCode: 'TEST-INVITE-CODE',
        updatedAt: DateTime.parse('2025-01-01T10:00:00Z'),
      ),
    ),
  );

  // UserStatus result type
  provideDummy<Result<UserStatus, Failure>>(
    const Result.ok(
      UserStatus(
        exists: false,
        hasProfile: false,
        requiresName: true,
        email: 'test@example.com',
      ),
    ),
  );

  // DateTime for common use
  provideDummy(DateTime.parse('2025-01-01T10:00:00Z'));

  // Basic types that might be missing
  provideDummy('test-string');
  provideDummy(42);
  provideDummy(true);
  provideDummy<double>(0.0);

  // Optional types
  provideDummy<String?>(null);
  provideDummy<int?>(null);
  provideDummy<bool?>(null);

  // ErrorHandlingResult for MockErrorHandlerService
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
        messageKey: 'error.test.message',
        actionableSteps: ['actionTryAgain'],
        canRetry: true,
        severity: ErrorSeverity.minor,
      ),
      wasLogged: true,
      wasReported: false,
    ),
  );

  // ErrorClassification for error handling
  provideDummy<ErrorClassification>(
    const ErrorClassification(
      category: ErrorCategory.unexpected,
      severity: ErrorSeverity.minor,
      isRetryable: true,
      requiresUserAction: false,
      analysisData: {},
    ),
  );

  // UserErrorMessage for error handling
  provideDummy<UserErrorMessage>(
    const UserErrorMessage(
      titleKey: 'error.test.title',
      messageKey: 'error.test.message',
      actionableSteps: ['actionTryAgain'],
      canRetry: true,
      severity: ErrorSeverity.minor,
    ),
  );
}

/// Sets up MockErrorHandlerService with proper stubs to prevent FakeUsedError
void setupMockErrorHandlerService(MockErrorHandlerService mockErrorHandler) {
  when(
    mockErrorHandler.handleError(any, any, stackTrace: anyNamed('stackTrace')),
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

void main() {
  // Mock fallbacks are support utilities - no direct tests needed
  // This file provides centralized mock fallback configuration
}

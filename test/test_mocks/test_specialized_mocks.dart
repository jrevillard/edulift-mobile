// Specialized Test Mocks - For specific testing scenarios
// These are test-specific implementations that extend real classes
// Following 2025 Flutter testing standards for centralized mock organization

import 'package:edulift/core/security/biometric_service.dart';
import 'package:local_auth/local_auth.dart';

// New service architecture mocks - using core AuthService directly
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/domain/services/auth_service.dart' as core;
import 'package:edulift/features/auth/domain/repositories/auth_repository.dart'
    show AuthenticationResult;
import 'package:mockito/mockito.dart';

// TestableVehiclesNotifier removed - vehicle functionality consolidated into FamilyNotifier

/// Test-specific BiometricService for controlled testing
class MockBiometricService extends BiometricService {
  LegacyBiometricAuthResult? _nextResult;

  MockBiometricService() : super(LocalAuthentication());

  /// Set the result that will be returned by the next authenticate call
  void setNextResult(LegacyBiometricAuthResult result) {
    _nextResult = result;
  }

  @override
  Future<LegacyBiometricAuthResult> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool sensitiveTransaction = false,
  }) async {
    if (_nextResult != null) {
      final result = _nextResult!;
      _nextResult = null; // Reset after use
      return result;
    }
    return LegacyBiometricAuthResult.success();
  }
}

/// Manual mock for core AuthService with mockito behaviors
/// Updated to use core AuthService directly - no more feature wrapper
class MockFeatureAuthService extends Mock implements core.AuthService {
  @override
  Future<Result<void, ApiFailure>> sendMagicLink(
    String email, {
    String? name,
    String? inviteCode,
  }) async {
    return super.noSuchMethod(
          Invocation.method(
            #sendMagicLink,
            [email],
            {#name: name, #inviteCode: inviteCode},
          ),
          returnValue: Future.value(const Result<void, ApiFailure>.ok(null)),
        ) ??
        Future.value(const Result<void, ApiFailure>.ok(null));
  }

  @override
  Future<Result<core.AuthResult, Failure>> authenticateWithMagicLink(
    String token, {
    String? inviteCode,
  }) async {
    return super.noSuchMethod(
          Invocation.method(#authenticateWithMagicLink, [token]),
          returnValue: Future.value(
            Result<core.AuthResult, Failure>.ok(
              core.AuthResult(
                user: User(
                  id: 'test-user-id',
                  email: 'test@example.com',
                  name: 'Test User',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  preferredLanguage: 'en',
                  timezone: 'UTC',
                ),
                token: 'test-token',
              ),
            ),
          ),
        ) ??
        Future.value(
          Result<core.AuthResult, ApiFailure>.ok(
            core.AuthResult(
              user: User(
                id: 'test-user-id',
                email: 'test@example.com',
                name: 'Test User',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                preferredLanguage: 'en',
                timezone: 'UTC',
              ),
              token: 'test-token',
            ),
          ),
        );
  }

  @override
  Future<Result<User, Failure>> getCurrentUser({
    bool forceRefresh = false,
    Map<String, dynamic>? userData,
  }) async {
    return super.noSuchMethod(
          Invocation.method(#getCurrentUser, []),
          returnValue: Future.value(
            Result<User, Failure>.ok(
              User(
                id: 'test-user-id',
                email: 'test@example.com',
                name: 'Test User',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                preferredLanguage: 'en',
                timezone: 'UTC',
              ),
            ),
          ),
        ) ??
        Future.value(
          Result<User, ApiFailure>.ok(
            User(
              id: 'test-user-id',
              email: 'test@example.com',
              name: 'Test User',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              preferredLanguage: 'en',
              timezone: 'UTC',
            ),
          ),
        );
  }

  @override
  Future<Result<User, ApiFailure>> enableBiometricAuth() async {
    return super.noSuchMethod(
          Invocation.method(#enableBiometricAuth, []),
          returnValue: Future.value(
            Result<User, ApiFailure>.ok(
              User(
                id: 'test-user-id',
                email: 'test@example.com',
                name: 'Test User',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                preferredLanguage: 'en',
                timezone: 'UTC',
              ),
            ),
          ),
        ) ??
        Future.value(
          Result<User, ApiFailure>.ok(
            User(
              id: 'test-user-id',
              email: 'test@example.com',
              name: 'Test User',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              preferredLanguage: 'en',
              timezone: 'UTC',
            ),
          ),
        );
  }

  @override
  Future<Result<User, ApiFailure>> disableBiometricAuth() async {
    return super.noSuchMethod(
          Invocation.method(#disableBiometricAuth, []),
          returnValue: Future.value(
            Result<User, ApiFailure>.ok(
              User(
                id: 'test-user-id',
                email: 'test@example.com',
                name: 'Test User',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                preferredLanguage: 'en',
                timezone: 'UTC',
              ),
            ),
          ),
        ) ??
        Future.value(
          Result<User, ApiFailure>.ok(
            User(
              id: 'test-user-id',
              email: 'test@example.com',
              name: 'Test User',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              preferredLanguage: 'en',
              timezone: 'UTC',
            ),
          ),
        );
  }

  @override
  Future<Result<void, ApiFailure>> logout() async {
    return super.noSuchMethod(
          Invocation.method(#logout, []),
          returnValue: Future.value(const Result<void, ApiFailure>.ok(null)),
        ) ??
        Future.value(const Result<void, ApiFailure>.ok(null));
  }

  @override
  Future<Result<bool, ApiFailure>> isAuthenticated() async {
    return super.noSuchMethod(
          Invocation.method(#isAuthenticated, []),
          returnValue: Future.value(const Result<bool, ApiFailure>.ok(true)),
        ) ??
        Future.value(const Result<bool, ApiFailure>.ok(true));
  }

  // Mock refreshToken method for backward compatibility with tests
  Future<Result<AuthenticationResult, ApiFailure>> refreshToken(
    String token,
  ) async {
    return super.noSuchMethod(
          Invocation.method(#refreshToken, [token]),
          returnValue: Future.value(
            Result<AuthenticationResult, ApiFailure>.ok(
              AuthenticationResult(
                accessToken: 'new-access-token',
                refreshToken: 'new-refresh-token',
                user: User(
                  id: 'test-user-id',
                  email: 'test@example.com',
                  name: 'Test User',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  preferredLanguage: 'en',
                  timezone: 'UTC',
                ),
                expiresAt: DateTime.now().add(const Duration(hours: 1)),
              ),
            ),
          ),
        ) ??
        Future.value(
          Result<AuthenticationResult, ApiFailure>.ok(
            AuthenticationResult(
              accessToken: 'new-access-token',
              refreshToken: 'new-refresh-token',
              user: User(
                id: 'test-user-id',
                email: 'test@example.com',
                name: 'Test User',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                preferredLanguage: 'en',
                timezone: 'UTC',
              ),
              expiresAt: DateTime.now().add(const Duration(hours: 1)),
            ),
          ),
        );
  }
}

/// Factory for creating centralized test mocks
class TestMockFactory {
  // TestableVehiclesNotifier factory removed - functionality consolidated into FamilyNotifier
  // TODO: Create TestableFamilyNotifier factory if needed for vehicle testing

  /// Create MockBiometricService with success as default
  static MockBiometricService createMockBiometricService() {
    return MockBiometricService();
  }

  /// Create MockFeatureAuthService with default success behaviors
  static MockFeatureAuthService createMockFeatureAuthService() {
    return MockFeatureAuthService();
  }
}

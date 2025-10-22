// EduLift Mobile - Auth Repository Mock Factory
// Phase 2.3: Separate factory per repository as required by execution plan

import 'package:mockito/mockito.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/utils/result.dart';

// Generated mocks
import '../generated_mocks.dart';

/// Auth Repository Mock Factory
/// TRUTH: Provides consistent authentication mock behavior
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

  // ========================================
  // HELPER METHODS
  // ========================================

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

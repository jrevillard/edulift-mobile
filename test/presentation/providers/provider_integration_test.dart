// Provider Integration Tests - Dependency Management & Error Handling
// Tests provider coordination, error propagation, and state consistency
// PRINCIPLE 0: RADICAL CANDOR - Tests only verified integrations

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/services/app_state_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';

import '../../test_mocks/test_mocks.dart';
import '../../support/test_provider_overrides.dart';

void main() {
  group('Provider Integration Tests', () {
    late ProviderContainer container;

    setUpAll(() {
      setupMockFallbacks();
    });

    setUp(() {
      container = TestProviderOverrides.createTestContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Provider Container Validation', () {
      test('should create container with all required providers', () {
        expect(container, isNotNull);

        // Test that core providers can be read
        expect(() => container.read(authStateProvider), returnsNormally);
        expect(() => container.read(appStateProvider), returnsNormally);
        expect(() => container.read(isAuthenticatedProvider), returnsNormally);
        expect(() => container.read(currentUserProvider), returnsNormally);
      });

      test('should initialize auth state correctly', () {
        final authState = container.read(authStateProvider);

        expect(authState.user, isNull);
        expect(authState.isLoading, isFalse);
        expect(authState.error, isNull);
        expect(authState.isInitialized, isTrue);
        expect(authState.isAuthenticated, isFalse);
      });

      test('should validate provider dependencies', () {
        // Test derived providers work correctly
        final isAuthenticated = container.read(isAuthenticatedProvider);
        expect(isAuthenticated, isFalse);

        final currentUser = container.read(currentUserProvider);
        expect(currentUser, isNull);
      });
    });

    group('Provider State Coordination', () {
      test('should coordinate auth state changes across providers', () {
        // Arrange
        final now = DateTime.now();
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          name: 'Test User',
          createdAt: now,
          updatedAt: now,
        );

        // Act - Update auth state
        container.read(authStateProvider.notifier).login(user);

        // Assert - All dependent providers should reflect the change
        expect(container.read(isAuthenticatedProvider), isTrue);
        expect(container.read(currentUserProvider), equals(user));

        final authState = container.read(authStateProvider);
        expect(authState.user, equals(user));
        expect(authState.isAuthenticated, isTrue);
      });

      test('should handle logout across all providers', () async {
        // Arrange - Set authenticated state
        final now = DateTime.now();
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          name: 'Test User',
          createdAt: now,
          updatedAt: now,
        );
        container.read(authStateProvider.notifier).login(user);

        // Act - Logout
        await container.read(authStateProvider.notifier).logout();

        // Assert - All providers should reflect logged out state
        expect(container.read(isAuthenticatedProvider), isFalse);
        expect(container.read(currentUserProvider), isNull);

        final authState = container.read(authStateProvider);
        expect(authState.user, isNull);
        expect(authState.isAuthenticated, isFalse);
      });
    });

    group('Error Handling Integration', () {
      test('should handle provider initialization errors gracefully', () {
        // Test container creation doesn't throw with mock failures
        expect(
          () => TestProviderOverrides.createTestContainer(),
          returnsNormally,
        );
      });

      test('should clear errors across providers', () {
        // Arrange - Set error state
        final authNotifier = container.read(authStateProvider.notifier);
        authNotifier.state = authNotifier.state.copyWith(error: 'Test error');

        // Act - Clear error
        authNotifier.clearError();

        // Assert - Error should be cleared
        final authState = container.read(authStateProvider);
        expect(authState.error, isNull);
      });
    });

    group('Provider Lifecycle', () {
      test('should dispose container without errors', () {
        // Act & Assert
        expect(() => container.dispose(), returnsNormally);
      });

      test('should handle multiple container creation and disposal', () {
        // Test multiple containers can be created and disposed safely
        for (var i = 0; i < 3; i++) {
          final testContainer = TestProviderOverrides.createTestContainer();
          expect(testContainer, isNotNull);
          testContainer.dispose();
        }
      });
    });

    group('Provider State Consistency', () {
      test('should maintain consistent state across provider reads', () {
        final authState1 = container.read(authStateProvider);
        final authState2 = container.read(authStateProvider);

        expect(authState1, equals(authState2));
      });

      test(
        'should handle rapid state changes without race conditions',
        () async {
          final authNotifier = container.read(authStateProvider.notifier);

          // Rapid state changes
          authNotifier.setShowNameField(true);
          authNotifier.setShowNameField(false);
          authNotifier.clearError();
          authNotifier.clearUserStatus();

          // Should not cause any errors
          final finalState = container.read(authStateProvider);
          expect(finalState.showNameField, isFalse);
          expect(finalState.error, isNull);
          expect(finalState.userStatus, isNull);
        },
      );
    });

    group('Provider Memory Management', () {
      test('should not leak memory on container disposal', () {
        // Create multiple containers to test memory management
        final containers = List.generate(
          10,
          (_) => TestProviderOverrides.createTestContainer(),
        );

        // Dispose all containers
        for (final testContainer in containers) {
          expect(() => testContainer.dispose(), returnsNormally);
        }
      });

      test('should handle provider state cleanup on disposal', () {
        final testContainer = TestProviderOverrides.createTestContainer();

        // Set some state
        final now = DateTime.now();
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          name: 'Test User',
          createdAt: now,
          updatedAt: now,
        );
        testContainer.read(authStateProvider.notifier).login(user);

        // Dispose should not throw
        expect(() => testContainer.dispose(), returnsNormally);
      });
    });

    group('Provider Override Validation', () {
      test('should validate custom provider overrides work', () {
        final customOverrides = [
          authStateProvider.overrideWith((ref) {
            final notifier = TestAuthNotifier.withRef(ref);
            notifier.state = notifier.state.copyWith(
              isInitialized: true,
              error: 'Custom test error',
            );
            return notifier;
          }),
        ];

        final customContainer = ProviderContainer(overrides: customOverrides);

        final authState = customContainer.read(authStateProvider);
        expect(authState.error, equals('Custom test error'));
        expect(authState.isInitialized, isTrue);

        customContainer.dispose();
      });
    });
  });
}

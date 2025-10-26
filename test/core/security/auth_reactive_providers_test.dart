// SECURITY TEST: Verify auth-reactive providers prevent data leakage
// This test ensures that family providers properly clean up when user logs out

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/features/family/presentation/providers/family_provider.dart';
import 'package:edulift/features/family/presentation/providers/create_family_provider.dart';

void main() {
  group('Auth-Reactive Providers Security Tests', () {
    test('familyProvider returns empty state when user is null', () async {
      // Create a provider container with no user (null)
      final container = ProviderContainer(
        overrides: [currentUserProvider.overrideWith((ref) => null)],
      );

      // Read the family provider state
      final familyState = container.read(familyProvider);

      // Verify it returns empty state, not cached data from previous user
      expect(familyState.family, isNull);
      expect(familyState.children, isEmpty);
      expect(familyState.vehicles, isEmpty);
      expect(familyState.error, isNull);
      expect(familyState.isLoading, isFalse);

      container.dispose();
    });

    test(
      'createFamilyProvider returns empty state when user is null',
      () async {
        // Create a provider container with no user (null)
        final container = ProviderContainer(
          overrides: [currentUserProvider.overrideWith((ref) => null)],
        );

        // Read the create family provider state
        final createFamilyState = container.read(createFamilyProvider);

        // Verify it returns empty state, not cached data from previous user
        expect(createFamilyState.family, isNull);
        expect(createFamilyState.error, isNull);
        expect(createFamilyState.isLoading, isFalse);
        expect(createFamilyState.isSuccess, isFalse);

        container.dispose();
      },
    );

    test('convenience providers return empty data when user is null', () async {
      // Create a provider container with no user (null)
      final container = ProviderContainer(
        overrides: [currentUserProvider.overrideWith((ref) => null)],
      );

      // Test family convenience providers
      expect(container.read(familyChildrenProvider), isEmpty);
      expect(container.read(familyDataProvider), isNull);
      expect(container.read(familyVehiclesProvider), isEmpty);
      expect(container.read(selectedVehicleProvider), isNull);
      expect(container.read(vehiclesCountProvider), equals(0));
      expect(container.read(totalCapacityProvider), equals(0));

      container.dispose();
    });

    test(
      'providers auto-dispose when user changes from authenticated to null',
      () async {
        // Create a mock user
        final mockUser = User(
          id: 'test-user-id',
          email: 'test@example.com',
          name: 'Test User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Start with authenticated user
        final container = ProviderContainer(
          overrides: [currentUserProvider.overrideWith((ref) => mockUser)],
        );

        // Read providers to ensure they're initialized
        container.read(familyProvider);
        container.read(createFamilyProvider);
        // DISABLED: invitationProvider removed;

        // Now override to null user (simulating logout)
        container.updateOverrides([
          currentUserProvider.overrideWith((ref) => null),
        ]);

        // Verify providers return empty state after user becomes null
        final familyState = container.read(familyProvider);
        final createFamilyState = container.read(createFamilyProvider);

        expect(familyState.family, isNull);
        expect(familyState.children, isEmpty);
        expect(createFamilyState.family, isNull);

        container.dispose();
      },
    );

    // DISABLED: EmptyFamilyNotifier replaced with SafeFamilyNotifier pattern
    // test('EmptyFamilyNotifier prevents state mutations', () {
    //   final emptyNotifier = EmptyFamilyNotifier();
    //   // State should always return empty
    //   expect(emptyNotifier.state.family, isNull);
    //   expect(emptyNotifier.state.children, isEmpty);
    //   expect(emptyNotifier.state.vehicles, isEmpty);
    //   // Attempting to set state should have no effect
    //   final initialState = emptyNotifier.state;
    //   emptyNotifier.state = initialState.copyWith(
    //     isLoading: true,
    //     error: 'test error',
    //   );
    //   // State should remain empty (mutations prevented)
    //   expect(emptyNotifier.state.family, isNull);
    //   expect(emptyNotifier.state.children, isEmpty);
    //   expect(emptyNotifier.state.isLoading, isFalse);
    //   expect(emptyNotifier.state.error, isNull);
    // });

    // DISABLED: EmptyCreateFamilyNotifier replaced with SafeCreateFamilyNotifier pattern
    // test('EmptyCreateFamilyNotifier prevents state mutations', () {
    //   final emptyNotifier = EmptyCreateFamilyNotifier();

    //   // State should always return empty
    //   expect(emptyNotifier.state.family, isNull);
    //   expect(emptyNotifier.state.isLoading, isFalse);
    //   expect(emptyNotifier.state.isSuccess, isFalse);
    //   // Attempting to set state should have no effect
    //   final initialState = emptyNotifier.state;
    //   emptyNotifier.state = initialState.copyWith(
    //     isLoading: true,
    //     error: 'test error',
    //     isSuccess: true,
    //   );
    //   // State should remain empty (mutations prevented)
    //   expect(emptyNotifier.state.family, isNull);
    //   expect(emptyNotifier.state.isLoading, isFalse);
    //   expect(emptyNotifier.state.isSuccess, isFalse);
    //   expect(emptyNotifier.state.error, isNull);
    // });

    // DISABLED: EmptyInvitationNotifier replaced with SafeInvitationNotifier pattern
    // test('EmptyInvitationNotifier prevents state mutations', () {
    //   final emptyNotifier = EmptyInvitationNotifier();
    //   // State should always return empty
    //   expect(emptyNotifier.state.pendingInvitations, isEmpty);
    //   expect(emptyNotifier.state.sentInvitations, isEmpty);
    //   expect(emptyNotifier.state.isLoading, isFalse);
    //   // Attempting to set state should have no effect
    //   final initialState = emptyNotifier.state;
    //   emptyNotifier.state = initialState.copyWith(
    //     isLoading: true,
    //     error: 'test error',
    //   );
    //   // State should remain empty (mutations prevented)
    //   expect(emptyNotifier.state.pendingInvitations, isEmpty);
    //   expect(emptyNotifier.state.sentInvitations, isEmpty);
    //   expect(emptyNotifier.state.isLoading, isFalse);
    //   expect(emptyNotifier.state.error, isNull);
    // });
  });
}

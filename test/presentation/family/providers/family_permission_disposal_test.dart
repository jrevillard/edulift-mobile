import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Import the orchestrator provider
import 'package:edulift/features/family/presentation/providers/family_permission_orchestrator_provider.dart';

void main() {
  group('Provider Disposal Fix Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'FamilyPermissionOrchestratorProvider should properly manage native Riverpod caching',
      () {
        const familyId = 'test_family_id';

        // First access - should create provider
        final provider1 = familyPermissionOrchestratorProvider(familyId);
        final notifier1 = container.read(provider1.notifier);

        expect(notifier1, isNotNull);
        expect(notifier1.mounted, isTrue);

        // With native Riverpod caching, the orchestrator should work efficiently
        // without manual cache layer complexity
        expect(notifier1.familyId, equals(familyId));
      },
    );

    test(
      'FamilyPermissionOrchestratorProvider should not dispose during navigation simulation',
      () {
        const familyId = 'test_family_id';

        // First access - should create provider
        final provider1 = familyPermissionOrchestratorProvider(familyId);
        final notifier1 = container.read(provider1.notifier);

        expect(notifier1, isNotNull);
        expect(notifier1.mounted, isTrue);

        // Simulate navigation by accessing provider again
        // With keepAlive(), this should return the same instance
        final provider2 = familyPermissionOrchestratorProvider(familyId);
        final notifier2 = container.read(provider2.notifier);

        // Should be the same instance (keepAlive working)
        expect(notifier2, equals(notifier1));
        expect(notifier2.mounted, isTrue);

        // Provider should still be alive
        expect(notifier1.mounted, isTrue);
      },
    );

    test('Multiple family providers should work independently', () {
      const familyId1 = 'family_1';
      const familyId2 = 'family_2';

      // Access providers for different families
      final provider1 = familyPermissionOrchestratorProvider(familyId1);
      final provider2 = familyPermissionOrchestratorProvider(familyId2);

      final notifier1 = container.read(provider1.notifier);
      final notifier2 = container.read(provider2.notifier);

      // Should be different instances for different family IDs
      expect(notifier1, isNot(equals(notifier2)));
      expect(notifier1.mounted, isTrue);
      expect(notifier2.mounted, isTrue);

      // Both should have correct family IDs
      expect(notifier1.familyId, equals(familyId1));
      expect(notifier2.familyId, equals(familyId2));
    });

    test('Provider should survive container state refresh', () {
      const familyId = 'test_family_id';

      // Create provider
      final provider = familyPermissionOrchestratorProvider(familyId);
      final originalNotifier = container.read(provider.notifier);

      expect(originalNotifier.mounted, isTrue);

      // Simulate state change that might trigger provider refresh
      container.refresh(provider);

      // Provider should still be accessible (keepAlive effect)
      final notifierAfterRefresh = container.read(provider.notifier);
      expect(notifierAfterRefresh.mounted, isTrue);

      // After refresh, should still be functional with new instance
      expect(notifierAfterRefresh.familyId, equals(familyId));
    });
  });
}

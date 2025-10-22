import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/navigation/navigation_state.dart';

void main() {
  group('NavigationState', () {
    test(
      'hasPendingNavigation returns true when trigger is set (no route needed)',
      () {
        // This test verifies our critical fix for magic link redirect
        final state = NavigationState(
          trigger: NavigationTrigger.magicLinkSuccess,
          timestamp: DateTime.now(),
        );

        expect(
          state.hasPendingNavigation,
          isTrue,
          reason:
              'Should return true when trigger is set, even without pendingRoute',
        );
      },
    );

    test('hasPendingNavigation returns false when no trigger is set', () {
      const state = NavigationState();

      expect(
        state.hasPendingNavigation,
        isFalse,
        reason: 'Should return false when no trigger is set',
      );
    });

    test('afterMagicLinkSuccess creates state with trigger but no route', () {
      final notifier = NavigationStateNotifier();

      notifier.afterMagicLinkSuccess();

      expect(notifier.state.trigger, NavigationTrigger.magicLinkSuccess);
      expect(notifier.state.pendingRoute, isNull);
      expect(
        notifier.state.hasPendingNavigation,
        isTrue,
        reason:
            'Critical: Should have pending navigation to trigger router refresh',
      );
    });
  });
}

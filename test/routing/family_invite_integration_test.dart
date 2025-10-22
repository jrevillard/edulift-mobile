import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/router/app_routes.dart';
import 'package:edulift/features/family/presentation/pages/invite_member_page.dart';
import '../support/simple_widget_test_helper.dart';
import '../support/accessibility_test_helper.dart';
import '../support/test_provider_overrides.dart';

void main() {
  group('Family Invite Integration Tests', () {
    testWidgets('InviteMemberPage should render correctly when navigated to', (
      WidgetTester tester,
    ) async {
      // Test that the InviteMemberPage can be rendered independently
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestProviderOverrides.common,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: InviteMemberPage(),
          ),
        ),
      );

      await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

      // Verify key elements are present
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Role'), findsOneWidget);
      expect(find.byKey(const Key('send_invitation_button')), findsOneWidget);
      expect(find.text('Invite New Member'), findsOneWidget);

      // WCAG 2.1 AA Accessibility validation
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    testWidgets('should navigate to family invite route correctly', (
      WidgetTester tester,
    ) async {
      var invitePageVisited = false;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => TestHomePage(
              onInvitePressed: () => context.push(AppRoutes.inviteMember),
            ),
          ),
          GoRoute(
            path: AppRoutes.inviteMember,
            builder: (context, state) {
              invitePageVisited = true;
              return const Scaffold(
                body: Center(
                  child: Text('Invite Member Page Loaded Successfully'),
                ),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: TestProviderOverrides.common,
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );

      // Tap the invite button
      await tester.tap(find.byKey(const Key('invite_button')));
      await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

      // Verify navigation occurred
      expect(invitePageVisited, isTrue);
      expect(
        find.text('Invite Member Page Loaded Successfully'),
        findsOneWidget,
      );

      // WCAG 2.1 AA Accessibility validation for navigation
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    test('AppRoutes.inviteMember should match expected path', () {
      expect(AppRoutes.inviteMember, equals('/family/invite'));
    });
  });
}

class TestHomePage extends StatelessWidget {
  final VoidCallback onInvitePressed;

  const TestHomePage({super.key, required this.onInvitePressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Family Management')),
      body: Center(
        child: ElevatedButton(
          key: const Key('invite_button'),
          onPressed: onInvitePressed,
          child: const Text('Inviter dans la famille'),
        ),
      ),
    );
  }
}

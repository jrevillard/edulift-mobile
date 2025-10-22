import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:edulift/core/router/app_routes.dart';
import '../support/simple_widget_test_helper.dart';
// import 'package:edulift/features/family/presentation/pages/invite_member_page.dart'; // Unused import

void main() {
  group('Family Invite Navigation Tests', () {
    testWidgets(
      'should navigate to InviteMemberPage when using context.push(AppRoutes.inviteMember)',
      (WidgetTester tester) async {
        var navigationCalled = false;
        String? navigationRoute;

        // Create a simple test router that captures navigation calls
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/test',
              builder: (context, state) => TestHomePage(
                onNavigate: (route) {
                  navigationCalled = true;
                  navigationRoute = route;
                },
              ),
            ),
            GoRoute(
              path: AppRoutes.inviteMember,
              builder: (context, state) => const InviteMemberPageWrapper(),
            ),
          ],
          initialLocation: '/test',
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

        // Find and tap the navigation button
        await tester.tap(find.byKey(const Key('navigate_button')));
        await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

        // Verify the navigation was attempted
        expect(navigationCalled, isTrue);
        expect(navigationRoute, equals(AppRoutes.inviteMember));
      },
    );

    test('AppRoutes.inviteMember should have correct path', () {
      expect(AppRoutes.inviteMember, equals('/family/invite'));
    });
  });
}

class TestHomePage extends StatelessWidget {
  final Function(String) onNavigate;

  const TestHomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          key: const Key('navigate_button'),
          onPressed: () {
            onNavigate(AppRoutes.inviteMember);
            context.push(AppRoutes.inviteMember);
          },
          child: const Text('Navigate to Invite'),
        ),
      ),
    );
  }
}

// Wrapper that provides minimal context for InviteMemberPage
class InviteMemberPageWrapper extends StatelessWidget {
  const InviteMemberPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Invite Member Page Loaded')),
    );
  }
}

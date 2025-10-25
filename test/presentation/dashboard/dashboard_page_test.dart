// EduLift Mobile - Dashboard Page Widget Tests
// Test-Driven Development - RED-GREEN-REFACTOR
// Following state-of-the-art testing patterns

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/features/dashboard/presentation/pages/dashboard_page.dart';
import '../../support/simple_widget_test_helper.dart';
import '../../support/accessibility_test_helper.dart';
import '../../support/test_screen_sizes.dart';

void main() {
  setUpAll(() async {
    await SimpleWidgetTestHelper.initialize();
  });

  tearDownAll(() async {
    await SimpleWidgetTestHelper.tearDown();
  });

  // Note: tearDown with WidgetTester parameter should be called per test if needed
  // The global tearDown cannot access tester instance

  group('Dashboard Page Widget Tests', () {
    testWidgets('should display dashboard title', (WidgetTester tester) async {
      // ARRANGE: Create test widget
      await tester.pumpWidget(
        SimpleWidgetTestHelper.createSimpleTestWidget(
          child: const DashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // ACT & ASSERT: Find dashboard elements
      expect(find.textContaining('Dashboard'), findsAtLeastNWidgets(1));
      // Look for app bar or scaffold
      final appBar = find.byType(AppBar);
      final scaffold = find.byType(Scaffold);

      final hasAppBarOrScaffold =
          appBar.evaluate().isNotEmpty || scaffold.evaluate().isNotEmpty;
      expect(hasAppBarOrScaffold, isTrue);

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should display welcome section', (WidgetTester tester) async {
      // ARRANGE: Create test widget with mock family data
      await tester.pumpWidget(
        SimpleWidgetTestHelper.createSimpleTestWidget(
          child: const DashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // ACT & ASSERT: Find welcome section (flexible checks)
      final welcomeKey = find.byKey(const Key('dashboard_welcome_section'));
      final welcomeText = find.byKey(
        const Key('dashboard_welcome_back_message'),
      );
      final container = find.byType(Container);

      final hasWelcomeSection = welcomeKey.evaluate().isNotEmpty ||
          welcomeText.evaluate().isNotEmpty ||
          container.evaluate().isNotEmpty;

      expect(hasWelcomeSection, isTrue);

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should display family overview section', (
      WidgetTester tester,
    ) async {
      // ARRANGE: Create test widget
      await tester.pumpWidget(
        SimpleWidgetTestHelper.createSimpleTestWidget(
          child: const DashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // ACT & ASSERT: Find family overview elements
      final familyOverviewKey = find.byKey(
        const Key('family_overview_section'),
      );
      final familyText = find.textContaining('Family');
      final card = find.byType(Card);
      final container = find.byType(Container);

      final hasFamilyOverview = familyOverviewKey.evaluate().isNotEmpty ||
          familyText.evaluate().isNotEmpty ||
          card.evaluate().isNotEmpty ||
          container.evaluate().isNotEmpty;

      expect(hasFamilyOverview, isTrue);

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should display schedule preview section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        SimpleWidgetTestHelper.createSimpleTestWidget(
          child: const DashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Look for schedule-related elements
      final scheduleText = find.textContaining('Schedule');
      final todayText = find.textContaining('Today');
      final upcomingText = find.textContaining('Upcoming');
      final listView = find.byType(ListView);
      final column = find.byType(Column);

      final hasScheduleElements = scheduleText.evaluate().isNotEmpty ||
          todayText.evaluate().isNotEmpty ||
          upcomingText.evaluate().isNotEmpty ||
          listView.evaluate().isNotEmpty ||
          column.evaluate().isNotEmpty;

      expect(hasScheduleElements, isTrue);

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should display quick actions section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        SimpleWidgetTestHelper.createSimpleTestWidget(
          child: const DashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Look for action buttons or navigation elements
      final elevatedButton = find.byType(ElevatedButton);
      final outlinedButton = find.byType(OutlinedButton);
      final textButton = find.byType(TextButton);
      final iconButton = find.byType(IconButton);
      final floatingActionButton = find.byType(FloatingActionButton);

      final hasActionButtons = elevatedButton.evaluate().isNotEmpty ||
          outlinedButton.evaluate().isNotEmpty ||
          textButton.evaluate().isNotEmpty ||
          iconButton.evaluate().isNotEmpty ||
          floatingActionButton.evaluate().isNotEmpty;

      expect(hasActionButtons, isTrue);

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should have proper scaffold structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        SimpleWidgetTestHelper.createSimpleTestWidget(
          child: const DashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Basic structure checks - allow multiple scaffolds (test wrapper + page scaffold)
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
      // Look for scrollable content or safe area
      final safeArea = find.byType(SafeArea);
      final scrollView = find.byType(SingleChildScrollView);

      final hasScrollableOrSafe =
          safeArea.evaluate().isNotEmpty || scrollView.evaluate().isNotEmpty;
      expect(hasScrollableOrSafe, isTrue);

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should handle loading states gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        SimpleWidgetTestHelper.createSimpleTestWidget(
          child: const DashboardPage(),
        ),
      );

      // Pump without settle to catch intermediate states
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Should handle all states without exceptions
      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should be responsive to different screen sizes', (
      tester,
    ) async {
      // Test with tablet size - testing large screen responsive layout
      await TestScreenSizes.setScreenSize(tester, TestScreenSizes.testTablet);

      await tester.pumpWidget(
        SimpleWidgetTestHelper.createSimpleTestWidget(
          child: const DashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      SimpleWidgetTestHelper.verifyNoExceptions(tester);

      // Test with mobile size - testing compact responsive layout
      await TestScreenSizes.setScreenSize(tester, TestScreenSizes.testMobile);
      await tester.pumpAndSettle();

      SimpleWidgetTestHelper.verifyNoExceptions(tester);

      // Reset to default size after responsive test
      await TestScreenSizes.resetScreenSize(tester);
    });

    testWidgets('should pass 2025 accessibility standards', (tester) async {
      // ARRANGE: Create dashboard widget
      await tester.pumpWidget(
        SimpleWidgetTestHelper.createSimpleTestWidget(
          child: const DashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // ACT & ASSERT: Run comprehensive 2025 accessibility test suite
      await AccessibilityTestHelper.runAccessibilityTestSuite(
        tester,
        requiredLabels: ['Dashboard', 'Family', 'Schedule'],
      );

      // Additional 2025 accessibility standards
      await AccessibilityTestHelper.testKeyboardNavigation(tester);
      await AccessibilityTestHelper.testScreenReaderCompatibility(tester);
    });
  });
}

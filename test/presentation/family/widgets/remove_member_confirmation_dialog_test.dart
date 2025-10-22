import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/features/family/presentation/widgets/remove_member_confirmation_dialog.dart';
import 'package:edulift/core/domain/entities/family.dart';

import '../../../support/mock_fallbacks.dart';
import '../../../support/accessibility_test_helper.dart';
import '../../../support/test_provider_overrides.dart';
import '../../../support/localized_test_app.dart';

void main() {
  setUpAll(() {
    setupMockFallbacks();
  });

  group('RemoveMemberConfirmationDialog Widget Tests', () {
    late FamilyMember testMember;
    late FamilyMember adminMember;

    setUp(() {
      testMember = FamilyMember(
        id: 'member-123',
        familyId: 'family-456',
        userId: 'user-789',
        role: FamilyRole.member,
      status: 'ACTIVE',
        joinedAt: DateTime(2024),
        userName: 'John Doe',
        userEmail: 'john@example.com',
      );

      adminMember = FamilyMember(
        id: 'admin-123',
        familyId: 'family-456',
        userId: 'admin-789',
        role: FamilyRole.admin,
      status: 'ACTIVE',
        joinedAt: DateTime(2024),
        userName: 'Admin User',
        userEmail: 'admin@example.com',
      );
    });

    testWidgets('should display member information correctly', (tester) async {
      // Arrange
      final widget = createLocalizedTestApp(
        child: RemoveMemberConfirmationDialog(member: testMember),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Dialog Structure
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byKey(const Key('dialog_title')), findsOneWidget);
      expect(find.byKey(const Key('remove_button')), findsOneWidget);
      expect(find.byIcon(Icons.person_remove), findsOneWidget);

      // Assert - Member Information
      expect(find.byKey(const Key('member_name')), findsOneWidget);
      expect(find.byKey(const Key('member_role')), findsOneWidget);
      expect(find.text('J'), findsOneWidget); // First letter in avatar

      // Assert - UI Elements
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(
        find.byKey(const Key('remove_member_remove_member_cancel_button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('remove_button')), findsOneWidget);

      // Verify accessibility
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    testWidgets('should display admin member with admin icon', (tester) async {
      // Arrange
      final widget = ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: RemoveMemberConfirmationDialog(member: adminMember),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Admin User'), findsOneWidget);
      expect(find.text('ADMIN'), findsOneWidget);
      expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);

      // Verify accessibility
      await AccessibilityTestHelper.runAccessibilityTestSuite(tester);
    });

    testWidgets('should show warning message for member removal', (
      tester,
    ) async {
      // Arrange
      final widget = ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: RemoveMemberConfirmationDialog(member: testMember),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Warning text should be present
      expect(find.textContaining('permanently remove'), findsOneWidget);
      expect(
        find.textContaining('This action cannot be undone'),
        findsOneWidget,
      );
    });

    testWidgets('should handle cancel button correctly', (tester) async {
      // Arrange
      final widget = ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        RemoveMemberConfirmationDialog(member: testMember),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert dialog is shown
      expect(find.byType(RemoveMemberConfirmationDialog), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.byKey(const Key('remove_member_cancel_button')));
      await tester.pumpAndSettle();

      // Assert dialog is dismissed
      expect(find.byType(RemoveMemberConfirmationDialog), findsNothing);
    });

    testWidgets('should handle successful member removal', (tester) async {
      // Arrange - Use TestProviderOverrides for proper provider setup
      final widget = ProviderScope(
        overrides: TestProviderOverrides.common,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        RemoveMemberConfirmationDialog(member: testMember),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap Remove
      await tester.tap(find.byKey(const Key('remove_button')));
      await tester.pumpAndSettle(); // Complete async operation immediately

      // Assert - Focus on UI behavior rather than internal provider calls
      // The dialog should close after successful removal
      expect(
        find.byType(RemoveMemberConfirmationDialog),
        findsNothing,
      ); // Dialog should close
    });

    testWidgets('should handle removal failure with error message', (
      tester,
    ) async {
      // Arrange - Use common overrides which already have family configured
      // Note: This test should pass because the family provider now has proper state
      // The "failure" will be simulated by the mocked repository in common overrides
      final widget = ProviderScope(
        overrides: TestProviderOverrides.common,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        RemoveMemberConfirmationDialog(member: testMember),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap Remove
      await tester.tap(find.byKey(const Key('remove_button')));
      await tester.pump(); // Start async operation
      await tester.pumpAndSettle(); // Complete async operation

      // Assert
      expect(
        find.byType(RemoveMemberConfirmationDialog),
        findsOneWidget,
      ); // Dialog stays open
      expect(
        find.textContaining('Failed to remove member'),
        findsOneWidget,
      ); // Error message shown
    });

    testWidgets('should show loading state during removal', (tester) async {
      // Arrange - Use TestProviderOverrides for proper provider setup
      final widget = ProviderScope(
        overrides: TestProviderOverrides.common,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        RemoveMemberConfirmationDialog(member: testMember),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap Remove
      await tester.tap(find.byKey(const Key('remove_button')));
      await tester.pump(); // Trigger setState for loading state
      await tester.pump(
        const Duration(milliseconds: 1),
      ); // Allow setState to complete

      // Assert - Loading state (CircularProgressIndicator is inside FilledButton, not TextButton)
      expect(
        find.descendant(
          of: find.byKey(const Key('remove_button')),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );

      // Remove button (FilledButton) should be disabled during loading
      final removeButtonFinder = find.byKey(const Key('remove_button'));
      final removeButton = tester.widget<FilledButton>(removeButtonFinder);
      expect(removeButton.onPressed, isNull);

      // Complete operation
      await tester.pumpAndSettle();
    });

    testWidgets('should handle empty display name gracefully', (tester) async {
      // Arrange - Create member with null userName to trigger "Loading..." fallback
      final memberWithEmptyName = FamilyMember(
        id: 'member-123',
        familyId: 'family-456',
        userId: 'user-789',
        role: FamilyRole.member,
      status: 'ACTIVE',
        joinedAt: DateTime(2024),
        userEmail: 'john@example.com',
      );
      final widget = ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: RemoveMemberConfirmationDialog(member: memberWithEmptyName),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Check that "L" appears in CircleAvatar when userName is null (first letter of "Loading...")
      expect(
        find.descendant(
          of: find.byType(CircleAvatar),
          matching: find.text('L'),
        ),
        findsOneWidget,
      ); // First letter of "Loading..."
      expect(
        find.text('Loading...'),
        findsOneWidget,
      ); // displayNameOrLoading returns "Loading..." when userName is null
    });

    testWidgets('should apply correct theme colors for error state', (
      tester,
    ) async {
      // Arrange
      const customTheme = ColorScheme.light(
        error: Colors.red,
        errorContainer: Colors.pink,
        onErrorContainer: Colors.black,
      );

      final widget = ProviderScope(
        child: MaterialApp(
          theme: ThemeData(colorScheme: customTheme),
          home: Scaffold(
            body: RemoveMemberConfirmationDialog(member: testMember),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Error-colored elements
      final removeIcon = tester.widget<Icon>(find.byIcon(Icons.person_remove));
      expect(removeIcon.color, customTheme.error);

      final titleText = tester.widget<Text>(
        find.byKey(const Key('dialog_title')),
      );
      expect(titleText.style?.color, customTheme.error);
    });

    testWidgets('should show confirmation text with member name', (
      tester,
    ) async {
      // Arrange
      final widget = ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: RemoveMemberConfirmationDialog(member: testMember),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Confirmation message includes member name
      expect(find.textContaining('John Doe'), findsAtLeastNWidgets(1));
      expect(find.textContaining('permanently remove'), findsOneWidget);
    });

    testWidgets('should handle member with long name', (tester) async {
      // Arrange
      final memberWithLongName = testMember.copyWith(
        userName:
            'This Is A Very Long Member Name That Should Be Handled Properly',
      );
      final widget = ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: RemoveMemberConfirmationDialog(member: memberWithLongName),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Long name should be displayed
      expect(find.byKey(const Key('member_name')), findsOneWidget);
    });

    testWidgets('should be accessible with screen reader', (tester) async {
      // Arrange
      final widget = ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: RemoveMemberConfirmationDialog(member: testMember),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Assert - Run comprehensive accessibility tests
      await AccessibilityTestHelper.runAccessibilityTestSuite(
        tester,
        requiredLabels: ['John Doe', 'Cancel'],
      );

      // Verify dialog is properly accessible
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('should handle keyboard navigation', (tester) async {
      // Arrange
      final widget = ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: RemoveMemberConfirmationDialog(member: testMember),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Focus should be on dialog
      expect(find.byType(AlertDialog), findsOneWidget);

      // Buttons should be focusable
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Should be able to navigate between buttons
      expect(tester.binding.focusManager.primaryFocus, isNotNull);
    });

    testWidgets('should dismiss on background tap when barrierDismissible', (
      tester,
    ) async {
      // Arrange
      final widget = ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        RemoveMemberConfirmationDialog(member: testMember),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert dialog is shown
      expect(find.byType(RemoveMemberConfirmationDialog), findsOneWidget);

      // Tap outside dialog (background)
      await tester.tapAt(
        const Offset(10, 10),
      ); // Top-left corner, outside dialog
      await tester.pumpAndSettle();

      // Assert dialog is dismissed
      expect(find.byType(RemoveMemberConfirmationDialog), findsNothing);
    });
  });
}

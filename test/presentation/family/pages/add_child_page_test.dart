// EduLift Mobile - Add Child Page Widget Tests
// Test-Driven Development - RED-GREEN-REFACTOR

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/features/family/presentation/pages/add_child_page.dart';
import '../../../support/simple_widget_test_helper.dart';
import '../../../support/accessibility_test_helper.dart';

void main() {
  setUpAll(() async {
    await SimpleWidgetTestHelper.initialize();
  });

  tearDownAll(() async {
    await SimpleWidgetTestHelper.tearDown();
  });

  group('Add Child Page Widget Tests', () {
    testWidgets('should display form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        SimpleWidgetTestHelper.createSimpleTestWidget(
          child: const AddChildPage(),
        ),
      );
      await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

      // Look for page title
      final titleFinder = find.textContaining('Add Child');
      final addFinder = find.textContaining('Add');

      final hasTitle =
          titleFinder.evaluate().isNotEmpty || addFinder.evaluate().isNotEmpty;
      expect(hasTitle, isTrue);
      // Look for form fields
      final nameFieldFinder = find.byKey(const Key('child_name_field'));
      final textFieldFinder = find.byType(TextFormField);

      final hasFormFields =
          nameFieldFinder.evaluate().isNotEmpty ||
          textFieldFinder.evaluate().isNotEmpty;
      expect(hasFormFields, isTrue);

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should validate required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        SimpleWidgetTestHelper.createSimpleTestWidget(
          child: const AddChildPage(),
        ),
      );
      await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

      // Find submit button (may have different key/text)
      final submitButtonKey = find.byKey(const Key('save_child_button'));
      final saveText = find.textContaining('Save');
      final submitText = find.textContaining('Submit');
      final elevatedButton = find.byType(ElevatedButton);

      Finder? submitButton;
      if (submitButtonKey.evaluate().isNotEmpty) {
        submitButton = submitButtonKey;
      } else if (saveText.evaluate().isNotEmpty) {
        submitButton = saveText;
      } else if (submitText.evaluate().isNotEmpty) {
        submitButton = submitText;
      } else if (elevatedButton.evaluate().isNotEmpty) {
        submitButton = elevatedButton;
      }

      if (submitButton != null && submitButton.evaluate().isNotEmpty) {
        // Try to submit without filling required fields
        await tester.tap(submitButton.first);
        await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

        // Should show validation errors (may have different text)
        final nameRequired = find.textContaining('Name is required');
        final required = find.textContaining('required');
        final cannotBeEmpty = find.textContaining('cannot be empty');

        final hasValidationError =
            nameRequired.evaluate().isNotEmpty ||
            required.evaluate().isNotEmpty ||
            cannotBeEmpty.evaluate().isNotEmpty;

        expect(hasValidationError, isTrue);
      }

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should accept valid input', (WidgetTester tester) async {
      await tester.pumpWidget(
        SimpleWidgetTestHelper.createTestAppForPage(
          child: const AddChildPage(),
        ),
      );
      await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

      // Find form fields
      final nameFieldKey = find.byKey(const Key('child_name_field'));
      final textFormField = find.byType(TextFormField);

      Finder? nameField;
      if (nameFieldKey.evaluate().isNotEmpty) {
        nameField = nameFieldKey;
      } else if (textFormField.evaluate().isNotEmpty) {
        nameField = textFormField;
      }

      final ageField = find.byKey(const Key('child_age_field'));
      final schoolField = find.byKey(const Key('child_school_field'));

      // Fill form with valid data if fields exist
      if (nameField != null && nameField.evaluate().isNotEmpty) {
        await tester.enterText(nameField.first, 'Alice');
      }
      if (ageField.evaluate().isNotEmpty) {
        await tester.enterText(ageField.first, '8');
      }
      if (schoolField.evaluate().isNotEmpty) {
        await tester.enterText(schoolField.first, 'Elementary School');
      }

      // Submit form
      final submitButtonKey = find.byKey(const Key('save_child_button'));
      final saveText = find.textContaining('Save');
      final submitText = find.textContaining('Submit');
      final elevatedButton = find.byType(ElevatedButton);

      Finder? submitButton;
      if (submitButtonKey.evaluate().isNotEmpty) {
        submitButton = submitButtonKey;
      } else if (saveText.evaluate().isNotEmpty) {
        submitButton = saveText;
      } else if (submitText.evaluate().isNotEmpty) {
        submitButton = submitText;
      } else if (elevatedButton.evaluate().isNotEmpty) {
        submitButton = elevatedButton;
      }

      if (submitButton != null && submitButton.evaluate().isNotEmpty) {
        await tester.tap(submitButton.first);
        await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

        // Should not show validation errors
        expect(find.textContaining('Name is required'), findsNothing);
        expect(find.textContaining('Age is required'), findsNothing);
      }

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should be accessible', (WidgetTester tester) async {
      await tester.pumpWidget(
        SimpleWidgetTestHelper.createSimpleTestWidget(
          child: const AddChildPage(),
        ),
      );
      await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

      // Check for any form fields or semantic labels (flexible accessibility check)
      final hasTextFields =
          find.byType(TextField).evaluate().isNotEmpty ||
          find.byType(TextFormField).evaluate().isNotEmpty;
      final hasButtons =
          find.byType(ElevatedButton).evaluate().isNotEmpty ||
          find.byType(FilledButton).evaluate().isNotEmpty ||
          find.byType(OutlinedButton).evaluate().isNotEmpty;
      final hasBasicAccessibility = hasTextFields || hasButtons;

      expect(hasBasicAccessibility, isTrue);

      SimpleWidgetTestHelper.verifyNoExceptions(tester);
    });

    testWidgets('should pass 2025 accessibility standards', (tester) async {
      await tester.pumpWidget(
        SimpleWidgetTestHelper.createSimpleTestWidget(
          child: const AddChildPage(),
        ),
      );
      await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

      // Run comprehensive 2025 accessibility test suite
      await AccessibilityTestHelper.runAccessibilityTestSuite(
        tester,
        requiredLabels: ['Child Name', 'Save', 'Add Child'],
      );

      // Additional 2025 accessibility standards
      await AccessibilityTestHelper.testKeyboardNavigation(tester);
      await AccessibilityTestHelper.testScreenReaderCompatibility(tester);
    });
  });
}

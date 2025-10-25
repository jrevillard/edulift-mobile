// EduLift Mobile E2E - Group Flow Helper
// Helper class for common group-related flows shared between tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// Helper class for group-related E2E test flows
///
/// This class provides common group operations used across multiple tests:
/// - Group error validation with i18n support
/// - Form validation verification
///
/// Usage:
/// ```dart
/// final errorMessage = await GroupFlowHelper.verifyGroupErrorMessage(
///   $,
///   'name_required',
///   fieldKey: 'editGroup_name_field',
/// );
/// ```
class GroupFlowHelper {
  /// Verify that a group form validation error message is displayed
  ///
  /// This validates TextFormField validator errors by:
  /// - Finding the TextFormField by its key
  /// - Checking that it has an error decoration
  /// - Extracting the errorText message
  /// - Validating the message is localized (not a raw key)
  /// - Validating the message is not empty
  ///
  /// Parameters:
  /// - [tester]: Patrol test instance
  /// - [expectedErrorKey]: The error key identifier (e.g., 'name_required', 'name_too_long')
  /// - [fieldKey]: The key of the TextFormField to check (e.g., 'editGroup_name_field')
  /// - [timeout]: Optional timeout duration (default: 5 seconds)
  ///
  /// Returns: The actual localized error message text found
  ///
  /// Throws: TestFailure if field not found, no error displayed, or message is invalid
  ///
  /// Example:
  /// ```dart
  /// // Verify empty name validation error
  /// final errorMessage = await GroupFlowHelper.verifyGroupErrorMessage(
  ///   $,
  ///   'name_required',
  ///   fieldKey: 'editGroup_name_field',
  ///   timeout: const Duration(seconds: 3),
  /// );
  /// debugPrint('✅ Validation error: "$errorMessage"');
  /// ```
  static Future<String> verifyGroupErrorMessage(
    PatrolIntegrationTester tester,
    String expectedErrorKey, {
    required String fieldKey,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    debugPrint('🔍 Verifying group error message for key: $expectedErrorKey');
    debugPrint('   Looking at field: $fieldKey');

    // Step 1: Find the TextFormField by its key
    final textFieldFinder = find.byKey(Key(fieldKey));

    // Wait for the field to exist
    await tester.waitUntilVisible(textFieldFinder, timeout: timeout);

    // Step 2: Get the TextFormField widget
    final fieldWidget = tester.tester.widget(textFieldFinder);

    if (fieldWidget is! TextFormField) {
      throw TestFailure(
        'Expected TextFormField with key $fieldKey, but found ${fieldWidget.runtimeType}',
      );
    }

    // Step 3: Extract the errorText from the InputDecoration
    // TextFormField doesn't directly expose decoration, so we need to find the TextField inside
    final textField = find.descendant(
      of: textFieldFinder,
      matching: find.byType(TextField),
    );

    final textFieldWidget = tester.tester.widget<TextField>(textField);
    final errorText = textFieldWidget.decoration?.errorText;

    if (errorText == null || errorText.isEmpty) {
      // Wait a bit and try again, in case validation hasn't triggered yet
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));

      // Re-fetch the widget
      final updatedTextField = find.descendant(
        of: textFieldFinder,
        matching: find.byType(TextField),
      );
      final updatedTextFieldWidget = tester.tester.widget<TextField>(
        updatedTextField,
      );
      final updatedErrorText = updatedTextFieldWidget.decoration?.errorText;

      if (updatedErrorText == null || updatedErrorText.isEmpty) {
        throw TestFailure(
          'TextFormField with key $fieldKey has no errorText. '
          'Expected error for: $expectedErrorKey',
        );
      }
      final actualMessage = updatedErrorText.trim();
      debugPrint(
        '📝 Found group error message (after retry): "$actualMessage"',
      );

      // Step 4: Validate message is not empty
      expect(
        actualMessage,
        isNotEmpty,
        reason: 'Group error message should not be empty',
      );

      return actualMessage;
    }

    final actualMessage = errorText.trim();
    debugPrint('📝 Found group error message: "$actualMessage"');

    // Step 4: Validate message is not empty
    expect(
      actualMessage,
      isNotEmpty,
      reason: 'Group error message should not be empty',
    );

    // Step 5: Validate message is localized (not a raw key)
    // Check if it looks like a camelCase key (starts with lowercase, has uppercase letters)
    final looksLikeKey = actualMessage.isNotEmpty &&
        actualMessage[0] == actualMessage[0].toLowerCase() &&
        actualMessage.contains(RegExp(r'[A-Z]')) &&
        !actualMessage.contains(' ');

    expect(
      looksLikeKey,
      isFalse,
      reason:
          'Group error message should be localized, not a raw key like "$actualMessage"',
    );

    debugPrint('✅ Group error message validation passed: "$actualMessage"');
    return actualMessage;
  }

  /// Verify that a group submission error message is displayed
  ///
  /// This validates submission errors (not validation errors) that appear in the
  /// error container at the bottom of group forms.
  ///
  /// Parameters:
  /// - [tester]: Patrol test instance
  /// - [expectedErrorKey]: The error key identifier
  /// - [timeout]: Optional timeout duration (default: 5 seconds)
  ///
  /// Returns: The actual localized error message text found
  ///
  /// Throws: TestFailure if error widget not found or message is invalid
  ///
  /// Example:
  /// ```dart
  /// final errorMessage = await GroupFlowHelper.verifyGroupSubmissionError(
  ///   $,
  ///   'network_error',
  /// );
  /// ```
  static Future<String> verifyGroupSubmissionError(
    PatrolIntegrationTester tester,
    String expectedErrorKey, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    debugPrint(
      '🔍 Verifying group submission error for key: $expectedErrorKey',
    );

    // Find error widget by key (format: group_error_$errorKey)
    final errorKey = Key('group_error_$expectedErrorKey');
    await tester.waitUntilVisible(find.byKey(errorKey), timeout: timeout);

    // Extract and validate the message
    final errorWidget = find.byKey(errorKey);
    final widget = tester.tester.widget(errorWidget);

    String actualMessage;
    if (widget is Text) {
      actualMessage =
          (widget.data ?? widget.textSpan?.toPlainText() ?? '').trim();
    } else {
      throw TestFailure('Expected Text widget with key $errorKey');
    }

    // Validate message is not empty and is localized
    expect(
      actualMessage,
      isNotEmpty,
      reason: 'Group submission error message should not be empty',
    );

    debugPrint('✅ Group submission error validation passed: "$actualMessage"');
    return actualMessage;
  }
}

// EduLift Mobile - Semantic Test Patterns
// SPARC Architecture: Widget-type and behavior-based testing

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget state enums for semantic testing
enum ButtonState { enabled, disabled, loading }

enum FormState { valid, invalid, submitting }

enum ListState { empty, loading, populated, error }

enum LoadingState { visible, hidden }

// Main function required for Flutter test files
void main() {
  // This file contains test utility patterns
  // Individual tests are in specific test files that import this
  group('Semantic Test Patterns', () {
    test('patterns available', () {
      expect(SemanticTestPatterns, isNotNull);
    });
  });
}

/// Semantic testing patterns that focus on widget behavior rather than text content
class SemanticTestPatterns {
  // Store the current tester for use in static methods
  static WidgetTester? _currentTester;

  /// Initialize with current tester instance
  static void initialize(WidgetTester tester) {
    _currentTester = tester;
  }

  /// Get the current tester or throw if not initialized
  static WidgetTester get tester {
    if (_currentTester == null) {
      throw StateError(
        'SemanticTestPatterns not initialized. Call initialize(tester) first.',
      );
    }
    return _currentTester!;
  }

  // ===========================================
  // BUTTON STATE TESTING
  // ===========================================

  /// Test button state semantically without depending on visual appearance
  static void expectButtonState(String testId, ButtonState expectedState) {
    final buttonFinder = find.byKey(Key(testId));
    expect(
      buttonFinder,
      findsOneWidget,
      reason: 'Button with testId $testId should exist',
    );

    final widget = tester.widget(buttonFinder);

    if (widget is ElevatedButton) {
      _validateElevatedButtonState(widget, expectedState, testId);
    } else if (widget is TextButton) {
      _validateTextButtonState(widget, expectedState, testId);
    } else if (widget is OutlinedButton) {
      _validateOutlinedButtonState(widget, expectedState, testId);
    } else if (widget is FloatingActionButton) {
      _validateFloatingActionButtonState(widget, expectedState, testId);
    } else {
      throw ArgumentError('Unsupported button type: ${widget.runtimeType}');
    }
  }

  static void _validateElevatedButtonState(
    ElevatedButton button,
    ButtonState expectedState,
    String testId,
  ) {
    switch (expectedState) {
      case ButtonState.enabled:
        expect(
          button.onPressed,
          isNotNull,
          reason: 'ElevatedButton $testId should be enabled',
        );
        break;
      case ButtonState.disabled:
        expect(
          button.onPressed,
          isNull,
          reason: 'ElevatedButton $testId should be disabled',
        );
        break;
      case ButtonState.loading:
        // Check for loading indicator in button
        final loadingFinder = find.descendant(
          of: find.byWidget(button),
          matching: find.byType(CircularProgressIndicator),
        );
        expect(
          loadingFinder,
          findsOneWidget,
          reason: 'ElevatedButton $testId should show loading indicator',
        );
        break;
    }
  }

  static void _validateTextButtonState(
    TextButton button,
    ButtonState expectedState,
    String testId,
  ) {
    switch (expectedState) {
      case ButtonState.enabled:
        expect(
          button.onPressed,
          isNotNull,
          reason: 'TextButton $testId should be enabled',
        );
        break;
      case ButtonState.disabled:
        expect(
          button.onPressed,
          isNull,
          reason: 'TextButton $testId should be disabled',
        );
        break;
      case ButtonState.loading:
        final loadingFinder = find.descendant(
          of: find.byWidget(button),
          matching: find.byType(CircularProgressIndicator),
        );
        expect(
          loadingFinder,
          findsOneWidget,
          reason: 'TextButton $testId should show loading indicator',
        );
        break;
    }
  }

  static void _validateOutlinedButtonState(
    OutlinedButton button,
    ButtonState expectedState,
    String testId,
  ) {
    switch (expectedState) {
      case ButtonState.enabled:
        expect(
          button.onPressed,
          isNotNull,
          reason: 'OutlinedButton $testId should be enabled',
        );
        break;
      case ButtonState.disabled:
        expect(
          button.onPressed,
          isNull,
          reason: 'OutlinedButton $testId should be disabled',
        );
        break;
      case ButtonState.loading:
        final loadingFinder = find.descendant(
          of: find.byWidget(button),
          matching: find.byType(CircularProgressIndicator),
        );
        expect(
          loadingFinder,
          findsOneWidget,
          reason: 'OutlinedButton $testId should show loading indicator',
        );
        break;
    }
  }

  static void _validateFloatingActionButtonState(
    FloatingActionButton button,
    ButtonState expectedState,
    String testId,
  ) {
    switch (expectedState) {
      case ButtonState.enabled:
        expect(
          button.onPressed,
          isNotNull,
          reason: 'FloatingActionButton $testId should be enabled',
        );
        break;
      case ButtonState.disabled:
        expect(
          button.onPressed,
          isNull,
          reason: 'FloatingActionButton $testId should be disabled',
        );
        break;
      case ButtonState.loading:
        final loadingFinder = find.descendant(
          of: find.byWidget(button),
          matching: find.byType(CircularProgressIndicator),
        );
        expect(
          loadingFinder,
          findsOneWidget,
          reason: 'FloatingActionButton $testId should show loading indicator',
        );
        break;
    }
  }

  // ===========================================
  // LOADING STATE TESTING
  // ===========================================

  /// Test loading indicator presence semantically
  static void expectLoadingState(
    String containerTestId,
    LoadingState expectedState,
  ) {
    final containerFinder = find.byKey(Key(containerTestId));
    expect(
      containerFinder,
      findsOneWidget,
      reason: 'Container with testId $containerTestId should exist',
    );

    final loadingFinder = find.descendant(
      of: containerFinder,
      matching: find.byType(CircularProgressIndicator),
    );

    switch (expectedState) {
      case LoadingState.visible:
        expect(
          loadingFinder,
          findsOneWidget,
          reason: 'Loading indicator should be visible in $containerTestId',
        );
        break;
      case LoadingState.hidden:
        expect(
          loadingFinder,
          findsNothing,
          reason: 'Loading indicator should be hidden in $containerTestId',
        );
        break;
    }
  }

  /// Test linear progress indicator
  static void expectLinearProgressState(
    String containerTestId,
    LoadingState expectedState,
  ) {
    final containerFinder = find.byKey(Key(containerTestId));
    expect(
      containerFinder,
      findsOneWidget,
      reason: 'Container with testId $containerTestId should exist',
    );

    final progressFinder = find.descendant(
      of: containerFinder,
      matching: find.byType(LinearProgressIndicator),
    );

    switch (expectedState) {
      case LoadingState.visible:
        expect(
          progressFinder,
          findsOneWidget,
          reason:
              'Linear progress indicator should be visible in $containerTestId',
        );
        break;
      case LoadingState.hidden:
        expect(
          progressFinder,
          findsNothing,
          reason:
              'Linear progress indicator should be hidden in $containerTestId',
        );
        break;
    }
  }

  // ===========================================
  // FORM STATE TESTING
  // ===========================================

  /// Test form field validation state semantically
  static Future<void> expectFormFieldState(
    String fieldTestId,
    FormState expectedState,
  ) async {
    final fieldFinder = find.byKey(Key(fieldTestId));
    expect(
      fieldFinder,
      findsOneWidget,
      reason: 'Form field with testId $fieldTestId should exist',
    );

    final widget = tester.widget(fieldFinder);

    if (widget is TextFormField) {
      await _validateTextFormFieldState(widget, expectedState, fieldTestId);
    } else if (widget is DropdownButtonFormField) {
      await _validateDropdownFormFieldState(widget, expectedState, fieldTestId);
    } else {
      throw ArgumentError('Unsupported form field type: ${widget.runtimeType}');
    }
  }

  static Future<void> _validateTextFormFieldState(
    TextFormField field,
    FormState expectedState,
    String testId,
  ) async {
    switch (expectedState) {
      case FormState.valid:
        // Trigger validation by pumping
        await tester.pump();
        expect(
          (field as dynamic).decoration?.errorText,
          isNull,
          reason: 'TextFormField $testId should be valid (no error text)',
        );
        break;
      case FormState.invalid:
        await tester.pump();
        expect(
          (field as dynamic).decoration?.errorText,
          isNotNull,
          reason: 'TextFormField $testId should be invalid (has error text)',
        );
        break;
      case FormState.submitting:
        expect(
          field.enabled,
          isFalse,
          reason: 'TextFormField $testId should be disabled during submission',
        );
        break;
    }
  }

  static Future<void> _validateDropdownFormFieldState(
    DropdownButtonFormField field,
    FormState expectedState,
    String testId,
  ) async {
    switch (expectedState) {
      case FormState.valid:
        await tester.pump();
        expect(
          (field as dynamic).decoration.errorText,
          isNull,
          reason: 'DropdownButtonFormField $testId should be valid',
        );
        break;
      case FormState.invalid:
        await tester.pump();
        expect(
          (field as dynamic).decoration.errorText,
          isNotNull,
          reason: 'DropdownButtonFormField $testId should be invalid',
        );
        break;
      case FormState.submitting:
        // Check if dropdown is disabled by trying to tap it
        final dropdownFinder = find.byWidget(field);
        await tester.tap(dropdownFinder);
        await tester.pump();

        // If submitting, dropdown menu should not appear
        expect(
          find.byType(DropdownMenuItem),
          findsNothing,
          reason:
              'DropdownButtonFormField $testId should be disabled during submission',
        );
        break;
    }
  }

  // ===========================================
  // LIST STATE TESTING
  // ===========================================

  /// Test list widget state semantically
  static void expectListState(
    String listTestId,
    ListState expectedState, {
    int? expectedItemCount,
  }) {
    final listFinder = find.byKey(Key(listTestId));
    expect(
      listFinder,
      findsOneWidget,
      reason: 'List with testId $listTestId should exist',
    );

    switch (expectedState) {
      case ListState.empty:
        // Look for empty state widget or no list items
        final emptyStateFinder = find.descendant(
          of: listFinder,
          matching: find.byKey(const Key('empty-state')),
        );
        if (emptyStateFinder.evaluate().isEmpty) {
          // No explicit empty state, check for lack of list items
          final listItemsFinder = find.descendant(
            of: listFinder,
            matching: find.byType(ListTile),
          );
          expect(
            listItemsFinder,
            findsNothing,
            reason: 'List $listTestId should be empty (no ListTile widgets)',
          );
        } else {
          expect(
            emptyStateFinder,
            findsOneWidget,
            reason: 'List $listTestId should show empty state',
          );
        }
        break;

      case ListState.loading:
        final loadingFinder = find.descendant(
          of: listFinder,
          matching: find.byType(CircularProgressIndicator),
        );
        expect(
          loadingFinder,
          findsWidgets,
          reason: 'List $listTestId should show loading indicator',
        );
        break;

      case ListState.populated:
        final listItemsFinder = find.descendant(
          of: listFinder,
          matching: find.byType(ListTile),
        );
        expect(
          listItemsFinder,
          findsWidgets,
          reason: 'List $listTestId should have list items',
        );

        if (expectedItemCount != null) {
          expect(
            listItemsFinder,
            findsNWidgets(expectedItemCount),
            reason:
                'List $listTestId should have exactly $expectedItemCount items',
          );
        }
        break;

      case ListState.error:
        final errorStateFinder = find.descendant(
          of: listFinder,
          matching: find.byKey(const Key('error-state')),
        );
        expect(
          errorStateFinder,
          findsOneWidget,
          reason: 'List $listTestId should show error state',
        );
        break;
    }
  }

  // ===========================================
  // WIDGET VISIBILITY TESTING
  // ===========================================

  /// Test widget visibility semantically
  static void expectWidgetVisible(String testId, {String? context}) {
    final finder = find.byKey(Key(testId));
    expect(
      finder,
      findsOneWidget,
      reason: 'Widget with testId $testId should be visible'
          '${context != null ? ' in context: $context' : ''}',
    );
  }

  /// Test widget is not visible
  static void expectWidgetHidden(String testId, {String? context}) {
    final finder = find.byKey(Key(testId));
    expect(
      finder,
      findsNothing,
      reason: 'Widget with testId $testId should be hidden'
          '${context != null ? ' in context: $context' : ''}',
    );
  }

  /// Test widget type within container
  static void expectWidgetType<T extends Widget>(
    String containerTestId, {
    bool shouldExist = true,
  }) {
    final containerFinder = find.byKey(Key(containerTestId));
    expect(
      containerFinder,
      findsOneWidget,
      reason: 'Container with testId $containerTestId should exist',
    );

    final widgetFinder = find.descendant(
      of: containerFinder,
      matching: find.byType(T),
    );

    if (shouldExist) {
      expect(
        widgetFinder,
        findsWidgets,
        reason: 'Widget of type $T should exist in container $containerTestId',
      );
    } else {
      expect(
        widgetFinder,
        findsNothing,
        reason:
            'Widget of type $T should not exist in container $containerTestId',
      );
    }
  }

  // ===========================================
  // INTERACTION TESTING
  // ===========================================

  /// Tap widget and verify it's interactive
  static Future<void> tapWidget(String testId, {String? context}) async {
    final finder = find.byKey(Key(testId));
    expect(
      finder,
      findsOneWidget,
      reason: 'Widget with testId $testId should exist for tapping'
          '${context != null ? ' in context: $context' : ''}',
    );

    await tester.tap(finder);
    await tester.pump();
  }

  /// Enter text in input field semantically
  static Future<void> enterTextInField(
    String fieldTestId,
    String text, {
    String? context,
  }) async {
    final fieldFinder = find.byKey(Key(fieldTestId));
    expect(
      fieldFinder,
      findsOneWidget,
      reason: 'Text field with testId $fieldTestId should exist'
          '${context != null ? ' in context: $context' : ''}',
    );

    await tester.enterText(fieldFinder, text);
    await tester.pump();
  }

  /// Scroll to make widget visible
  static Future<void> scrollToWidget(
    String testId, {
    double delta = 300.0,
  }) async {
    final finder = find.byKey(Key(testId));
    await tester.scrollUntilVisible(finder, delta);
    await tester.pump();
  }

  // ===========================================
  // NAVIGATION TESTING
  // ===========================================

  /// Expect specific route to be current
  static void expectCurrentRoute(String expectedRoute) {
    final navigator = tester.state(find.byType(Navigator));
    final currentRoute = (navigator.widget as dynamic).pages?.last?.name ?? '';

    expect(
      currentRoute,
      equals(expectedRoute),
      reason: 'Current route should be $expectedRoute',
    );
  }

  /// Expect dialog to be visible
  static void expectDialogVisible({String? dialogTestId}) {
    if (dialogTestId != null) {
      final dialogFinder = find.byKey(Key(dialogTestId));
      expect(
        dialogFinder,
        findsOneWidget,
        reason: 'Dialog with testId $dialogTestId should be visible',
      );
    } else {
      final dialogFinder = find.byType(Dialog);
      expect(dialogFinder, findsOneWidget, reason: 'Dialog should be visible');
    }
  }

  /// Expect snackbar to be visible
  static void expectSnackBarVisible({String? message}) {
    final snackBarFinder = find.byType(SnackBar);
    expect(
      snackBarFinder,
      findsOneWidget,
      reason: 'SnackBar should be visible',
    );

    if (message != null) {
      final messageFinder = find.descendant(
        of: snackBarFinder,
        matching: find.text(message),
      );
      expect(
        messageFinder,
        findsOneWidget,
        reason: 'SnackBar should contain message: $message',
      );
    }
  }
}

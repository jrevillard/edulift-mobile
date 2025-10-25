// EduLift Mobile - i18n-Safe Test Patterns
// SPARC Architecture: Locale-independent testing using widget keys and semantic patterns

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../simple_widget_test_helper.dart';

/// Supported locales for testing
class TestLocales {
  static const List<Locale> supported = [
    Locale('en', 'US'),
    Locale('es', 'ES'),
    Locale('fr', 'FR'),
  ];
}

// Main function required for Flutter test files
void main() {
  // This file contains i18n test utility patterns
  // Individual tests are in specific test files that import this
  group('I18n Safe Test Patterns', () {
    test('patterns available', () {
      expect(I18nSafeTestPatterns, isNotNull);
      expect(TestLocales.supported, isNotEmpty);
    });
  });
}

/// i18n-safe testing patterns that work across all locales
class I18nSafeTestPatterns {
  static WidgetTester? _currentTester;

  /// Initialize with current tester instance
  static void initialize(WidgetTester tester) {
    _currentTester = tester;
  }

  /// Get the current tester or throw if not initialized
  static WidgetTester get tester {
    if (_currentTester == null) {
      throw StateError(
        'I18nSafeTestPatterns not initialized. Call initialize(tester) first.',
      );
    }
    return _currentTester!;
  }

  // ===========================================
  // LOCALIZATION KEY TESTING
  // ===========================================

  /// Test for presence of content using localization keys instead of text
  static void expectLocalizedContent(String contentKey, {String? context}) {
    // Look for widget with localization key as the widget key
    final finder = find.byKey(Key('i18n-content-$contentKey'));
    expect(
      finder,
      findsOneWidget,
      reason:
          'Content with localization key "$contentKey" should exist'
          '${context != null ? ' in context: $context' : ''}',
    );
  }

  /// Test for absence of content using localization keys
  static void expectNoLocalizedContent(String contentKey, {String? context}) {
    final finder = find.byKey(Key('i18n-content-$contentKey'));
    expect(
      finder,
      findsNothing,
      reason:
          'Content with localization key "$contentKey" should not exist'
          '${context != null ? ' in context: $context' : ''}',
    );
  }

  /// Test for localized button using semantic key instead of text
  static void expectLocalizedButton(String buttonKey, {String? context}) {
    final finder = find.byKey(Key('i18n-button-$buttonKey'));
    expect(
      finder,
      findsOneWidget,
      reason:
          'Button with localization key "$buttonKey" should exist'
          '${context != null ? ' in context: $context' : ''}',
    );
  }

  /// Test for localized form field label using semantic key
  static void expectLocalizedFormField(String fieldKey, {String? context}) {
    final finder = find.byKey(Key('i18n-form-field-$fieldKey'));
    expect(
      finder,
      findsOneWidget,
      reason:
          'Form field with localization key "$fieldKey" should exist'
          '${context != null ? ' in context: $context' : ''}',
    );
  }

  // ===========================================
  // WIDGET TYPE-BASED VALIDATION
  // ===========================================

  /// Validate presence of specific widget types without relying on text
  static void expectWidgetTypeInContainer<T extends Widget>(
    String containerTestId, {
    int expectedCount = 1,
    String? context,
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

    expect(
      widgetFinder,
      findsNWidgets(expectedCount),
      reason:
          'Should find exactly $expectedCount widget(s) of type $T in $containerTestId'
          '${context != null ? ' in context: $context' : ''}',
    );
  }

  /// Validate icon presence using IconData comparison instead of text
  static void expectIconInWidget(
    String widgetTestId,
    IconData expectedIcon, {
    String? context,
  }) {
    final widgetFinder = find.byKey(Key(widgetTestId));
    expect(
      widgetFinder,
      findsOneWidget,
      reason: 'Widget with testId $widgetTestId should exist',
    );

    final iconFinder = find.descendant(
      of: widgetFinder,
      matching: find.byWidgetPredicate(
        (widget) => widget is Icon && widget.icon == expectedIcon,
      ),
    );

    expect(
      iconFinder,
      findsOneWidget,
      reason:
          'Icon $expectedIcon should be found in widget $widgetTestId'
          '${context != null ? ' in context: $context' : ''}',
    );
  }

  // ===========================================
  // FORM VALIDATION (LOCALE-INDEPENDENT)
  // ===========================================

  /// Test form validation state using widget properties instead of error text
  static Future<void> expectFormFieldValidationState(
    String fieldTestId,
    bool shouldHaveError, {
    String? context,
  }) async {
    final fieldFinder = find.byKey(Key(fieldTestId));
    expect(
      fieldFinder,
      findsOneWidget,
      reason: 'Form field with testId $fieldTestId should exist',
    );

    final widget = tester.widget(fieldFinder);

    // Trigger validation
    await tester.pump();

    if (widget is TextFormField) {
      final hasError = (widget as dynamic).decoration?.errorText != null;
      expect(
        hasError,
        equals(shouldHaveError),
        reason:
            'Form field $fieldTestId validation state should be ${shouldHaveError ? "error" : "valid"}'
            '${context != null ? ' in context: $context' : ''}',
      );
    } else if (widget is DropdownButtonFormField) {
      final hasError = (widget as dynamic).decoration.errorText != null;
      expect(
        hasError,
        equals(shouldHaveError),
        reason:
            'Dropdown field $fieldTestId validation state should be ${shouldHaveError ? "error" : "valid"}'
            '${context != null ? ' in context: $context' : ''}',
      );
    }
  }

  // ===========================================
  // NAVIGATION TESTING (I18N-SAFE)
  // ===========================================

  /// Test navigation using route names instead of page titles
  static void expectRoute(String expectedRouteName, {String? context}) {
    final navigator = tester.state(find.byType(Navigator));
    final currentRoute = ModalRoute.of(navigator.context)?.settings.name;

    expect(
      currentRoute,
      equals(expectedRouteName),
      reason:
          'Current route should be $expectedRouteName'
          '${context != null ? ' in context: $context' : ''}',
    );
  }

  /// Test app bar presence using semantic properties instead of title text
  static void expectAppBarWithBackButton({String? context}) {
    final appBarFinder = find.byType(AppBar);
    expect(
      appBarFinder,
      findsOneWidget,
      reason:
          'AppBar should be present${context != null ? ' in context: $context' : ''}',
    );

    final backButtonFinder = find.descendant(
      of: appBarFinder,
      matching: find.byType(BackButton),
    );

    expect(
      backButtonFinder,
      findsOneWidget,
      reason:
          'AppBar should have back button${context != null ? ' in context: $context' : ''}',
    );
  }

  // ===========================================
  // LIST TESTING (SEMANTIC)
  // ===========================================

  /// Test list content using item count and widget types instead of text
  static void expectListWithItemCount(
    String listTestId,
    int expectedCount, {
    Type? itemWidgetType,
    String? context,
  }) {
    final listFinder = find.byKey(Key(listTestId));
    expect(
      listFinder,
      findsOneWidget,
      reason: 'List with testId $listTestId should exist',
    );

    if (itemWidgetType != null) {
      final itemsFinder = find.descendant(
        of: listFinder,
        matching: find.byType(itemWidgetType),
      );
      expect(
        itemsFinder,
        findsNWidgets(expectedCount),
        reason:
            'List $listTestId should contain $expectedCount items of type $itemWidgetType'
            '${context != null ? ' in context: $context' : ''}',
      );
    } else {
      // Use ListTile as default item type
      final itemsFinder = find.descendant(
        of: listFinder,
        matching: find.byType(ListTile),
      );
      expect(
        itemsFinder,
        findsNWidgets(expectedCount),
        reason:
            'List $listTestId should contain $expectedCount ListTile items'
            '${context != null ? ' in context: $context' : ''}',
      );
    }
  }

  /// Test empty list state using semantic indicators
  static void expectEmptyListState(String listTestId, {String? context}) {
    final listFinder = find.byKey(Key(listTestId));
    expect(
      listFinder,
      findsOneWidget,
      reason: 'List with testId $listTestId should exist',
    );

    // Look for empty state indicator widget
    final emptyStateFinder = find.descendant(
      of: listFinder,
      matching: find.byKey(const Key('empty-state-indicator')),
    );

    // If no explicit empty state widget, check for absence of list items
    if (emptyStateFinder.evaluate().isEmpty) {
      final itemsFinder = find.descendant(
        of: listFinder,
        matching: find.byType(ListTile),
      );
      expect(
        itemsFinder,
        findsNothing,
        reason:
            'Empty list $listTestId should have no ListTile items'
            '${context != null ? ' in context: $context' : ''}',
      );
    } else {
      expect(
        emptyStateFinder,
        findsOneWidget,
        reason:
            'List $listTestId should show empty state indicator'
            '${context != null ? ' in context: $context' : ''}',
      );
    }
  }

  // ===========================================
  // DIALOG TESTING (I18N-SAFE)
  // ===========================================

  /// Test dialog presence using dialog type instead of title text
  static void expectDialogOfType<T extends Widget>({String? context}) {
    final dialogFinder = find.byType(T);
    expect(
      dialogFinder,
      findsOneWidget,
      reason:
          'Dialog of type $T should be visible'
          '${context != null ? ' in context: $context' : ''}',
    );
  }

  /// Test confirmation dialog using button types instead of text
  static void expectConfirmationDialog({String? context}) {
    final dialogFinder = find.byType(AlertDialog);
    expect(
      dialogFinder,
      findsOneWidget,
      reason:
          'Confirmation dialog should be visible'
          '${context != null ? ' in context: $context' : ''}',
    );

    // Look for two buttons (typically cancel and confirm)
    final buttonsFinder = find.descendant(
      of: dialogFinder,
      matching: find.byType(TextButton),
    );

    expect(
      buttonsFinder,
      findsNWidgets(2),
      reason:
          'Confirmation dialog should have 2 action buttons'
          '${context != null ? ' in context: $context' : ''}',
    );
  }

  // ===========================================
  // INTERACTION TESTING (I18N-SAFE)
  // ===========================================

  /// Tap widget using test ID regardless of text content
  static Future<void> tapByTestId(String testId, {String? context}) async {
    final finder = find.byKey(Key(testId));
    expect(
      finder,
      findsOneWidget,
      reason:
          'Widget with testId $testId should exist for tapping'
          '${context != null ? ' in context: $context' : ''}',
    );

    await tester.tap(finder);
    await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);
  }

  /// Enter text in field using test ID regardless of label text
  static Future<void> enterTextByTestId(
    String fieldTestId,
    String text, {
    String? context,
  }) async {
    final finder = find.byKey(Key(fieldTestId));
    expect(
      finder,
      findsOneWidget,
      reason:
          'Text field with testId $fieldTestId should exist'
          '${context != null ? ' in context: $context' : ''}',
    );

    await tester.enterText(finder, text);
    await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);
  }

  /// Select dropdown option using index instead of text matching
  static Future<void> selectDropdownByIndex(
    String dropdownTestId,
    int optionIndex, {
    String? context,
  }) async {
    final dropdownFinder = find.byKey(Key(dropdownTestId));
    expect(
      dropdownFinder,
      findsOneWidget,
      reason:
          'Dropdown with testId $dropdownTestId should exist'
          '${context != null ? ' in context: $context' : ''}',
    );

    // Tap to open dropdown
    await tester.tap(dropdownFinder);
    await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

    // Find all dropdown menu items
    final menuItemsFinder = find.byType(DropdownMenuItem);
    final menuItems = menuItemsFinder.evaluate().toList();

    expect(
      menuItems.length,
      greaterThan(optionIndex),
      reason: 'Dropdown should have at least ${optionIndex + 1} options',
    );

    // Tap the option at the specified index
    await tester.tap(menuItemsFinder.at(optionIndex));
    await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);
  }

  // ===========================================
  // WIDGET STATE TESTING
  // ===========================================

  /// Test widget enabled state using properties instead of visual appearance
  static void expectWidgetEnabled(
    String testId,
    bool shouldBeEnabled, {
    String? context,
  }) {
    final finder = find.byKey(Key(testId));
    expect(
      finder,
      findsOneWidget,
      reason: 'Widget with testId $testId should exist',
    );

    final widget = tester.widget(finder);
    var isEnabled = true;

    // Check enabled state based on widget type
    if (widget is TextFormField) {
      // ignore: dead_null_aware_expression
      isEnabled = widget.enabled ?? true;
    } else if (widget is ElevatedButton ||
        widget is TextButton ||
        widget is OutlinedButton) {
      final button = widget as dynamic;
      isEnabled = button.onPressed != null;
    } else if (widget is Switch) {
      // Switch doesn't have an enabled property, check onChanged
      isEnabled = widget.onChanged != null;
    } else if (widget is Checkbox) {
      isEnabled = widget.onChanged != null;
    }

    expect(
      isEnabled,
      equals(shouldBeEnabled),
      reason:
          'Widget $testId should be ${shouldBeEnabled ? "enabled" : "disabled"}'
          '${context != null ? ' in context: $context' : ''}',
    );
  }

  /// Test widget visibility using finder results instead of opacity
  static void expectWidgetVisibility(
    String testId,
    bool shouldBeVisible, {
    String? context,
  }) {
    final finder = find.byKey(Key(testId));

    if (shouldBeVisible) {
      expect(
        finder,
        findsOneWidget,
        reason:
            'Widget with testId $testId should be visible'
            '${context != null ? ' in context: $context' : ''}',
      );
    } else {
      expect(
        finder,
        findsNothing,
        reason:
            'Widget with testId $testId should not be visible'
            '${context != null ? ' in context: $context' : ''}',
      );
    }
  }
}

/// Multi-locale test runner for comprehensive i18n testing
class MultiLocaleTestRunner {
  /// Run the same test across all supported locales
  static void runAcrossLocales(
    String testName,
    Future<void> Function(WidgetTester tester, Locale locale) testCallback,
  ) {
    for (final locale in TestLocales.supported) {
      testWidgets('$testName - ${locale.languageCode}_${locale.countryCode}', (
        tester,
      ) async {
        await testCallback(tester, locale);
      });
    }
  }

  /// Create a localized app wrapper for testing
  static Widget createLocalizedApp(Widget child, Locale locale) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: TestLocales.supported,
      home: child,
    );
  }

  /// Helper to set up locale-specific test environment
  static Future<void> setupLocaleTest(
    WidgetTester tester,
    Locale locale,
    Widget app,
  ) async {
    await tester.pumpWidget(createLocalizedApp(app, locale));
    await SimpleWidgetTestHelper.pumpAndSettleWithTimeout(tester);

    // Initialize patterns with current tester
    I18nSafeTestPatterns.initialize(tester);
  }
}

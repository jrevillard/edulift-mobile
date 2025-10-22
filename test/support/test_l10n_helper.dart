// Test Localization Helper
// Provides standardized i18n testing utilities following Flutter best practices

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';

/// Helper class for testing internationalization (i18n) functionality
///
/// Provides standardized utilities for testing widgets with different locales,
/// validating localized strings, and ensuring proper locale fallback behavior.
class TestL10nHelper {
  /// Wrap a widget with MaterialApp and proper localization delegates
  ///
  /// Example:
  /// ```dart
  /// testWidgets('shows localized text', (tester) async {
  ///   await tester.pumpWidget(
  ///     TestL10nHelper.wrapWithLocalizations(
  ///       Text('Hello'),
  ///       locale: const Locale('fr'),
  ///     ),
  ///   );
  /// });
  /// ```
  static Widget wrapWithLocalizations(
    Widget child, {
    Locale locale = const Locale('en'),
    List<Locale>? supportedLocales,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales ?? AppLocalizations.supportedLocales,
      locale: locale,
      home: Scaffold(body: child),
    );
  }

  /// Create a test app with localization for a specific locale
  /// Similar to wrapWithLocalizations but with more control over the app structure
  static Widget createLocalizedTestApp(
    Widget child, {
    Locale locale = const Locale('en'),
    List<Locale>? supportedLocales,
    ThemeData? theme,
  }) {
    return MaterialApp(
      title: 'Test App',
      theme: theme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales ?? AppLocalizations.supportedLocales,
      locale: locale,
      home: child,
    );
  }

  /// Test a widget with multiple locales to ensure proper internationalization
  ///
  /// Example:
  /// ```dart
  /// testWidgets('works with multiple locales', (tester) async {
  ///   await TestL10nHelper.testMultipleLocales(
  ///     tester,
  ///     const Text('Hello World'),
  ///     locales: [Locale('en'), Locale('fr')],
  ///   );
  /// });
  /// ```
  static Future<void> testMultipleLocales(
    WidgetTester tester,
    Widget child, {
    List<Locale> locales = const [Locale('en'), Locale('fr')],
    Future<void> Function(Locale locale)? validateLocale,
  }) async {
    for (final locale in locales) {
      await tester.pumpWidget(wrapWithLocalizations(child, locale: locale));
      await tester.pump();

      // Custom validation for each locale if provided
      if (validateLocale != null) {
        await validateLocale(locale);
      }

      // Ensure no exceptions occurred
      expect(tester.takeException(), isNull);
    }
  }

  /// Get AppLocalizations instance for a specific locale in tests
  /// Useful for verifying localized strings directly
  ///
  /// Note: This uses a sync approach as testWidgets is async void
  static AppLocalizations getLocalizationsForLocale(Locale locale) {
    AppLocalizations? localizations;

    // Create a test widget tester to get the localizations
    testWidgets('get localizations', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          Builder(
            builder: (context) {
              localizations = AppLocalizations.of(context);
              return const SizedBox.shrink();
            },
          ),
          locale: locale,
        ),
      );
    });

    if (localizations == null) {
      throw Exception(
        'Failed to get localizations for locale: ${locale.languageCode}',
      );
    }

    return localizations!;
  }

  /// Verify that a localized string exists for all supported locales
  ///
  /// Example:
  /// ```dart
  /// test('login button has localized text for all locales', () {
  ///   TestL10nHelper.verifyStringExistsForAllLocales(
  ///     (l10n) => l10n.loginButton,
  ///   );
  /// });
  /// ```
  static void verifyStringExistsForAllLocales(
    String Function(AppLocalizations) getLocalizedString, {
    List<Locale>? locales,
  }) {
    final testLocales = locales ?? AppLocalizations.supportedLocales;

    for (final locale in testLocales) {
      testWidgets('verify localized string for ${locale.languageCode}', (
        tester,
      ) async {
        AppLocalizations? localizations;

        await tester.pumpWidget(
          wrapWithLocalizations(
            Builder(
              builder: (context) {
                localizations = AppLocalizations.of(context);
                return const SizedBox.shrink();
              },
            ),
            locale: locale,
          ),
        );

        if (localizations != null) {
          final localizedString = getLocalizedString(localizations!);
          expect(
            localizedString.isNotEmpty,
            isTrue,
            reason:
                'Localized string is empty for locale: ${locale.languageCode}',
          );
        }
      });
    }
  }

  /// Common locales used in testing
  static const Locale english = Locale('en');
  static const Locale french = Locale('fr');

  /// All supported locales from the app
  static List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  /// Default localization delegates for testing
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

/// Extension to easily get localized strings in tests
extension TestL10nExtension on WidgetTester {
  /// Get AppLocalizations from the current widget tree
  AppLocalizations? get l10n {
    final context = element(find.byType(MaterialApp).first);
    return AppLocalizations.of(context);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// Common widget interaction helpers for i18n-safe testing
class WidgetHelpers {
  /// Wait for a widget with a specific key to appear
  static Future<void> waitForKey(
    PatrolIntegrationTester $,
    String keyName, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await $.waitUntilVisible(find.byKey(Key(keyName)), timeout: timeout);
  }

  /// Tap a button by its key
  static Future<void> tapButton(
    PatrolIntegrationTester $,
    String buttonKey,
  ) async {
    await $.tap(find.byKey(Key(buttonKey)));
    await $.pumpAndSettle();
  }

  /// Enter text in a field identified by key
  static Future<void> enterTextInField(
    PatrolIntegrationTester $,
    String fieldKey,
    String text,
  ) async {
    await $.enterText(find.byKey(Key(fieldKey)), text);
    await $.pumpAndSettle();
  }

  /// Wait for a page to load by checking for its key
  static Future<void> waitForPage(
    PatrolIntegrationTester $,
    String pageKey, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await $.waitUntilVisible(find.byKey(Key(pageKey)), timeout: timeout);
  }

  /// Scroll until a widget with key is visible
  static Future<void> scrollToKey(
    PatrolIntegrationTester $,
    String scrollableKey,
    String targetKey,
  ) async {
    await $.scrollUntilVisible(
      finder: find.byKey(Key(targetKey)),
      view: find.byKey(Key(scrollableKey)),
    );
  }

  /// Generic wait with better error messages
  static Future<void> waitUntilPresent(
    PatrolIntegrationTester $,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
    String? description,
  }) async {
    try {
      await $.waitUntilVisible(finder, timeout: timeout);
    } catch (e) {
      final desc = description ?? 'Widget ${finder.toString()}';
      throw StateError('$desc was not found within ${timeout.inSeconds}s');
    }
  }

  /// Common navigation patterns
  static Future<void> navigateBack(PatrolIntegrationTester $) async {
    await $.tap(find.byKey(const Key('back_button')));
    await $.pumpAndSettle();
  }

  static Future<void> openDrawer(PatrolIntegrationTester $) async {
    await $.tap(find.byKey(const Key('drawer_button')));
    await $.pumpAndSettle();
  }

  static Future<void> submitForm(
    PatrolIntegrationTester $,
    String formKey,
  ) async {
    await $.tap(find.byKey(Key('${formKey}_submit_button')));
    await $.pumpAndSettle();
  }
}

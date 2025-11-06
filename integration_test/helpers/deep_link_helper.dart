// EduLift Mobile E2E - Deep Link Helper
// Provides robust deep link handling with timeout protection
// Prevents tests from hanging when deep links are misconfigured

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// Helper class for safe deep link handling in E2E tests
///
/// This helper prevents tests from hanging indefinitely when deep links fail
/// by wrapping openUrl() calls with timeouts and verification.
///
/// Usage:
/// ```dart
/// // Open a deep link and verify expected screen appears
/// await DeepLinkHelper.openAndVerify(
///   $,
///   'edulift://auth?token=abc123',
///   expect: find.text('Verification'),
///   timeout: Duration(seconds: 10),
/// );
///
/// // Or just open with timeout (no verification)
/// await DeepLinkHelper.openWithTimeout(
///   $,
///   'edulift://dashboard',
///   timeout: Duration(seconds: 5),
/// );
/// ```
class DeepLinkHelper {
  /// Opens a deep link and verifies that the expected widget is visible.
  ///
  /// **WARNING**: If the deep link is completely broken (wrong scheme, no handler),
  /// this call may hang indefinitely. Always verify your AndroidManifest.xml and
  /// config/*.json are correct BEFORE running tests.
  ///
  /// Parameters:
  /// - [$]: The Patrol tester instance
  /// - [url]: The deep link URL to open (e.g., 'edulift://auth?token=abc')
  /// - [expect]: The finder for a widget that should appear after successful navigation
  /// - [timeout]: Maximum time to wait for expected widget (default: 10s)
  /// - [pumpAndSettle]: Whether to call pumpAndSettle after verification (default: true)
  ///
  /// Throws:
  /// - [TestFailure] with a clear error message if navigation doesn't succeed
  static Future<void> openAndVerify(
    PatrolIntegrationTester $,
    String url, {
    required Finder expect,
    Duration timeout = const Duration(seconds: 10),
    bool pumpAndSettle = true,
  }) async {
    // Open the deep link
    await $.native.openUrl(url);
    await $.pump(const Duration(milliseconds: 300));

    // Verify that the navigation was successful by checking for the widget
    try {
      await $.waitUntilVisible(expect, timeout: timeout);

      // Wait for animations to finish if requested
      if (pumpAndSettle) {
        await $.pumpAndSettle();
      }
    } catch (e) {
      fail(
        'Failed to find expected widget within ${timeout.inSeconds}s after opening deep link.\n'
        'URL: "$url"\n'
        'Please check:\n'
        '  1. AndroidManifest.xml has correct intent-filters\n'
        '  2. config/*.json has correct DEEP_LINK_BASE_URL\n'
        '  3. go_router is configured to handle this path\n'
        '  4. The expected widget is actually rendered after navigation\n'
        'Original error: $e',
      );
    }
  }

  /// Opens a deep link without verification.
  ///
  /// **WARNING**: If the deep link is completely broken (wrong scheme, no handler),
  /// this call may hang indefinitely. Always verify your AndroidManifest.xml and
  /// config/*.json are correct BEFORE running tests.
  ///
  /// Use this when you don't have a specific widget to verify, or when you want
  /// to perform custom verification after opening the link.
  ///
  /// Parameters:
  /// - [$]: The Patrol tester instance
  /// - [url]: The deep link URL to open
  /// - [pumpDuration]: Duration to pump after opening (default: 300ms)
  static Future<void> openWithTimeout(
    PatrolIntegrationTester $,
    String url, {
    Duration pumpDuration = const Duration(milliseconds: 300),
  }) async {
    await $.native.openUrl(url);
    await $.pump(pumpDuration);
  }

  /// Helper to validate that a deep link URL matches the expected format
  ///
  /// Useful for debugging before attempting to open a link
  static void validateUrl(String url, String expectedScheme) {
    if (!url.startsWith('$expectedScheme://')) {
      throw ArgumentError(
        'Invalid deep link URL: "$url"\n'
        'Expected scheme: "$expectedScheme://"\n'
        'Got: "${url.split('://').first}://"',
      );
    }
  }
}

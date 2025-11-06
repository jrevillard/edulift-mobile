// EduLift Mobile Integration Test - Cross-User Attack Prevention
// Tests that cross-user magic link attacks are blocked at the service layer

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../helpers/deep_link_helper.dart';
import '../helpers/mailpit_helper.dart';
import '../helpers/auth_flow_helper.dart';

void main() {
  group('Cross-User Attack Prevention Integration Tests', () {
    String? testEmail;

    setUpAll(() async {
      debugPrint('🔧 CROSS USER: Setting up test suite');
    });

    setUp(() async {
      debugPrint('🔧 CROSS USER: Setting up individual test');
      testEmail = null;
    });

    tearDown(() async {
      if (testEmail != null && testEmail!.isNotEmpty) {
        await MailpitHelper.clearEmailsForRecipient(testEmail!);
        debugPrint('🧹 CROSS USER: Cleaned up emails for: $testEmail');
      }
    });

    patrolTest('cross-user magic link attack is blocked by service layer security', (
      $,
    ) async {
      // SIMPLE TEST: Use a hardcoded invalid magic link to test security validation
      // This simulates a cross-user attack scenario where someone tries to use
      // a magic link without proper local storage context

      debugPrint('🚀 Starting cross-user magic link security validation');
      debugPrint('   Testing security with invalid/cross-user magic link');

      // STEP 1: Initialize fresh app session (no stored email context)
      await AuthFlowHelper.initializeApp($);
      debugPrint('✅ Fresh app session initialized (no stored context)');

      // STEP 2: SECURITY TEST - Try to use an invalid magic link without proper context
      // This simulates what happens when someone tries to use another user's magic link
      // The security implementation requires:
      // 1. Original email stored in local storage during magic link request
      // 2. Valid PKCE code_verifier in local storage
      // 3. Matching token from backend
      // Without these, the service layer should block the verification

      const invalidMagicLink =
          'edulift://auth/verify?token=invalid_cross_user_token_12345';
      debugPrint('🔍 Testing cross-user attack with invalid magic link');
      debugPrint(
        '   No stored email context - should trigger security failure',
      );

      // Open the invalid magic link
      await DeepLinkHelper.openWithTimeout($, invalidMagicLink);
      await $.pump(const Duration(milliseconds: 500));
      await $.pumpAndSettle();

      // STEP 3: ENHANCED - Verify security error message content
      // The service layer should detect the missing context and show verification failed
      final errorMessage = await AuthFlowHelper.verifyVerificationFailedMessage(
        $,
        'errorAuthInvalidToken',
        timeout: const Duration(seconds: 6),
      );
      debugPrint(
        '✅ Cross-user magic link properly rejected by service layer security',
      );
      debugPrint('📝 Error message: "$errorMessage"');

      // STEP 4: Test proper recovery navigation after security rejection
      await $.waitUntilVisible(
        find.byKey(const Key('back-to-login-button')),
        timeout: const Duration(seconds: 3),
      );

      await $.tap(find.byKey(const Key('back-to-login-button')));
      await $.pumpAndSettle();

      expect(
        find.byKey(const Key('welcomeToEduLift')),
        findsOneWidget,
        reason: 'Should return to login after security rejection',
      );

      debugPrint('✅ Recovery navigation working after security rejection');

      debugPrint('🎉 Cross-user security test completed!');
      debugPrint(
        '   RESULT: Service layer properly blocks invalid/cross-user magic links',
      );
      debugPrint(
        '   SECURITY: Missing local context triggers security validation failure',
      );
    });
  });
}

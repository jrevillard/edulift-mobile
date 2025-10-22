/// Family Member Management E2E Tests
///
/// Tests the complete family member management workflow including:
/// - Admin permission validation
/// - Member invitation system (sending invitations with different roles)
/// - Member card content validation (both members and pending invitations)
/// - Context menu functionality for member actions
/// - Error handling for duplicate invitations
/// - Data persistence across navigation
///
/// This test validates all functionality using key-based selectors for
/// internationalization compatibility and follows deterministic testing patterns.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../helpers/test_data_generator.dart';
import '../helpers/auth_flow_helper.dart';
import '../helpers/invitation_flow_helper.dart';
import '../helpers/mailpit_helper.dart';

void main() {
  group('Family Member Management Tests', () {
    setUp(() async {
      // setUp is called before each test
      // Email clearing is handled in the test itself for specific invitations
    });

    patrolTest('Member management with content validation', ($) async {
      final userProfile = TestDataGenerator.generateUniqueUserProfile(
        prefix: 'member_test',
      );
      await AuthFlowHelper.initializeApp($);
      await AuthFlowHelper.completeNewUserAuthentication($, userProfile);
      await AuthFlowHelper.completeOnboardingFlow($);

      // Navigate to family members tab
      await $.tap(find.byKey(const Key('navigation_family')));
      await $.waitUntilVisible(
        find.byKey(const Key('family_members_tab')),
        timeout: const Duration(seconds: 5),
      );
      await $.tap(find.byKey(const Key('family_members_tab')));

      // Wait for tab content to load and stabilize
      await $.waitUntilVisible(
        find.byKey(const Key('floating_action_button_tab_0')),
        timeout: const Duration(seconds: 5),
      );
      await $.pumpAndSettle();

      // Validate admin permissions and initial state

      // FAB must be visible for admin users
      final fabElement = find.byKey(const Key('floating_action_button_tab_0'));
      expect(
        $(fabElement).visible,
        true,
        reason: 'CRITICAL: Admin FAB not visible - test cannot proceed',
      );

      // Count initial state
      final initialMemberCards = find.byType(Card);
      final initialMemberCount = initialMemberCards.evaluate().length;
      expect(
        initialMemberCount,
        greaterThan(0),
        reason:
            'CRITICAL: No member cards found - admin user should have at least one card',
      );

      // Test invitation system using helper
      final testInvitations = InvitationFlowHelper.generateTestInvitations(
        2,
        prefix: 'member_mgmt',
        roles: ['member', 'admin'],
      );

      // Clear any existing test emails to ensure clean state
      for (final invitation in testInvitations) {
        await MailpitHelper.clearEmailsForRecipient(invitation['email']!);
      }

      // Brief stabilization after email clearing
      await $.pumpAndSettle();

      // Send invitations using helper (already on family members tab)
      await InvitationFlowHelper.sendMultipleInvitations(
        $,
        testInvitations,
        fromMembersTab: true,
      );

      // Wait for all invitations to be processed and UI to stabilize
      await $.pumpAndSettle();

      // Validate member card content

      // Validate current member cards exist
      final currentMemberCards = find.byType(Card);
      final currentMemberCount = currentMemberCards.evaluate().length;
      expect(
        currentMemberCount,
        greaterThanOrEqualTo(initialMemberCount),
        reason: 'Member card count decreased unexpectedly',
      );

      // Validate specific card types based on actual application structure
      var memberCards = 0;
      var invitationCards = 0;

      for (var cardIndex = 0; cardIndex < currentMemberCount; cardIndex++) {
        final cardFinder = currentMemberCards.at(cardIndex);
        final cardWidget = cardFinder.evaluate().first.widget as Card;
        final keyString = cardWidget.key?.toString() ?? 'null';

        // Invitation cards have 'invitation_card_' in their key string
        if (keyString.contains('invitation_card_')) {
          invitationCards++;
        }
        // Member cards use ValueKey(member.id) but don't contain 'invitation_card_'
        else if (cardWidget.key is ValueKey) {
          memberCards++;
        }
      }

      // Validate exact card counts
      expect(
        memberCards,
        equals(1),
        reason: 'Should have exactly 1 member card (admin user)',
      );
      expect(
        invitationCards,
        equals(testInvitations.length),
        reason: 'Expected ${testInvitations.length} invitation cards',
      );

      // Wait for invitation cards to appear and stabilize before verification
      for (final invitation in testInvitations) {
        await InvitationFlowHelper.waitForInvitationCard($, invitation['email']!);
      }

      // Verify invitation cards exist with proper keys using helper
      InvitationFlowHelper.verifyInvitationCards(testInvitations);

      // Test complete invitation cancellation functionality with SEPARATED responsibilities
      final testInvitationEmail = testInvitations.first['email']!;

      // STEP A: Optional - Verify invitation code before cancellation (separate concern)
      // This verifies the email-to-UI code matching following the real UX flow
      debugPrint('🔍 OPTIONAL: Verifying invitation code before cancellation...');
      final codeVerificationResult = await InvitationFlowHelper.verifyInvitationCodeBeforeCancellation(
        $,
        testInvitationEmail,
      );

      expect(
        codeVerificationResult['success'],
        equals(true),
        reason: 'Invitation code should match between email and UI: ${codeVerificationResult['reason']}',
      );
      debugPrint('✅ Code verification passed: ${codeVerificationResult['emailCode']} == ${codeVerificationResult['uiCode']}');

      // STEP B: Perform FOCUSED invitation cancellation test (single responsibility)
      // This focuses ONLY on the cancellation flow without mixing in code verification
      debugPrint('🎯 MAIN: Performing focused invitation cancellation...');
      await InvitationFlowHelper.performCompleteInvitationCancellationTest(
        $,
        testInvitationEmail,
      );
      // If we reach this point, all cancellation validations have passed

      // Update card count after successful cancellation
      final postCancellationCards = find.byType(Card);
      final postCancellationCount = postCancellationCards.evaluate().length;
      expect(
        postCancellationCount,
        equals(currentMemberCount - 1),
        reason: 'Card count should decrease by 1 after successful cancellation',
      );

      // Context menu validation
      final memberActionButtons = find.byWidgetPredicate(
        (widget) =>
            widget.key != null &&
            widget.key.toString().contains('member_more_vert_button'),
      );

      final contextMenuCount = memberActionButtons.evaluate().length;
      expect(
        contextMenuCount,
        equals(1),
        reason:
            'Single admin should have 1 context menu button (for valid actions like Leave Family, View Details)',
      );

      // Test error handling

      // Test duplicate invitation error - Use an email that actually exists
      // We need to use an invitation that was just sent and still exists in the system
      // testInvitations[1] should still exist as we only cancelled testInvitations[0]
      final remainingInvitations = testInvitations.where((invitation) =>
        invitation['email'] != testInvitationEmail
      ).toList();

      expect(
        remainingInvitations.isNotEmpty,
        true,
        reason: 'Should have at least one remaining invitation for duplicate test',
      );

      final duplicateEmail = remainingInvitations.first['email']!;
      debugPrint('🔄 Testing duplicate invitation with existing email: $duplicateEmail');

      await $.tap(find.byKey(const Key('floating_action_button_tab_0')));
      await $.waitUntilVisible(
        find.byKey(const Key('email_address_field')),
        timeout: const Duration(seconds: 5),
      );

      // Allow form to fully load
      await $.pumpAndSettle();

      final duplicateEmailField = find.byKey(const Key('email_address_field'));
      await $.enterText(duplicateEmailField, duplicateEmail);

      final duplicateSendButton = find.byKey(
        const Key('send_invitation_button'),
      );
      await $.tap(duplicateSendButton);

      // Wait for response processing
      await $.pumpAndSettle();

      // Verify that duplicate invitation error is displayed
      // The duplicate invitation should remain in the form (not sent successfully)
      // and the form should still be visible (not automatically closed)
      final emailFieldAfterDuplicate = find.byKey(const Key('email_address_field'));
      expect(
        $(emailFieldAfterDuplicate).visible,
        true,
        reason: 'Email field should still be visible after duplicate attempt - form should not close on error',
      );

      // Verify the email is still in the field (indicating the invitation was not sent)
      final emailFieldWidget = emailFieldAfterDuplicate.evaluate().first.widget;
      if (emailFieldWidget is TextField) {
        final currentText = emailFieldWidget.controller?.text ?? '';
        expect(
          currentText,
          equals(duplicateEmail),
          reason: 'Email should remain in field after duplicate error - indicating invitation was not sent',
        );
      }

      debugPrint('✅ Duplicate invitation error handling verified - form remained open with email preserved');

      // Always ensure we return to members tab via cancel button
      final cancelButton = find.byKey(const Key('invite_member_cancel_button'));
      expect($(cancelButton).visible, true, reason: 'Cancel button not found');
      await $.tap(cancelButton);
      await $.waitUntilVisible(
        find.byKey(const Key('family_members_tab')),
        timeout: const Duration(seconds: 5),
      );

      // Allow navigation to complete and UI to stabilize
      await $.pumpAndSettle();

      // Test data persistence

      // Record current state
      final preNavMemberCount = find.byType(Card).evaluate().length;

      // Navigate to dashboard and back
      await $.tap(find.byKey(const Key('navigation_dashboard')));
      await $.waitUntilVisible(
        find.byKey(const Key('dashboard_title')),
        timeout: const Duration(seconds: 5),
      );

      // Allow dashboard to fully load
      await $.pumpAndSettle();

      expect(
        find.byKey(const Key('dashboard_title')),
        findsOneWidget,
        reason: 'Dashboard navigation failed',
      );

      // Return to members tab
      await $.tap(find.byKey(const Key('navigation_family')));
      await $.waitUntilVisible(
        find.byKey(const Key('family_members_tab')),
        timeout: const Duration(seconds: 5),
      );
      await $.tap(find.byKey(const Key('family_members_tab')));
      await $.waitUntilVisible(
        find.byKey(const Key('floating_action_button_tab_0')),
        timeout: const Duration(seconds: 5),
      );

      // Allow tab to fully load and UI to stabilize
      await $.pumpAndSettle();

      // Validate data persistence
      final postNavMemberCount = find.byType(Card).evaluate().length;
      expect(
        postNavMemberCount,
        equals(preNavMemberCount),
        reason:
            'Data persistence failed: $preNavMemberCount → $postNavMemberCount',
      );

      // Final validations

      // Final assertions
      expect(
        testInvitations.length,
        greaterThan(0),
        reason: 'No invitations sent',
      );
      expect(
        currentMemberCount,
        greaterThan(initialMemberCount),
        reason: 'Member count did not increase after invitations',
      );
      expect(
        postNavMemberCount,
        equals(preNavMemberCount),
        reason: 'Data persistence failed',
      );
    });
  });
}

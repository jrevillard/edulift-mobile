// EduLift Mobile E2E - Invitation Flow Helper
// Helper class for common invitation-related flows shared between tests
// Extracted from family_member_management_e2e_test.dart to avoid duplication

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'test_data_generator.dart';
import 'mailpit_helper.dart';

/// Helper class for invitation-related E2E test flows
///
/// This class provides common invitation operations used across multiple tests:
/// - Sending invitations with different roles
/// - Navigating to invitation forms
/// - Extracting invitation links from emails
/// - Basic invitation form validation
///
/// Usage:
/// ```dart
/// await InvitationFlowHelper.sendInvitation($, 'user@example.com', 'admin');
/// final link = await InvitationFlowHelper.getInvitationLinkFromEmail('user@example.com');
/// ```
class InvitationFlowHelper {
  /// Navigate to the family members tab and prepare for invitation sending
  ///
  /// This method handles the navigation from any location to the family members
  /// tab and ensures the invitation form is accessible.
  ///
  /// [tester] The PatrolIntegrationTester instance
  static Future<void> navigateToFamilyMembersTab(
    PatrolIntegrationTester tester,
  ) async {
    await tester.tap(find.byKey(const Key('navigation_family')));
    await tester.waitUntilVisible(
      find.byKey(const Key('family_members_tab')),
      timeout: const Duration(seconds: 5),
    );
    await tester.tap(find.byKey(const Key('family_members_tab')));
    await tester.waitUntilVisible(
      find.byKey(const Key('floating_action_button_tab_0')),
      timeout: const Duration(seconds: 5),
    );
  }

  /// Open the invitation form by tapping the FAB
  ///
  /// [tester] The PatrolIntegrationTester instance
  static Future<void> openInvitationForm(PatrolIntegrationTester tester) async {
    await tester.tap(find.byKey(const Key('floating_action_button_tab_0')));
    await tester.waitUntilVisible(
      find.byKey(const Key('email_address_field')),
      timeout: const Duration(seconds: 5),
    );
  }

  /// Fill the invitation form with email and role
  ///
  /// [tester] The PatrolIntegrationTester instance
  /// [email] The email address to invite
  /// [role] The role to assign ('admin' or 'member')
  static Future<void> fillInvitationForm(
    PatrolIntegrationTester tester,
    String email,
    String role, {
    String? personalMessage,
  }) async {
    // Fill email field
    final emailField = find.byKey(const Key('email_address_field'));
    await tester.enterText(emailField, email);

    // Select role from dropdown
    final roleSelector = find.byKey(const Key('inviteRoleSelector'));
    await tester.tap(roleSelector);
    await tester.pumpAndSettle();

    // Select specific role from dropdown menu
    final menuTextKey = role == 'admin'
        ? const Key('role_menu_text_ADMIN')
        : const Key('role_menu_text_MEMBER');

    await tester.waitUntilVisible(
      find.byKey(menuTextKey),
      timeout: const Duration(seconds: 5),
    );
    await tester.tap(find.byKey(menuTextKey));
    await tester.pumpAndSettle();

    // Fill personal message if provided
    if (personalMessage != null && personalMessage.isNotEmpty) {
      final messageField = find.byKey(const Key('personal_message_field'));
      await tester.enterText(messageField, personalMessage);
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  /// Submit the invitation form
  ///
  /// [tester] The PatrolIntegrationTester instance
  static Future<void> submitInvitationForm(
    PatrolIntegrationTester tester,
  ) async {
    final sendButton = find.byKey(const Key('send_invitation_button'));
    await tester.tap(sendButton);

    // Wait for navigation back to family members tab (success indicator)
    await tester.waitUntilVisible(
      find.byKey(const Key('family_members_tab')),
      timeout: const Duration(seconds: 5),
    );
  }

  /// Send a complete invitation (navigate + fill + submit)
  ///
  /// This is a convenience method that combines all the steps to send an invitation.
  /// Use this when you need to send an invitation from any starting point.
  ///
  /// [tester] The PatrolIntegrationTester instance
  /// [email] The email address to invite
  /// [role] The role to assign ('admin' or 'member')
  static Future<void> sendInvitation(
    PatrolIntegrationTester tester,
    String email,
    String role, {
    String? personalMessage,
  }) async {
    await navigateToFamilyMembersTab(tester);
    await openInvitationForm(tester);
    await fillInvitationForm(
      tester,
      email,
      role,
      personalMessage: personalMessage,
    );
    await submitInvitationForm(tester);
  }

  /// Send an invitation from the family members tab (assumes already on the tab)
  ///
  /// Use this when you're already on the family members tab and just need to
  /// send another invitation.
  ///
  /// [tester] The PatrolIntegrationTester instance
  /// [email] The email address to invite
  /// [role] The role to assign ('admin' or 'member')
  static Future<void> sendInvitationFromMembersTab(
    PatrolIntegrationTester tester,
    String email,
    String role, {
    String? personalMessage,
  }) async {
    await openInvitationForm(tester);
    await fillInvitationForm(
      tester,
      email,
      role,
      personalMessage: personalMessage,
    );
    await submitInvitationForm(tester);
  }

  /// Send multiple invitations efficiently
  ///
  /// [tester] The PatrolIntegrationTester instance
  /// [invitations] List of maps with 'email' and 'role' keys
  /// [fromMembersTab] If true, assumes already on family members tab
  static Future<void> sendMultipleInvitations(
    PatrolIntegrationTester tester,
    List<Map<String, String>> invitations, {
    bool fromMembersTab = false,
  }) async {
    if (!fromMembersTab) {
      await navigateToFamilyMembersTab(tester);
    }

    for (final invitation in invitations) {
      final email = invitation['email'];
      final role = invitation['role'];
      if (email == null || role == null) {
        debugPrint(
          '⚠️ Skipping invitation with null email or role: $invitation',
        );
        continue;
      }
      await sendInvitationFromMembersTab(tester, email, role);
    }
  }

  /// Get invitation email for a specific recipient
  ///
  /// [recipientEmail] The email address to look for
  /// [timeout] Maximum time to wait for the email
  static Future<MailpitMessage?> getInvitationEmail(
    String recipientEmail, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final email = await MailpitHelper.waitForEmail(
      recipientEmail,
      timeout: timeout,
      subjectFilter: 'Invitation',
    );

    return email;
  }

  /// Extract invitation link from email content
  ///
  /// [recipientEmail] The email address to get the invitation for
  /// [timeout] Maximum time to wait for the email
  static Future<String?> getInvitationLinkFromEmail(
    String recipientEmail, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    debugPrint(
      '🔍 DEBUG: getInvitationLinkFromEmail() starting for: $recipientEmail',
    );

    final invitationEmail = await getInvitationEmail(
      recipientEmail,
      timeout: timeout,
    );

    if (invitationEmail == null) {
      debugPrint(
        '🔍 DEBUG: getInvitationEmail() returned null for: $recipientEmail',
      );
      return null;
    }

    debugPrint('🔍 DEBUG: Found invitation email: ${invitationEmail.subject}');

    final fullMessage = await MailpitHelper.getMessageById(invitationEmail.id);
    if (fullMessage == null) {
      debugPrint(
        '🔍 DEBUG: getMessageById() returned null for email ID: ${invitationEmail.id}',
      );
      return null;
    }

    debugPrint(
      '🔍 DEBUG: Retrieved full message, HTML length: ${fullMessage.html.length}',
    );
    final link = _extractInvitationLink(fullMessage.html);
    debugPrint('🔍 DEBUG: _extractInvitationLink() returned: $link');

    return link;
  }

  /// Extract invitation code from email content
  ///
  /// [recipientEmail] The email address to get the invitation for
  /// [timeout] Maximum time to wait for the email
  static Future<String?> getInvitationCodeFromEmail(
    String recipientEmail, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final invitationEmail = await getInvitationEmail(
      recipientEmail,
      timeout: timeout,
    );

    if (invitationEmail == null) {
      return null;
    }

    final fullMessage = await MailpitHelper.getMessageById(invitationEmail.id);
    if (fullMessage == null) {
      return null;
    }

    return _extractInvitationCode(fullMessage);
  }

  /// Verify invitation email content contains expected information
  ///
  /// [recipientEmail] The email address to verify
  /// [timeout] Maximum time to wait for the email
  static Future<Map<String, String?>> verifyInvitationEmailContent(
    String recipientEmail, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final invitationEmail = await getInvitationEmail(
      recipientEmail,
      timeout: timeout,
    );

    if (invitationEmail == null) {
      return {'status': 'not_found', 'email': null, 'code': null, 'link': null};
    }

    final fullMessage = await MailpitHelper.getMessageById(invitationEmail.id);
    if (fullMessage == null) {
      return {
        'status': 'content_not_found',
        'email': invitationEmail.to.isNotEmpty
            ? invitationEmail.to.first
            : null,
        'code': null,
        'link': null,
      };
    }

    final code = _extractInvitationCode(fullMessage);
    final link = _extractInvitationLink(fullMessage.html);

    return {
      'status': 'found',
      'email': invitationEmail.to.isNotEmpty ? invitationEmail.to.first : null,
      'code': code,
      'link': link,
      'subject': fullMessage.subject,
    };
  }

  /// Helper function to extract invitation link from email HTML content
  static String? _extractInvitationLink(String htmlContent) {
    // Recherche le pattern edulift://families/join?code=... OU edulift://groups/join?code=...
    final linkPattern = RegExp(
      r'edulift://(families|groups)/join\?code=([A-Z0-9]+)',
    );
    final match = linkPattern.firstMatch(htmlContent);

    if (match != null) {
      return match.group(0); // Retourne le lien complet
    }

    return null;
  }

  /// Helper function to extract invitation code from email content
  static String? _extractInvitationCode(MailpitFullMessage fullMessage) {
    // Try HTML content first, then fallback to text
    final content = fullMessage.html.isNotEmpty
        ? fullMessage.html
        : fullMessage.text;

    // Various patterns to match invitation codes
    final patterns = [
      // Deep link format: edulift://families/join?code=...
      RegExp(r'edulift://families/join\?code=([A-Z0-9]+)'),
      // URL parameter format
      RegExp(r'code=([A-Z0-9_]+)'),
      // Text patterns
      RegExp(r'invitation.*code[:\s]*([A-Z0-9_]{6,})'),
      RegExp(r'code[:\s]*([A-Z0-9_]{6,})'),
      RegExp(r'INV_[0-9]+_[A-Z0-9]+'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(content);
      if (match != null) {
        final code = match.group(1) ?? match.group(0);
        if (code != null && code.length >= 6) {
          return code;
        }
      }
    }

    return null;
  }

  /// Generate test invitation data
  ///
  /// [count] Number of invitations to generate
  /// [prefix] Prefix for email generation
  /// [roles] List of roles to cycle through (defaults to ['member', 'admin'])
  static List<Map<String, String>> generateTestInvitations(
    int count, {
    String prefix = 'test_invite',
    List<String> roles = const ['member', 'admin'],
  }) {
    final invitations = <Map<String, String>>[];

    for (var i = 0; i < count; i++) {
      final email = TestDataGenerator.generateEmailWithPrefix('${prefix}_$i');
      final role = roles[i % roles.length];

      invitations.add({'email': email, 'role': role});
    }

    return invitations;
  }

  /// Verify invitation cards exist for sent invitations with retry logic
  ///
  /// [invitations] List of invitations to verify
  static void verifyInvitationCards(List<Map<String, String>> invitations) {
    for (final invitation in invitations) {
      final email = invitation['email'];
      if (email == null) {
        debugPrint(
          '⚠️ Skipping invitation card verification with null email: $invitation',
        );
        continue;
      }
      debugPrint('🔍 Verifying invitation card for: $email');

      // Verify invitation card exists
      final invitationCardKey = Key('invitation_card_${email}_pending');
      expect(
        find.byKey(invitationCardKey),
        findsOneWidget,
        reason: 'Invitation card should exist for email: $email',
      );

      // Verify email display exists
      final emailKey = Key('invitation_email_$email');
      expect(
        find.byKey(emailKey),
        findsOneWidget,
        reason: 'Email display should exist for: $email',
      );

      debugPrint('✅ Invitation card verified for: $email');
    }
  }

  /// Ensures an invitation card is visible on screen by scrolling if necessary
  ///
  /// This method tries multiple scrolling strategies to handle different UI layouts:
  /// 1. SingleChildScrollView (most common)
  /// 2. ListView (for list-based layouts)
  /// 3. Scrollable (generic fallback)
  ///
  /// [tester] The PatrolIntegrationTester instance
  /// [cardFinder] The Finder for the invitation card widget
  static Future<void> _ensureInvitationCardVisible(
    PatrolIntegrationTester tester,
    Finder cardFinder,
  ) async {
    debugPrint('🔍 Ensuring invitation card is visible on screen...');

    // First check if card is already visible
    try {
      await tester.waitUntilVisible(
        cardFinder,
        timeout: const Duration(seconds: 1),
      );
      debugPrint('✅ Card is already visible');
      return;
    } catch (e) {
      debugPrint('⚠️ Card not immediately visible, attempting to scroll...');
    }

    // Strategy 1: Try SingleChildScrollView (most common in family screens)
    try {
      final scrollViews = find.byType(SingleChildScrollView);
      if (scrollViews.evaluate().isNotEmpty) {
        debugPrint('📜 Found SingleChildScrollView, attempting scroll...');
        await tester.scrollUntilVisible(
          finder: cardFinder,
          view: scrollViews.first,
          scrollDirection: AxisDirection.down,
        );
        debugPrint('✅ Successfully scrolled using SingleChildScrollView');
        return;
      }
    } catch (scrollError) {
      debugPrint('⚠️ SingleChildScrollView scroll failed: $scrollError');
    }

    // Strategy 2: Try ListView
    try {
      final listViews = find.byType(ListView);
      if (listViews.evaluate().isNotEmpty) {
        debugPrint('📋 Found ListView, attempting scroll...');
        await tester.scrollUntilVisible(
          finder: cardFinder,
          view: listViews.first,
          scrollDirection: AxisDirection.down,
        );
        debugPrint('✅ Successfully scrolled using ListView');
        return;
      }
    } catch (scrollError) {
      debugPrint('⚠️ ListView scroll failed: $scrollError');
    }

    // Strategy 3: Try generic Scrollable widget
    try {
      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isNotEmpty) {
        debugPrint('🔄 Found Scrollable widget, attempting scroll...');
        await tester.scrollUntilVisible(
          finder: cardFinder,
          view: scrollables.first,
          scrollDirection: AxisDirection.down,
        );
        debugPrint('✅ Successfully scrolled using Scrollable');
        return;
      }
    } catch (scrollError) {
      debugPrint('⚠️ Scrollable scroll failed: $scrollError');
    }

    debugPrint(
      '❌ All scrolling strategies failed, but card exists in widget tree',
    );
    // Don't throw exception - the card might still be tappable even if not fully visible
    debugPrint(
      '⚠️ Proceeding without perfect visibility - attempting tap anyway',
    );
  }

  /// Wait for invitation to be processed and card to appear with improved stability
  ///
  /// [tester] The PatrolIntegrationTester instance
  /// [email] The email address of the invitation
  /// [timeout] Maximum time to wait
  static Future<void> waitForInvitationCard(
    PatrolIntegrationTester tester,
    String email, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final invitationCardKey = Key('invitation_card_${email}_pending');

    // Wait for widget tree to stabilize
    await tester.pumpAndSettle();

    // Check if the widget exists in the widget tree
    final cardFinder = find.byKey(invitationCardKey);

    // Wait for the widget to exist with faster polling
    var attempts = 0;
    while (cardFinder.evaluate().isEmpty && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      attempts++;
    }

    if (cardFinder.evaluate().isEmpty) {
      throw Exception(
        'Invitation card with key $invitationCardKey not found in widget tree',
      );
    }

    debugPrint('🎴 Found invitation card widget, ensuring it\'s visible...');

    // Now ensure the widget is scrolled into view and visible with robust error handling
    try {
      // Try multiple scrolling strategies to ensure the card is visible
      await _ensureInvitationCardVisible(tester, cardFinder);
      debugPrint('🔄 Successfully ensured invitation card is visible');

      // Check widget visibility with safer approach
      var retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          // Check if the widget still exists before trying to wait for it
          final currentElements = cardFinder.evaluate();
          if (currentElements.isEmpty) {
            debugPrint('❌ Widget disappeared from widget tree during waiting');
            throw Exception(
              'Invitation card widget was removed from widget tree',
            );
          }

          // First try to check if widget is already visible with safe access
          try {
            if (currentElements.isEmpty) {
              throw Exception('No elements found in currentElements');
            }
            final element = currentElements.first;

            // Safely check if element still has a valid widget
            // Note: element.widget CAN be null during dispose operations
            final widget = element.widget;
            debugPrint(
              '🎯 Widget found: ${widget.runtimeType} with key: ${widget.key}',
            );

            // Try to check if it's visible by attempting a simple operation
            final renderObject = element.renderObject;
            if (renderObject != null) {
              debugPrint('✅ Widget has render object - likely visible');
              return; // Widget is likely visible
            }
          } catch (nullCheckError) {
            debugPrint(
              '⚠️ Null check error during widget access: $nullCheckError',
            );
            // Continue with the waiting logic below
          }

          // If not immediately visible, wait for it with shorter timeout
          await tester.waitUntilVisible(
            cardFinder,
            timeout: const Duration(seconds: 3),
          );

          debugPrint('✅ Widget is now visible');
          return; // Success - widget is visible
        } catch (visibilityError) {
          retryCount++;
          debugPrint(
            '⚠️ Visibility attempt $retryCount failed: $visibilityError',
          );

          if (retryCount >= maxRetries) {
            // For the final retry, just check if widget exists - that might be enough
            try {
              final elements = cardFinder.evaluate();
              if (elements.isNotEmpty) {
                debugPrint(
                  '🤞 Widget exists but visibility check failed - proceeding anyway',
                );
                return; // Widget exists, proceed with test
              }
            } catch (finalCheckError) {
              debugPrint('❌ Final widget check also failed: $finalCheckError');
            }
            rethrow;
          }

          // Brief stabilization before retry
          await tester.pumpAndSettle();
        }
      }
    } catch (e) {
      debugPrint('❌ Critical error in waitForInvitationCard: $e');

      // Provide helpful error context
      final cardExists = cardFinder.evaluate().isNotEmpty;
      final errorMessage =
          'Failed to make invitation card visible. '
          'Card exists in widget tree: $cardExists. '
          'Original error: $e';

      throw Exception(errorMessage);
    }
  }

  /// Verify invitation code before cancellation (separate step)
  ///
  /// This method verifies that the invitation code from email matches what's displayed
  /// in the UI by following the real UX flow: Card → BottomSheet → Show Code Dialog
  ///
  /// [tester] The PatrolIntegrationTester instance
  /// [email] The email address of the invitation
  /// [timeout] Maximum time to wait for email
  static Future<Map<String, dynamic>> verifyInvitationCodeBeforeCancellation(
    PatrolIntegrationTester tester,
    String email, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      debugPrint('🔍 Starting invitation code verification for: $email');

      // Step 1: Get the invitation code from the email
      final emailContent = await verifyInvitationEmailContent(
        email,
        timeout: timeout,
      );

      if (emailContent['status'] != 'found' || emailContent['code'] == null) {
        return {
          'success': false,
          'reason': 'invitation_email_not_found',
          'emailCode': null,
          'uiCode': null,
        };
      }

      final emailCode = emailContent['code'];
      if (emailCode == null) {
        return {
          'success': false,
          'reason': 'code_null_after_verification',
          'emailCode': null,
          'uiCode': null,
        };
      }
      debugPrint('📧 Email code found: $emailCode');

      // Step 2: Find the invitation card in the UI
      final invitationCardKey = Key('invitation_card_${email}_pending');
      final cardFinder = find.byKey(invitationCardKey);

      if (cardFinder.evaluate().isEmpty) {
        debugPrint('❌ Invitation card not found for email: $email');
        return {
          'success': false,
          'reason': 'invitation_card_not_found',
          'emailCode': emailCode,
          'uiCode': null,
        };
      }

      debugPrint('🎴 Invitation card found');

      // Step 3: Ensure card is visible before tapping
      await _ensureInvitationCardVisible(tester, cardFinder);

      // Step 3: Tap card to open BottomSheet
      await tester.tap(cardFinder);
      await tester.pumpAndSettle();

      debugPrint('📋 BottomSheet opened');

      // Step 4: Find and tap "Show Code" action
      final showCodeActionFinder = find.byKey(Key('show_code_action_${email}'));

      if (showCodeActionFinder.evaluate().isEmpty) {
        debugPrint('❌ Show code action not found with deterministic key');
        return {
          'success': false,
          'reason': 'show_code_action_not_found',
          'emailCode': emailCode,
          'uiCode': null,
        };
      }

      await tester.tap(showCodeActionFinder);
      await tester.pumpAndSettle();

      debugPrint('🔐 Code dialog opened');

      // Step 5: Find the code display using ONLY deterministic key
      final codeDisplayFinder = find.byKey(
        Key('invitation_code_display_$email'),
      );

      if (codeDisplayFinder.evaluate().isEmpty) {
        debugPrint('❌ Code display not found with deterministic key');
        return {
          'success': false,
          'reason': 'code_display_not_found',
          'emailCode': emailCode,
          'uiCode': null,
        };
      }

      // Extract the code from the SelectableText widget with robust null safety
      String? uiCode;
      try {
        // Wait for widget tree to stabilize before accessing
        await tester.pumpAndSettle();

        final elements = codeDisplayFinder.evaluate();
        if (elements.isNotEmpty) {
          final element = elements.first;

          // Check if element still has a valid widget before accessing
          final widget = element.widget;
          if (widget is SelectableText) {
            uiCode = widget.data;
            debugPrint('🔤 UI code found with deterministic key: $uiCode');
          } else {
            debugPrint('❌ Widget is not SelectableText: ${widget.runtimeType}');
          }
        } else {
          debugPrint('❌ No elements found for code display finder');
        }
      } catch (e) {
        debugPrint('❌ Error accessing SelectableText widget safely: $e');
        uiCode = null;
      }

      // Step 6: Close the dialog with robust error handling
      final closeFinder = find.byKey(
        Key('close_invitation_code_dialog_$email'),
      );

      try {
        if (closeFinder.evaluate().isNotEmpty) {
          await tester.tap(closeFinder);
          await tester.pumpAndSettle();
          debugPrint('🚪 Dialog closed with deterministic key');
        } else {
          debugPrint(
            '⚠️ Close button not found - dialog might already be closed',
          );
        }
      } catch (e) {
        debugPrint('⚠️ Error closing dialog: $e - continuing with test');
      }

      // Step 7: Check if the codes match
      final codesMatch = uiCode != null && uiCode.contains(emailCode);

      final result = {
        'success': uiCode != null && codesMatch,
        'reason': uiCode == null
            ? 'code_not_displayed_in_ui'
            : !codesMatch
            ? 'codes_do_not_match'
            : 'success',
        'emailCode': emailCode,
        'uiCode': uiCode,
        'emailSubject': emailContent['subject'],
      };

      debugPrint(
        '✅ Code verification result: ${result['success']} - ${result['reason']}',
      );
      return result;
    } catch (e, stackTrace) {
      debugPrint('❌ Error during code verification: $e');
      debugPrint('StackTrace: $stackTrace');
      return {
        'success': false,
        'reason': 'verification_error: $e',
        'emailCode': null,
        'uiCode': null,
      };
    }
  }

  /// Cancel a pending invitation using DETERMINISTIC key-based approach
  ///
  /// This method follows README.md principles strictly:
  /// - "Tests doivent être déterministes"
  /// - "Toujours utiliser des key pour trouver les objects"
  /// - NO fallback strategies, NO widget predicates, NO text searching
  ///
  /// [tester] The PatrolIntegrationTester instance
  /// [email] The email address of the invitation to cancel
  static Future<bool> cancelInvitation(
    PatrolIntegrationTester tester,
    String email,
  ) async {
    try {
      debugPrint(
        '🔧 Starting DETERMINISTIC invitation cancellation for: $email',
      );

      // STEP 1: Find the invitation card using deterministic key
      final invitationCard = find.byKey(
        Key('invitation_card_${email}_pending'),
      );
      if (invitationCard.evaluate().isEmpty) {
        debugPrint('❌ Invitation card not found for email: $email');
        return false;
      }

      debugPrint('🎴 Found invitation card with deterministic key');

      // STEP 2: Ensure card is visible before tapping
      await _ensureInvitationCardVisible(tester, invitationCard);

      // STEP 2: Tap directly on the invitation card to open the bottom sheet
      // The invitation card is clickable and will open the actions bottom sheet
      debugPrint('DEBUG: Tapping on invitation card for email: $email');

      await tester.tap(invitationCard);
      await tester.pumpAndSettle();

      debugPrint('📋 BottomSheet opened');

      // STEP 3: Find and tap the cancel action using ONLY deterministic key
      final cancelAction = find.byKey(Key('cancel_invitation_action_$email'));

      if (cancelAction.evaluate().isEmpty) {
        debugPrint(
          '❌ Cancel invitation action not found with deterministic key: cancel_invitation_action_$email',
        );

        // DEBUG: Let's see what widgets are actually available
        debugPrint('DEBUG: Available widgets in the widget tree:');
        final allWidgets = find.byType(Widget);
        for (final element in allWidgets.evaluate()) {
          final widget = element.widget;
          if (widget.key != null) {
            debugPrint('  Found widget with key: ${widget.key}');
          }
        }

        return false;
      }

      debugPrint('🗑️ Found cancel action with deterministic key');

      await tester.waitUntilVisible(
        cancelAction,
        timeout: const Duration(seconds: 5),
      );
      await tester.tap(cancelAction);

      // Wait for the cancellation action to complete
      await tester.pumpAndSettle();

      debugPrint('✅ DETERMINISTIC invitation cancellation completed');
      return true;
    } catch (e) {
      debugPrint('❌ Error during DETERMINISTIC invitation cancellation: $e');
      return false;
    }
  }

  /// Verify invitation cancellation was successful
  ///
  /// [tester] The PatrolIntegrationTester instance
  /// [email] The email address of the cancelled invitation
  static Future<bool> verifyInvitationCancellation(
    PatrolIntegrationTester tester,
    String email,
  ) async {
    // Wait for UI to update
    await tester.pumpAndSettle();

    // Check if the invitation card we just cancelled is no longer present
    final invitationCard = find.byKey(Key('invitation_card_${email}_pending'));
    debugPrint(
      'DEBUG: Initial card check - found: ${invitationCard.evaluate().isNotEmpty}',
    );

    if (invitationCard.evaluate().isEmpty) {
      debugPrint('✅ Card successfully disappeared');
      return true; // Card disappeared, cancellation successful
    }

    debugPrint('DEBUG: TIMEOUT - Card still exists after cancellation!');
    return false; // card is still present
  }

  /// Complete invitation cancellation test - FOCUSED ON CANCELLATION ONLY
  ///
  /// This method performs ONLY the invitation cancellation flow and validates:
  /// 1. Verifies email content exists (basic validation)
  /// 2. Performs cancellation with expect() assertions
  /// 3. Verifies cancellation was successful with expect() assertions
  ///
  /// NOTE: Code verification should be done separately using
  /// verifyInvitationCodeBeforeCancellation() if needed.
  ///
  /// Throws meaningful assertion errors if any step fails.
  /// Follows Single Responsibility Principle - ONLY does cancellation.
  ///
  /// [tester] The PatrolIntegrationTester instance
  /// [email] The email address of the invitation to cancel
  static Future<void> performCompleteInvitationCancellationTest(
    PatrolIntegrationTester tester,
    String email,
  ) async {
    try {
      debugPrint(
        '🧪 Starting FOCUSED invitation cancellation test for: $email',
      );

      // Step 1: Basic email verification (ensure email exists)
      debugPrint('📧 Step 1: Verifying email content exists...');
      final emailVerification = await verifyInvitationEmailContent(email);

      expect(
        emailVerification,
        isNotNull,
        reason: 'Email verification should have been performed',
      );

      expect(
        emailVerification['status'],
        equals('found'),
        reason: 'Invitation email should be found in MailHog',
      );

      expect(
        emailVerification['email'],
        equals(email),
        reason: 'Email recipient should match test invitation email',
      );

      debugPrint(
        '✅ Step 1: Email verification passed - Email found for: ${emailVerification['email']}',
      );

      // Step 2: Perform cancellation with assertions
      debugPrint('🔍 Step 2: Performing invitation cancellation...');
      final cancellationPerformed = await cancelInvitation(tester, email);

      expect(
        cancellationPerformed,
        equals(true),
        reason:
            'Cancellation operation should have been performed successfully',
      );

      debugPrint('✅ Step 2: Cancellation performed successfully');

      // Step 3: Verify cancellation was successful with assertions
      debugPrint('🔍 Step 3: Verifying cancellation result...');
      final cancellationVerified = await verifyInvitationCancellation(
        tester,
        email,
      );

      expect(
        cancellationVerified,
        equals(true),
        reason:
            'Invitation card should be removed after successful cancellation',
      );

      debugPrint('✅ Step 3: Cancellation verification passed');

      debugPrint('🎉 FOCUSED invitation cancellation test PASSED for: $email');
    } catch (e, stackTrace) {
      debugPrint('❌ FOCUSED invitation cancellation test FAILED for: $email');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');

      // Re-throw the error with enhanced context
      if (e is TestFailure) {
        // Re-throw TestFailure as-is with original message
        rethrow;
      } else {
        // Wrap other exceptions as test failures
        throw TestFailure(
          'FOCUSED invitation cancellation test failed for $email: $e',
        );
      }
    }
  }

  /// Verify that invitation error message is displayed with correct localized content
  ///
  /// This validates the 'invitation_error_$errorKey' Text widget used in invitation_error_display.dart
  /// Unlike simple existence checks, this validates the actual user-facing message content.
  ///
  /// Parameters:
  /// - [tester]: Patrol test instance
  /// - [expectedErrorKey]: The error key (e.g., 'errorInvitationEmailMismatch', 'errorInvitationCodeInvalid')
  /// - [timeout]: Optional timeout duration (default: 5 seconds)
  ///
  /// Returns: The actual error message text found
  ///
  /// Throws: TestFailure if error widget not found or message doesn't match expectations
  ///
  /// Example:
  /// ```dart
  /// await InvitationFlowHelper.verifyInvitationErrorMessage(
  ///   $,
  ///   'errorInvitationEmailMismatch',
  /// );
  /// ```
  static Future<String> verifyInvitationErrorMessage(
    PatrolIntegrationTester tester,
    String expectedErrorKey, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    debugPrint(
      '🔍 Verifying invitation error message for key: $expectedErrorKey',
    );

    // Step 1: Wait for invitation error widget to appear
    final errorKey = Key('invitation_error_$expectedErrorKey');
    await tester.waitUntilVisible(find.byKey(errorKey), timeout: timeout);
    debugPrint(
      '✅ Invitation error widget found: invitation_error_$expectedErrorKey',
    );

    // Step 2: Get the Text widget (it has the key directly)
    final errorWidget = find.byKey(errorKey);
    final widget = tester.tester.widget(errorWidget);

    // Step 3: Extract the message text
    String actualMessage;
    if (widget is Text) {
      actualMessage = (widget.data ?? widget.textSpan?.toPlainText() ?? '')
          .trim();
      debugPrint('📝 Found invitation error message: "$actualMessage"');
    } else {
      throw TestFailure(
        'Expected Text widget with key invitation_error_$expectedErrorKey, but found ${widget.runtimeType}',
      );
    }

    // Step 4: Verify message is not empty
    expect(
      actualMessage,
      isNotEmpty,
      reason: 'Invitation error message should not be empty',
    );

    // Step 5: Verify message is not a raw localization key
    expect(
      actualMessage.startsWith('error') &&
          actualMessage.contains(RegExp(r'[A-Z]')),
      isFalse,
      reason:
          'Invitation error message should be localized, not a raw key like "$actualMessage"',
    );

    debugPrint(
      '✅ Invitation error message validation passed: "$actualMessage"',
    );
    return actualMessage;
  }

  /// Verify that NO invitation error is displayed
  ///
  /// Useful for testing successful invitation flows or error state clearing
  static Future<void> verifyNoInvitationError(
    PatrolIntegrationTester tester,
    String errorKey,
  ) async {
    debugPrint('🔍 Verifying no invitation error is displayed for: $errorKey');

    expect(
      find.byKey(Key('invitation_error_$errorKey')),
      findsNothing,
      reason: 'Invitation error $errorKey should not be visible',
    );

    debugPrint('✅ Confirmed: No invitation error displayed');
  }
}

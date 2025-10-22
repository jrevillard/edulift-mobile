// EduLift Mobile E2E - Profile Timezone Checkbox Toggle Test
// Tests specifically for timezone auto-sync checkbox toggle functionality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

// Import app and test helpers
import 'helpers/test_data_generator.dart';
import 'helpers/mailpit_helper.dart';
import 'helpers/auth_flow_helper.dart';

/// E2E test specifically for checkbox toggle functionality
///
/// Tests that the auto-sync timezone checkbox can be toggled in BOTH directions
/// and that it properly controls the dropdown enable/disable state
void main() {
  group('Profile Timezone Checkbox Toggle Tests', () {
    String? testEmail;

    tearDown(() async {
      // Clean up emails for this specific test after completion
      if (testEmail != null && testEmail!.isNotEmpty) {
        await MailpitHelper.clearEmailsForRecipient(testEmail!);
        debugPrint('🗑️ Cleaned up emails for: $testEmail');
      }
    });

    patrolTest('Timezone checkbox can be toggled in both directions', ($) async {
      // STEP 1: Generate unique test data
      final userProfile = TestDataGenerator.generateUniqueUserProfile(
        prefix: 'checkbox_toggle',
      );
      testEmail = userProfile['email']!;

      debugPrint('🚀 Starting checkbox toggle test');
      debugPrint('   User: ${userProfile['email']}');

      // STEP 2: Complete authentication and onboarding
      await AuthFlowHelper.initializeApp($);
      await AuthFlowHelper.completeNewUserAuthentication($, userProfile);

      await AuthFlowHelper.completeOnboardingFlow($);
      debugPrint('✅ User authenticated and onboarded');

      // STEP 3: Navigate to profile page
      await $.tap(find.byKey(const Key('navigation_profile')));
      await $.pumpAndSettle();

      // STEP 4: Verify timezone components are visible
      debugPrint('🌍 Verifying timezone components...');

      await $.waitUntilVisible(find.byKey(const Key('profile_timezone_card')));
      await $.waitUntilVisible(find.byKey(const Key('current_timezone_display')));
      await $.waitUntilVisible(find.byKey(const Key('timezone_dropdown')));
      await $.waitUntilVisible(find.byKey(const Key('auto_sync_timezone_checkbox')));

      debugPrint('✅ All timezone components are visible');

      // STEP 5: COMPREHENSIVE CHECKBOX TOGGLE TESTS
      debugPrint('🔄 Testing auto-sync checkbox toggle functionality...');

      // Test 1: Verify checkbox starts CHECKED (auto-sync enabled by default)
      final checkboxFinder = find.byKey(const Key('auto_sync_timezone_checkbox'));
      final initialCheckbox = $.tester.widget<CheckboxListTile>(checkboxFinder);

      debugPrint('📊 Initial checkbox state:');
      debugPrint('   enabled: ${initialCheckbox.enabled}');
      debugPrint('   value: ${initialCheckbox.value}');
      debugPrint('   onChanged: ${initialCheckbox.onChanged != null ? "NOT NULL" : "NULL"}');

      expect(initialCheckbox.value, true,
        reason: 'Checkbox should be checked by default (auto-sync enabled)');

      // Test 2: Verify dropdown is DISABLED when checkbox is checked
      final dropdownFinder = find.byKey(const Key('timezone_dropdown'));
      await $.waitUntilVisible(dropdownFinder);

      final initialDropdown = $.tester.widget<DropdownButtonFormField<String>>(dropdownFinder);
      debugPrint('📊 Initial dropdown state:');
      debugPrint('   onChanged: ${initialDropdown.onChanged != null ? "NOT NULL (enabled)" : "NULL (disabled)"}');

      expect(initialDropdown.onChanged, null,
        reason: 'Dropdown should be disabled when auto-sync is enabled');

      // Test 3: CRITICAL - Verify checkbox is ENABLED (not grayed out)
      expect(initialCheckbox.enabled, true,
        reason: 'CRITICAL: Checkbox must be enabled so user can toggle it');
      expect(initialCheckbox.onChanged, isNotNull,
        reason: 'CRITICAL: onChanged callback must exist for checkbox to be interactive');

      debugPrint('✅ Initial state verified: checkbox checked, dropdown disabled, checkbox ENABLED');

      // Test 4: UNCHECK the checkbox (disable auto-sync)
      debugPrint('🔄 Tapping checkbox to UNCHECK (disable auto-sync)...');
      await $.tap(checkboxFinder);
      await $.pumpAndSettle();

      // Test 5: Verify checkbox is now UNCHECKED
      final uncheckedCheckbox = $.tester.widget<CheckboxListTile>(checkboxFinder);
      debugPrint('📊 After unchecking:');
      debugPrint('   enabled: ${uncheckedCheckbox.enabled}');
      debugPrint('   value: ${uncheckedCheckbox.value}');
      debugPrint('   onChanged: ${uncheckedCheckbox.onChanged != null ? "NOT NULL" : "NULL"}');

      expect(uncheckedCheckbox.value, false,
        reason: 'Checkbox should be unchecked after tap');
      expect(uncheckedCheckbox.enabled, true,
        reason: 'Checkbox should remain enabled when unchecked');

      // Test 6: Verify dropdown is now ENABLED
      final enabledDropdown = $.tester.widget<DropdownButtonFormField<String>>(dropdownFinder);
      debugPrint('📊 Dropdown after unchecking:');
      debugPrint('   onChanged: ${enabledDropdown.onChanged != null ? "NOT NULL (enabled)" : "NULL (disabled)"}');

      expect(enabledDropdown.onChanged, isNotNull,
        reason: 'Dropdown should be enabled when auto-sync is disabled');

      debugPrint('✅ Unchecked state verified: checkbox unchecked, dropdown ENABLED');

      // Test 7: CHECK the checkbox again (re-enable auto-sync)
      debugPrint('🔄 Tapping checkbox to CHECK (re-enable auto-sync)...');
      await $.tap(checkboxFinder);
      await $.pumpAndSettle();

      // Test 8: Verify checkbox is CHECKED again
      final recheckedCheckbox = $.tester.widget<CheckboxListTile>(checkboxFinder);
      debugPrint('📊 After re-checking:');
      debugPrint('   enabled: ${recheckedCheckbox.enabled}');
      debugPrint('   value: ${recheckedCheckbox.value}');
      debugPrint('   onChanged: ${recheckedCheckbox.onChanged != null ? "NOT NULL" : "NULL"}');

      expect(recheckedCheckbox.value, true,
        reason: 'Checkbox should be checked after second tap');
      expect(recheckedCheckbox.enabled, true,
        reason: 'CRITICAL: Checkbox should remain enabled when checked');
      expect(recheckedCheckbox.onChanged, isNotNull,
        reason: 'CRITICAL: onChanged must exist even when checked');

      // Test 9: Verify dropdown is DISABLED again
      final disabledAgainDropdown = $.tester.widget<DropdownButtonFormField<String>>(dropdownFinder);
      debugPrint('📊 Dropdown after re-checking:');
      debugPrint('   onChanged: ${disabledAgainDropdown.onChanged != null ? "NOT NULL (enabled)" : "NULL (disabled)"}');

      expect(disabledAgainDropdown.onChanged, null,
        reason: 'Dropdown should be disabled again when auto-sync is re-enabled');

      debugPrint('✅ Re-checked state verified: checkbox checked, dropdown disabled, checkbox still ENABLED');
      debugPrint('🎉 COMPREHENSIVE CHECKBOX TOGGLE TEST PASSED');

      debugPrint('🎉 TIMEZONE CHECKBOX TOGGLE TEST COMPLETED');
    });
  });
}

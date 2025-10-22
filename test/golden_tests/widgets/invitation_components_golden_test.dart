// Phase 4: Invitation Components Golden Tests
// Tests for error states, loading states, and manual code input
// CRITICAL: Uses SimpleWidgetTestHelper.wrapWidget() pattern from AGENTS.md

@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/core/presentation/widgets/invitation/invitation_error_display.dart';
import 'package:edulift/core/presentation/widgets/invitation/invitation_loading_state.dart';
import 'package:edulift/core/presentation/widgets/invitation/invitation_manual_code_input.dart';
import 'package:edulift/core/navigation/navigation_state.dart' as nav;
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';
import '../../support/golden/golden_test_wrapper.dart';
import '../../support/golden/device_configurations.dart';
import '../../support/golden/theme_configurations.dart';

void main() {
  /// Helper function to create common provider overrides
  List<Override> createProviderOverrides() {
    final testUser = User(
      id: 'user-test',
      email: 'test@example.com',
      name: 'Test User',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return [
      currentUserProvider.overrideWith((ref) => testUser),
      nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
    ];
  }
  group('Phase 4: Invitation Components Golden Tests', () {
    group('InvitationErrorDisplay', () {
      testWidgets('InvitationErrorDisplay - Expired Error - Light',
          (tester) async {
        await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: InvitationErrorDisplay(
                  errorKey: 'errorInvitationExpired',
                  contextTitle: 'Family Management',
                ),
              ),
            ),
        testName: 'invitation_error_expired_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: createProviderOverrides(),
      );
      });

      testWidgets('InvitationErrorDisplay - Invalid Code - Dark',
          (tester) async {
        await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: InvitationErrorDisplay(
                  errorKey: 'errorInvitationCodeInvalid',
                  contextTitle: 'Group Management',
                ),
              ),
            ),
        testName: 'invitation_error_invalid_code_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
        providerOverrides: createProviderOverrides(),
      );
      });

      testWidgets('InvitationErrorDisplay - Email Mismatch', (tester) async {
        await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: InvitationErrorDisplay(
                  errorKey: 'errorInvitationEmailMismatch',
                  contextTitle: 'Family Management',
                ),
              ),
            ),
        testName: 'invitation_error_email_mismatch',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: createProviderOverrides(),
      );
      });

      testWidgets('InvitationErrorDisplay - Not Found - Tablet Layout',
          (tester) async {
        await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: InvitationErrorDisplay(
                  errorKey: 'errorInvitationNotFound',
                  contextTitle: 'Group Management',
                  isTablet: true,
                ),
              ),
            ),
        testName: 'invitation_error_not_found_tablet',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: createProviderOverrides(),
      );
      });

      testWidgets('InvitationErrorDisplay - Network Error', (tester) async {
        await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: InvitationErrorDisplay(
                  errorKey: 'errorNetworkGeneral',
                  contextTitle: 'Family Management',
                ),
              ),
            ),
        testName: 'invitation_error_network_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
        providerOverrides: createProviderOverrides(),
      );
      });
    });

    group('InvitationLoadingState', () {
      testWidgets('InvitationLoadingState - Family Type - Light',
          (tester) async {
        await GoldenTestWrapper.testLoadingState(
          tester: tester,
          widget: const Center(
            child: InvitationLoadingState(
              invitationType: InvitationType.family,
            ),
          ),
          testName: 'invitation_loading_family_light',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.light],
          providerOverrides: createProviderOverrides(),
        );
      });

      testWidgets('InvitationLoadingState - Group Type - Dark',
          (tester) async {
        await GoldenTestWrapper.testLoadingState(
          tester: tester,
          widget: const Center(
            child: InvitationLoadingState(
              invitationType: InvitationType.group,
            ),
          ),
          testName: 'invitation_loading_group_dark',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.dark],
          providerOverrides: createProviderOverrides(),
        );
      });

      testWidgets('InvitationLoadingState - Tablet Layout', (tester) async {
        await GoldenTestWrapper.testLoadingState(
          tester: tester,
          widget: const Center(
            child: InvitationLoadingState(
              invitationType: InvitationType.family,
              isTablet: true,
            ),
          ),
          testName: 'invitation_loading_tablet',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.light],
          providerOverrides: createProviderOverrides(),
        );
      });
    });

    group('InvitationManualCodeInput', () {
      testWidgets('InvitationManualCodeInput - Family Type - Empty',
          (tester) async {
        final controller = TextEditingController();

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: InvitationManualCodeInput(
                  invitationType: InvitationType.family,
                  icon: Icons.people,
                  controller: controller,
                  onValidate: () {},
                ),
              ),
            ),
          ),
          testName: 'invitation_manual_input_family_empty',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.light],
          providerOverrides: createProviderOverrides(),
        );
      });

      testWidgets('InvitationManualCodeInput - Group Type - With Code',
          (tester) async {
        final controller = TextEditingController(text: 'ABC123XYZ');

        await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InvitationManualCodeInput(
                    invitationType: InvitationType.group,
                    icon: Icons.group,
                    controller: controller,
                    onValidate: () {},
                  ),
                ),
              ),
            ),
        testName: 'invitation_manual_input_group_with_code_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
        providerOverrides: createProviderOverrides(),
      );
      });

      testWidgets('InvitationManualCodeInput - With Error Message',
          (tester) async {
        final controller = TextEditingController(text: 'INVALID');

        await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InvitationManualCodeInput(
                    invitationType: InvitationType.family,
                    icon: Icons.people,
                    controller: controller,
                    onValidate: () {},
                    errorMessage: 'Code d\'invitation invalide ou expiré',
                  ),
                ),
              ),
            ),
        testName: 'invitation_manual_input_with_error',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: createProviderOverrides(),
      );
      });

      testWidgets('InvitationManualCodeInput - With Cancel Button',
          (tester) async {
        final controller = TextEditingController();

        await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InvitationManualCodeInput(
                    invitationType: InvitationType.group,
                    icon: Icons.group,
                    controller: controller,
                    onValidate: () {},
                    onCancel: () {},
                  ),
                ),
              ),
            ),
        testName: 'invitation_manual_input_with_cancel',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: createProviderOverrides(),
      );
      });

      testWidgets('InvitationManualCodeInput - Tablet Layout',
          (tester) async {
        final controller = TextEditingController();

        await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: InvitationManualCodeInput(
                    invitationType: InvitationType.family,
                    icon: Icons.people,
                    controller: controller,
                    onValidate: () {},
                    isTablet: true,
                  ),
                ),
              ),
            ),
        testName: 'invitation_manual_input_tablet_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
        providerOverrides: createProviderOverrides(),
      );
      });
    });
  });
}

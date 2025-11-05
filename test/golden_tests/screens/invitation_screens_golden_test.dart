// Phase 3 Golden Tests - Invitation Screens
// Tests for InviteMemberPage, InviteFamilyPage, FamilyInvitationPage,
// GroupInvitationPage, and ConfigureFamilyInvitationPage

@Tags(['golden'])
library;

import 'package:edulift/features/family/presentation/pages/family_invitation_page.dart';
import 'package:edulift/features/family/presentation/pages/invite_member_page.dart';
import 'package:edulift/features/groups/presentation/pages/configure_family_invitation_page.dart';
import 'package:edulift/features/groups/presentation/pages/group_invitation_page.dart';
import 'package:edulift/features/groups/presentation/pages/invite_family_page.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/core/navigation/navigation_state.dart' as nav;

import '../../support/golden/golden_test_wrapper.dart';
import '../../support/factories/test_data_factory.dart';
import '../../support/network_mocking.dart';

void main() {
  setUp(() {
    TestDataFactory.resetSeed();
  });

  group('InviteMemberPage Golden Tests', () {
    testWidgets('invite member page - light theme', (tester) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const InviteMemberPage(),
        testName: 'invite_member_page_light',
        providerOverrides: overrides,
      );
    });

    testWidgets('invite member page - dark theme', (tester) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const InviteMemberPage(),
        testName: 'invite_member_page_dark',
        providerOverrides: overrides,
      );
    });
  });

  group('InviteFamilyPage Golden Tests', () {
    testWidgets('invite family page - light theme', (tester) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const InviteFamilyPage(groupId: 'test-group-1'),
        testName: 'invite_family_page_light',
        providerOverrides: overrides,
      );
    });

    testWidgets('invite family page - dark theme', (tester) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const InviteFamilyPage(groupId: 'test-group-2'),
        testName: 'invite_family_page_dark',
        providerOverrides: overrides,
      );
    });
  });

  group('FamilyInvitationPage Golden Tests', () {
    testWidgets('family invitation page without code - light theme', (
      tester,
    ) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const FamilyInvitationPage(),
        testName: 'family_invitation_page_no_code_light',
        providerOverrides: overrides,
      );
    });

    testWidgets('family invitation page without code - dark theme', (
      tester,
    ) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const FamilyInvitationPage(),
        testName: 'family_invitation_page_no_code_dark',
        providerOverrides: overrides,
      );
    });

    testWidgets('family invitation page with code - light theme', (
      tester,
    ) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const FamilyInvitationPage(inviteCode: 'FAMILY123ABC'),
        testName: 'family_invitation_page_with_code_light',
        providerOverrides: overrides,
      );
    });

    testWidgets('family invitation page with code - dark theme', (
      tester,
    ) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const FamilyInvitationPage(inviteCode: 'FAMILY456DEF'),
        testName: 'family_invitation_page_with_code_dark',
        providerOverrides: overrides,
      );
    });
  });

  group('GroupInvitationPage Golden Tests', () {
    testWidgets('group invitation page without code - light theme', (
      tester,
    ) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const GroupInvitationPage(),
        testName: 'group_invitation_page_no_code_light',
        providerOverrides: overrides,
      );
    });

    testWidgets('group invitation page without code - dark theme', (
      tester,
    ) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const GroupInvitationPage(),
        testName: 'group_invitation_page_no_code_dark',
        providerOverrides: overrides,
      );
    });

    testWidgets('group invitation page with code - light theme', (
      tester,
    ) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const GroupInvitationPage(inviteCode: 'GROUP789GHI'),
        testName: 'group_invitation_page_with_code_light',
        providerOverrides: overrides,
      );
    });

    testWidgets('group invitation page with code - dark theme', (tester) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const GroupInvitationPage(inviteCode: 'GROUP012JKL'),
        testName: 'group_invitation_page_with_code_dark',
        providerOverrides: overrides,
      );
    });
  });

  group('ConfigureFamilyInvitationPage Golden Tests', () {
    testWidgets('configure family invitation page - light theme', (
      tester,
    ) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const ConfigureFamilyInvitationPage(
          groupId: 'test-group-1',
          familyId: 'test-family-1',
          familyName: 'Famille Dubois',
          memberCount: 4,
        ),
        testName: 'configure_family_invitation_page_light',
        providerOverrides: overrides,
      );
    });

    testWidgets('configure family invitation page - dark theme', (
      tester,
    ) async {
      final overrides = [
        nav.navigationStateProvider.overrideWith(
          (ref) => nav.NavigationStateNotifier(),
        ),

        // CRITICAL: Prevent all real network calls during golden tests
        ...getAllNetworkMockOverrides(),
      ];

      await GoldenTestWrapper.testScreen(
        tester: tester,
        screen: const ConfigureFamilyInvitationPage(
          groupId: 'test-group-2',
          familyId: 'test-family-2',
          familyName: 'Famille García-Martínez',
          memberCount: 5,
        ),
        testName: 'configure_family_invitation_page_dark',
        providerOverrides: overrides,
      );
    });

    testWidgets(
      'configure family invitation page with international name - light theme',
      (tester) async {
        final overrides = [
          nav.navigationStateProvider.overrideWith(
            (ref) => nav.NavigationStateNotifier(),
          ),

          // CRITICAL: Prevent all real network calls during golden tests
          ...getAllNetworkMockOverrides(),
        ];

        await GoldenTestWrapper.testScreen(
          tester: tester,
          screen: const ConfigureFamilyInvitationPage(
            groupId: 'test-group-intl',
            familyId: 'test-family-intl',
            familyName: 'Famille Müller-Øvergård',
            memberCount: 3,
          ),
          testName: 'configure_family_invitation_page_intl_light',
          providerOverrides: overrides,
        );
      },
    );
  });
}

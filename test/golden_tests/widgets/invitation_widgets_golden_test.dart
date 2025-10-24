// Phase 3 Golden Tests - Invitation Widgets
// Tests for InviteMemberWidget and FamilyInvitationManagementWidget

@Tags(['golden'])
library;

import 'package:edulift/features/family/presentation/widgets/invitation_management_widget.dart';
import 'package:edulift/features/family/presentation/widgets/invite_member_widget.dart';
import 'package:edulift/features/family/providers.dart';
import 'package:edulift/core/domain/entities/family.dart' as family_entities;
import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/core/navigation/navigation_state.dart' as nav;
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import '../../support/golden/golden_test_wrapper.dart';
import '../../support/golden/device_configurations.dart';
import '../../support/golden/theme_configurations.dart';
import '../../support/factories/test_data_factory.dart';
import '../../test_mocks/generated_mocks.mocks.dart';
import '../../support/network_mocking.dart';

void main() {
  setUp(() {
    TestDataFactory.resetSeed();
  });

  /// Helper function to create common provider overrides
  /// Override familyProvider to prevent Hive initialization
  List<Override> createProviderOverrides() {
    final testUser = User(
      id: 'user-test',
      email: 'test@example.com',
      name: 'Test User',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Create mocked repositories with stubbed methods
    final mockFamilyRepo = MockFamilyRepository();
    final mockInvitationRepo = MockInvitationRepository();

    // Provide dummy values for Result types that Mockito can't auto-generate
    provideDummy<Result<family_entities.Family?, ApiFailure>>(const Result.err(ApiFailure(message: 'dummy')));
    provideDummy<Result<List<FamilyInvitation>, ApiFailure>>(const Result.ok([]));

    // Stub the methods that FamilyNotifier.loadFamily() will call
    // Return error to prevent loading (simpler than creating full Family entity)
    when(mockFamilyRepo.getFamily()).thenAnswer((_) async =>
      const Result.err(ApiFailure(message: 'No family')));
    when(mockInvitationRepo.getPendingInvitations(familyId: anyNamed('familyId')))
        .thenAnswer((_) async => const Result.ok([]));

    return [
      currentUserProvider.overrideWith((ref) => testUser),
      // Override repository providers to prevent Hive access
      familyRepositoryComposedProvider.overrideWithValue(mockFamilyRepo),
      invitationRepositoryComposedProvider.overrideWithValue(mockInvitationRepo),
      nav.navigationStateProvider.overrideWith((ref) => nav.NavigationStateNotifier()),
      // CRITICAL: Prevent all real network calls during golden tests
      ...getAllNetworkMockOverrides(),
    ];
  }

  group('InviteMemberWidget Golden Tests', () {
    testWidgets('invite member widget - light theme', (tester) async {
      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: const InviteMemberWidget(),
        testName: 'invite_member_widget_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: createProviderOverrides(),
      );
    });

    testWidgets('invite member widget - dark theme', (tester) async {
      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: const InviteMemberWidget(),
        testName: 'invite_member_widget_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
        providerOverrides: createProviderOverrides(),
      );
    });

    testWidgets('invite member widget with callback - light theme',
        (tester) async {
      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: InviteMemberWidget(
          onInvitationSent: () {},
        ),
        testName: 'invite_member_widget_with_callback_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: createProviderOverrides(),
      );
    });
  });

  group('FamilyInvitationManagementWidget Golden Tests', () {
    testWidgets('invitation management widget as admin - light theme',
        (tester) async {
      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: const FamilyInvitationManagementWidget(
          isAdmin: true,
          familyId: 'test-family-1',
        ),
        testName: 'invitation_management_widget_admin_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: createProviderOverrides(),
      );
    });

    testWidgets('invitation management widget as admin - dark theme',
        (tester) async {
      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: const FamilyInvitationManagementWidget(
          isAdmin: true,
          familyId: 'test-family-2',
        ),
        testName: 'invitation_management_widget_admin_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
        providerOverrides: createProviderOverrides(),
      );
    });

    testWidgets('invitation management widget as member - light theme',
        (tester) async {
      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: const FamilyInvitationManagementWidget(
          isAdmin: false,
          familyId: 'test-family-3',
        ),
        testName: 'invitation_management_widget_member_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
        providerOverrides: createProviderOverrides(),
      );
    });

    testWidgets('invitation management widget as member - dark theme',
        (tester) async {
      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: const FamilyInvitationManagementWidget(
          isAdmin: false,
          familyId: 'test-family-4',
        ),
        testName: 'invitation_management_widget_member_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
        providerOverrides: createProviderOverrides(),
      );
    });
  });
}

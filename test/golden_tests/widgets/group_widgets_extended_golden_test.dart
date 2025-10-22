// EduLift - Group Widgets Extended Golden Tests
// Phase 2: Additional group widgets not covered in main test file

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/features/groups/presentation/widgets/promote_to_admin_confirmation_dialog.dart';
import 'package:edulift/features/groups/presentation/widgets/demote_to_member_confirmation_dialog.dart';
import 'package:edulift/features/groups/presentation/widgets/remove_family_confirmation_dialog.dart';
import 'package:edulift/features/groups/presentation/widgets/cancel_invitation_confirmation_dialog.dart';
import 'package:edulift/features/groups/presentation/widgets/leave_group_confirmation_dialog.dart';
import 'package:edulift/features/groups/presentation/widgets/family_action_bottom_sheet.dart';
import 'package:edulift/features/groups/presentation/widgets/weekday_selector.dart';
import 'package:edulift/core/domain/entities/groups/group_family.dart';
import 'package:edulift/core/domain/entities/groups/group.dart';

import '../../support/golden/golden_test_wrapper.dart';
import '../../support/golden/device_configurations.dart';
import '../../support/golden/theme_configurations.dart';
import '../../support/factories/group_data_factory.dart';
import '../../support/factories/test_data_factory.dart';

@Tags(['golden'])
void main() {
  setUpAll(() {
    GroupDataFactory.resetCounters();
    TestDataFactory.resetSeed();
  });

  group('PromoteToAdminConfirmationDialog - Golden Tests', () {
    testWidgets('PromoteToAdminConfirmationDialog - light theme', (tester) async {
      final family = GroupDataFactory.createRealisticGroupFamily(
        role: GroupFamilyRole.member,
      );

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: PromoteToAdminConfirmationDialog(
            family: family,
            groupId: 'test-group-id',
            onSuccess: () {},
          ),
        testName: 'promote_admin_dialog_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('PromoteToAdminConfirmationDialog - dark theme', (tester) async {
      final family = GroupDataFactory.createGroupFamilyWithLongName();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: PromoteToAdminConfirmationDialog(
            family: family,
            groupId: 'test-group-id',
            onSuccess: () {},
          ),
        testName: 'promote_admin_dialog_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
      );
    });
  });

  group('DemoteToMemberConfirmationDialog - Golden Tests', () {
    testWidgets('DemoteToMemberConfirmationDialog - light theme', (tester) async {
      final family = GroupDataFactory.createRealisticGroupFamily(
        role: GroupFamilyRole.admin,
      );

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: DemoteToMemberConfirmationDialog(
            family: family,
            groupId: 'test-group-id',
            onSuccess: () {},
          ),
        testName: 'demote_member_dialog_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('DemoteToMemberConfirmationDialog - dark theme', (tester) async {
      final family = GroupDataFactory.createRealisticGroupFamily(
        role: GroupFamilyRole.admin,
      );

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: DemoteToMemberConfirmationDialog(
            family: family,
            groupId: 'test-group-id',
            onSuccess: () {},
          ),
        testName: 'demote_member_dialog_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
      );
    });
  });

  group('RemoveFamilyConfirmationDialog - Golden Tests', () {
    testWidgets('RemoveFamilyConfirmationDialog - light theme', (tester) async {
      final family = GroupDataFactory.createRealisticGroupFamily();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: RemoveFamilyConfirmationDialog(
            family: family,
            groupId: 'test-group-id',
            onSuccess: () {},
          ),
        testName: 'remove_family_dialog_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('RemoveFamilyConfirmationDialog - dark theme', (tester) async {
      final family = GroupDataFactory.createGroupFamilyWithLongName();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: RemoveFamilyConfirmationDialog(
            family: family,
            groupId: 'test-group-id',
            onSuccess: () {},
          ),
        testName: 'remove_family_dialog_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
      );
    });
  });

  group('CancelInvitationConfirmationDialog - Golden Tests', () {
    testWidgets('CancelInvitationConfirmationDialog - light theme', (tester) async {
      final family = GroupDataFactory.createPendingGroupFamily();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: CancelInvitationConfirmationDialog(
            family: family,
            groupId: 'test-group-id',
            onSuccess: () {},
          ),
        testName: 'cancel_invitation_dialog_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('CancelInvitationConfirmationDialog - dark theme', (tester) async {
      final family = GroupDataFactory.createPendingGroupFamily();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: CancelInvitationConfirmationDialog(
            family: family,
            groupId: 'test-group-id',
            onSuccess: () {},
          ),
        testName: 'cancel_invitation_dialog_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
      );
    });
  });

  group('LeaveGroupConfirmationDialog - Golden Tests', () {
    testWidgets('LeaveGroupConfirmationDialog - light theme', (tester) async {
      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: const LeaveGroupConfirmationDialog(
            groupId: 'test-group-id',
            groupName: 'Covoiturage École Primaire',
            userRole: GroupMemberRole.member,
          ),
        testName: 'leave_group_dialog_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('LeaveGroupConfirmationDialog - dark theme', (tester) async {
      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: const LeaveGroupConfirmationDialog(
            groupId: 'test-group-id',
            groupName: 'Covoiturage École Müller-O\'Brien & Søren',
            userRole: GroupMemberRole.admin,
          ),
        testName: 'leave_group_dialog_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
      );
    });
  });

  group('FamilyActionBottomSheet - Golden Tests', () {
    testWidgets('FamilyActionBottomSheet - member family - light theme', (tester) async {
      final family = GroupDataFactory.createRealisticGroupFamily(
        role: GroupFamilyRole.member,
      );

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: FamilyActionBottomSheet(
            family: family,
            onPromoteToAdmin: () {},
            onRemoveFamily: () {},
          ),
        testName: 'family_action_sheet_member_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('FamilyActionBottomSheet - admin family - dark theme', (tester) async {
      final family = GroupDataFactory.createRealisticGroupFamily(
        role: GroupFamilyRole.admin,
      );

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: FamilyActionBottomSheet(
            family: family,
            onDemoteToMember: () {},
            onRemoveFamily: () {},
          ),
        testName: 'family_action_sheet_admin_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
      );
    });

    testWidgets('FamilyActionBottomSheet - pending invitation - light theme', (tester) async {
      final family = GroupDataFactory.createPendingGroupFamily();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: FamilyActionBottomSheet(
            family: family,
            onCancelInvitation: () {},
          ),
        testName: 'family_action_sheet_pending_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
      );
    });
  });

  group('WeekdaySelector - Golden Tests', () {
    testWidgets('WeekdaySelector - weekdays selected - light theme', (tester) async {
      final selectedDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: WeekdaySelector(
            selectedDays: selectedDays,
            onSelectionChanged: (days) {},
          ),
        testName: 'weekday_selector_weekdays_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('WeekdaySelector - all days selected - dark theme', (tester) async {
      final selectedDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: WeekdaySelector(
            selectedDays: selectedDays,
            onSelectionChanged: (days) {},
          ),
        testName: 'weekday_selector_all_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
      );
    });

    testWidgets('WeekdaySelector - partial selection - light theme', (tester) async {
      final selectedDays = ['Monday', 'Wednesday', 'Friday'];

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: WeekdaySelector(
            selectedDays: selectedDays,
            onSelectionChanged: (days) {},
          ),
        testName: 'weekday_selector_partial_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
      );
    });
  });

  group('Group Widgets - Large Lists Volume Testing', () {
    testWidgets('Group families list - 20+ items for scroll validation - light theme', (tester) async {
      final families = GroupDataFactory.createLargeGroupFamilyList(count: 22);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: SizedBox(
            height: 600,
            child: ListView.builder(
              itemCount: families.length,
              itemBuilder: (context, index) {
                final family = families[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(family.name.substring(0, 1).toUpperCase()),
                    ),
                    title: Text(family.name),
                    subtitle: Text(family.role.displayName),
                    trailing: family.isPending
                        ? const Chip(
                            label: Text('Pending'),
                            backgroundColor: Colors.orange,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        testName: 'group_families_list_large_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('Group families list - 20+ items with mixed states - dark theme', (tester) async {
      final families = GroupDataFactory.createLargeGroupFamilyList(count: 24);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: SizedBox(
            height: 600,
            child: ListView.builder(
              itemCount: families.length,
              itemBuilder: (context, index) {
                final family = families[index];
                return ListTile(
                  leading: Icon(
                    family.isPending ? Icons.hourglass_empty : Icons.family_restroom,
                    color: family.isPending ? Colors.orange : Colors.blue,
                  ),
                  title: Text(family.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(family.role.displayName),
                      if (family.admins.isNotEmpty)
                        Text(
                          'Admins: ${family.admins.map((a) => a.name).join(", ")}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: family.canManage
                      ? const Icon(Icons.settings)
                      : null,
                );
              },
            ),
          ),
        testName: 'group_families_list_mixed_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
      );
    });
  });
}

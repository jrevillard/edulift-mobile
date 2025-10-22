// EduLift - Group Widgets Golden Tests
// Comprehensive visual regression tests for group-related widgets

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/core/domain/entities/groups/group.dart';
import 'package:edulift/features/groups/presentation/widgets/group_card.dart';

import '../../support/golden/golden_test_wrapper.dart';
import '../../support/golden/device_configurations.dart';
import '../../support/golden/theme_configurations.dart';
import '../../support/factories/group_data_factory.dart';
import '../../support/factories/test_data_factory.dart';

void main() {
  // Reset factories before tests
  setUpAll(() {
    GroupDataFactory.resetCounters();
    TestDataFactory.resetSeed();
  });

  group('Group Widgets - Golden Tests', () {
    testWidgets('GroupCard - realistic group', (tester) async {
      final group = GroupDataFactory.createRealisticGroup(index: 0);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: GroupCard(
          group: group,
          onSelect: () {},
          onManage: () {},
        ),
        testName: 'group_card_realistic',
        devices: DeviceConfigurations.defaultSet,
        themes: ThemeConfigurations.basic,
      );
    });

    testWidgets('GroupCard - owner role', (tester) async {
      final ownerGroup = GroupDataFactory.createRealisticGroup(index: 1).copyWith(
        userRole: GroupMemberRole.owner,
      );

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: GroupCard(
          group: ownerGroup,
          onSelect: () {},
          onManage: () {},
        ),
        testName: 'group_card_owner',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('GroupCard - long name edge case', (tester) async {
      final longNameGroup = GroupDataFactory.createGroupWithLongName();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: GroupCard(
          group: longNameGroup,
          onSelect: () {},
          onManage: () {},
        ),
        testName: 'group_card_long_name',
        devices: [DeviceConfigurations.iphoneSE],
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('GroupCard - special characters', (tester) async {
      final specialCharsGroup = GroupDataFactory.createGroupWithSpecialChars();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: GroupCard(
          group: specialCharsGroup,
          onSelect: () {},
          onManage: () {},
        ),
        testName: 'group_card_special_chars',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('GroupCard - at capacity', (tester) async {
      final fullGroup = GroupDataFactory.createGroupAtCapacity();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: GroupCard(
          group: fullGroup,
          onSelect: () {},
          onManage: () {},
        ),
        testName: 'group_card_at_capacity',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('GroupCard - paused status', (tester) async {
      final pausedGroup = GroupDataFactory.createPausedGroup();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: GroupCard(
          group: pausedGroup,
          onSelect: () {},
          onManage: () {},
        ),
        testName: 'group_card_paused',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('GroupCard - dark theme', (tester) async {
      final group = GroupDataFactory.createRealisticGroup(index: 2);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: GroupCard(
          group: group,
          onSelect: () {},
          onManage: () {},
        ),
        testName: 'group_card_dark',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.dark],
      );
    });

    testWidgets('GroupCard - high contrast theme', (tester) async {
      final group = GroupDataFactory.createRealisticGroup(index: 3);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: GroupCard(
          group: group,
          onSelect: () {},
          onManage: () {},
        ),
        testName: 'group_card_high_contrast',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.highContrastLight],
      );
    });

    testWidgets('GroupCard - large font accessibility', (tester) async {
      final group = GroupDataFactory.createRealisticGroup(index: 4);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: GroupCard(
          group: group,
          onSelect: () {},
          onManage: () {},
        ),
        testName: 'group_card_large_font',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.lightLargeFont],
      );
    });

    testWidgets('GroupCard - tablet device', (tester) async {
      final group = GroupDataFactory.createRealisticGroup(index: 5);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: GroupCard(
          group: group,
          onSelect: () {},
          onManage: () {},
        ),
        testName: 'group_card_tablet',
        devices: [DeviceConfigurations.iPadPro],
        themes: [ThemeConfigurations.light],
      );
    });
  });

  group('Group - Multiple States', () {
    testWidgets('GroupCard - all group statuses', (tester) async {
      await GoldenTestWrapper.testStates(
        tester: tester,
        states: {
          'active': GroupCard(
            group: GroupDataFactory.createRealisticGroup(status: GroupStatus.active),
            onSelect: () {},
            onManage: () {},
          ),
          'paused': GroupCard(
            group: GroupDataFactory.createPausedGroup(),
            onSelect: () {},
            onManage: () {},
          ),
          'archived': GroupCard(
            group: GroupDataFactory.createArchivedGroup(),
            onSelect: () {},
            onManage: () {},
          ),
          'draft': GroupCard(
            group: GroupDataFactory.createDraftGroup(),
            onSelect: () {},
            onManage: () {},
          ),
        },
        baseTestName: 'group_card_states',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.light],
      );
    });
  });

  group('Group - Volume Testing', () {
    testWidgets('Group list with volumetric data', (tester) async {
      final groups = GroupDataFactory.createLargeGroupList();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return GroupCard(
              group: group,
              onSelect: () {},
              onManage: () {},
            );
          },
        ),
        testName: 'group_list_volumetric',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('Group families list volumetric', (tester) async {
      final families = GroupDataFactory.createLargeGroupFamilyList();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: ListView.builder(
          itemCount: families.length,
          itemBuilder: (context, index) {
            final family = families[index];
            return ListTile(
              title: Text(family.name),
              subtitle: Text(family.role.displayName),
              trailing: family.isPending
                  ? const Chip(label: Text('Pending'))
                  : null,
            );
          },
        ),
        testName: 'group_families_volumetric',
        devices: [DeviceConfigurations.iphone13],
        themes: [ThemeConfigurations.light],
      );
    });
  });
}

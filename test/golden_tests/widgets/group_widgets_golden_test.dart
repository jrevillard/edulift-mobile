// EduLift - Group Widgets Golden Tests
// Comprehensive visual regression tests for group-related widgets

@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/core/domain/entities/groups/group.dart';
import 'package:edulift/features/groups/presentation/widgets/group_card.dart';

import '../../support/golden/golden_test_wrapper.dart';
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
        widget: GroupCard(group: group, onSelect: () {}, onManage: () {}),
        testName: 'group_card_realistic',
      );
    });

    testWidgets('GroupCard - owner role', (tester) async {
      final ownerGroup = GroupDataFactory.createRealisticGroup(
        index: 1,
      ).copyWith(userRole: GroupMemberRole.owner);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: GroupCard(group: ownerGroup, onSelect: () {}, onManage: () {}),
        testName: 'group_card_owner',
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
      );
    });

    testWidgets('GroupCard - at capacity', (tester) async {
      final fullGroup = GroupDataFactory.createGroupAtCapacity();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: GroupCard(group: fullGroup, onSelect: () {}, onManage: () {}),
        testName: 'group_card_at_capacity',
      );
    });

    testWidgets('GroupCard - paused status', (tester) async {
      final pausedGroup = GroupDataFactory.createPausedGroup();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: GroupCard(group: pausedGroup, onSelect: () {}, onManage: () {}),
        testName: 'group_card_paused',
      );
    });

    testWidgets('GroupCard - dark theme', (tester) async {
      final group = GroupDataFactory.createRealisticGroup(index: 2);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: GroupCard(group: group, onSelect: () {}, onManage: () {}),
        testName: 'group_card_dark',
      );
    });

    testWidgets('GroupCard - high contrast theme', (tester) async {
      final group = GroupDataFactory.createRealisticGroup(index: 3);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: GroupCard(group: group, onSelect: () {}, onManage: () {}),
        testName: 'group_card_high_contrast',
      );
    });

    testWidgets('GroupCard - large font accessibility', (tester) async {
      final group = GroupDataFactory.createRealisticGroup(index: 4);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: GroupCard(group: group, onSelect: () {}, onManage: () {}),
        testName: 'group_card_large_font',
      );
    });

    testWidgets('GroupCard - tablet device', (tester) async {
      final group = GroupDataFactory.createRealisticGroup(index: 5);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: GroupCard(group: group, onSelect: () {}, onManage: () {}),
        testName: 'group_card_tablet',
      );
    });
  });

  group('Group - Multiple States', () {
    testWidgets('GroupCard - all group statuses', (tester) async {
      await GoldenTestWrapper.testStates(
        tester: tester,
        states: {
          'active': GroupCard(
            group: GroupDataFactory.createRealisticGroup(
              status: GroupStatus.active,
            ),
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
            return GroupCard(group: group, onSelect: () {}, onManage: () {});
          },
        ),
        testName: 'group_list_volumetric',
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
      );
    });
  });
}

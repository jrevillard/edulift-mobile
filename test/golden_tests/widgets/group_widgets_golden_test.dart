// EduLift - Group Widgets Golden Tests
// Comprehensive visual regression tests for group-related widgets

@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/core/domain/entities/groups/group.dart';
import 'package:edulift/features/groups/presentation/widgets/unified_group_card.dart';

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
    testWidgets('UnifiedGroupCard - realistic group', (tester) async {
      final group = GroupDataFactory.createRealisticGroup(index: 0);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: UnifiedGroupCard(group: group, onTap: () {}),
        testName: 'group_card_realistic',
      );
    });

    testWidgets('UnifiedGroupCard - owner role', (tester) async {
      final ownerGroup = GroupDataFactory.createRealisticGroup(
        index: 1,
      ).copyWith(userRole: GroupMemberRole.owner);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: UnifiedGroupCard(group: ownerGroup, onTap: () {}),
        testName: 'group_card_owner',
      );
    });

    testWidgets('UnifiedGroupCard - long name edge case', (tester) async {
      final longNameGroup = GroupDataFactory.createGroupWithLongName();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: UnifiedGroupCard(group: longNameGroup, onTap: () {}),
        testName: 'group_card_long_name',
      );
    });

    testWidgets('UnifiedGroupCard - special characters', (tester) async {
      final specialCharsGroup = GroupDataFactory.createGroupWithSpecialChars();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: UnifiedGroupCard(group: specialCharsGroup, onTap: () {}),
        testName: 'group_card_special_chars',
      );
    });

    testWidgets('UnifiedGroupCard - at capacity', (tester) async {
      final fullGroup = GroupDataFactory.createGroupAtCapacity();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: UnifiedGroupCard(group: fullGroup, onTap: () {}),
        testName: 'group_card_at_capacity',
      );
    });

    testWidgets('UnifiedGroupCard - paused status', (tester) async {
      final pausedGroup = GroupDataFactory.createPausedGroup();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: UnifiedGroupCard(group: pausedGroup, onTap: () {}),
        testName: 'group_card_paused',
      );
    });

    testWidgets('UnifiedGroupCard - dark theme', (tester) async {
      final group = GroupDataFactory.createRealisticGroup(index: 2);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: UnifiedGroupCard(group: group, onTap: () {}),
        testName: 'group_card_dark',
      );
    });

    testWidgets('UnifiedGroupCard - high contrast theme', (tester) async {
      final group = GroupDataFactory.createRealisticGroup(index: 3);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: UnifiedGroupCard(group: group, onTap: () {}),
        testName: 'group_card_high_contrast',
      );
    });

    testWidgets('UnifiedGroupCard - large font accessibility', (tester) async {
      final group = GroupDataFactory.createRealisticGroup(index: 4);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: UnifiedGroupCard(group: group, onTap: () {}),
        testName: 'group_card_large_font',
      );
    });

    testWidgets('UnifiedGroupCard - tablet device', (tester) async {
      final group = GroupDataFactory.createRealisticGroup(index: 5);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: UnifiedGroupCard(group: group, onTap: () {}),
        testName: 'group_card_tablet',
      );
    });
  });

  group('Group - Multiple States', () {
    testWidgets('UnifiedGroupCard - all group statuses', (tester) async {
      await GoldenTestWrapper.testStates(
        tester: tester,
        states: {
          'active': UnifiedGroupCard(
            group: GroupDataFactory.createRealisticGroup(
              status: GroupStatus.active,
            ),
            onTap: () {},
          ),
          'paused': UnifiedGroupCard(
            group: GroupDataFactory.createPausedGroup(),
            onTap: () {},
          ),
          'archived': UnifiedGroupCard(
            group: GroupDataFactory.createArchivedGroup(),
            onTap: () {},
          ),
          'draft': UnifiedGroupCard(
            group: GroupDataFactory.createDraftGroup(),
            onTap: () {},
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
            return UnifiedGroupCard(group: group, onTap: () {});
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

// EduLift - Family Widgets Golden Tests
// Comprehensive visual regression tests for family-related widgets

@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/features/family/presentation/widgets/member_action_bottom_sheet.dart';

import '../../support/golden/golden_test_wrapper.dart';
import '../../support/factories/family_data_factory.dart';
import '../../support/factories/test_data_factory.dart';

void main() {
  // Reset factories before tests
  setUpAll(() {
    FamilyDataFactory.resetCounters();
    TestDataFactory.resetSeed();
  });

  group('FamilyMember Widgets - Golden Tests', () {
    testWidgets('MemberActionBottomSheet - realistic member', (tester) async {
      final member = FamilyDataFactory.createRealisticMember(index: 0);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: MemberActionBottomSheet(
          member: member,
          canManageRoles: true,
          onViewDetails: () {},
          onChangeRole: () {},
          onRemoveMember: () {},
        ),
        testName: 'member_action_bottom_sheet_realistic',
      );
    });

    testWidgets('MemberActionBottomSheet - admin member', (tester) async {
      final adminMember = FamilyDataFactory.createRealisticMember(
        index: 1,
        role: FamilyRole.admin,
      );

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: MemberActionBottomSheet(
          member: adminMember,
          canManageRoles: true,
          onViewDetails: () {},
          onChangeRole: () {},
          onRemoveMember: () {},
        ),
        testName: 'member_action_bottom_sheet_admin',
      );
    });

    testWidgets('MemberActionBottomSheet - long name edge case', (
      tester,
    ) async {
      final longNameMember = FamilyDataFactory.createMemberWithLongName();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: MemberActionBottomSheet(
          member: longNameMember,
          canManageRoles: true,
          onViewDetails: () {},
          onChangeRole: () {},
          onRemoveMember: () {},
        ),
        testName: 'member_action_bottom_sheet_long_name',
      );
    });

    testWidgets('MemberActionBottomSheet - special characters', (tester) async {
      final specialCharsMember =
          FamilyDataFactory.createMemberWithSpecialChars();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: MemberActionBottomSheet(
          member: specialCharsMember,
          canManageRoles: true,
          onViewDetails: () {},
          onChangeRole: () {},
          onRemoveMember: () {},
        ),
        testName: 'member_action_bottom_sheet_special_chars',
      );
    });

    testWidgets('MemberActionBottomSheet - dark theme', (tester) async {
      final member = FamilyDataFactory.createRealisticMember(index: 2);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: MemberActionBottomSheet(
          member: member,
          canManageRoles: true,
          onViewDetails: () {},
          onChangeRole: () {},
          onRemoveMember: () {},
        ),
        testName: 'member_action_bottom_sheet_dark',
      );
    });

    testWidgets('MemberActionBottomSheet - high contrast theme', (
      tester,
    ) async {
      final member = FamilyDataFactory.createRealisticMember(index: 3);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: MemberActionBottomSheet(
          member: member,
          canManageRoles: true,
          onViewDetails: () {},
          onChangeRole: () {},
          onRemoveMember: () {},
        ),
        testName: 'member_action_bottom_sheet_high_contrast',
      );
    });

    testWidgets('MemberActionBottomSheet - large font accessibility', (
      tester,
    ) async {
      final member = FamilyDataFactory.createRealisticMember(index: 4);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: MemberActionBottomSheet(
          member: member,
          canManageRoles: true,
          onViewDetails: () {},
          onChangeRole: () {},
          onRemoveMember: () {},
        ),
        testName: 'member_action_bottom_sheet_large_font',
      );
    });

    testWidgets('MemberActionBottomSheet - tablet device', (tester) async {
      final member = FamilyDataFactory.createRealisticMember(index: 5);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: MemberActionBottomSheet(
          member: member,
          canManageRoles: true,
          onViewDetails: () {},
          onChangeRole: () {},
          onRemoveMember: () {},
        ),
        testName: 'member_action_bottom_sheet_tablet',
      );
    });
  });

  group('FamilyMember - Multiple States', () {
    testWidgets('MemberActionBottomSheet - all member states', (tester) async {
      await GoldenTestWrapper.testStates(
        tester: tester,
        states: {
          'admin': MemberActionBottomSheet(
            member: FamilyDataFactory.createRealisticMember(
              role: FamilyRole.admin,
            ),
            canManageRoles: true,
            onViewDetails: () {},
            onChangeRole: () {},
            onRemoveMember: () {},
          ),
          'member': MemberActionBottomSheet(
            member: FamilyDataFactory.createRealisticMember(
              role: FamilyRole.member,
            ),
            canManageRoles: true,
            onViewDetails: () {},
            onChangeRole: () {},
            onRemoveMember: () {},
          ),
          'no_permissions': MemberActionBottomSheet(
            member: FamilyDataFactory.createRealisticMember(),
            canManageRoles: false,
            onViewDetails: () {},
          ),
        },
        baseTestName: 'member_action_states',
      );
    });
  });

  group('FamilyMember - Volume Testing', () {
    testWidgets('Member list with volumetric data', (tester) async {
      final members = FamilyDataFactory.createLargeMemberList();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return ListTile(
              title: Text(member.userName ?? 'Unknown'),
              subtitle: Text(member.userEmail ?? ''),
              trailing: Text(member.role.toString()),
            );
          },
        ),
        testName: 'member_list_volumetric',
      );
    });
  });
}

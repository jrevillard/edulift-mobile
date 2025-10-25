// EduLift - Family Widgets Extended Golden Tests
// Phase 2: Additional family widgets not covered in main test file

@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/features/family/presentation/widgets/role_change_confirmation_dialog.dart';
import 'package:edulift/features/family/presentation/widgets/remove_member_confirmation_dialog.dart';
import 'package:edulift/features/family/presentation/widgets/leave_family_confirmation_dialog.dart';
import 'package:edulift/features/family/presentation/widgets/vehicle_capacity_indicator.dart';
import 'package:edulift/features/family/presentation/widgets/conflict_indicator.dart';
import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

import '../../support/golden/golden_test_wrapper.dart';
import '../../support/golden/device_configurations.dart';
import '../../support/golden/theme_configurations.dart';
import '../../support/factories/family_data_factory.dart';
import '../../support/factories/test_data_factory.dart';

void main() {
  setUpAll(() {
    FamilyDataFactory.resetCounters();
    TestDataFactory.resetSeed();
  });

  group('RoleChangeConfirmationDialog - Golden Tests', () {
    testWidgets(
      'RoleChangeConfirmationDialog - promote to admin - light theme',
      (tester) async {
        final member = FamilyDataFactory.createRealisticMember(
          role: FamilyRole.member,
        );

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: RoleChangeConfirmationDialog(
            member: member,
            onSuccess: () {},
          ),
          testName: 'role_change_dialog_promote_light',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.light],
        );
      },
    );

    testWidgets(
      'RoleChangeConfirmationDialog - demote to member - dark theme',
      (tester) async {
        final admin = FamilyDataFactory.createRealisticMember(
          role: FamilyRole.admin,
        );

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: RoleChangeConfirmationDialog(member: admin, onSuccess: () {}),
          testName: 'role_change_dialog_demote_dark',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.dark],
        );
      },
    );
  });

  group('RemoveMemberConfirmationDialog - Golden Tests', () {
    testWidgets('RemoveMemberConfirmationDialog - light theme', (tester) async {
      final member = FamilyDataFactory.createRealisticMember();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: RemoveMemberConfirmationDialog(
          member: member,
          onSuccess: () {},
        ),
        testName: 'remove_member_dialog_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('RemoveMemberConfirmationDialog - dark theme', (tester) async {
      final member = FamilyDataFactory.createMemberWithLongName();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: RemoveMemberConfirmationDialog(
          member: member,
          onSuccess: () {},
        ),
        testName: 'remove_member_dialog_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
      );
    });
  });

  group('LeaveFamilyConfirmationDialog - Golden Tests', () {
    testWidgets('LeaveFamilyConfirmationDialog - light theme', (tester) async {
      final member = FamilyDataFactory.createRealisticMember();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: LeaveFamilyConfirmationDialog(member: member, onSuccess: () {}),
        testName: 'leave_family_dialog_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('LeaveFamilyConfirmationDialog - dark theme', (tester) async {
      final member = FamilyDataFactory.createRealisticMember();

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: LeaveFamilyConfirmationDialog(member: member, onSuccess: () {}),
        testName: 'leave_family_dialog_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
      );
    });
  });

  group('VehicleCapacityIndicator - Golden Tests', () {
    testWidgets('VehicleCapacityIndicator - normal capacity - light theme', (
      tester,
    ) async {
      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: const VehicleCapacityIndicator(usedSeats: 3, totalSeats: 5),
        testName: 'vehicle_capacity_normal_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('VehicleCapacityIndicator - at capacity - dark theme', (
      tester,
    ) async {
      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: const VehicleCapacityIndicator(usedSeats: 7, totalSeats: 7),
        testName: 'vehicle_capacity_full_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
      );
    });

    testWidgets('VehicleCapacityIndicator - nearly full - light theme', (
      tester,
    ) async {
      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: const VehicleCapacityIndicator(usedSeats: 8, totalSeats: 9),
        testName: 'vehicle_capacity_nearly_full_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
      );
    });
  });

  group('ConflictIndicator - Golden Tests', () {
    testWidgets('ConflictIndicator - light theme', (tester) async {
      final conflicts = [
        ScheduleConflict(
          id: '1',
          firstTimeSlotId: 'slot1',
          secondTimeSlotId: 'slot2',
          type: ConflictType.timeOverlap,
          severity: ConflictSeverity.medium,
          description: 'Time overlap conflict',
          detectedAt: DateTime.now(),
        ),
        ScheduleConflict(
          id: '2',
          firstTimeSlotId: 'slot3',
          secondTimeSlotId: 'slot4',
          type: ConflictType.vehicleUnavailable,
          severity: ConflictSeverity.high,
          description: 'Vehicle unavailable',
          detectedAt: DateTime.now(),
        ),
      ];

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: ConflictIndicator(conflicts: conflicts),
        testName: 'conflict_indicator_light',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.light],
      );
    });

    testWidgets('ConflictIndicator - dark theme', (tester) async {
      final conflicts = List.generate(
        5,
        (index) => ScheduleConflict(
          id: 'conflict_$index',
          firstTimeSlotId: 'slot_${index * 2}',
          secondTimeSlotId: 'slot_${index * 2 + 1}',
          type: ConflictType.timeOverlap,
          severity: ConflictSeverity.medium,
          description: 'Conflict $index',
          detectedAt: DateTime.now(),
        ),
      );

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: ConflictIndicator(conflicts: conflicts),
        testName: 'conflict_indicator_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
      );
    });
  });

  group('Family Widgets - Large Lists Volume Testing', () {
    testWidgets(
      'Children list - 10+ items for scroll validation - light theme',
      (tester) async {
        final children = FamilyDataFactory.createLargeChildList(count: 12);

        await GoldenTestWrapper.testWidget(
          tester: tester,
          widget: SizedBox(
            height: 600,
            child: ListView.builder(
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(child.name.substring(0, 1).toUpperCase()),
                  ),
                  title: Text(child.name),
                  subtitle:
                      child.age != null ? Text('Age: ${child.age}') : null,
                  trailing: const Icon(Icons.edit),
                );
              },
            ),
          ),
          testName: 'children_list_large_light',
          devices: DeviceConfigurations.defaultSet,
          themes: [ThemeConfigurations.light],
        );
      },
    );

    testWidgets('Vehicles list - 5+ items for scroll validation - dark theme', (
      tester,
    ) async {
      final vehicles = FamilyDataFactory.createLargeVehicleList(count: 7);

      await GoldenTestWrapper.testWidget(
        tester: tester,
        widget: SizedBox(
          height: 600,
          child: ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: Text(vehicle.name),
                  subtitle: vehicle.description != null
                      ? Text(vehicle.description!)
                      : null,
                  trailing: Text('${vehicle.capacity} seats'),
                ),
              );
            },
          ),
        ),
        testName: 'vehicles_list_large_dark',
        devices: DeviceConfigurations.defaultSet,
        themes: [ThemeConfigurations.dark],
      );
    });
  });
}

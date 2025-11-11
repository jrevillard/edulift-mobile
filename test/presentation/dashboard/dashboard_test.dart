// Dashboard Tests
// Simple tests focusing on core functionality

import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';

import '../../test_mocks/dashboard_mock_factory.dart';

void main() {
  group('Dashboard Entity Tests', () {
    test('DayTransportSummary creates correct structure', () {
      // Arrange
      const transport = TransportSlotSummary(
        time: '08:30',
        groupId: 'group-123',
        groupName: 'Morning School',
        scheduleSlotId: 'slot-456',
        vehicleAssignmentSummaries: [],
        totalChildrenAssigned: 12,
        totalCapacity: 15,
        overallCapacityStatus: CapacityStatus.available,
      );

      const daySummary = DayTransportSummary(
        date: '2024-01-15',
        transports: [transport],
        totalChildrenInVehicles: 12,
        totalVehiclesWithAssignments: 1,
        hasScheduledTransports: true,
      );

      // Assert
      expect(daySummary.date, equals('2024-01-15'));
      expect(daySummary.transports, contains(transport));
      expect(daySummary.totalChildrenInVehicles, equals(12));
      expect(daySummary.hasScheduledTransports, isTrue);
    });

    test('VehicleAssignmentSummary creates correct structure', () {
      // Arrange
      const vehicle = VehicleAssignmentSummary(
        vehicleId: 'vehicle-1',
        vehicleName: 'School Bus 1',
        vehicleCapacity: 20,
        assignedChildrenCount: 15,
        availableSeats: 5,
        capacityStatus: CapacityStatus.available,
        vehicleFamilyId: 'family-456',
        isFamilyVehicle: true,
        driver: VehicleDriver(id: 'driver-1', name: 'Driver John'),
        children: [
          VehicleChild(
            childId: 'child-1',
            childName: 'Test Child',
            childFamilyId: 'family-456',
            isFamilyChild: true,
          ),
        ],
      );

      // Assert
      expect(vehicle.vehicleId, equals('vehicle-1'));
      expect(vehicle.vehicleName, equals('School Bus 1'));
      expect(vehicle.vehicleCapacity, equals(20));
      expect(vehicle.assignedChildrenCount, equals(15));
      expect(vehicle.availableSeats, equals(5));
      expect(vehicle.capacityStatus, equals(CapacityStatus.available));
      expect(vehicle.isFamilyVehicle, isTrue);
      expect(vehicle.driver?.name, equals('Driver John'));
      expect(vehicle.children, isNotEmpty);
    });

    test('CapacityStatus enum values work correctly', () {
      // Test all capacity status values
      expect(CapacityStatus.available, isA<CapacityStatus>());
      expect(CapacityStatus.limited, isA<CapacityStatus>());
      expect(CapacityStatus.full, isA<CapacityStatus>());
      expect(CapacityStatus.overcapacity, isA<CapacityStatus>());
    });

    test('TransportSlotSummary utilization calculation works', () {
      const transport = TransportSlotSummary(
        time: '10:00',
        groupId: 'group-1',
        groupName: 'Test Transport',
        scheduleSlotId: 'slot-1',
        vehicleAssignmentSummaries: [],
        totalChildrenAssigned: 15,
        totalCapacity: 20,
        overallCapacityStatus: CapacityStatus.limited,
      );

      expect(transport.utilizationPercentage, equals(75.0));
    });

    test('VehicleAssignmentSummary utilization calculation works', () {
      const vehicle = VehicleAssignmentSummary(
        vehicleId: 'vehicle-1',
        vehicleName: 'School Bus 1',
        vehicleCapacity: 20,
        assignedChildrenCount: 15,
        availableSeats: 5,
        capacityStatus: CapacityStatus.limited,
        vehicleFamilyId: 'family-456',
        isFamilyVehicle: true,
        driver: VehicleDriver(id: 'driver-1', name: 'Driver John'),
        children: [
          VehicleChild(
            childId: 'child-1',
            childName: 'Test Child',
            childFamilyId: 'family-456',
            isFamilyChild: true,
          ),
        ],
      );

      expect(vehicle.utilizationPercentage, equals(75.0));
    });
  });

  group('Dashboard Mock Factory', () {
    test('Create mock day summary works', () {
      final summary = DashboardMockFactory.createMockDaySummary();
      expect(summary.date, isNotEmpty);
      expect(summary.transports, isNotEmpty);
      expect(summary.hasScheduledTransports, isTrue);
    });

    test('Create empty day summary works', () {
      final emptySummary = DashboardMockFactory.createEmptyDaySummary();
      expect(emptySummary.date, isNotEmpty);
      expect(emptySummary.transports, isEmpty);
      expect(emptySummary.hasScheduledTransports, isFalse);
    });

    test('Create mock transport works', () {
      final transport = DashboardMockFactory.createMockTransport();
      expect(transport.time, isNotEmpty);
      expect(transport.groupName, isNotEmpty);
      expect(transport.totalChildrenAssigned, greaterThanOrEqualTo(0));
      expect(transport.totalCapacity, greaterThanOrEqualTo(0));
    });

    test('Create mock vehicle works', () {
      final vehicle = DashboardMockFactory.createMockVehicle();
      expect(vehicle.vehicleId, isNotEmpty);
      expect(vehicle.vehicleName, isNotEmpty);
      expect(vehicle.vehicleCapacity, greaterThanOrEqualTo(0));
      expect(vehicle.assignedChildrenCount, greaterThanOrEqualTo(0));
      expect(vehicle.availableSeats, greaterThanOrEqualTo(0));
    });

    test('Create week summaries works', () {
      final summaries = DashboardMockFactory.createMockWeekSummaries();
      expect(summaries.length, equals(7));
      expect(summaries.every((s) => s.date.isNotEmpty), isTrue);
    });

    test('User and Family entity creation works', () {
      final user = DashboardMockFactory.createMockUser();
      final family = DashboardMockFactory.createMockFamily();

      expect(user.id, isNotEmpty);
      expect(user.name, isNotEmpty);
      expect(user.email, isNotEmpty);
      expect(user.timezone, isNotEmpty);

      expect(family.id, isNotEmpty);
      expect(family.name, isNotEmpty);
    });
  });
}

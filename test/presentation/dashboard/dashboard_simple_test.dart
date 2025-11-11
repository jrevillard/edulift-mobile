// Simple Dashboard Widget Tests
// Tests focused on core functionality without complex mocks

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';

import '../../test_mocks/dashboard_mock_factory.dart';

void main() {
  group('Dashboard Simple Tests', () {
    testWidgets('Dashboard mock factory works correctly', (
      WidgetTester tester,
    ) async {
      // Arrange: Create mock data
      final mockTransport = DashboardMockFactory.createMockTransport();
      final mockVehicle = DashboardMockFactory.createMockVehicle();
      final mockDaySummary = DashboardMockFactory.createMockDaySummary();

      // Assert: Verify mock data structure
      expect(mockTransport.time, equals('08:30'));
      expect(mockTransport.groupName, equals('Test Group'));
      expect(mockTransport.totalChildrenAssigned, equals(15));
      expect(mockTransport.totalCapacity, equals(20));
      expect(
        mockTransport.overallCapacityStatus,
        equals(CapacityStatus.available),
      );

      expect(mockVehicle.vehicleName, isNotEmpty);
      expect(mockVehicle.capacityStatus, equals(CapacityStatus.available));
      expect(mockVehicle.children, isNotEmpty);

      expect(mockDaySummary.date, equals('2024-01-15'));
      expect(mockDaySummary.transports, isNotEmpty);
      expect(mockDaySummary.hasScheduledTransports, isTrue);
    });

    testWidgets('CapacityStatus enum works correctly', (
      WidgetTester tester,
    ) async {
      // Test all capacity status values
      const availableTransport = TransportSlotSummary(
        time: '09:00',
        groupId: 'group-1',
        groupName: 'Available Transport',
        scheduleSlotId: 'slot-1',
        vehicleAssignmentSummaries: [],
        totalChildrenAssigned: 5,
        totalCapacity: 20,
        overallCapacityStatus: CapacityStatus.available,
      );

      const limitedTransport = TransportSlotSummary(
        time: '10:00',
        groupId: 'group-2',
        groupName: 'Limited Transport',
        scheduleSlotId: 'slot-2',
        vehicleAssignmentSummaries: [],
        totalChildrenAssigned: 18,
        totalCapacity: 20,
        overallCapacityStatus: CapacityStatus.limited,
      );

      const fullTransport = TransportSlotSummary(
        time: '11:00',
        groupId: 'group-3',
        groupName: 'Full Transport',
        scheduleSlotId: 'slot-3',
        vehicleAssignmentSummaries: [],
        totalChildrenAssigned: 20,
        totalCapacity: 20,
        overallCapacityStatus: CapacityStatus.full,
      );

      const overcapacityTransport = TransportSlotSummary(
        time: '12:00',
        groupId: 'group-4',
        groupName: 'Overcapacity Transport',
        scheduleSlotId: 'slot-4',
        vehicleAssignmentSummaries: [],
        totalChildrenAssigned: 25,
        totalCapacity: 20,
        overallCapacityStatus: CapacityStatus.overcapacity,
      );

      // Assert capacity status calculations
      expect(availableTransport.utilizationPercentage, equals(25.0));
      expect(limitedTransport.utilizationPercentage, equals(90.0));
      expect(fullTransport.utilizationPercentage, equals(100.0));
      expect(overcapacityTransport.utilizationPercentage, equals(125.0));

      // Assert capacity status checks
      expect(availableTransport.isFull, isFalse);
      expect(limitedTransport.isFull, isFalse);
      expect(fullTransport.isFull, isTrue);
      expect(overcapacityTransport.isFull, isTrue);
    });

    testWidgets('Entity copyWith methods work correctly', (
      WidgetTester tester,
    ) async {
      // Test DayTransportSummary copyWith
      final original = DashboardMockFactory.createMockDaySummary();
      final modified = original.copyWith(
        totalChildrenInVehicles: 25,
        hasScheduledTransports: false,
      );

      expect(modified.totalChildrenInVehicles, equals(25));
      expect(modified.hasScheduledTransports, isFalse);
      expect(modified.date, equals(original.date));
      expect(modified.transports, equals(original.transports));

      // Test TransportSlotSummary copyWith
      final originalTransport = DashboardMockFactory.createMockTransport();
      final modifiedTransport = originalTransport.copyWith(
        totalChildrenAssigned: 20,
        totalCapacity: 25,
        overallCapacityStatus: CapacityStatus.full,
      );

      expect(modifiedTransport.totalChildrenAssigned, equals(20));
      expect(modifiedTransport.totalCapacity, equals(25));
      expect(
        modifiedTransport.overallCapacityStatus,
        equals(CapacityStatus.full),
      );
    });

    testWidgets('VehicleAssignmentSummary copyWith works correctly', (
      WidgetTester tester,
    ) async {
      // Test VehicleAssignmentSummary copyWith
      final original = DashboardMockFactory.createMockVehicle();
      final modified = original.copyWith(
        assignedChildrenCount: 18,
        capacityStatus: CapacityStatus.full,
        availableSeats: 2,
      );

      expect(modified.assignedChildrenCount, equals(18));
      expect(modified.capacityStatus, equals(CapacityStatus.full));
      expect(modified.availableSeats, equals(2));
      expect(modified.isFull, isFalse); // 2 available seats means not full
    });
  });
}

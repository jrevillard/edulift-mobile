// DASHBOARD MOCK FACTORY
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// Centralized mock factory for dashboard domain entities and test data.
// This replaces scattered mock creation with a single, maintainable source of truth.

import 'package:edulift/features/dashboard/domain/entities/dashboard_transport_summary.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';
import 'package:edulift/core/domain/entities/user.dart';
import 'package:edulift/core/domain/entities/family.dart' as entities;
import 'package:edulift/core/domain/entities/schedule.dart';

/// Centralized Dashboard Mock Factory
/// All dashboard-related mock data creation should use this factory
class DashboardMockFactory {
  // Day Transport Summary Mocks
  static DayTransportSummary createMockDaySummary({
    String? date,
    List<TransportSlotSummary>? transports,
    int totalChildren = 15,
    int totalVehicles = 2,
    bool hasTransports = true,
  }) {
    return DayTransportSummary(
      date: date ?? '2024-01-15',
      transports: transports ?? createMockTransportList(),
      totalChildrenInVehicles: totalChildren,
      totalVehiclesWithAssignments: totalVehicles,
      hasScheduledTransports: hasTransports,
    );
  }

  static DayTransportSummary createEmptyDaySummary({String? date}) {
    return createMockDaySummary(
      date: date,
      transports: [],
      hasTransports: false,
      totalChildren: 0,
      totalVehicles: 0,
    );
  }

  // Transport Slot Summary Mocks
  static TransportSlotSummary createMockTransport({
    String? time,
    String? groupId,
    String? groupName,
    List<VehicleAssignmentSummary>? vehicles,
    int totalChildren = 15,
    int totalCapacity = 20,
    CapacityStatus status = CapacityStatus.available,
  }) {
    return TransportSlotSummary(
      time: time ?? '08:30',
      groupId: groupId ?? 'group-123',
      groupName: groupName ?? 'Test Group',
      scheduleSlotId: 'slot-456',
      vehicleAssignmentSummaries: vehicles ?? createMockVehicleList(),
      totalChildrenAssigned: totalChildren,
      totalCapacity: totalCapacity,
      overallCapacityStatus: status,
    );
  }

  static TransportSlotSummary createEmptyTransport() {
    return const TransportSlotSummary(
      time: '09:00',
      groupId: 'group-empty',
      groupName: 'Empty Group',
      scheduleSlotId: 'slot-empty',
      vehicleAssignmentSummaries: [],
      totalChildrenAssigned: 0,
      totalCapacity: 0,
      overallCapacityStatus: CapacityStatus.available,
    );
  }

  static TransportSlotSummary createOverCapacityTransport() {
    return createMockTransport(
      totalChildren: 25,
      status: CapacityStatus.overcapacity,
      vehicles: [
        createMockVehicle(
          assigned: 25,
          available: -5,
          status: CapacityStatus.overcapacity,
        ),
      ],
    );
  }

  // Vehicle Assignment Summary Mocks
  static VehicleAssignmentSummary createMockVehicle({
    String? id,
    String? name,
    int capacity = 20,
    int assigned = 15,
    int available = 5,
    CapacityStatus status = CapacityStatus.available,
    String? vehicleFamilyId,
    bool isFamilyVehicle = true,
  }) {
    return VehicleAssignmentSummary(
      vehicleId: id ?? 'vehicle_$assigned',
      vehicleName: name ?? 'Bus $assigned',
      vehicleCapacity: capacity,
      assignedChildrenCount: assigned,
      availableSeats: available,
      capacityStatus: status,
      vehicleFamilyId: vehicleFamilyId ?? 'family-456',
      isFamilyVehicle: isFamilyVehicle,
      driver: const VehicleDriver(id: 'driver-1', name: 'Driver John'),
      children: const [
        VehicleChild(
          childId: 'child-1',
          childName: 'Test Child',
          childFamilyId: 'family-456',
          isFamilyChild: true,
        ),
      ],
    );
  }

  static VehicleAssignmentSummary createEmptyVehicle() {
    return createMockVehicle(assigned: 0, available: 20);
  }

  static VehicleAssignmentSummary createFullVehicle() {
    return createMockVehicle(
      assigned: 20,
      available: 0,
      status: CapacityStatus.full,
    );
  }

  // Collections Mocks
  static List<TransportSlotSummary> createMockTransportList() {
    return [
      createMockTransport(
        time: '08:00',
        groupName: 'Morning School',
        totalChildren: 12,
      ),
      createMockTransport(
        time: '15:30',
        groupName: 'Afternoon Activity',
        status: CapacityStatus.limited,
        totalChildren: 18,
      ),
      createMockTransport(
        time: '18:00',
        groupName: 'Evening Program',
        status: CapacityStatus.full,
        totalCapacity: 15,
      ),
    ];
  }

  static List<VehicleAssignmentSummary> createMockVehicleList() {
    return [
      createMockVehicle(id: 'bus1', name: 'School Bus 1'),
      createMockVehicle(
        id: 'van1',
        name: 'Activity Van',
        capacity: 8,
        assigned: 7,
        available: 1,
        status: CapacityStatus.limited,
      ),
    ];
  }

  static List<DayTransportSummary> createMockWeekSummaries() {
    final today = DateTime.now();
    return List.generate(7, (index) {
      final date = today.add(Duration(days: index));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final hasTransports =
          index % 2 == 0; // Alternate days with/without transports

      return createMockDaySummary(
        date: dateStr,
        transports: hasTransports ? createMockTransportList() : [],
        hasTransports: hasTransports,
      );
    });
  }

  // User and Family Entity Factories (using real entities, not mocks)
  static User createMockUser({
    String id = 'test-user-123',
    String name = 'John Doe',
    String email = 'john.doe@example.com',
    String timezone = 'Europe/Paris',
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      timezone: timezone,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      preferredLanguage: 'en',
    );
  }

  static entities.Family createMockFamily({
    String id = 'test-family-456',
    String name = 'Test Family',
    List<entities.Child>? children,
    List<entities.Vehicle>? vehicles,
  }) {
    return entities.Family(
      id: id,
      name: name,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      description: 'Test family for dashboard testing',
    );
  }

  static List<entities.Child> createMockChildren() {
    return [
      createMockChild(id: 'child-1', name: 'Alice Doe'),
      createMockChild(id: 'child-2', name: 'Bob Doe'),
    ];
  }

  static entities.Child createMockChild({
    String id = 'test-child-789',
    String name = 'Test Child',
    String familyId = 'test-family-456',
  }) {
    return entities.Child(
      id: id,
      name: name,
      familyId: familyId,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    );
  }

  static List<entities.Vehicle> createMockVehicles() {
    return [
      createMockVehicleEntity(id: 'vehicle-1', name: 'Family Van', capacity: 7),
      createMockVehicleEntity(id: 'vehicle-2', name: 'Family Car', capacity: 4),
    ];
  }

  static entities.Vehicle createMockVehicleEntity({
    String id = 'test-vehicle-101',
    String name = 'Test Vehicle',
    int capacity = 5,
    String familyId = 'test-family-456',
  }) {
    return entities.Vehicle(
      id: id,
      name: name,
      capacity: capacity,
      familyId: familyId,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
    );
  }

  // Test constants
  static const String testUserTimezone = 'Europe/Paris';
  static const String testFamilyId = 'test-family-456';
  static const String testUserId = 'test-user-123';

  static DateTime get testWeekStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day); // Today at midnight
  }
}

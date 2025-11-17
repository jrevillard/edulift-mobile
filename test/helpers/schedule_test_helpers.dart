import 'package:edulift/core/domain/entities/schedule/day_of_week.dart';
import 'package:edulift/core/domain/entities/schedule/schedule_slot.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';
import 'package:edulift/core/domain/entities/family/vehicle.dart';
import 'package:edulift/core/domain/entities/family/child.dart';
import 'package:edulift/core/domain/entities/family/child_assignment.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart'
    as schedule_assignment;
import 'package:edulift/features/schedule/presentation/models/displayable_time_slot.dart';

/// Test helpers for schedule-related widgets and business logic
///
/// This file provides comprehensive helper methods to create test data
/// for DisplayableTimeSlot, vehicles, children, assignments, and conflicts.
/// All helpers generate valid, coherent data that respects the domain model.
///
/// Example usage:
/// ```dart
/// // Create a single slot for testing
/// final slot = ScheduleTestHelpers.createDisplayableSlot(
///   dayOfWeek: DayOfWeek.monday,
///   timeOfDay: TimeOfDayValue(8, 0),
///   hasVehicle: true,
///   childrenCount: 3,
/// );
///
/// // Create a full week of slots
/// final weekSlots = ScheduleTestHelpers.createWeekSchedule(
///   weekId: '2025-W46',
///   vehiclesPerSlot: 2,
///   childrenPerVehicle: 3,
/// );
///
/// // Create conflicting slot
/// final conflictSlot = ScheduleTestHelpers.createConflictingSlot(
///   conflictType: ConflictType.overcapacity,
///   excessCount: 2,
/// );
/// ```
class ScheduleTestHelpers {
  static const String _testGroupId = 'test-group-123';
  static const String _testFamilyId = 'test-family-456';
  static const String _testWeek = '2025-W46';
  static const String _testTimezone = 'America/New_York';

  // ====================================================================
  // DISPLAYABLE TIME SLOT HELPERS
  // ====================================================================

  /// Creates a single DisplayableTimeSlot with optional vehicle assignments
  ///
  /// Parameters:
  /// - [dayOfWeek]: Day of the week for the slot
  /// - [timeOfDay]: Time of day for the slot
  /// - [week]: Week identifier (defaults to test week)
  /// - [existsInBackend]: Whether slot exists in backend
  /// - [vehicles]: Number of vehicles to assign
  /// - [childrenPerVehicle]: Number of children per vehicle
  /// - [maxVehicles]: Maximum vehicles allowed for the slot
  /// - [vehicleCapacity]: Capacity for each vehicle
  /// - [isPast]: Whether this slot should be in the past
  /// - [vehicleNames]: Optional custom vehicle names
  /// - [childNames]: Optional custom child names
  static DisplayableTimeSlot createDisplayableSlot({
    required DayOfWeek dayOfWeek,
    required TimeOfDayValue timeOfDay,
    String week = _testWeek,
    bool existsInBackend = true,
    int vehicles = 0,
    int childrenPerVehicle = 0,
    int maxVehicles = 3,
    int vehicleCapacity = 5,
    bool isPast = false,
    List<String>? vehicleNames,
    List<String>? childNames,
  }) {
    if (vehicles > maxVehicles) {
      throw ArgumentError(
        'Vehicles ($vehicles) cannot exceed maxVehicles ($maxVehicles)',
      );
    }

    if (childrenPerVehicle > vehicleCapacity) {
      throw ArgumentError(
        'Children per vehicle ($childrenPerVehicle) cannot exceed vehicle capacity ($vehicleCapacity)',
      );
    }

    ScheduleSlot? scheduleSlot;
    if (existsInBackend && vehicles > 0) {
      scheduleSlot = _createScheduleSlot(
        dayOfWeek: dayOfWeek,
        timeOfDay: timeOfDay,
        week: week,
        vehicles: vehicles,
        childrenPerVehicle: childrenPerVehicle,
        maxVehicles: maxVehicles,
        vehicleCapacity: vehicleCapacity,
        vehicleNames: vehicleNames,
        childNames: childNames,
      );
    } else if (existsInBackend) {
      scheduleSlot = _createScheduleSlot(
        dayOfWeek: dayOfWeek,
        timeOfDay: timeOfDay,
        week: week,
        vehicles: 0,
        maxVehicles: maxVehicles,
      );
    }

    return DisplayableTimeSlot(
      dayOfWeek: dayOfWeek,
      timeOfDay: isPast ? _createPastTime(timeOfDay) : timeOfDay,
      week: week,
      scheduleSlot: scheduleSlot,
      existsInBackend: scheduleSlot != null,
    );
  }

  /// Creates a complete week schedule with slots for each day
  ///
  /// Parameters:
  /// - [week]: Week identifier
  /// - [timeSlots]: List of times for each day (defaults to 08:00 and 15:00)
  /// - [vehiclesPerSlot]: Number of vehicles per time slot
  /// - [childrenPerVehicle]: Number of children per vehicle
  /// - [vehicleCapacity]: Capacity for each vehicle
  /// - [maxVehicles]: Maximum vehicles per slot
  /// - [includeWeekend]: Whether to include weekend slots
  /// - [emptyDays]: Days that should have no vehicles
  static List<DisplayableTimeSlot> createWeekSchedule({
    String week = _testWeek,
    List<TimeOfDayValue>? timeSlots,
    int vehiclesPerSlot = 1,
    int childrenPerVehicle = 2,
    int vehicleCapacity = 5,
    int maxVehicles = 3,
    bool includeWeekend = false,
    List<DayOfWeek>? emptyDays,
  }) {
    final slots = <DisplayableTimeSlot>[];
    final times =
        timeSlots ??
        [
          const TimeOfDayValue(8, 0), // Morning
          const TimeOfDayValue(15, 0), // Afternoon
        ];

    final days = includeWeekend
        ? DayOfWeek.values
        : [
            DayOfWeek.monday,
            DayOfWeek.tuesday,
            DayOfWeek.wednesday,
            DayOfWeek.thursday,
            DayOfWeek.friday,
          ];

    for (final day in days) {
      final shouldCreateEmptySlot = emptyDays?.contains(day) ?? false;

      for (final time in times) {
        slots.add(
          createDisplayableSlot(
            dayOfWeek: day,
            timeOfDay: time,
            week: week,
            vehicles: shouldCreateEmptySlot ? 0 : vehiclesPerSlot,
            childrenPerVehicle: shouldCreateEmptySlot ? 0 : childrenPerVehicle,
            maxVehicles: maxVehicles,
            vehicleCapacity: vehicleCapacity,
          ),
        );
      }
    }

    return slots;
  }

  // ====================================================================
  // VEHICLE HELPERS
  // ====================================================================

  /// Creates a test vehicle with specified properties
  ///
  /// Parameters:
  /// - [name]: Vehicle name
  /// - [capacity]: Seating capacity
  /// - [familyId]: Family ID (defaults to test family)
  /// - [description]: Optional description
  static Vehicle createTestVehicle({
    required String name,
    required int capacity,
    String familyId = _testFamilyId,
    String? description,
  }) {
    final now = DateTime.now();
    return Vehicle(
      id: 'vehicle-${name.toLowerCase().replaceAll(' ', '-')}',
      name: name,
      familyId: familyId,
      capacity: capacity,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a list of test vehicles
  ///
  /// Parameters:
  /// - [count]: Number of vehicles to create
  /// - [capacity]: Capacity for each vehicle
  /// - [familyId]: Family ID
  /// - [namePrefix]: Prefix for vehicle names
  static List<Vehicle> createTestVehicles({
    int count = 3,
    int capacity = 5,
    String familyId = _testFamilyId,
    String namePrefix = 'Test Vehicle',
  }) {
    return List.generate(count, (index) {
      return createTestVehicle(
        name: '$namePrefix ${index + 1}',
        capacity: capacity,
        familyId: familyId,
      );
    });
  }

  /// Creates a map of vehicle ID to Vehicle for testing
  ///
  /// Parameters:
  /// - [vehicles]: List of vehicles (creates default if null)
  /// - [includeNull]: Whether to include null entries in the map
  static Map<String, Vehicle?> createVehicleMap({
    List<Vehicle>? vehicles,
    bool includeNull = false,
  }) {
    final vehicleList = vehicles ?? createTestVehicles();
    final vehicleMap = <String, Vehicle?>{};

    for (final vehicle in vehicleList) {
      vehicleMap[vehicle.id] = vehicle;
    }

    if (includeNull) {
      vehicleMap['non-existent-vehicle'] = null;
    }

    return vehicleMap;
  }

  // ====================================================================
  // CHILD HELPERS
  // ====================================================================

  /// Creates a test child with specified properties
  ///
  /// Parameters:
  /// - [name]: Child name
  /// - [age]: Child age
  /// - [familyId]: Family ID
  static Child createTestChild({
    required String name,
    int? age,
    String familyId = _testFamilyId,
  }) {
    return Child(
      id: 'child-${name.toLowerCase().replaceAll(' ', '-')}',
      familyId: familyId,
      name: name,
      age: age,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a list of test children
  ///
  /// Parameters:
  /// - [count]: Number of children to create
  /// - [familyId]: Family ID
  /// - [namePrefix]: Prefix for child names
  /// - [startAge]: Starting age for children
  static List<Child> createTestChildren({
    int count = 5,
    String familyId = _testFamilyId,
    String namePrefix = 'Test Child',
    int startAge = 8,
  }) {
    return List.generate(count, (index) {
      return createTestChild(
        name: '$namePrefix ${index + 1}',
        age: startAge + index,
        familyId: familyId,
      );
    });
  }

  /// Creates a map of child ID to Child for testing
  static Map<String, Child> createChildMap({List<Child>? children}) {
    final childList = children ?? createTestChildren();
    return {for (final child in childList) child.id: child};
  }

  // ====================================================================
  // VEHICLE ASSIGNMENT HELPERS
  // ====================================================================

  /// Creates a VehicleAssignment with child assignments
  ///
  /// Parameters:
  /// - [vehicle]: Vehicle to assign
  /// - [children]: List of children to assign
  /// - [scheduleSlotId]: Schedule slot ID
  /// - [seatOverride]: Optional seat override
  /// - [isActive]: Whether assignment is active
  static schedule_assignment.VehicleAssignment createVehicleAssignment({
    required Vehicle vehicle,
    required List<Child> children,
    required String scheduleSlotId,
    int? seatOverride,
    bool isActive = true,
  }) {
    final now = DateTime.now();

    return schedule_assignment.VehicleAssignment(
      id: 'assignment-${vehicle.id}-${scheduleSlotId}',
      scheduleSlotId: scheduleSlotId,
      vehicleId: vehicle.id,
      assignedAt: now,
      assignedBy: 'test-user',
      isActive: isActive,
      seatOverride: seatOverride,
      vehicleName: vehicle.name,
      childAssignments: children
          .map(
            (child) => ChildAssignment(
              id: 'child-assignment-${child.id}-${vehicle.id}',
              childId: child.id,
              assignmentType: 'driver',
              assignmentId: vehicle.id,
              createdAt: now,
              vehicleAssignmentId: vehicle.id,
            ),
          )
          .toList(),
      capacity: vehicle.capacity,
      createdAt: now,
      updatedAt: now,
    );
  }

  // ====================================================================
  // UTILITY METHODS
  // ====================================================================

  /// Creates a ScheduleSlot with vehicle assignments
  static ScheduleSlot _createScheduleSlot({
    required DayOfWeek dayOfWeek,
    required TimeOfDayValue timeOfDay,
    required String week,
    required int vehicles,
    required int maxVehicles,
    int childrenPerVehicle = 0,
    int vehicleCapacity = 5,
    List<String>? vehicleNames,
    List<String>? childNames,
  }) {
    final now = DateTime.now();
    final slotId = 'slot-${dayOfWeek.name}-${timeOfDay.toApiFormat()}';

    final vehicleAssignments = <schedule_assignment.VehicleAssignment>[];
    final childList = createTestChildren(count: childrenPerVehicle * vehicles);

    for (var i = 0; i < vehicles; i++) {
      final vehicleName =
          vehicleNames?.elementAtOrNull(i) ?? 'Test Vehicle ${i + 1}';
      final vehicle = createTestVehicle(
        name: vehicleName,
        capacity: vehicleCapacity,
      );

      final assignedChildren = childList
          .skip(i * childrenPerVehicle)
          .take(childrenPerVehicle)
          .toList();

      vehicleAssignments.add(
        createVehicleAssignment(
          vehicle: vehicle,
          children: assignedChildren,
          scheduleSlotId: slotId,
        ),
      );
    }

    return ScheduleSlot(
      id: slotId,
      groupId: _testGroupId,
      dayOfWeek: dayOfWeek,
      timeOfDay: timeOfDay,
      week: week,
      vehicleAssignments: vehicleAssignments,
      maxVehicles: maxVehicles,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a time in the past for testing past slot behavior
  static TimeOfDayValue _createPastTime(TimeOfDayValue originalTime) {
    final now = DateTime.now();
    final pastDateTime = now.subtract(const Duration(hours: 2));
    return TimeOfDayValue(pastDateTime.hour, pastDateTime.minute);
  }

  /// Creates a DisplayableTimeSlot that represents a slot in the past
  static DisplayableTimeSlot createPastSlot({
    DayOfWeek dayOfWeek = DayOfWeek.monday,
    TimeOfDayValue? timeOfDay,
    String week = _testWeek,
    bool hasVehicles = false,
  }) {
    final pastTime = timeOfDay ?? _createPastTime(const TimeOfDayValue(10, 0));

    return createDisplayableSlot(
      dayOfWeek: dayOfWeek,
      timeOfDay: pastTime,
      week: week,
      vehicles: hasVehicles ? 1 : 0,
      isPast: true,
    );
  }

  /// Creates test data for capacity scenarios (available, limited, full, overcapacity)
  static Map<String, DisplayableTimeSlot> createCapacityTestCases({
    int vehicleCapacity = 5,
  }) {
    return {
      'empty': createDisplayableSlot(
        dayOfWeek: DayOfWeek.monday,
        timeOfDay: const TimeOfDayValue(8, 0),
      ),
      'available': createDisplayableSlot(
        dayOfWeek: DayOfWeek.tuesday,
        timeOfDay: const TimeOfDayValue(8, 0),
        vehicles: 1,
        childrenPerVehicle: 2,
        vehicleCapacity: vehicleCapacity,
      ),
      'limited': createDisplayableSlot(
        dayOfWeek: DayOfWeek.wednesday,
        timeOfDay: const TimeOfDayValue(8, 0),
        vehicles: 1,
        childrenPerVehicle: (vehicleCapacity * 0.8).round(),
        vehicleCapacity: vehicleCapacity,
      ),
      'full': createDisplayableSlot(
        dayOfWeek: DayOfWeek.thursday,
        timeOfDay: const TimeOfDayValue(8, 0),
        vehicles: 1,
        childrenPerVehicle: vehicleCapacity,
        vehicleCapacity: vehicleCapacity,
      ),
      'overcapacity': createDisplayableSlot(
        dayOfWeek: DayOfWeek.friday,
        timeOfDay: const TimeOfDayValue(8, 0),
        vehicles: 1,
        childrenPerVehicle: vehicleCapacity + 2,
        vehicleCapacity:
            vehicleCapacity + 2, // Increase capacity to accommodate
      ),
    };
  }

  /// Gets the default test timezone
  static String get testTimezone => _testTimezone;

  /// Gets the default test group ID
  static String get testGroupId => _testGroupId;

  /// Gets the default test family ID
  static String get testFamilyId => _testFamilyId;

  /// Gets the default test week
  static String get testWeek => _testWeek;
}

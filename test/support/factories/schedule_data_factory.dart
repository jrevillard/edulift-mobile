// EduLift - Schedule Data Factory
// Generates realistic schedule-related test data

import 'package:edulift/core/domain/entities/schedule/schedule_slot.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';
import 'package:edulift/core/domain/entities/schedule/day_of_week.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';
import 'package:edulift/core/domain/entities/schedule/period_slot_data.dart';
import 'package:edulift/core/domain/entities/schedule/schedule_period.dart';
import 'package:edulift/core/domain/entities/family/child_assignment.dart';

import 'test_data_factory.dart';

/// Factory for generating realistic schedule test data
class ScheduleDataFactory {
  static int _slotCounter = 0;
  static int _assignmentCounter = 0;
  static int _childAssignmentCounter = 0;

  /// Days of the week (type-safe enum values)
  static const daysOfWeek = [
    DayOfWeek.monday,
    DayOfWeek.tuesday,
    DayOfWeek.wednesday,
    DayOfWeek.thursday,
    DayOfWeek.friday,
    DayOfWeek.saturday,
    DayOfWeek.sunday,
  ];

  /// Legacy string days (for backward compatibility during migration)
  @Deprecated('Use daysOfWeek instead')
  static const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// Week identifiers
  static const weeks = ['A', 'B', 'C', 'D'];

  /// Time slots for schedules (type-safe TimeOfDayValue)
  static final timesOfDay = [
    const TimeOfDayValue(7, 0),
    const TimeOfDayValue(7, 30),
    const TimeOfDayValue(8, 0),
    const TimeOfDayValue(8, 30),
    const TimeOfDayValue(9, 0),
    const TimeOfDayValue(12, 0),
    const TimeOfDayValue(12, 30),
    const TimeOfDayValue(13, 0),
    const TimeOfDayValue(13, 30),
    const TimeOfDayValue(14, 0),
    const TimeOfDayValue(16, 0),
    const TimeOfDayValue(16, 30),
    const TimeOfDayValue(17, 0),
    const TimeOfDayValue(17, 30),
    const TimeOfDayValue(18, 0),
  ];

  /// Legacy string times (for backward compatibility during migration)
  @Deprecated('Use timesOfDay instead')
  static const times = [
    '07:00',
    '07:30',
    '08:00',
    '08:30',
    '09:00',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
  ];

  /// Create a realistic schedule slot (TYPE-SAFE)
  static ScheduleSlot createRealisticScheduleSlot({
    int? index,
    String? groupId,
    int? vehicleCount,
  }) {
    final i = index ?? _slotCounter++;
    final now = DateTime.now();

    final vehicleAssignments = List.generate(
      vehicleCount ?? TestDataFactory.randomInt(1, 3),
      (j) => createRealisticVehicleAssignment(
        index: j,
        scheduleSlotId: 'slot-${i + 1}',
      ),
    );

    return ScheduleSlot(
      id: 'slot-${i + 1}',
      groupId: groupId ?? 'group-1',
      dayOfWeek: daysOfWeek[i % daysOfWeek.length],
      timeOfDay: timesOfDay[i % timesOfDay.length],
      week: weeks[i % weeks.length],
      vehicleAssignments: vehicleAssignments,
      maxVehicles: TestDataFactory.randomInt(3, 8),
      createdAt: TestDataFactory.randomPastDate(maxDaysAgo: 90),
      updatedAt: now,
    );
  }

  /// Create a realistic vehicle assignment
  static VehicleAssignment createRealisticVehicleAssignment({
    int? index,
    String? scheduleSlotId,
    int? childCount,
  }) {
    final i = index ?? _assignmentCounter++;
    final now = DateTime.now();

    final children = List.generate(
      childCount ?? TestDataFactory.randomInt(2, 5),
      (j) => createRealisticChildAssignment(
        index: j,
        vehicleAssignmentId: 'vehicle-assignment-${i + 1}',
      ),
    );

    final capacity = TestDataFactory.randomSeats();

    return VehicleAssignment(
      id: 'vehicle-assignment-${i + 1}',
      scheduleSlotId: scheduleSlotId ?? 'slot-1',
      vehicleId: 'vehicle-${i + 1}',
      driverId: i % 3 == 0 ? null : 'driver-${i + 1}',
      assignedAt: TestDataFactory.randomPastDate(maxDaysAgo: 30),
      assignedBy: 'user-1',
      isActive: i % 10 != 0,
      seatOverride: i % 4 == 0 ? capacity - 1 : null,
      notes: i % 3 == 0 ? _generateVehicleNotes(i) : null,
      status: _getVehicleStatus(i),
      vehicleName: _generateVehicleName(i),
      driverName: i % 3 == 0 ? null : TestDataFactory.randomName(),
      childAssignments: children,
      capacity: capacity,
      createdAt: TestDataFactory.randomPastDate(maxDaysAgo: 60),
      updatedAt: now,
    );
  }

  /// Create a realistic child assignment
  static ChildAssignment createRealisticChildAssignment({
    int? index,
    String? vehicleAssignmentId,
    String? type,
  }) {
    final i = index ?? _childAssignmentCounter++;
    final assignmentType = type ?? (i % 2 == 0 ? 'transportation' : 'schedule');

    if (assignmentType == 'transportation') {
      return ChildAssignment.transportation(
        id: 'child-assignment-${i + 1}',
        childId: 'child-${i + 1}',
        groupId: 'group-1',
        scheduleSlotId: 'slot-1',
        vehicleAssignmentId: vehicleAssignmentId ?? 'vehicle-assignment-1',
        assignedAt: TestDataFactory.randomPastDate(maxDaysAgo: 30),
        status: _getChildAssignmentStatus(i),
        assignmentDate: TestDataFactory.randomFutureDate(maxDaysAhead: 30),
        notes: i % 4 == 0 ? _generateChildNotes(i) : null,
      );
    } else {
      return ChildAssignment.schedule(
        id: 'child-assignment-${i + 1}',
        childId: 'child-${i + 1}',
        childName: TestDataFactory.randomFirstName(),
        familyId: 'family-${(i % 5) + 1}',
        familyName: 'Famille ${TestDataFactory.randomLastName()}',
        pickupAddress: TestDataFactory.randomAddress(),
        pickupLat: 48.8566 + (TestDataFactory.randomInt(-100, 100) / 1000),
        pickupLng: 2.3522 + (TestDataFactory.randomInt(-100, 100) / 1000),
        status: _getScheduleStatus(i),
        createdAt: TestDataFactory.randomPastDate(maxDaysAgo: 60),
        pickupTime: _generatePickupTime(),
        dropoffTime: _generateDropoffTime(),
      );
    }
  }

  /// Create a weekly schedule with all days (TYPE-SAFE)
  static List<ScheduleSlot> createWeeklySchedule({
    String? groupId,
    String? week,
  }) {
    final scheduleWeek = week ?? 'A';
    final slots = <ScheduleSlot>[];

    for (var dayIndex = 0; dayIndex < 5; dayIndex++) {
      // Monday to Friday
      for (var timeIndex = 0; timeIndex < 3; timeIndex++) {
        // Morning, Noon, Afternoon
        final dayOfWeek = daysOfWeek[dayIndex];
        final timeOfDay = [
          timesOfDay[2],
          timesOfDay[7],
          timesOfDay[12],
        ][timeIndex];

        slots.add(
          ScheduleSlot(
            id: 'slot-$scheduleWeek-${dayOfWeek.fullName}-${timeOfDay.toApiFormat()}',
            groupId: groupId ?? 'group-1',
            dayOfWeek: dayOfWeek,
            timeOfDay: timeOfDay,
            week: scheduleWeek,
            vehicleAssignments: List.generate(
              TestDataFactory.randomInt(1, 2),
              (i) => createRealisticVehicleAssignment(index: i),
            ),
            maxVehicles: 5,
            createdAt: TestDataFactory.randomPastDate(maxDaysAgo: 90),
            updatedAt: DateTime.now(),
          ),
        );
      }
    }

    return slots;
  }

  /// Create a large list of schedule slots for scroll testing
  /// Only uses times that match testScheduleConfig
  static List<ScheduleSlot> createLargeScheduleSlotList({
    int count = 20,
    String? groupId,
  }) {
    // Get only the times that are in our test configuration
    final availableTimes = [
      const TimeOfDayValue(7, 0), // 07:00
      const TimeOfDayValue(7, 30), // 07:30
      const TimeOfDayValue(8, 0), // 08:00
      const TimeOfDayValue(8, 30), // 08:30
      const TimeOfDayValue(9, 0), // 09:00
      const TimeOfDayValue(9, 30), // 09:30
      const TimeOfDayValue(10, 0), // 10:00
      const TimeOfDayValue(10, 30), // 10:30
      const TimeOfDayValue(11, 0), // 11:00
      const TimeOfDayValue(11, 30), // 11:30
      const TimeOfDayValue(12, 0), // 12:00
      const TimeOfDayValue(12, 30), // 12:30
      const TimeOfDayValue(13, 0), // 13:00
      const TimeOfDayValue(13, 30), // 13:30
      const TimeOfDayValue(14, 0), // 14:00
      const TimeOfDayValue(14, 30), // 14:30
      const TimeOfDayValue(15, 0), // 15:00
      const TimeOfDayValue(15, 30), // 15:30
      const TimeOfDayValue(16, 0), // 16:00
      const TimeOfDayValue(16, 30), // 16:30
      const TimeOfDayValue(17, 0), // 17:00
      const TimeOfDayValue(17, 30), // 17:30
    ];

    return List.generate(count, (i) {
      final timeOfDay = availableTimes[i % availableTimes.length];
      final dayOfWeek = daysOfWeek[i % daysOfWeek.length];

      return createRealisticScheduleSlot(index: i, groupId: groupId).copyWith(
        dayOfWeek: dayOfWeek,
        timeOfDay: timeOfDay,
        week: weeks[i % weeks.length],
      );
    });
  }

  /// Create test schedule slots (alias for createLargeScheduleSlotList for backward compatibility)
  @Deprecated('Use createLargeScheduleSlotList instead')
  static List<ScheduleSlot> createTestScheduleSlots({
    int count = 20,
    String? groupId,
  }) {
    return createLargeScheduleSlotList(count: count, groupId: groupId);
  }

  /// Create configured schedule slot list (alias for createLargeScheduleSlotList for backward compatibility)
  @Deprecated('Use createLargeScheduleSlotList instead')
  static List<ScheduleSlot> createConfiguredScheduleSlotList({
    int count = 20,
    String? groupId,
    Map<String, List<String>>? scheduleHours,
  }) {
    // scheduleHours parameter is ignored in this simplified implementation
    return createLargeScheduleSlotList(count: count, groupId: groupId);
  }

  /// Create a large list of vehicle assignments
  static List<VehicleAssignment> createLargeVehicleAssignmentList({
    int count = 15,
    String? scheduleSlotId,
  }) {
    return List.generate(
      count,
      (i) => createRealisticVehicleAssignment(
        index: i,
        scheduleSlotId: scheduleSlotId,
      ),
    );
  }

  /// Create a large list of child assignments
  static List<ChildAssignment> createLargeChildAssignmentList({
    int count = 25,
    String? vehicleAssignmentId,
  }) {
    return List.generate(
      count,
      (i) => createRealisticChildAssignment(
        index: i,
        vehicleAssignmentId: vehicleAssignmentId,
      ),
    );
  }

  // Edge cases

  /// Create schedule slot with no vehicles
  static ScheduleSlot createEmptyScheduleSlot({String? groupId}) {
    return createRealisticScheduleSlot(groupId: groupId, vehicleCount: 0);
  }

  /// Create schedule slot at maximum capacity
  static ScheduleSlot createFullScheduleSlot({String? groupId}) {
    final slot = createRealisticScheduleSlot(groupId: groupId);
    return slot.copyWith(
      vehicleAssignments: List.generate(
        slot.maxVehicles,
        (i) => createRealisticVehicleAssignment(index: i),
      ),
    );
  }

  /// Create vehicle assignment with no driver
  static VehicleAssignment createVehicleAssignmentWithoutDriver() {
    return createRealisticVehicleAssignment(index: 0);
  }

  /// Create vehicle assignment with no children
  static VehicleAssignment createVehicleAssignmentWithoutChildren() {
    return createRealisticVehicleAssignment(childCount: 0);
  }

  /// Create vehicle assignment at full capacity
  static VehicleAssignment createFullVehicleAssignment() {
    final assignment = createRealisticVehicleAssignment();
    return assignment.copyWith(
      childAssignments: List.generate(
        assignment.capacity - 1, // -1 for driver
        (i) => createRealisticChildAssignment(index: i),
      ),
    );
  }

  /// Create cancelled vehicle assignment
  static VehicleAssignment createCancelledVehicleAssignment() {
    return createRealisticVehicleAssignment().copyWith(
      status: VehicleAssignmentStatus.cancelled,
      isActive: false,
    );
  }

  /// Create completed vehicle assignment
  static VehicleAssignment createCompletedVehicleAssignment() {
    return createRealisticVehicleAssignment().copyWith(
      status: VehicleAssignmentStatus.completed,
    );
  }

  /// Create child assignment with very long address
  static ChildAssignment createChildAssignmentWithLongAddress() {
    return ChildAssignment.schedule(
      id: 'child-long-address',
      childId: 'child-1',
      childName: TestDataFactory.randomFirstName(),
      familyId: 'family-1',
      familyName: 'Famille Test',
      pickupAddress:
          '123 Avenue des Champs-Élysées prolongée jusque la Place de l\'Étoile, Appartement 456, 75008 Paris, France',
      pickupLat: 48.8566,
      pickupLng: 2.3522,
      status: 'CONFIRMED',
    );
  }

  /// Create cancelled child assignment
  static ChildAssignment createCancelledChildAssignment() {
    return createRealisticChildAssignment(
      type: 'transportation',
    ).copyWith(status: AssignmentStatus.cancelled);
  }

  /// Create no-show child assignment
  static ChildAssignment createNoShowChildAssignment() {
    return createRealisticChildAssignment(
      type: 'transportation',
    ).copyWith(status: AssignmentStatus.noShow);
  }

  // Period slot data factory methods

  /// Create a realistic PeriodSlotData for testing
  static PeriodSlotData createRealisticPeriodSlotData({
    String? groupId,
    String? week,
    DayOfWeek? dayOfWeek,
    PeriodType? periodType,
    List<String>? timeStrings,
    int? slotCount,
  }) {
    final day = dayOfWeek ??
        daysOfWeek[TestDataFactory.randomInt(0, daysOfWeek.length - 1)];
    final period = periodType ??
        PeriodType.values[TestDataFactory.randomInt(
          0,
          PeriodType.values.length - 1,
        )];
    final weekId = week ?? '2025-W41';

    // Generate time strings based on period type
    final times = timeStrings ?? _generateTimeStringsForPeriod(period);

    // Create schedule slots
    final slots = List.generate(
      slotCount ?? TestDataFactory.randomInt(1, 3),
      (i) => createRealisticScheduleSlot(index: i, groupId: groupId).copyWith(
        dayOfWeek: day,
        timeOfDay: TimeOfDayValue.parse(times[i % times.length]),
        week: weekId,
      ),
    );

    return PeriodSlotData(
      dayOfWeek: day,
      period: AggregatePeriod.fromTimeStrings(type: period, timeStrings: times),
      times: times.map((t) => TimeOfDayValue.parse(t)).toList(),
      slots: slots,
      week: weekId,
    );
  }

  /// Create a PeriodSlotData with morning period
  static PeriodSlotData createMorningPeriodSlotData({
    String? groupId,
    String? week,
    DayOfWeek? dayOfWeek,
  }) {
    return createRealisticPeriodSlotData(
      groupId: groupId,
      week: week,
      dayOfWeek: dayOfWeek,
      periodType: PeriodType.morning,
      timeStrings: ['07:00', '07:30', '08:00'],
      slotCount: 2,
    );
  }

  /// Create a PeriodSlotData with afternoon period
  static PeriodSlotData createAfternoonPeriodSlotData({
    String? groupId,
    String? week,
    DayOfWeek? dayOfWeek,
  }) {
    return createRealisticPeriodSlotData(
      groupId: groupId,
      week: week,
      dayOfWeek: dayOfWeek,
      periodType: PeriodType.afternoon,
      timeStrings: ['15:00', '15:30', '16:00'],
      slotCount: 2,
    );
  }

  /// Create a PeriodSlotData with evening period
  static PeriodSlotData createEveningPeriodSlotData({
    String? groupId,
    String? week,
    DayOfWeek? dayOfWeek,
  }) {
    return createRealisticPeriodSlotData(
      groupId: groupId,
      week: week,
      dayOfWeek: dayOfWeek,
      periodType: PeriodType.evening,
      timeStrings: ['17:00', '17:30', '18:00'],
      slotCount: 1,
    );
  }

  /// Create a PeriodSlotData with no slots (empty)
  static PeriodSlotData createEmptyPeriodSlotData({
    String? groupId,
    String? week,
    DayOfWeek? dayOfWeek,
  }) {
    final day = dayOfWeek ?? DayOfWeek.monday;
    final weekId = week ?? '2025-W41';

    return PeriodSlotData(
      dayOfWeek: day,
      period: AggregatePeriod.fromTimeStrings(
        type: PeriodType.morning,
        timeStrings: const ['07:00'],
      ),
      times: const [TimeOfDayValue(7, 0)],
      slots: const [], // Empty slots
      week: weekId,
    );
  }

  /// Create a PeriodSlotData with maximum vehicle assignments
  static PeriodSlotData createFullPeriodSlotData({
    String? groupId,
    String? week,
    DayOfWeek? dayOfWeek,
  }) {
    final periodData = createRealisticPeriodSlotData(
      groupId: groupId,
      week: week,
      dayOfWeek: dayOfWeek,
      periodType: PeriodType.morning,
      timeStrings: ['07:00', '07:30', '08:00'],
      slotCount: 1, // One slot but filled to capacity
    );

    // Fill the slot with maximum vehicles
    final fullSlot = createFullScheduleSlot(groupId: groupId);
    return periodData.copyWith(slots: [fullSlot]);
  }

  // Aggregate period factory methods

  /// Create a realistic AggregatePeriod for testing
  static AggregatePeriod createRealisticAggregatePeriod({
    PeriodType? periodType,
    List<String>? timeStrings,
  }) {
    final type = periodType ??
        PeriodType.values[TestDataFactory.randomInt(
          0,
          PeriodType.values.length - 1,
        )];
    final times = timeStrings ?? _generateTimeStringsForPeriod(type);

    return AggregatePeriod.fromTimeStrings(type: type, timeStrings: times);
  }

  /// Create morning AggregatePeriod
  static AggregatePeriod createMorningAggregatePeriod() {
    return AggregatePeriod.fromTimeStrings(
      type: PeriodType.morning,
      timeStrings: const ['07:00', '07:30', '08:00', '08:30'],
    );
  }

  /// Create afternoon AggregatePeriod
  static AggregatePeriod createAfternoonAggregatePeriod() {
    return AggregatePeriod.fromTimeStrings(
      type: PeriodType.afternoon,
      timeStrings: const ['15:00', '15:30', '16:00', '16:30'],
    );
  }

  /// Create evening AggregatePeriod
  static AggregatePeriod createEveningAggregatePeriod() {
    return AggregatePeriod.fromTimeStrings(
      type: PeriodType.evening,
      timeStrings: const ['17:00', '17:30', '18:00'],
    );
  }

  /// Create all-day AggregatePeriod
  static AggregatePeriod createAllDayAggregatePeriod() {
    return AggregatePeriod.fromTimeStrings(
      type: PeriodType.allDay,
      timeStrings: const ['07:00', '08:00', '12:00', '15:00', '17:00', '18:00'],
    );
  }

  // PeriodType helper methods

  /// Get a random PeriodType
  static PeriodType getRandomPeriodType() {
    return PeriodType.values[TestDataFactory.randomInt(
      0,
      PeriodType.values.length - 1,
    )];
  }

  /// Get all PeriodType values for testing
  static List<PeriodType> getAllPeriodTypes() {
    return PeriodType.values;
  }

  // Week identifier factory methods

  /// Get a realistic ISO week identifier for testing
  static String getRealisticWeekId({int? weekOffset}) {
    final now = DateTime.now();
    final offset = weekOffset ?? TestDataFactory.randomInt(-5, 10);

    // Calculate the week number with offset
    final targetDate = now.add(Duration(days: offset * 7));
    final weekNumber = _getIsoWeekNumber(targetDate);

    return '${targetDate.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }

  /// Get a list of realistic week identifiers for testing
  static List<String> getRealisticWeekIds({int count = 5}) {
    final weeks = <String>[];
    for (var i = 0; i < count; i++) {
      weeks.add(
        getRealisticWeekId(weekOffset: i - 2),
      ); // Mix of past, current, future weeks
    }
    return weeks;
  }

  /// Get a specific test week (commonly used in tests)
  static String getTestWeek() => '2025-W41';

  /// Get a list of test weeks spanning multiple months
  static List<String> getTestWeeksForMultipleMonths() {
    return [
      '2025-W40', // Previous week
      '2025-W41', // Current test week
      '2025-W42', // Next week
      '2025-W43', // Future week
    ];
  }

  /// Reset all counters for test isolation
  static void resetCounters() {
    _slotCounter = 0;
    _assignmentCounter = 0;
    _childAssignmentCounter = 0;
  }

  // Private helper methods

  /// Generate appropriate time strings for a given period type
  static List<String> _generateTimeStringsForPeriod(PeriodType periodType) {
    switch (periodType) {
      case PeriodType.morning:
        return ['07:00', '07:30', '08:00', '08:30'];
      case PeriodType.afternoon:
        return ['15:00', '15:30', '16:00', '16:30'];
      case PeriodType.evening:
        return ['17:00', '17:30', '18:00'];
      case PeriodType.allDay:
        return ['07:00', '08:00', '12:00', '15:00', '17:00', '18:00'];
    }
  }

  /// Calculate ISO week number for a given date
  static int _getIsoWeekNumber(DateTime date) {
    // Simple ISO week number calculation
    final firstDayOfYear = DateTime(date.year);
    final daysDifference = date.difference(firstDayOfYear).inDays;
    final weekNumber =
        ((daysDifference + firstDayOfYear.weekday - 1) / 7).floor() + 1;

    // Handle edge cases where the week might be from previous/next year
    if (weekNumber == 0) {
      return _getIsoWeekNumber(DateTime(date.year - 1, 12, 31));
    } else if (weekNumber == 53) {
      return _getIsoWeekNumber(DateTime(date.year + 1));
    }

    return weekNumber;
  }

  static VehicleAssignmentStatus _getVehicleStatus(int index) {
    const statuses = VehicleAssignmentStatus.values;
    return statuses[index % statuses.length];
  }

  static AssignmentStatus _getChildAssignmentStatus(int index) {
    const statuses = AssignmentStatus.values;
    return statuses[index % statuses.length];
  }

  static String _getScheduleStatus(int index) {
    const statuses = ['PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED'];
    return statuses[index % statuses.length];
  }

  static String _generateVehicleName(int index) {
    final brands = [
      'Renault Clio',
      'Peugeot 208',
      'Citroën C3',
      'Volkswagen Golf',
      'Toyota Corolla',
      'Mercedes-Benz Classe A',
      'BMW Série 3',
      'Audi A4',
    ];

    return brands[index % brands.length];
  }

  static String _generateVehicleNotes(int index) {
    const notes = [
      'Siège enfant disponible',
      'Espace bagages limité',
      'Véhicule climatisé',
      'Place handicapé disponible',
      'Animaux acceptés',
      'Non-fumeur uniquement',
    ];

    return notes[index % notes.length];
  }

  static String _generateChildNotes(int index) {
    const notes = [
      'Allergie aux arachides',
      'Besoin d\'un siège rehausseur',
      'À déposer devant l\'école',
      'Préfère s\'asseoir à l\'avant',
      'Peut avoir le mal des transports',
      'Tendance à oublier son sac',
    ];

    return notes[index % notes.length];
  }

  static DateTime _generatePickupTime() {
    final now = DateTime.now();
    final hour = TestDataFactory.randomInt(7, 9);
    final minute = TestDataFactory.randomInt(0, 59);

    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  static DateTime _generateDropoffTime() {
    final now = DateTime.now();
    final hour = TestDataFactory.randomInt(16, 18);
    final minute = TestDataFactory.randomInt(0, 59);

    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}

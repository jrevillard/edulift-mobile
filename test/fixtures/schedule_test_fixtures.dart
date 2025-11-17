import 'dart:convert';

/// Test fixtures for schedule-related data
///
/// This file provides JSON test data that matches the actual structures
/// used by DisplayableTimeSlot and related entities. These fixtures are
/// designed to be realistic, comprehensive, and cover edge cases.
///
/// Example usage:
/// ```dart
/// // Get JSON for a basic DisplayableTimeSlot
/// final basicSlotJson = ScheduleTestFixtures.basicDisplayableSlot;
/// final slot = DisplayableTimeSlot.fromJson(jsonDecode(basicSlotJson));
///
/// // Get conflicting slot fixture
/// final conflictSlotJson = ScheduleTestFixtures.conflictingSlot;
/// final conflictSlot = DisplayableTimeSlot.fromJson(jsonDecode(conflictSlotJson));
/// ```
class ScheduleTestFixtures {
  // ====================================================================
  // DISPLAYABLE TIME SLOT FIXTURES
  // ====================================================================

  /// Basic DisplayableTimeSlot with one vehicle and children
  static const String basicDisplayableSlot = '''
  {
    "dayOfWeek": "monday",
    "timeOfDay": "08:00",
    "week": "2025-W46",
    "scheduleSlot": {
      "id": "slot-monday-0800",
      "groupId": "group-123",
      "dayOfWeek": "monday",
      "timeOfDay": {
        "hour": 8,
        "minute": 0
      },
      "week": "2025-W46",
      "vehicleAssignments": [
        {
          "id": "assignment-vehicle-1",
          "scheduleSlotId": "slot-monday-0800",
          "vehicleId": "vehicle-1",
          "driverId": null,
          "assignedAt": "2025-11-14T10:00:00.000Z",
          "assignedBy": "user-123",
          "isActive": true,
          "seatOverride": null,
          "notes": null,
          "status": "assigned",
          "vehicleName": "Family Car",
          "driverName": null,
          "childAssignments": [
            {
              "id": "child-assignment-1",
              "childId": "child-1",
              "vehicleId": "vehicle-1",
              "assignmentType": "driver",
              "assignedAt": "2025-11-14T10:00:00.000Z",
              "assignedBy": "user-123"
            },
            {
              "id": "child-assignment-2",
              "childId": "child-2",
              "vehicleId": "vehicle-1",
              "assignmentType": "driver",
              "assignedAt": "2025-11-14T10:00:00.000Z",
              "assignedBy": "user-123"
            }
          ],
          "capacity": 5,
          "createdAt": "2025-11-14T10:00:00.000Z",
          "updatedAt": "2025-11-14T10:00:00.000Z"
        }
      ],
      "maxVehicles": 3,
      "createdAt": "2025-11-14T09:00:00.000Z",
      "updatedAt": "2025-11-14T10:00:00.000Z"
    },
    "existsInBackend": true
  }
  ''';

  /// Empty slot (configured but not created in backend)
  static const String emptySlot = '''
  {
    "dayOfWeek": "tuesday",
    "timeOfDay": "15:00",
    "week": "2025-W46",
    "scheduleSlot": null,
    "existsInBackend": false
  }
  ''';

  /// Slot with maximum capacity reached
  static const String fullCapacitySlot = '''
  {
    "dayOfWeek": "wednesday",
    "timeOfDay": "08:00",
    "week": "2025-W46",
    "scheduleSlot": {
      "id": "slot-wednesday-0800",
      "groupId": "group-123",
      "dayOfWeek": "wednesday",
      "timeOfDay": {
        "hour": 8,
        "minute": 0
      },
      "week": "2025-W46",
      "vehicleAssignments": [
        {
          "id": "assignment-vehicle-2",
          "scheduleSlotId": "slot-wednesday-0800",
          "vehicleId": "vehicle-2",
          "driverId": null,
          "assignedAt": "2025-11-14T10:00:00.000Z",
          "assignedBy": "user-123",
          "isActive": true,
          "seatOverride": null,
          "notes": null,
          "status": "assigned",
          "vehicleName": "Minivan",
          "driverName": null,
          "childAssignments": [
            {
              "id": "child-assignment-3",
              "childId": "child-3",
              "vehicleId": "vehicle-2",
              "assignmentType": "driver",
              "assignedAt": "2025-11-14T10:00:00.000Z",
              "assignedBy": "user-123"
            },
            {
              "id": "child-assignment-4",
              "childId": "child-4",
              "vehicleId": "vehicle-2",
              "assignmentType": "driver",
              "assignedAt": "2025-11-14T10:00:00.000Z",
              "assignedBy": "user-123"
            },
            {
              "id": "child-assignment-5",
              "childId": "child-5",
              "vehicleId": "vehicle-2",
              "assignmentType": "driver",
              "assignedAt": "2025-11-14T10:00:00.000Z",
              "assignedBy": "user-123"
            },
            {
              "id": "child-assignment-6",
              "childId": "child-6",
              "vehicleId": "vehicle-2",
              "assignmentType": "driver",
              "assignedAt": "2025-11-14T10:00:00.000Z",
              "assignedBy": "user-123"
            },
            {
              "id": "child-assignment-7",
              "childId": "child-7",
              "vehicleId": "vehicle-2",
              "assignmentType": "driver",
              "assignedAt": "2025-11-14T10:00:00.000Z",
              "assignedBy": "user-123"
            }
          ],
          "capacity": 5,
          "createdAt": "2025-11-14T10:00:00.000Z",
          "updatedAt": "2025-11-14T10:00:00.000Z"
        }
      ],
      "maxVehicles": 3,
      "createdAt": "2025-11-14T09:00:00.000Z",
      "updatedAt": "2025-11-14T10:00:00.000Z"
    },
    "existsInBackend": true
  }
  ''';

  /// Slot with overcapacity conflict
  static const String conflictingSlot = '''
  {
    "dayOfWeek": "thursday",
    "timeOfDay": "08:00",
    "week": "2025-W46",
    "scheduleSlot": {
      "id": "slot-thursday-0800",
      "groupId": "group-123",
      "dayOfWeek": "thursday",
      "timeOfDay": {
        "hour": 8,
        "minute": 0
      },
      "week": "2025-W46",
      "vehicleAssignments": [
        {
          "id": "assignment-vehicle-3",
          "scheduleSlotId": "slot-thursday-0800",
          "vehicleId": "vehicle-3",
          "driverId": null,
          "assignedAt": "2025-11-14T10:00:00.000Z",
          "assignedBy": "user-123",
          "isActive": true,
          "seatOverride": null,
          "notes": null,
          "status": "assigned",
          "vehicleName": "Small Car",
          "driverName": null,
          "childAssignments": [
            {
              "id": "child-assignment-8",
              "childId": "child-8",
              "vehicleId": "vehicle-3",
              "assignmentType": "driver",
              "assignedAt": "2025-11-14T10:00:00.000Z",
              "assignedBy": "user-123"
            },
            {
              "id": "child-assignment-9",
              "childId": "child-9",
              "vehicleId": "vehicle-3",
              "assignmentType": "driver",
              "assignedAt": "2025-11-14T10:00:00.000Z",
              "assignedBy": "user-123"
            },
            {
              "id": "child-assignment-10",
              "childId": "child-10",
              "vehicleId": "vehicle-3",
              "assignmentType": "driver",
              "assignedAt": "2025-11-14T10:00:00.000Z",
              "assignedBy": "user-123"
            },
            {
              "id": "child-assignment-11",
              "childId": "child-11",
              "vehicleId": "vehicle-3",
              "assignmentType": "driver",
              "assignedAt": "2025-11-14T10:00:00.000Z",
              "assignedBy": "user-123"
            }
          ],
          "capacity": 3,
          "createdAt": "2025-11-14T10:00:00.000Z",
          "updatedAt": "2025-11-14T10:00:00.000Z"
        }
      ],
      "maxVehicles": 3,
      "createdAt": "2025-11-14T09:00:00.000Z",
      "updatedAt": "2025-11-14T10:00:00.000Z"
    },
    "existsInBackend": true
  }
  ''';

  /// Slot with multiple vehicles
  static const String multiVehicleSlot = '''
  {
    "dayOfWeek": "friday",
    "timeOfDay": "08:00",
    "week": "2025-W46",
    "scheduleSlot": {
      "id": "slot-friday-0800",
      "groupId": "group-123",
      "dayOfWeek": "friday",
      "timeOfDay": {
        "hour": 8,
        "minute": 0
      },
      "week": "2025-W46",
      "vehicleAssignments": [
        {
          "id": "assignment-vehicle-4",
          "scheduleSlotId": "slot-friday-0800",
          "vehicleId": "vehicle-4",
          "driverId": null,
          "assignedAt": "2025-11-14T10:00:00.000Z",
          "assignedBy": "user-123",
          "isActive": true,
          "seatOverride": null,
          "notes": null,
          "status": "assigned",
          "vehicleName": "SUV",
          "driverName": null,
          "childAssignments": [
            {
              "id": "child-assignment-12",
              "childId": "child-12",
              "vehicleId": "vehicle-4",
              "assignmentType": "driver",
              "assignedAt": "2025-11-14T10:00:00.000Z",
              "assignedBy": "user-123"
            },
            {
              "id": "child-assignment-13",
              "childId": "child-13",
              "vehicleId": "vehicle-4",
              "assignmentType": "driver",
              "assignedAt": "2025-11-14T10:00:00.000Z",
              "assignedBy": "user-123"
            }
          ],
          "capacity": 7,
          "createdAt": "2025-11-14T10:00:00.000Z",
          "updatedAt": "2025-11-14T10:00:00.000Z"
        },
        {
          "id": "assignment-vehicle-5",
          "scheduleSlotId": "slot-friday-0800",
          "vehicleId": "vehicle-5",
          "driverId": null,
          "assignedAt": "2025-11-14T10:00:00.000Z",
          "assignedBy": "user-123",
          "isActive": true,
          "seatOverride": null,
          "notes": null,
          "status": "assigned",
          "vehicleName": "Sedan",
          "driverName": null,
          "childAssignments": [
            {
              "id": "child-assignment-14",
              "childId": "child-14",
              "vehicleId": "vehicle-5",
              "assignmentType": "driver",
              "assignedAt": "2025-11-14T10:00:00.000Z",
              "assignedBy": "user-123"
            }
          ],
          "capacity": 4,
          "createdAt": "2025-11-14T10:00:00.000Z",
          "updatedAt": "2025-11-14T10:00:00.000Z"
        }
      ],
      "maxVehicles": 3,
      "createdAt": "2025-11-14T09:00:00.000Z",
      "updatedAt": "2025-11-14T10:00:00.000Z"
    },
    "existsInBackend": true
  }
  ''';

  /// Slot with seat override
  static const String seatOverrideSlot = '''
  {
    "dayOfWeek": "monday",
    "timeOfDay": "15:00",
    "week": "2025-W46",
    "scheduleSlot": {
      "id": "slot-monday-1500",
      "groupId": "group-123",
      "dayOfWeek": "monday",
      "timeOfDay": {
        "hour": 15,
        "minute": 0
      },
      "week": "2025-W46",
      "vehicleAssignments": [
        {
          "id": "assignment-vehicle-6",
          "scheduleSlotId": "slot-monday-1500",
          "vehicleId": "vehicle-6",
          "driverId": null,
          "assignedAt": "2025-11-14T10:00:00.000Z",
          "assignedBy": "user-123",
          "isActive": true,
          "seatOverride": 6,
          "notes": "Booster seat available",
          "status": "assigned",
          "vehicleName": "Compact Car",
          "driverName": null,
          "childAssignments": [
            {
              "id": "child-assignment-15",
              "childId": "child-15",
              "vehicleId": "vehicle-6",
              "assignmentType": "driver",
              "assignedAt": "2025-11-14T10:00:00.000Z",
              "assignedBy": "user-123"
            },
            {
              "id": "child-assignment-16",
              "childId": "child-16",
              "vehicleId": "vehicle-6",
              "assignmentType": "driver",
              "assignedAt": "2025-11-14T10:00:00.000Z",
              "assignedBy": "user-123"
            },
            {
              "id": "child-assignment-17",
              "childId": "child-17",
              "vehicleId": "vehicle-6",
              "assignmentType": "driver",
              "assignedAt": "2025-11-14T10:00:00.000Z",
              "assignedBy": "user-123"
            }
          ],
          "capacity": 4,
          "createdAt": "2025-11-14T10:00:00.000Z",
          "updatedAt": "2025-11-14T10:00:00.000Z"
        }
      ],
      "maxVehicles": 3,
      "createdAt": "2025-11-14T09:00:00.000Z",
      "updatedAt": "2025-11-14T10:00:00.000Z"
    },
    "existsInBackend": true
  }
  ''';

  // ====================================================================
  // VEHICLE FIXTURES
  // ====================================================================

  /// Basic vehicle fixture
  static const String basicVehicle = '''
  {
    "id": "vehicle-1",
    "name": "Family Car",
    "familyId": "family-123",
    "capacity": 5,
    "description": "Toyota Sienna 2019",
    "createdAt": "2025-01-15T10:00:00.000Z",
    "updatedAt": "2025-11-14T09:00:00.000Z"
  }
  ''';

  /// Large vehicle fixture
  static const String largeVehicle = '''
  {
    "id": "vehicle-2",
    "name": "Minivan",
    "familyId": "family-123",
    "capacity": 8,
    "description": "Honda Odyssey 2021",
    "createdAt": "2025-02-20T14:30:00.000Z",
    "updatedAt": "2025-11-14T09:00:00.000Z"
  }
  ''';

  /// Small vehicle fixture
  static const String smallVehicle = '''
  {
    "id": "vehicle-3",
    "name": "Compact Car",
    "familyId": "family-123",
    "capacity": 4,
    "description": "Honda Civic 2020",
    "createdAt": "2025-03-10T11:15:00.000Z",
    "updatedAt": "2025-11-14T09:00:00.000Z"
  }
  ''';

  // ====================================================================
  // CHILD FIXTURES
  // ====================================================================

  /// Basic child fixture
  static const String basicChild = '''
  {
    "id": "child-1",
    "familyId": "family-123",
    "name": "Emma Johnson",
    "age": 8,
    "createdAt": "2025-01-15T10:00:00.000Z",
    "updatedAt": "2025-11-14T09:00:00.000Z"
  }
  ''';

  /// Teenager child fixture
  static const String teenagerChild = '''
  {
    "id": "child-2",
    "familyId": "family-123",
    "name": "Michael Johnson",
    "age": 14,
    "createdAt": "2025-01-15T10:00:00.000Z",
    "updatedAt": "2025-11-14T09:00:00.000Z"
  }
  ''';

  /// Multiple child fixtures list
  static const String multipleChildren = '''
  [
    {
      "id": "child-1",
      "familyId": "family-123",
      "name": "Emma Johnson",
      "age": 8,
      "createdAt": "2025-01-15T10:00:00.000Z",
      "updatedAt": "2025-11-14T09:00:00.000Z"
    },
    {
      "id": "child-2",
      "familyId": "family-123",
      "name": "Michael Johnson",
      "age": 14,
      "createdAt": "2025-01-15T10:00:00.000Z",
      "updatedAt": "2025-11-14T09:00:00.000Z"
    },
    {
      "id": "child-3",
      "familyId": "family-123",
      "name": "Sophia Johnson",
      "age": 6,
      "createdAt": "2025-01-15T10:00:00.000Z",
      "updatedAt": "2025-11-14T09:00:00.000Z"
    },
    {
      "id": "child-4",
      "familyId": "family-123",
      "name": "Oliver Johnson",
      "age": 10,
      "createdAt": "2025-01-15T10:00:00.000Z",
      "updatedAt": "2025-11-14T09:00:00.000Z"
    },
    {
      "id": "child-5",
      "familyId": "family-123",
      "name": "Ava Johnson",
      "age": 12,
      "createdAt": "2025-01-15T10:00:00.000Z",
      "updatedAt": "2025-11-14T09:00:00.000Z"
    }
  ]
  ''';

  // ====================================================================
  // WEEK SCHEDULE FIXTURES
  // ====================================================================

  /// Complete week schedule with mixed scenarios
  static const String weekSchedule = '''
  [
    {
      "dayOfWeek": "monday",
      "timeOfDay": "08:00",
      "week": "2025-W46",
      "scheduleSlot": {
        "id": "slot-monday-0800",
        "groupId": "group-123",
        "dayOfWeek": "monday",
        "timeOfDay": {"hour": 8, "minute": 0},
        "week": "2025-W46",
        "vehicleAssignments": [
          {
            "id": "assignment-vehicle-1",
            "scheduleSlotId": "slot-monday-0800",
            "vehicleId": "vehicle-1",
            "driverId": null,
            "assignedAt": "2025-11-14T10:00:00.000Z",
            "assignedBy": "user-123",
            "isActive": true,
            "seatOverride": null,
            "notes": null,
            "status": "assigned",
            "vehicleName": "Family Car",
            "driverName": null,
            "childAssignments": [
              {
                "id": "child-assignment-1",
                "childId": "child-1",
                "vehicleId": "vehicle-1",
                "assignmentType": "driver",
                "assignedAt": "2025-11-14T10:00:00.000Z",
                "assignedBy": "user-123"
              },
              {
                "id": "child-assignment-2",
                "childId": "child-2",
                "vehicleId": "vehicle-1",
                "assignmentType": "driver",
                "assignedAt": "2025-11-14T10:00:00.000Z",
                "assignedBy": "user-123"
              }
            ],
            "capacity": 5,
            "createdAt": "2025-11-14T10:00:00.000Z",
            "updatedAt": "2025-11-14T10:00:00.000Z"
          }
        ],
        "maxVehicles": 3,
        "createdAt": "2025-11-14T09:00:00.000Z",
        "updatedAt": "2025-11-14T10:00:00.000Z"
      },
      "existsInBackend": true
    },
    {
      "dayOfWeek": "monday",
      "timeOfDay": "15:00",
      "week": "2025-W46",
      "scheduleSlot": null,
      "existsInBackend": false
    },
    {
      "dayOfWeek": "tuesday",
      "timeOfDay": "08:00",
      "week": "2025-W46",
      "scheduleSlot": {
        "id": "slot-tuesday-0800",
        "groupId": "group-123",
        "dayOfWeek": "tuesday",
        "timeOfDay": {"hour": 8, "minute": 0},
        "week": "2025-W46",
        "vehicleAssignments": [
          {
            "id": "assignment-vehicle-2",
            "scheduleSlotId": "slot-tuesday-0800",
            "vehicleId": "vehicle-2",
            "driverId": null,
            "assignedAt": "2025-11-14T10:00:00.000Z",
            "assignedBy": "user-123",
            "isActive": true,
            "seatOverride": null,
            "notes": null,
            "status": "assigned",
            "vehicleName": "Minivan",
            "driverName": null,
            "childAssignments": [
              {
                "id": "child-assignment-3",
                "childId": "child-3",
                "vehicleId": "vehicle-2",
                "assignmentType": "driver",
                "assignedAt": "2025-11-14T10:00:00.000Z",
                "assignedBy": "user-123"
              },
              {
                "id": "child-assignment-4",
                "childId": "child-4",
                "vehicleId": "vehicle-2",
                "assignmentType": "driver",
                "assignedAt": "2025-11-14T10:00:00.000Z",
                "assignedBy": "user-123"
              },
              {
                "id": "child-assignment-5",
                "childId": "child-5",
                "vehicleId": "vehicle-2",
                "assignmentType": "driver",
                "assignedAt": "2025-11-14T10:00:00.000Z",
                "assignedBy": "user-123"
              },
              {
                "id": "child-assignment-6",
                "childId": "child-6",
                "vehicleId": "vehicle-2",
                "assignmentType": "driver",
                "assignedAt": "2025-11-14T10:00:00.000Z",
                "assignedBy": "user-123"
              },
              {
                "id": "child-assignment-7",
                "childId": "child-7",
                "vehicleId": "vehicle-2",
                "assignmentType": "driver",
                "assignedAt": "2025-11-14T10:00:00.000Z",
                "assignedBy": "user-123"
              }
            ],
            "capacity": 5,
            "createdAt": "2025-11-14T10:00:00.000Z",
            "updatedAt": "2025-11-14T10:00:00.000Z"
          }
        ],
        "maxVehicles": 3,
        "createdAt": "2025-11-14T09:00:00.000Z",
        "updatedAt": "2025-11-14T10:00:00.000Z"
      },
      "existsInBackend": true
    },
    {
      "dayOfWeek": "tuesday",
      "timeOfDay": "15:00",
      "week": "2025-W46",
      "scheduleSlot": null,
      "existsInBackend": false
    },
    {
      "dayOfWeek": "wednesday",
      "timeOfDay": "08:00",
      "week": "2025-W46",
      "scheduleSlot": {
        "id": "slot-wednesday-0800",
        "groupId": "group-123",
        "dayOfWeek": "wednesday",
        "timeOfDay": {"hour": 8, "minute": 0},
        "week": "2025-W46",
        "vehicleAssignments": [
          {
            "id": "assignment-vehicle-3",
            "scheduleSlotId": "slot-wednesday-0800",
            "vehicleId": "vehicle-3",
            "driverId": null,
            "assignedAt": "2025-11-14T10:00:00.000Z",
            "assignedBy": "user-123",
            "isActive": true,
            "seatOverride": null,
            "notes": null,
            "status": "assigned",
            "vehicleName": "Small Car",
            "driverName": null,
            "childAssignments": [
              {
                "id": "child-assignment-8",
                "childId": "child-8",
                "vehicleId": "vehicle-3",
                "assignmentType": "driver",
                "assignedAt": "2025-11-14T10:00:00.000Z",
                "assignedBy": "user-123"
              },
              {
                "id": "child-assignment-9",
                "childId": "child-9",
                "vehicleId": "vehicle-3",
                "assignmentType": "driver",
                "assignedAt": "2025-11-14T10:00:00.000Z",
                "assignedBy": "user-123"
              },
              {
                "id": "child-assignment-10",
                "childId": "child-10",
                "vehicleId": "vehicle-3",
                "assignmentType": "driver",
                "assignedAt": "2025-11-14T10:00:00.000Z",
                "assignedBy": "user-123"
              },
              {
                "id": "child-assignment-11",
                "childId": "child-11",
                "vehicleId": "vehicle-3",
                "assignmentType": "driver",
                "assignedAt": "2025-11-14T10:00:00.000Z",
                "assignedBy": "user-123"
              }
            ],
            "capacity": 3,
            "createdAt": "2025-11-14T10:00:00.000Z",
            "updatedAt": "2025-11-14T10:00:00.000Z"
          }
        ],
        "maxVehicles": 3,
        "createdAt": "2025-11-14T09:00:00.000Z",
        "updatedAt": "2025-11-14T10:00:00.000Z"
      },
      "existsInBackend": true
    },
    {
      "dayOfWeek": "wednesday",
      "timeOfDay": "15:00",
      "week": "2025-W46",
      "scheduleSlot": null,
      "existsInBackend": false
    },
    {
      "dayOfWeek": "thursday",
      "timeOfDay": "08:00",
      "week": "2025-W46",
      "scheduleSlot": {
        "id": "slot-thursday-0800",
        "groupId": "group-123",
        "dayOfWeek": "thursday",
        "timeOfDay": {"hour": 8, "minute": 0},
        "week": "2025-W46",
        "vehicleAssignments": [],
        "maxVehicles": 3,
        "createdAt": "2025-11-14T09:00:00.000Z",
        "updatedAt": "2025-11-14T09:00:00.000Z"
      },
      "existsInBackend": true
    },
    {
      "dayOfWeek": "thursday",
      "timeOfDay": "15:00",
      "week": "2025-W46",
      "scheduleSlot": null,
      "existsInBackend": false
    },
    {
      "dayOfWeek": "friday",
      "timeOfDay": "08:00",
      "week": "2025-W46",
      "scheduleSlot": {
        "id": "slot-friday-0800",
        "groupId": "group-123",
        "dayOfWeek": "friday",
        "timeOfDay": {"hour": 8, "minute": 0},
        "week": "2025-W46",
        "vehicleAssignments": [
          {
            "id": "assignment-vehicle-4",
            "scheduleSlotId": "slot-friday-0800",
            "vehicleId": "vehicle-4",
            "driverId": null,
            "assignedAt": "2025-11-14T10:00:00.000Z",
            "assignedBy": "user-123",
            "isActive": true,
            "seatOverride": null,
            "notes": null,
            "status": "assigned",
            "vehicleName": "SUV",
            "driverName": null,
            "childAssignments": [
              {
                "id": "child-assignment-12",
                "childId": "child-12",
                "vehicleId": "vehicle-4",
                "assignmentType": "driver",
                "assignedAt": "2025-11-14T10:00:00.000Z",
                "assignedBy": "user-123"
              }
            ],
            "capacity": 7,
            "createdAt": "2025-11-14T10:00:00.000Z",
            "updatedAt": "2025-11-14T10:00:00.000Z"
          },
          {
            "id": "assignment-vehicle-5",
            "scheduleSlotId": "slot-friday-0800",
            "vehicleId": "vehicle-5",
            "driverId": null,
            "assignedAt": "2025-11-14T10:00:00.000Z",
            "assignedBy": "user-123",
            "isActive": true,
            "seatOverride": null,
            "notes": null,
            "status": "assigned",
            "vehicleName": "Sedan",
            "driverName": null,
            "childAssignments": [],
            "capacity": 4,
            "createdAt": "2025-11-14T10:00:00.000Z",
            "updatedAt": "2025-11-14T10:00:00.000Z"
          }
        ],
        "maxVehicles": 3,
        "createdAt": "2025-11-14T09:00:00.000Z",
        "updatedAt": "2025-11-14T10:00:00.000Z"
      },
      "existsInBackend": true
    },
    {
      "dayOfWeek": "friday",
      "timeOfDay": "15:00",
      "week": "2025-W46",
      "scheduleSlot": null,
      "existsInBackend": false
    }
  ]
  ''';

  // ====================================================================
  // CONFLICT SCENARIO FIXTURES
  // ====================================================================

  /// Slot with empty vehicle (vehicle assigned but no children)
  static const String emptyVehicleSlot = '''
  {
    "dayOfWeek": "monday",
    "timeOfDay": "09:00",
    "week": "2025-W46",
    "scheduleSlot": {
      "id": "slot-monday-0900",
      "groupId": "group-123",
      "dayOfWeek": "monday",
      "timeOfDay": {
        "hour": 9,
        "minute": 0
      },
      "week": "2025-W46",
      "vehicleAssignments": [
        {
          "id": "assignment-vehicle-empty",
          "scheduleSlotId": "slot-monday-0900",
          "vehicleId": "vehicle-empty",
          "driverId": null,
          "assignedAt": "2025-11-14T10:00:00.000Z",
          "assignedBy": "user-123",
          "isActive": true,
          "seatOverride": null,
          "notes": null,
          "status": "assigned",
          "vehicleName": "Empty Van",
          "driverName": null,
          "childAssignments": [],
          "capacity": 8,
          "createdAt": "2025-11-14T10:00:00.000Z",
          "updatedAt": "2025-11-14T10:00:00.000Z"
        }
      ],
      "maxVehicles": 3,
      "createdAt": "2025-11-14T09:00:00.000Z",
      "updatedAt": "2025-11-14T10:00:00.000Z"
    },
    "existsInBackend": true
  }
  ''';

  // ====================================================================
  // UTILITY METHODS
  // ====================================================================

  /// Parse JSON string to Map<String, dynamic>
  static Map<String, dynamic> parseJson(String jsonString) {
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Parse JSON string to List<Map<String, dynamic>>
  static List<Map<String, dynamic>> parseJsonList(String jsonString) {
    final decoded = jsonDecode(jsonString);
    return (decoded as List).cast<Map<String, dynamic>>();
  }

  /// Get all available fixture names and descriptions
  static Map<String, String> get availableFixtures => {
    'basicDisplayableSlot': 'Basic slot with one vehicle and children',
    'emptySlot': 'Empty slot (configured but not created)',
    'fullCapacitySlot': 'Slot at maximum capacity',
    'conflictingSlot': 'Slot with overcapacity conflict',
    'multiVehicleSlot': 'Slot with multiple vehicles',
    'seatOverrideSlot': 'Slot with seat override',
    'basicVehicle': 'Standard 5-seat vehicle',
    'largeVehicle': 'Large 8-seat vehicle',
    'smallVehicle': 'Small 4-seat vehicle',
    'basicChild': '8-year-old child',
    'teenagerChild': '14-year-old teenager',
    'multipleChildren': 'List of 5 children of different ages',
    'weekSchedule': 'Complete week with mixed scenarios',
    'emptyVehicleSlot': 'Vehicle assigned but no children',
  };

  /// Get fixtures by category
  static Map<String, List<String>> get fixturesByCategory => {
    'slots': [
      'basicDisplayableSlot',
      'emptySlot',
      'fullCapacitySlot',
      'conflictingSlot',
      'multiVehicleSlot',
      'seatOverrideSlot',
      'emptyVehicleSlot',
    ],
    'vehicles': ['basicVehicle', 'largeVehicle', 'smallVehicle'],
    'children': ['basicChild', 'teenagerChild', 'multipleChildren'],
    'schedules': ['weekSchedule'],
  };

  /// Get fixture for specific capacity scenario
  static String getCapacityFixture(String scenario) {
    switch (scenario.toLowerCase()) {
      case 'empty':
        return basicDisplayableSlot; // Can be modified to have no vehicles
      case 'available':
        return basicDisplayableSlot;
      case 'limited':
        return fullCapacitySlot; // Can be modified to have 80% capacity
      case 'full':
        return fullCapacitySlot;
      case 'overcapacity':
        return conflictingSlot;
      default:
        throw ArgumentError('Unknown capacity scenario: $scenario');
    }
  }

  /// Get fixture for specific conflict type
  static String getConflictFixture(String conflictType) {
    switch (conflictType.toLowerCase()) {
      case 'overcapacity':
        return conflictingSlot;
      case 'empty_vehicle':
        return emptyVehicleSlot;
      case 'missing_driver':
        return basicDisplayableSlot; // Driver conflicts are disabled
      case 'double_booking':
        return multiVehicleSlot; // Can be modified to show double booking
      default:
        throw ArgumentError('Unknown conflict type: $conflictType');
    }
  }
}

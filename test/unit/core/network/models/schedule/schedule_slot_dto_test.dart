import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:edulift/core/network/models/schedule/schedule_slot_dto.dart';
import 'package:edulift/core/network/models/schedule/vehicle_assignment_dto.dart';
import 'package:edulift/core/domain/entities/schedule/day_of_week.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';

void main() {
  // Initialize timezone database for tests
  setUpAll(() {
    tz.initializeTimeZones();
  });
  group('ScheduleSlotDto', () {
    group('JSON Deserialization', () {
      test('should deserialize from API response with datetime field', () {
        // This is the NEW API format from backend
        final json = {
          'id': 'cmgo1nrje000xozw6r96szv1g',
          'groupId': 'test-group-123',
          'datetime':
              '2025-10-14T05:30:00.000Z', // Tuesday at 5:30 UTC (07:30 local)
          'createdAt': '2025-10-12T10:00:00.000Z',
          'updatedAt': '2025-10-12T12:00:00.000Z',
          'vehicleAssignments': [],
        };

        final dto = ScheduleSlotDto.fromJson(json);

        expect(dto.id, 'cmgo1nrje000xozw6r96szv1g');
        expect(dto.groupId, 'test-group-123');
        expect(dto.datetime, DateTime.parse('2025-10-14T05:30:00.000Z'));
        expect(dto.createdAt, DateTime.parse('2025-10-12T10:00:00.000Z'));
        expect(dto.updatedAt, DateTime.parse('2025-10-12T12:00:00.000Z'));
        expect(dto.vehicleAssignments, isEmpty);
      });

      test('should deserialize with vehicle assignments', () {
        // ACTUAL backend API format - no driver field, no driverId
        final json = {
          'id': 'slot-1',
          'groupId': 'group-1',
          'datetime': '2025-10-14T07:30:00.000Z',
          'vehicleAssignments': [
            {
              'id': 'va-1',
              'seatOverride': null,
              'vehicle': {
                'id': 'vehicle-1',
                'name': 'Test Vehicle',
                'capacity': 5,
              },
            },
          ],
        };

        final dto = ScheduleSlotDto.fromJson(json);

        expect(dto.vehicleAssignments, hasLength(1));
        expect(dto.vehicleAssignments![0].id, 'va-1');
        expect(dto.vehicleAssignments![0].vehicle.name, 'Test Vehicle');
      });

      test('should handle missing optional fields', () {
        final json = {
          'id': 'slot-1',
          'groupId': 'group-1',
          'datetime': '2025-10-14T07:30:00.000Z',
        };

        final dto = ScheduleSlotDto.fromJson(json);

        expect(dto.id, 'slot-1');
        expect(dto.groupId, 'group-1');
        expect(dto.datetime, DateTime.parse('2025-10-14T07:30:00.000Z'));
        expect(dto.createdAt, isNull);
        expect(dto.updatedAt, isNull);
        expect(dto.vehicleAssignments, isNull);
      });

      test(
        'CRITICAL FIX: should handle vehicle assignments WITHOUT scheduleSlotId (nested response)',
        () {
          // This is the ACTUAL backend response format when vehicleAssignments are nested in ScheduleSlot
          // The scheduleSlotId field is NOT sent because it's redundant (already in parent)
          final json = {
            'id': 'cmgo5u4530019ozw6jhns2e1k',
            'groupId': 'cmfo27ec3000gv2unmp3729r5',
            'datetime': '2025-10-14T05:30:00.000Z',
            'vehicleAssignments': [
              {
                'id': 'cmgpaxcla000zs976lxow15ec',
                'vehicle': {
                  'id': 'cmgkkuhb40005ozw6puvidjo0',
                  'name': 'Alfa',
                  'capacity': 3,
                },
                'seatOverride': 4,
                // NOTE: scheduleSlotId is ABSENT in nested responses (not null, absent!)
              },
              {
                'id': 'cmgo5u45z001cozw6zdb39ol4',
                'vehicle': {
                  'id': 'cmgkkts4v0001ozw6jsi74c2i',
                  'name': 'MG4',
                  'capacity': 5,
                },
                'seatOverride': null,
                // NOTE: scheduleSlotId is ABSENT in nested responses
              },
            ],
            'childAssignments': [],
            'totalCapacity': 9,
            'availableSeats': 9,
            'createdAt': '2025-10-12T20:31:58.839Z',
            'updatedAt': '2025-10-12T20:31:58.839Z',
          };

          // This should NOT throw a null cast error anymore
          final dto = ScheduleSlotDto.fromJson(json);

          expect(dto.id, 'cmgo5u4530019ozw6jhns2e1k');
          expect(dto.groupId, 'cmfo27ec3000gv2unmp3729r5');
          expect(dto.vehicleAssignments, hasLength(2));

          // First vehicle assignment
          expect(dto.vehicleAssignments![0].id, 'cmgpaxcla000zs976lxow15ec');
          expect(
            dto.vehicleAssignments![0].scheduleSlotId,
            isNull,
          ); // Should be null, not cause error
          expect(dto.vehicleAssignments![0].vehicle.name, 'Alfa');
          expect(dto.vehicleAssignments![0].vehicle.capacity, 3);
          expect(dto.vehicleAssignments![0].seatOverride, 4);

          // Second vehicle assignment
          expect(dto.vehicleAssignments![1].id, 'cmgo5u45z001cozw6zdb39ol4');
          expect(
            dto.vehicleAssignments![1].scheduleSlotId,
            isNull,
          ); // Should be null, not cause error
          expect(dto.vehicleAssignments![1].vehicle.name, 'MG4');
          expect(dto.vehicleAssignments![1].vehicle.capacity, 5);
          expect(dto.vehicleAssignments![1].seatOverride, isNull);

          // Verify toDomain() handles null scheduleSlotId correctly AND injects parent ID
          final domain = dto.toDomain();
          expect(domain.vehicleAssignments, hasLength(2));
          // CRITICAL: Parent ScheduleSlot MUST inject its ID into nested vehicle assignments
          expect(
            domain.vehicleAssignments[0].scheduleSlotId,
            'cmgo5u4530019ozw6jhns2e1k',
          ); // Injected from parent
          expect(
            domain.vehicleAssignments[1].scheduleSlotId,
            'cmgo5u4530019ozw6jhns2e1k',
          ); // Injected from parent
          expect(domain.vehicleAssignments[0].vehicleName, 'Alfa');
          expect(domain.vehicleAssignments[1].vehicleName, 'MG4');
        },
      );
    });

    group('JSON Serialization', () {
      test('should serialize to JSON with datetime field', () {
        final dto = ScheduleSlotDto(
          id: 'slot-1',
          groupId: 'group-1',
          datetime: DateTime.parse('2025-10-14T07:30:00.000Z'),
          createdAt: DateTime.parse('2025-10-12T10:00:00.000Z'),
          updatedAt: DateTime.parse('2025-10-12T12:00:00.000Z'),
        );

        final json = dto.toJson();

        expect(json['id'], 'slot-1');
        expect(json['groupId'], 'group-1');
        expect(json['datetime'], '2025-10-14T07:30:00.000Z');
        expect(json['createdAt'], '2025-10-12T10:00:00.000Z');
        expect(json['updatedAt'], '2025-10-12T12:00:00.000Z');
      });
    });

    group('Domain Conversion', () {
      test(
        'should convert DTO to domain model with correct day/time/week extraction',
        () {
          // Tuesday, October 14, 2025 at 07:30 UTC
          // API sends UTC, DTO now keeps UTC to prevent orphaned slot false positives
          // ScheduleConfig contains UTC times, so we must compare UTC vs UTC
          final utcDateTime = DateTime.utc(2025, 10, 14, 7, 30);

          final dto = ScheduleSlotDto(
            id: 'slot-1',
            groupId: 'group-1',
            datetime: utcDateTime, // API format: UTC
            vehicleAssignments: [],
          );

          final domain = dto.toDomain();

          expect(domain.id, 'slot-1');
          expect(domain.groupId, 'group-1');
          expect(domain.dayOfWeek, DayOfWeek.fromWeekday(utcDateTime.weekday));
          expect(
            domain.timeOfDay,
            TimeOfDayValue(utcDateTime.hour, utcDateTime.minute),
          );
          expect(domain.week, '2025-W42'); // ISO week for Oct 14, 2025
          expect(domain.vehicleAssignments, isEmpty);
        },
      );

      test('should handle different days of week correctly', () {
        // API sends UTC, DTO now keeps UTC to prevent orphaned slot false positives
        // We compare UTC vs UTC to match scheduleConfig format
        final testCases = [
          (DateTime.utc(2025, 10, 13, 8), '2025-W42'), // Monday Oct 13
          (DateTime.utc(2025, 10, 14, 8), '2025-W42'), // Tuesday Oct 14
          (DateTime.utc(2025, 10, 15, 8), '2025-W42'), // Wednesday Oct 15
          (DateTime.utc(2025, 10, 16, 8), '2025-W42'), // Thursday Oct 16
          (DateTime.utc(2025, 10, 17, 8), '2025-W42'), // Friday Oct 17
        ];

        for (final (utcDatetime, expectedWeek) in testCases) {
          final expectedDay = DayOfWeek.fromWeekday(utcDatetime.weekday);

          final dto = ScheduleSlotDto(
            id: 'slot-1',
            groupId: 'group-1',
            datetime: utcDatetime,
          );

          final domain = dto.toDomain();

          expect(
            domain.dayOfWeek,
            expectedDay,
            reason: 'Failed for $utcDatetime (expected $expectedDay)',
          );
          expect(
            domain.week,
            expectedWeek,
            reason: 'Failed for $utcDatetime (expected $expectedWeek)',
          );
        }
      });

      test('should handle different times of day correctly', () {
        // API sends UTC, DTO now keeps UTC to prevent orphaned slot false positives
        // We compare UTC vs UTC to match scheduleConfig format
        final testCases = [
          DateTime.utc(2025, 10, 14, 7),
          DateTime.utc(2025, 10, 14, 7, 30),
          DateTime.utc(2025, 10, 14, 12),
          DateTime.utc(2025, 10, 14, 17, 30),
        ];

        for (final utcDatetime in testCases) {
          final expectedTime = TimeOfDayValue(
            utcDatetime.hour,
            utcDatetime.minute,
          );

          final dto = ScheduleSlotDto(
            id: 'slot-1',
            groupId: 'group-1',
            datetime: utcDatetime,
          );

          final domain = dto.toDomain();

          expect(
            domain.timeOfDay,
            expectedTime,
            reason: 'Failed for $utcDatetime',
          );
        }
      });

      test('should use proper ISO 8601 week calculation', () {
        // Test week boundary cases
        final testCases = [
          // Year start cases
          (DateTime.utc(2025, 1, 6, 8), '2025-W02'), // First full week of 2025
          (
            DateTime.utc(2024, 12, 30, 8),
            '2025-W01',
          ), // Dec 30, 2024 is in week 1 of 2025
          // Mid-year cases
          (DateTime.utc(2025, 6, 2, 8), '2025-W23'),
          (DateTime.utc(2025, 10, 14, 8), '2025-W42'),
        ];

        for (final (datetime, expectedWeek) in testCases) {
          final dto = ScheduleSlotDto(
            id: 'slot-1',
            groupId: 'group-1',
            datetime: datetime,
          );

          final domain = dto.toDomain();

          expect(
            domain.week,
            expectedWeek,
            reason: 'Failed ISO week calculation for $datetime',
          );
        }
      });

      test('should convert vehicle assignments to domain', () {
        final dto = ScheduleSlotDto(
          id: 'slot-1',
          groupId: 'group-1',
          datetime: DateTime.utc(2025, 10, 14, 7, 30),
          vehicleAssignments: [
            const VehicleAssignmentDto(
              id: 'va-1',
              scheduleSlotId: 'slot-1',
              vehicle: VehicleNestedDto(
                id: 'vehicle-1',
                name: 'Test Vehicle',
                capacity: 5,
              ),
            ),
          ],
        );

        final domain = dto.toDomain();

        expect(domain.vehicleAssignments, hasLength(1));
        expect(domain.vehicleAssignments[0].id, 'va-1');
        expect(domain.vehicleAssignments[0].vehicleName, 'Test Vehicle');
      });

      test(
        'CRITICAL FIX: should distribute flat childAssignments into VehicleAssignments',
        () {
          // This tests the fix for the critical UI bug where children weren't displayed
          // Backend sends flat childAssignments list at ScheduleSlot level
          // We need to distribute them into the correct VehicleAssignment.childAssignments
          final json = {
            'id': 'slot-1',
            'groupId': 'group-1',
            'datetime': '2025-10-14T07:30:00.000Z',
            'vehicleAssignments': [
              {
                'id': 'va-1',
                'vehicle': {
                  'id': 'vehicle-1',
                  'name': 'Vehicle A',
                  'capacity': 5,
                },
              },
              {
                'id': 'va-2',
                'vehicle': {
                  'id': 'vehicle-2',
                  'name': 'Vehicle B',
                  'capacity': 3,
                },
              },
            ],
            'childAssignments': [
              {
                'vehicleAssignmentId': 'va-1',
                'child': {
                  'id': 'child-1',
                  'name': 'Emmie',
                  'familyId': 'family-1',
                },
              },
              {
                'vehicleAssignmentId': 'va-1',
                'child': {
                  'id': 'child-2',
                  'name': 'Alex',
                  'familyId': 'family-1',
                },
              },
              {
                'vehicleAssignmentId': 'va-2',
                'child': {
                  'id': 'child-3',
                  'name': 'Sam',
                  'familyId': 'family-2',
                },
              },
            ],
          };

          final dto = ScheduleSlotDto.fromJson(json);
          final domain = dto.toDomain();

          // Verify vehicle assignments
          expect(domain.vehicleAssignments, hasLength(2));

          // Verify first vehicle has 2 children
          final vehicle1 = domain.vehicleAssignments[0];
          expect(vehicle1.id, 'va-1');
          expect(vehicle1.vehicleName, 'Vehicle A');
          expect(vehicle1.childAssignments, hasLength(2));
          expect(vehicle1.childAssignments[0].childName, 'Emmie');
          expect(vehicle1.childAssignments[0].vehicleAssignmentId, 'va-1');
          expect(vehicle1.childAssignments[1].childName, 'Alex');
          expect(vehicle1.childAssignments[1].vehicleAssignmentId, 'va-1');

          // Verify second vehicle has 1 child
          final vehicle2 = domain.vehicleAssignments[1];
          expect(vehicle2.id, 'va-2');
          expect(vehicle2.vehicleName, 'Vehicle B');
          expect(vehicle2.childAssignments, hasLength(1));
          expect(vehicle2.childAssignments[0].childName, 'Sam');
          expect(vehicle2.childAssignments[0].vehicleAssignmentId, 'va-2');

          // Verify scheduleSlotId was injected into child assignments
          expect(vehicle1.childAssignments[0].scheduleSlotId, 'slot-1');
          expect(vehicle2.childAssignments[0].scheduleSlotId, 'slot-1');
        },
      );

      test('should handle vehicle assignments with no children', () {
        final json = {
          'id': 'slot-1',
          'groupId': 'group-1',
          'datetime': '2025-10-14T07:30:00.000Z',
          'vehicleAssignments': [
            {
              'id': 'va-1',
              'vehicle': {
                'id': 'vehicle-1',
                'name': 'Empty Vehicle',
                'capacity': 5,
              },
            },
          ],
          'childAssignments': [],
        };

        final dto = ScheduleSlotDto.fromJson(json);
        final domain = dto.toDomain();

        expect(domain.vehicleAssignments, hasLength(1));
        expect(domain.vehicleAssignments[0].childAssignments, isEmpty);
      });
    });

    group('Round-trip Conversion', () {
      test('should convert domain to DTO and back', () {
        final originalDto = ScheduleSlotDto(
          id: 'slot-1',
          groupId: 'group-1',
          datetime: DateTime.utc(2025, 10, 14, 7, 30),
          createdAt: DateTime.utc(2025, 10, 12, 10),
          updatedAt: DateTime.utc(2025, 10, 12, 12),
        );

        final domain = originalDto.toDomain();
        final convertedDto = ScheduleSlotDto.fromDomain(domain);

        // After conversion to domain (which now keeps UTC) and back to DTO,
        // we should compare with the original UTC version
        expect(convertedDto.id, originalDto.id);
        expect(convertedDto.groupId, originalDto.groupId);
        // DateTime should match exactly since we keep UTC throughout
        expect(convertedDto.datetime.weekday, originalDto.datetime.weekday);
        expect(convertedDto.datetime.hour, originalDto.datetime.hour);
        expect(convertedDto.datetime.minute, originalDto.datetime.minute);
      });
    });

    group('Edge Cases', () {
      test('should handle midnight correctly', () {
        final utcDatetime = DateTime.utc(2025, 10, 14);

        final dto = ScheduleSlotDto(
          id: 'slot-1',
          groupId: 'group-1',
          datetime: utcDatetime,
        );

        final domain = dto.toDomain();

        expect(
          domain.timeOfDay,
          TimeOfDayValue(utcDatetime.hour, utcDatetime.minute),
        );
      });

      test('should handle end of day correctly', () {
        final utcDatetime = DateTime.utc(2025, 10, 14, 23, 59);

        final dto = ScheduleSlotDto(
          id: 'slot-1',
          groupId: 'group-1',
          datetime: utcDatetime,
        );

        final domain = dto.toDomain();

        expect(
          domain.timeOfDay,
          TimeOfDayValue(utcDatetime.hour, utcDatetime.minute),
        );
      });

      test('should handle year boundary correctly', () {
        // Dec 31, 2024 might be in week 1 of 2025
        final dto = ScheduleSlotDto(
          id: 'slot-1',
          groupId: 'group-1',
          datetime: DateTime.utc(2024, 12, 31, 8),
        );

        final domain = dto.toDomain();

        expect(domain.dayOfWeek, DayOfWeek.tuesday);
        // Week should be calculated correctly per ISO 8601
        expect(domain.week.startsWith('2025-W'), isTrue);
      });
    });
  });
}

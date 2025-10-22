import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/network/models/family/schedule_slot_child_dto.dart';

void main() {
  group('ScheduleSlotChildDto', () {
    group('JSON Deserialization - Backend Response Formats', () {
      test(
        'CRITICAL: should handle simplified GET /schedule response (only vehicleAssignmentId + nested child)',
        () {
          // This is the ACTUAL backend response from GET /schedule endpoint
          // Example from error log: scheduleSlots[0].childAssignments[0]
          final json = {
            'vehicleAssignmentId': 'cmgv17fia000u7t9ha4gzfhsl',
            'child': {'id': 'cmgoum8zc001pozw6w9jxd014', 'name': 'Emmie'},
            // NOTE: scheduleSlotId, childId, assignedAt are ABSENT (not null, missing!)
          };

          // This should NOT throw a null cast error
          final dto = ScheduleSlotChildDto.fromJson(json);

          // Verify DTO fields
          expect(dto.vehicleAssignmentId, 'cmgv17fia000u7t9ha4gzfhsl');
          expect(dto.child?.id, 'cmgoum8zc001pozw6w9jxd014');
          expect(dto.child?.name, 'Emmie');
          expect(dto.scheduleSlotId, isNull); // Should be null, not error
          expect(dto.childId, isNull); // Should be null, not error
          expect(dto.assignedAt, isNull); // Should be null, not error
        },
      );

      test(
        'CRITICAL: toDomain() should handle missing fields with fallback values',
        () {
          final json = {
            'vehicleAssignmentId': 'cmgv17fia000u7t9ha4gzfhsl',
            'child': {'id': 'cmgoum8zc001pozw6w9jxd014', 'name': 'Emmie'},
          };

          final dto = ScheduleSlotChildDto.fromJson(json);
          final domain = dto.toDomain();

          // Verify domain entity
          expect(
            domain.childId,
            'cmgoum8zc001pozw6w9jxd014',
          ); // Extracted from child.id
          expect(domain.vehicleAssignmentId, 'cmgv17fia000u7t9ha4gzfhsl');
          expect(domain.assignmentType, 'transportation');
          expect(domain.childName, 'Emmie');
          expect(
            domain.scheduleSlotId,
            '',
          ); // Fallback to empty (will be injected by parent)
          expect(domain.createdAt, isNotNull); // Fallback to DateTime.now()
          expect(
            domain.id,
            startsWith('_cmgoum8zc001pozw6w9jxd014'),
          ); // Composite ID
        },
      );

      test(
        'should handle detailed POST /children response (all fields present)',
        () {
          final json = {
            'scheduleSlotId': 'cmgo1ji9x000sozw6a2zxkkpn',
            'childId': 'cmgoum8zc001pozw6w9jxd014',
            'vehicleAssignmentId': 'cmgv17fia000u7t9ha4gzfhsl',
            'assignedAt': '2025-10-15T08:30:00.000Z',
            'child': {
              'id': 'cmgoum8zc001pozw6w9jxd014',
              'name': 'Emmie',
              'familyId': 'family-123',
            },
          };

          final dto = ScheduleSlotChildDto.fromJson(json);

          expect(dto.scheduleSlotId, 'cmgo1ji9x000sozw6a2zxkkpn');
          expect(dto.childId, 'cmgoum8zc001pozw6w9jxd014');
          expect(dto.vehicleAssignmentId, 'cmgv17fia000u7t9ha4gzfhsl');
          expect(dto.assignedAt, DateTime.parse('2025-10-15T08:30:00.000Z'));
          expect(dto.child?.id, 'cmgoum8zc001pozw6w9jxd014');
          expect(dto.child?.name, 'Emmie');
          expect(dto.child?.familyId, 'family-123');
        },
      );

      test('toDomain() should use provided fields when available', () {
        final json = {
          'scheduleSlotId': 'cmgo1ji9x000sozw6a2zxkkpn',
          'childId': 'cmgoum8zc001pozw6w9jxd014',
          'vehicleAssignmentId': 'cmgv17fia000u7t9ha4gzfhsl',
          'assignedAt': '2025-10-15T08:30:00.000Z',
          'child': {
            'id': 'cmgoum8zc001pozw6w9jxd014',
            'name': 'Emmie',
            'familyId': 'family-123',
          },
        };

        final dto = ScheduleSlotChildDto.fromJson(json);
        final domain = dto.toDomain();

        expect(domain.scheduleSlotId, 'cmgo1ji9x000sozw6a2zxkkpn');
        expect(domain.childId, 'cmgoum8zc001pozw6w9jxd014');
        expect(domain.vehicleAssignmentId, 'cmgv17fia000u7t9ha4gzfhsl');
        expect(domain.createdAt, DateTime.parse('2025-10-15T08:30:00.000Z'));
        expect(domain.childName, 'Emmie');
        expect(domain.familyId, 'family-123');
        expect(
          domain.id,
          'cmgo1ji9x000sozw6a2zxkkpn_cmgoum8zc001pozw6w9jxd014',
        );
      });
    });

    group('Edge Cases', () {
      test('should handle null child object gracefully', () {
        final json = {
          'vehicleAssignmentId': 'cmgv17fia000u7t9ha4gzfhsl',
          'childId': 'cmgoum8zc001pozw6w9jxd014',
          // child is missing entirely
        };

        final dto = ScheduleSlotChildDto.fromJson(json);
        final domain = dto.toDomain();

        expect(domain.childId, 'cmgoum8zc001pozw6w9jxd014');
        expect(domain.childName, isNull); // No child object = no name
        expect(domain.familyId, isNull); // No child object = no familyId
      });

      test('should handle missing child.id by using childId field', () {
        final json = {
          'childId': 'explicit-child-id',
          'vehicleAssignmentId': 'va-123',
          'child': {
            // id is missing from child object
            'name': 'TestChild',
            'familyId': 'family-123',
          },
        };

        final dto = ScheduleSlotChildDto.fromJson(json);
        final domain = dto.toDomain();

        expect(
          domain.childId,
          'explicit-child-id',
        ); // Should use direct childId
        expect(domain.childName, 'TestChild');
      });

      test(
        'CRITICAL: should handle completely empty child (only vehicleAssignmentId)',
        () {
          final json = {
            'vehicleAssignmentId': 'va-123',
            // Everything else missing
          };

          final dto = ScheduleSlotChildDto.fromJson(json);
          final domain = dto.toDomain();

          // Should not throw, should use fallback values
          expect(domain.vehicleAssignmentId, 'va-123');
          expect(domain.childId, ''); // Fallback to empty
          expect(domain.scheduleSlotId, ''); // Fallback to empty
          expect(domain.createdAt, isNotNull); // Fallback to now
          expect(domain.childName, isNull);
          expect(domain.familyId, isNull);
        },
      );

      test('should handle child object with only id (minimal response)', () {
        final json = {
          'vehicleAssignmentId': 'va-123',
          'child': {
            'id': 'child-123',
            // name and familyId missing
          },
        };

        final dto = ScheduleSlotChildDto.fromJson(json);
        final domain = dto.toDomain();

        expect(domain.childId, 'child-123');
        expect(domain.vehicleAssignmentId, 'va-123');
        expect(domain.childName, isNull);
        expect(domain.familyId, isNull);
      });
    });

    group('Domain Round-trip', () {
      test('should convert from domain back to DTO', () {
        final json = {
          'scheduleSlotId': 'slot-123',
          'childId': 'child-123',
          'vehicleAssignmentId': 'va-123',
          'assignedAt': '2025-10-15T08:30:00.000Z',
          'child': {
            'id': 'child-123',
            'name': 'TestChild',
            'familyId': 'family-123',
          },
        };

        final dto = ScheduleSlotChildDto.fromJson(json);
        final domain = dto.toDomain();
        final dtoFromDomain = ScheduleSlotChildDto.fromDomain(domain);

        expect(dtoFromDomain.scheduleSlotId, 'slot-123');
        expect(dtoFromDomain.childId, 'child-123');
        expect(dtoFromDomain.vehicleAssignmentId, 'va-123');
        expect(
          dtoFromDomain.assignedAt,
          DateTime.parse('2025-10-15T08:30:00.000Z'),
        );
        expect(dtoFromDomain.child?.id, 'child-123');
        expect(dtoFromDomain.child?.name, 'TestChild');
        expect(dtoFromDomain.child?.familyId, 'family-123');
      });

      test('should handle domain without optional fields', () {
        final json = {
          'vehicleAssignmentId': 'va-123',
          'child': {'id': 'child-123', 'name': 'TestChild'},
        };

        final dto = ScheduleSlotChildDto.fromJson(json);
        final domain = dto.toDomain();
        final dtoFromDomain = ScheduleSlotChildDto.fromDomain(domain);

        expect(dtoFromDomain.vehicleAssignmentId, 'va-123');
        expect(dtoFromDomain.child?.id, 'child-123');
        expect(dtoFromDomain.child?.name, 'TestChild');
      });
    });
  });
}

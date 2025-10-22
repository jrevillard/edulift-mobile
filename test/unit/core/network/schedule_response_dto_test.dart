import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/network/models/schedule/schedule_response_dto.dart';

void main() {
  group('ScheduleResponseDto', () {
    test('should create DTO with empty slots', () {
      const dto = ScheduleResponseDto(
        groupId: 'test-group-id',
        startDate: '2025-10-09T00:00:00Z',
        endDate: '2025-10-15T23:59:59Z',
        scheduleSlots: [],
      );

      expect(dto.groupId, 'test-group-id');
      expect(dto.scheduleSlots, isEmpty);
    });

    test('should serialize to JSON', () {
      const dto = ScheduleResponseDto(
        groupId: 'test-group-id',
        startDate: '2025-10-09T00:00:00Z',
        endDate: '2025-10-15T23:59:59Z',
        scheduleSlots: [],
      );

      final json = dto.toJson();

      expect(json['groupId'], 'test-group-id');
      expect(json['startDate'], '2025-10-09T00:00:00Z');
      expect(json['endDate'], '2025-10-15T23:59:59Z');
      expect(json['scheduleSlots'], isEmpty);
    });

    test('should deserialize from JSON', () {
      final json = {
        'groupId': 'test-group-id',
        'startDate': '2025-10-09T00:00:00Z',
        'endDate': '2025-10-15T23:59:59Z',
        'scheduleSlots': [],
      };

      final dto = ScheduleResponseDto.fromJson(json);

      expect(dto.groupId, 'test-group-id');
      expect(dto.startDate, '2025-10-09T00:00:00Z');
      expect(dto.endDate, '2025-10-15T23:59:59Z');
      expect(dto.scheduleSlots, isEmpty);
    });
  });
}

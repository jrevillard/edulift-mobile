import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../converters/domain_converter.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

part 'time_slot_config_dto.freezed.dart';
part 'time_slot_config_dto.g.dart';

/// Default duration for time slots when not specified by API
const Duration _kDefaultSlotDuration = Duration(hours: 1);

/// Time Slot Configuration Data Transfer Object
/// Represents schedule configuration settings from the backend API
@freezed
abstract class TimeSlotConfigDto
    with _$TimeSlotConfigDto
    implements DomainConverter<List<ScheduleTimeSlot>> {
  const TimeSlotConfigDto._();

  const factory TimeSlotConfigDto({
    required String id,
    required String groupId,
    required List<String> availableDays,
    required List<String> timeSlots,
    required Map<String, dynamic> settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TimeSlotConfigDto;

  factory TimeSlotConfigDto.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotConfigDtoFromJson(json);

  /// Convert DTO to Domain Entity list
  /// Converts configuration time slots to ScheduleTimeSlot entities
  /// Note: This is a configuration -> entity conversion, times are parsed as today's times
  @override
  List<ScheduleTimeSlot> toDomain() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return timeSlots.map((timeSlot) {
      // Parse time string (e.g., "08:00")
      final parts = timeSlot.split(':');
      if (parts.length != 2) {
        // Invalid format, skip
        return null;
      }

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) {
        return null;
      }

      final startTime = today.add(Duration(hours: hour, minutes: minute));
      final endTime = startTime.add(_kDefaultSlotDuration);

      return ScheduleTimeSlot(
        id: '${id}_$timeSlot',
        startTime: startTime,
        endTime: endTime,
        isAvailable: true,
        conflictingScheduleIds: const [],
        groupId: groupId,
        metadata: {
          'timeSlot': timeSlot,
          'availableDays': availableDays,
          'settings': settings,
        },
      );
    }).whereType<ScheduleTimeSlot>().toList();
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:edulift/core/network/models/schedule/schedule_slot_dto.dart';
import '../../../converters/domain_converter.dart';
import '../../../../core/domain/entities/schedule/schedule_slot.dart';

part 'schedule_response_dto.freezed.dart';
part 'schedule_response_dto.g.dart';

/// Schedule Response Data Transfer Object
/// Wraps the schedule response from GET /groups/:groupId/schedule
@freezed
abstract class ScheduleResponseDto
    with _$ScheduleResponseDto
    implements DomainConverter<List<ScheduleSlot>> {
  const ScheduleResponseDto._();

  const factory ScheduleResponseDto({
    required String groupId,
    required String startDate,
    required String endDate,
    required List<ScheduleSlotDto> scheduleSlots,
  }) = _ScheduleResponseDto;

  factory ScheduleResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ScheduleResponseDtoFromJson(json);

  /// Convert DTO to Domain Entity list
  /// Returns list of ScheduleSlot entities from the response
  @override
  List<ScheduleSlot> toDomain() {

    final domainSlots = scheduleSlots.map((slotDto) {
      try {
        final domainSlot = slotDto.toDomain();
        return domainSlot;
      } catch (e) {
        rethrow;
      }
    }).toList();

    return domainSlots;
  }
}

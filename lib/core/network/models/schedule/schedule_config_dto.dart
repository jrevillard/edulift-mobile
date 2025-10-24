import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../converters/domain_converter.dart';
import '../../../domain/entities/schedule/schedule_config.dart';

part 'schedule_config_dto.freezed.dart';
part 'schedule_config_dto.g.dart';

/// ScheduleConfig Data Transfer Object
/// Mirrors backend ScheduleConfig API response structure exactly
/// Matches domain entity structure for clean architecture compliance
@freezed
abstract class ScheduleConfigDto
    with _$ScheduleConfigDto
    implements DomainConverter<ScheduleConfig> {
  const ScheduleConfigDto._();
  const factory ScheduleConfigDto({
    // Core ScheduleConfig fields from API
    required String id,
    required String groupId,
    @Default({}) Map<String, List<String>> scheduleHours,
    DateTime? createdAt,
    DateTime? updatedAt,

    // Relations from API includes (nested objects)
    Map<String, dynamic>? group,
    int? totalSlots,
    @Default(false) bool isDefault, // Backend adds this field to response
  }) = _ScheduleConfigDto;

  factory ScheduleConfigDto.fromJson(Map<String, dynamic> json) =>
      _$ScheduleConfigDtoFromJson(json);

  @override
  ScheduleConfig toDomain() {
    final now = DateTime.now();

    return ScheduleConfig(
      id: id,
      groupId: groupId,
      scheduleHours: scheduleHours,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  /// Create DTO from domain model
  factory ScheduleConfigDto.fromDomain(ScheduleConfig scheduleConfig) {
    return ScheduleConfigDto(
      id: scheduleConfig.id,
      groupId: scheduleConfig.groupId,
      scheduleHours: scheduleConfig.scheduleHours,
      createdAt: scheduleConfig.createdAt,
      updatedAt: scheduleConfig.updatedAt,
    );
  }
}

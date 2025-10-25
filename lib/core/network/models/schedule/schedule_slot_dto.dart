import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../converters/domain_converter.dart';
import '../../../domain/entities/schedule/schedule_slot.dart';
import '../../../domain/entities/schedule/day_of_week.dart';
import '../../../domain/entities/schedule/time_of_day.dart';
import '../../../domain/entities/family/child_assignment.dart';
import '../../../utils/date/iso_week_utils.dart';
import 'vehicle_assignment_dto.dart';
import '../family/schedule_slot_child_dto.dart';

part 'schedule_slot_dto.freezed.dart';
part 'schedule_slot_dto.g.dart';

/// Schedule Slot Data Transfer Object
/// Mirrors backend ScheduleSlot API response structure EXACTLY
/// Based on Prisma schema: id, groupId, datetime, createdAt, updatedAt + relations
@freezed
abstract class ScheduleSlotDto
    with _$ScheduleSlotDto
    implements DomainConverter<ScheduleSlot> {
  const ScheduleSlotDto._();
  const factory ScheduleSlotDto({
    // Only fields that exist in backend ScheduleSlot schema
    required String id,
    required String groupId,
    required DateTime datetime,
    DateTime? createdAt,
    DateTime? updatedAt,

    // Relations from API includes (when populated)
    List<VehicleAssignmentDto>? vehicleAssignments,
    List<ScheduleSlotChildDto>? childAssignments,
  }) = _ScheduleSlotDto;

  factory ScheduleSlotDto.fromJson(Map<String, dynamic> json) =>
      _$ScheduleSlotDtoFromJson(json);

  @override
  ScheduleSlot toDomain() {
    final now = DateTime.now();

    // Keep UTC datetime to ensure consistency with scheduleConfig (which contains UTC times)
    // This prevents orphaned slot false positives caused by timezone conversion
    final utcDatetime = datetime;

    // Convert backend datetime to TYPE-SAFE domain entities
    final weekNumber = _getWeekFromDateTime(utcDatetime);
    final dayOfWeek = DayOfWeek.fromWeekday(utcDatetime.weekday);
    final timeOfDay = TimeOfDayValue.fromDateTime(utcDatetime);

    // STEP 1: Convert childAssignments to domain and inject scheduleSlotId
    final childAssignmentsDomain = childAssignments?.map((dto) {
          final assignment = dto.toDomain();
          // If scheduleSlotId is empty (from nested response), inject parent's ID
          if (assignment.scheduleSlotId?.isEmpty ?? true) {
            return assignment.copyWith(scheduleSlotId: id);
          }
          return assignment;
        }).toList() ??
        [];

    // STEP 2: Group children by vehicleAssignmentId
    final childrenByVehicle = <String, List<ChildAssignment>>{};
    for (final child in childAssignmentsDomain) {
      final vaId = child.vehicleAssignmentId;
      if (vaId != null && vaId.isNotEmpty) {
        childrenByVehicle.putIfAbsent(vaId, () => []).add(child);
      }
    }

    // STEP 3: Inject scheduleSlotId AND attach children to vehicle assignments
    final vehicleAssignmentsWithSlotId = vehicleAssignments?.map((dto) {
          final assignment = dto.toDomain();
          // Inject scheduleSlotId if empty
          final withSlotId = assignment.scheduleSlotId.isEmpty
              ? assignment.copyWith(scheduleSlotId: id)
              : assignment;

          // Attach children for this vehicle assignment
          final children = childrenByVehicle[withSlotId.id] ?? [];
          return withSlotId.copyWith(childAssignments: children);
        }).toList() ??
        [];

    // STEP 4: Return domain entity
    return ScheduleSlot(
      id: id,
      groupId: groupId,
      dayOfWeek: dayOfWeek, // Type-safe enum
      timeOfDay: timeOfDay, // Type-safe value object
      week: weekNumber,
      maxVehicles: 10, // Default since backend doesn't track this
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      vehicleAssignments: vehicleAssignmentsWithSlotId,
    );
  }

  /// Create DTO from domain model
  factory ScheduleSlotDto.fromDomain(ScheduleSlot scheduleSlot) {
    // Convert type-safe domain entities to DateTime for API
    final dateTime = _getDateTimeFromTypedComponents(
      scheduleSlot.dayOfWeek,
      scheduleSlot.timeOfDay,
      scheduleSlot.week,
    );

    return ScheduleSlotDto(
      id: scheduleSlot.id,
      groupId: scheduleSlot.groupId,
      datetime: dateTime,
      createdAt: scheduleSlot.createdAt,
      updatedAt: scheduleSlot.updatedAt,
      vehicleAssignments: scheduleSlot.vehicleAssignments
          .map((assignment) => VehicleAssignmentDto.fromDomain(assignment))
          .toList(),
    );
  }

  /// Convert datetime to week string (ISO week format)
  /// Uses proper ISO 8601 week calculation from iso_week_utils
  String _getWeekFromDateTime(DateTime dt) {
    return getISOWeekString(dt);
  }

  /// Convert TYPE-SAFE domain components to DateTime for API
  static DateTime _getDateTimeFromTypedComponents(
    DayOfWeek dayOfWeek,
    TimeOfDayValue timeOfDay,
    String week,
  ) {
    // Parse week format "YYYY-WNN" to get the year and week number
    final parts = week.split('-W');
    final year = parts.length == 2
        ? int.tryParse(parts[0]) ?? DateTime.now().year
        : DateTime.now().year;
    final weekNumber = parts.length == 2 ? int.tryParse(parts[1]) ?? 1 : 1;

    // Calculate the start of the week (Monday)
    final jan4 = DateTime(year, 1, 4);
    final daysFromMonday = jan4.weekday - 1;
    final firstMonday = jan4.subtract(Duration(days: daysFromMonday));
    final weekStart = firstMonday.add(Duration(days: (weekNumber - 1) * 7));

    // Add days to get to the specific day of week
    final targetDay = weekStart.add(Duration(days: dayOfWeek.weekday - 1));

    // Apply the time
    return DateTime(
      targetDay.year,
      targetDay.month,
      targetDay.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }
}

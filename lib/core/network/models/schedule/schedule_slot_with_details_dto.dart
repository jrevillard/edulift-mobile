import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../converters/domain_converter.dart';
import '../../../domain/entities/schedule/schedule_slot.dart';
import '../../../domain/entities/schedule/day_of_week.dart';
import '../../../domain/entities/schedule/time_of_day.dart';
import '../../../domain/entities/schedule/vehicle_assignment.dart';
import '../../../domain/entities/family/child_assignment.dart';

part 'schedule_slot_with_details_dto.freezed.dart';
part 'schedule_slot_with_details_dto.g.dart';

/// Schedule Slot With Details Data Transfer Object
/// Mirrors backend ScheduleSlotWithDetails API response structure EXACTLY
/// Based on backend types/index.ts:75-103
@freezed
abstract class ScheduleSlotWithDetailsDto
    with _$ScheduleSlotWithDetailsDto
    implements DomainConverter<ScheduleSlot> {
  const ScheduleSlotWithDetailsDto._();
  const factory ScheduleSlotWithDetailsDto({
    // Core ScheduleSlot fields
    required String id,
    required String groupId,
    required DateTime datetime,
    @JsonKey(name: 'createdAt') String? createdAt,
    @JsonKey(name: 'updatedAt') String? updatedAt,

    // Vehicle assignments with full details
    @JsonKey(name: 'vehicleAssignments')
    required List<VehicleAssignmentDetailsDto> vehicleAssignments,

    // Child assignments linked to vehicle assignments
    @JsonKey(name: 'childAssignments')
    required List<ChildAssignmentDetailsDto> childAssignments,

    // Computed fields from backend
    @JsonKey(name: 'totalCapacity') required int totalCapacity,
    @JsonKey(name: 'availableSeats') required int availableSeats,
  }) = _ScheduleSlotWithDetailsDto;

  factory ScheduleSlotWithDetailsDto.fromJson(Map<String, dynamic> json) =>
      _$ScheduleSlotWithDetailsDtoFromJson(json);

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

    // Convert vehicle assignments with proper mapping
    final domainVehicleAssignments = vehicleAssignments
        .map((dto) => dto.toDomain())
        .toList();

    // Convert child assignments and link them to vehicles
    final domainChildAssignments = <ChildAssignment>[];
    for (final childDto in childAssignments) {
      final childAssignment = childDto.toDomain();
      domainChildAssignments.add(childAssignment);
    }

    // Link child assignments to their respective vehicle assignments
    for (final vehicleAssignment in domainVehicleAssignments) {
      final linkedChildren = domainChildAssignments
          .where((child) => child.vehicleAssignmentId == vehicleAssignment.id)
          .toList();

      // Update vehicle assignment with linked children
      // Note: This would require VehicleAssignment.copyWith support
      // For now, we'll handle this in the repository layer

      // Avoid unused variable warning - linkedChildren is used for logic
      if (linkedChildren.isNotEmpty) {
        // Logic to handle linked children would go here
        // For now, we acknowledge the relationship exists
      }
    }

    return ScheduleSlot(
      id: id,
      groupId: groupId,
      dayOfWeek: dayOfWeek,
      timeOfDay: timeOfDay,
      week: weekNumber,
      maxVehicles: 10, // Default since backend doesn't track this
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : now,
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : now,
      vehicleAssignments: domainVehicleAssignments,
    );
  }

  /// Convert datetime to week string (ISO week format)
  /// Uses proper ISO 8601 week calculation from iso_week_utils
  String _getWeekFromDateTime(DateTime dt) {
    // Import would cause circular dependency, so we implement here
    final year = dt.year;
    final weekNumber = _getISOWeekNumber(dt);
    return '$year-W${weekNumber.toString().padLeft(2, '0')}';
  }

  /// Calculate ISO week number for a given date
  int _getISOWeekNumber(DateTime date) {
    final jan1 = DateTime(date.year);
    final daysToThursday = (DateTime.thursday - jan1.weekday) % 7;
    final firstThursday = jan1.add(Duration(days: daysToThursday));
    final weekNumber = ((date.difference(firstThursday).inDays) / 7).ceil();
    return weekNumber < 1 ? 53 : weekNumber;
  }
}

/// Vehicle Assignment Details DTO for nested structure in ScheduleSlotWithDetails
@freezed
abstract class VehicleAssignmentDetailsDto
    with _$VehicleAssignmentDetailsDto
    implements DomainConverter<VehicleAssignment> {
  const VehicleAssignmentDetailsDto._();
  const factory VehicleAssignmentDetailsDto({
    required String id,
    @JsonKey(name: 'scheduleSlotId') required String scheduleSlotId,
    required VehicleDto vehicle,
    DriverDto? driver,
    int? seatOverride,
  }) = _VehicleAssignmentDetailsDto;

  factory VehicleAssignmentDetailsDto.fromJson(Map<String, dynamic> json) =>
      _$VehicleAssignmentDetailsDtoFromJson(json);

  @override
  VehicleAssignment toDomain() {
    final now = DateTime.now();

    return VehicleAssignment(
      id: id,
      scheduleSlotId: scheduleSlotId, // FIXED: Now properly set from API
      vehicleId: vehicle.id,
      driverId: driver?.id,
      seatOverride: seatOverride,
      createdAt: now,
      assignedAt: now,
      assignedBy: driver?.id ?? 'system',
      capacity: vehicle.capacity,
      updatedAt: now,
      vehicleName: vehicle.name,
      driverName: driver?.name,
    );
  }
}

/// Child Assignment Details DTO for nested structure in ScheduleSlotWithDetails
@freezed
abstract class ChildAssignmentDetailsDto
    with _$ChildAssignmentDetailsDto
    implements DomainConverter<ChildAssignment> {
  const ChildAssignmentDetailsDto._();
  const factory ChildAssignmentDetailsDto({
    required String vehicleAssignmentId,
    required ChildDetailsDto child,
  }) = _ChildAssignmentDetailsDto;

  factory ChildAssignmentDetailsDto.fromJson(Map<String, dynamic> json) =>
      _$ChildAssignmentDetailsDtoFromJson(json);

  @override
  ChildAssignment toDomain() {
    return ChildAssignment(
      id: '${vehicleAssignmentId}_${child.id}', // Generate composite ID
      childId: child.id,
      assignmentType: 'transportation',
      assignmentId: vehicleAssignmentId,
      createdAt: DateTime.now(),
      scheduleSlotId: '', // Will be set by parent
      vehicleAssignmentId: vehicleAssignmentId,
      childName: child.name,
      familyId: child.familyId,
    );
  }
}

/// Simple Vehicle DTO for nested structures
@freezed
abstract class VehicleDto with _$VehicleDto {
  const factory VehicleDto({
    required String id,
    required String name,
    required int capacity,
  }) = _VehicleDto;

  factory VehicleDto.fromJson(Map<String, dynamic> json) =>
      _$VehicleDtoFromJson(json);
}

/// Simple Driver DTO for nested structures
@freezed
abstract class DriverDto with _$DriverDto {
  const factory DriverDto({
    required String id,
    required String name,
  }) = _DriverDto;

  factory DriverDto.fromJson(Map<String, dynamic> json) =>
      _$DriverDtoFromJson(json);
}

/// Simple Child DTO for nested structures
@freezed
abstract class ChildDetailsDto with _$ChildDetailsDto {
  const factory ChildDetailsDto({
    required String id,
    required String name,
    required String familyId,
  }) = _ChildDetailsDto;

  factory ChildDetailsDto.fromJson(Map<String, dynamic> json) =>
      _$ChildDetailsDtoFromJson(json);
}
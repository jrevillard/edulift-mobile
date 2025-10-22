import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../converters/domain_converter.dart';
import '../../../domain/entities/schedule/vehicle_assignment.dart';

part 'vehicle_assignment_dto.freezed.dart';
part 'vehicle_assignment_dto.g.dart';

/// Vehicle Assignment Data Transfer Object
/// Mirrors backend ScheduleSlotVehicle API response structure EXACTLY
/// Based on backend types/index.ts:79-91 structure
@freezed
abstract class VehicleAssignmentDto
    with _$VehicleAssignmentDto
    implements DomainConverter<VehicleAssignment> {
  const factory VehicleAssignmentDto({
    // Core fields from backend API response (EXACT match to API)
    required String id,
    // CRITICAL FIX: scheduleSlotId is NOT sent in nested vehicle assignments
    // Backend only sends scheduleSlotId in standalone vehicle assignment responses
    // When vehicleAssignments are nested in ScheduleSlot, this field is absent
    @JsonKey(name: 'scheduleSlotId') String? scheduleSlotId,
    @JsonKey(name: 'seatOverride') int? seatOverride,

    // Relations from API includes (nested objects)
    required VehicleNestedDto vehicle, // Always present in API response
    // NOTE: driverId and driver are NOT in the actual API response, removed per Principle 0
  }) = _VehicleAssignmentDto;

  factory VehicleAssignmentDto.fromJson(Map<String, dynamic> json) =>
      _$VehicleAssignmentDtoFromJson(json);

  const VehicleAssignmentDto._();

  @override
  VehicleAssignment toDomain() {
    final now = DateTime.now();

    return VehicleAssignment(
      id: id,
      // CRITICAL: scheduleSlotId may be null when nested in ScheduleSlot response
      // In that case, use empty string as placeholder (will be set by parent ScheduleSlot)
      scheduleSlotId: scheduleSlotId ?? '',
      vehicleId: vehicle.id,
      seatOverride: seatOverride,
      createdAt: now,
      // Use defaults for fields not in backend API
      assignedAt: now,
      assignedBy: 'system',
      capacity: vehicle.capacity,
      updatedAt: now,
      // Extract from nested relations
      vehicleName: vehicle.name,
    );
  }

  /// Create DTO from domain model
  /// Note: This is used for testing/mocking, not for API responses
  factory VehicleAssignmentDto.fromDomain(VehicleAssignment assignment) {
    return VehicleAssignmentDto(
      id: assignment.id,
      scheduleSlotId: assignment.scheduleSlotId.isNotEmpty
          ? assignment.scheduleSlotId
          : '',
      seatOverride: assignment.seatOverride,
      vehicle: VehicleNestedDto(
        id: assignment.vehicleId,
        name: assignment.vehicleName,
        capacity: assignment.capacity,
      ),
    );
  }
}

/// Nested Vehicle DTO for VehicleAssignment structure
/// Mirrors EXACTLY the vehicle object from backend API response
@freezed
abstract class VehicleNestedDto with _$VehicleNestedDto {
  const factory VehicleNestedDto({
    required String id,
    required String name,
    required int capacity,
  }) = _VehicleNestedDto;

  factory VehicleNestedDto.fromJson(Map<String, dynamic> json) =>
      _$VehicleNestedDtoFromJson(json);
}

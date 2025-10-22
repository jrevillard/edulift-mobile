import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../converters/domain_converter.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

part 'conflict_dto.freezed.dart';
part 'conflict_dto.g.dart';

/// Schedule Conflict Data Transfer Object
/// Represents conflicts in scheduling from the backend API
@freezed
abstract class ConflictDto
    with _$ConflictDto
    implements DomainConverter<ScheduleConflict> {
  const ConflictDto._();

  const factory ConflictDto({
    required String id,
    required String type,
    required String description,
    required String conflictingResourceId,
    required DateTime conflictTime,
    String? resolution,
  }) = _ConflictDto;

  factory ConflictDto.fromJson(Map<String, dynamic> json) =>
      _$ConflictDtoFromJson(json);

  /// Convert DTO to Domain Entity
  @override
  ScheduleConflict toDomain() {
    // Parse type string to ConflictType enum
    ConflictType parsedType;
    switch (type.toLowerCase()) {
      case 'timeoverlap':
      case 'time_overlap':
        parsedType = ConflictType.timeOverlap;
        break;
      case 'resourceconflict':
      case 'resource_conflict':
        parsedType = ConflictType.resourceConflict;
        break;
      case 'locationconflict':
      case 'location_conflict':
        parsedType = ConflictType.locationConflict;
        break;
      case 'driverunavailable':
      case 'driver_unavailable':
        parsedType = ConflictType.driverUnavailable;
        break;
      case 'vehicleunavailable':
      case 'vehicle_unavailable':
        parsedType = ConflictType.vehicleUnavailable;
        break;
      case 'childunavailable':
      case 'child_unavailable':
        parsedType = ConflictType.childUnavailable;
        break;
      default:
        parsedType = ConflictType.resourceConflict;
    }

    // Use factory constructor to handle severity calculation in domain layer
    return ScheduleConflict.fromType(
      id: id,
      firstTimeSlotId: conflictingResourceId,
      type: parsedType,
      description: description,
      detectedAt: conflictTime,
      isResolved: resolution != null,
      resolvedAt: resolution != null ? DateTime.now() : null,
      resolution: resolution,
    );
  }
}

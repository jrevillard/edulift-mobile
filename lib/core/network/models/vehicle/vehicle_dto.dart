import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/converters/domain_converter.dart';
import 'package:edulift/core/domain/entities/family.dart';

part 'vehicle_dto.freezed.dart';
part 'vehicle_dto.g.dart';

/// Vehicle Data Transfer Object
/// Mirrors backend Vehicle API response structure exactly
@freezed
abstract class VehicleDto
    with _$VehicleDto
    implements DomainConverter<Vehicle> {
  const factory VehicleDto({
    required String id,
    required String name,
    required String familyId,
    required int capacity,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _VehicleDto;

  factory VehicleDto.fromJson(Map<String, dynamic> json) =>
      _$VehicleDtoFromJson(json);

  const VehicleDto._();

  @override
  Vehicle toDomain() {
    final now = DateTime.now();
    return Vehicle(
      id: id,
      name: name,
      familyId: familyId,
      capacity: capacity,
      description: description,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  /// Create DTO from domain model
  factory VehicleDto.fromDomain(Vehicle vehicle) {
    return VehicleDto(
      id: vehicle.id,
      name: vehicle.name,
      familyId: vehicle.familyId,
      capacity: vehicle.capacity,
      description: vehicle.description,
      createdAt: vehicle.createdAt,
      updatedAt: vehicle.updatedAt,
    );
  }
}

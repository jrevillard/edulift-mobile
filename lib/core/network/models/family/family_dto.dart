import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/converters/domain_converter.dart';
import 'package:edulift/core/domain/entities/family.dart';
import 'family_member_dto.dart';
import '../child/child_dto.dart';
import '../vehicle/vehicle_dto.dart';

part 'family_dto.freezed.dart';
part 'family_dto.g.dart';

/// Family Data Transfer Object
/// Mirrors backend Family API response structure exactly
@freezed
abstract class FamilyDto with _$FamilyDto implements DomainConverter<Family> {
  const FamilyDto._();
  const factory FamilyDto({
    required String id,
    required String name,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<FamilyMemberDto>? members,
    List<ChildDto>? children,
    List<VehicleDto>? vehicles,
  }) = _FamilyDto;

  factory FamilyDto.fromJson(Map<String, dynamic> json) =>
      _$FamilyDtoFromJson(json);

  @override
  Family toDomain() {
    final now = DateTime.now();
    return Family(
      id: id,
      name: name,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      members: members?.map((dto) => dto.toDomain()).toList() ?? [],
      children: children?.map((dto) => dto.toDomain()).toList() ?? [],
      vehicles: vehicles?.map((dto) => dto.toDomain()).toList() ?? [],
    );
  }

  /// Create DTO from domain model
  factory FamilyDto.fromDomain(Family family) {
    return FamilyDto(
      id: family.id,
      name: family.name,
      createdAt: family.createdAt,
      updatedAt: family.updatedAt,
      members: family.members
          .map((member) => FamilyMemberDto.fromDomain(member))
          .toList(),
      children:
          family.children.map((child) => ChildDto.fromDomain(child)).toList(),
      vehicles: family.vehicles
          .map((vehicle) => VehicleDto.fromDomain(vehicle))
          .toList(),
    );
  }
}

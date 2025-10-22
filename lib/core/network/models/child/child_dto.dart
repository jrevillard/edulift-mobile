import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/converters/domain_converter.dart';
import '../../../domain/entities/family/child.dart';

part 'child_dto.freezed.dart';
part 'child_dto.g.dart';

/// Child Data Transfer Object
/// Mirrors backend Child API response structure exactly
@freezed
abstract class ChildDto with _$ChildDto implements DomainConverter<Child> {
  const factory ChildDto({
    String? id,
    String? name,
    String? familyId,
    int? age,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ChildDto;

  factory ChildDto.fromJson(Map<String, dynamic> json) =>
      _$ChildDtoFromJson(json);

  const ChildDto._();

  @override
  Child toDomain() {
    final now = DateTime.now();
    return Child(
      id: id ?? '',
      name: name ?? '',
      familyId: familyId ?? '',
      age: age,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  /// Create DTO from domain model
  factory ChildDto.fromDomain(Child child) {
    return ChildDto(
      id: child.id,
      name: child.name,
      familyId: child.familyId,
      age: child.age,
      createdAt: child.createdAt,
      updatedAt: child.updatedAt,
    );
  }
}

/// Family Children Response Data Transfer Object
/// Wraps the list response from the children endpoint
@freezed
abstract class FamilyChildrenResponseDto with _$FamilyChildrenResponseDto {
  const factory FamilyChildrenResponseDto({
    required List<ChildDto> children,
    @Default(0) int totalCount,
  }) = _FamilyChildrenResponseDto;

  factory FamilyChildrenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$FamilyChildrenResponseDtoFromJson(json);

  const FamilyChildrenResponseDto._();

  /// Create from API response list
  factory FamilyChildrenResponseDto.fromApiResponse(
    List<Map<String, dynamic>> children,
  ) {
    return FamilyChildrenResponseDto(
      children: children.map((child) => ChildDto.fromJson(child)).toList(),
    );
  }
}

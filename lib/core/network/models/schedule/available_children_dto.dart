import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../converters/domain_converter.dart';
import '../child/child_dto.dart';
import '../../../domain/entities/family/child.dart';

part 'available_children_dto.freezed.dart';
part 'available_children_dto.g.dart';

/// Available Children Data Transfer Object
/// Represents children available for schedule assignment from the backend API
@freezed
abstract class AvailableChildrenDto
    with _$AvailableChildrenDto
    implements DomainConverter<List<Child>> {
  const AvailableChildrenDto._();

  const factory AvailableChildrenDto({
    required List<ChildDto> availableChildren,
    required String groupId,
    required String week,
    required String day,
    required String time,
  }) = _AvailableChildrenDto;

  factory AvailableChildrenDto.fromJson(Map<String, dynamic> json) =>
      _$AvailableChildrenDtoFromJson(json);

  /// Convert DTO to Domain Entity list
  /// Returns list of Child entities from the availableChildren DTOs
  @override
  List<Child> toDomain() {
    return availableChildren.map((childDto) => childDto.toDomain()).toList();
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../converters/domain_converter.dart';
import '../../../domain/entities/groups/group.dart';

part 'group_dto.freezed.dart';
part 'group_dto.g.dart';

/// Group Data Transfer Object
///
/// **CRITICAL**: This DTO mirrors the backend GroupData structure EXACTLY.
/// DO NOT add default values, DO NOT invent attributes.
/// Backend API returns: group_api_client.dart lines 272-305 (GroupData class)
@Freezed(toJson: true)
abstract class GroupDto with _$GroupDto implements DomainConverter<Group> {
  const factory GroupDto({
    required String id,
    required String name,
    String? description,
    required String familyId,
    @JsonKey(name: 'invite_code') String? inviteCode,
    required String createdAt,
    required String updatedAt,
    String? userRole,
    String? joinedAt,
    Map<String, dynamic>? ownerFamily,
    int? familyCount,
    int? scheduleCount,
  }) = _GroupDto;

  const GroupDto._();

  factory GroupDto.fromJson(Map<String, dynamic> json) =>
      _$GroupDtoFromJson(json);

  @override
  Group toDomain() {
    // Parse String dates from backend to DateTime for domain
    final parsedCreatedAt = DateTime.parse(createdAt);
    final parsedUpdatedAt = DateTime.parse(updatedAt);

    return Group(
      id: id,
      name: name,
      familyId: familyId,
      description: description,
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
      userRole: GroupMemberRole.fromJson(userRole),
      familyCount: familyCount ?? 0,
      scheduleCount: scheduleCount ?? 0,
      // Domain entity has default values for these fields
      // Backend doesn't return them, so we use domain defaults
    );
  }

  /// Create DTO from domain model
  /// Used when sending data TO the backend
  factory GroupDto.fromDomain(Group group) {
    return GroupDto(
      id: group.id,
      name: group.name,
      familyId: group.familyId,
      description: group.description,
      createdAt: group.createdAt.toIso8601String(),
      updatedAt: group.updatedAt.toIso8601String(),
      userRole: group.userRole?.name,
      familyCount: group.familyCount,
      scheduleCount: group.scheduleCount,
    );
  }
}

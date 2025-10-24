import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/converters/domain_converter.dart';
import 'package:edulift/core/domain/entities/family.dart';

part 'family_member_dto.freezed.dart';
part 'family_member_dto.g.dart';

/// User data nested in FamilyMember response
@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String name,
    required String email,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}

/// Family Member Data Transfer Object
/// Mirrors backend FamilyMember API response structure exactly
@freezed
abstract class FamilyMemberDto
    with _$FamilyMemberDto
    implements DomainConverter<FamilyMember> {
  const FamilyMemberDto._();
  const factory FamilyMemberDto({
    required String id,
    required String userId,
    required String familyId,
    required String role,
    required DateTime joinedAt,
    UserDto? user, // User data from backend include
  }) = _FamilyMemberDto;

  factory FamilyMemberDto.fromJson(Map<String, dynamic> json) =>
      _$FamilyMemberDtoFromJson(json);

  @override
  FamilyMember toDomain() {
    return FamilyMember(
      id: id,
      userId: userId,
      familyId: familyId,
      role: FamilyRole.fromString(role),
      status: 'ACTIVE', // Default status from backend
      joinedAt: joinedAt,
      userName: user?.name,
      userEmail: user?.email,
    );
  }

  /// Create DTO from domain model
  factory FamilyMemberDto.fromDomain(FamilyMember member) {
    return FamilyMemberDto(
      id: member.id,
      userId: member.userId,
      familyId: member.familyId,
      role: member.role.value,
      joinedAt: member.joinedAt,
      user: member.userName != null && member.userEmail != null
          ? UserDto(
              id: member.userId,
              name: member.userName!,
              email: member.userEmail!,
            )
          : null,
    );
  }
}

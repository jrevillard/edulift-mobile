import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/user.dart';

part 'user_current_family_dto.freezed.dart';
part 'user_current_family_dto.g.dart';

/// User Current Family Data Transfer Object
/// Represents the user's current family information from API
@freezed
abstract class UserCurrentFamilyDto with _$UserCurrentFamilyDto {
  const factory UserCurrentFamilyDto({
    required String id,
    required String email,
    required String name,
    @Default('UTC') String timezone,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'is_biometric_enabled')
    @Default(false)
    bool isBiometricEnabled,
    @JsonKey(name: 'family_id') String? familyId,
    @JsonKey(name: 'family_name') String? familyName,
    @JsonKey(name: 'user_role') String? userRole,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    @JsonKey(name: 'is_active') bool? isActive,
  }) = _UserCurrentFamilyDto;

  factory UserCurrentFamilyDto.fromJson(Map<String, dynamic> json) =>
      _$UserCurrentFamilyDtoFromJson(json);
}

extension UserCurrentFamilyDtoExtension on UserCurrentFamilyDto {
  /// Convert DTO to domain User entity
  User toDomain() {
    return User(
      id: id,
      email: email,
      name: name,
      timezone: timezone,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      isBiometricEnabled: isBiometricEnabled,
      // CLEAN ARCHITECTURE: familyId no longer passed to User constructor
      // Family data now accessible via UserFamilyExtension
    );
  }
}

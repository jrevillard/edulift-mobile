import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_dto.freezed.dart';
part 'user_profile_dto.g.dart';

@freezed
abstract class UserProfileDto with _$UserProfileDto {
  const factory UserProfileDto({
    required String id,
    required String email,
    required String name,
    @Default('UTC') String timezone,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserProfileDto;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);
}

@freezed
abstract class CreateUserProfileDto with _$CreateUserProfileDto {
  const factory CreateUserProfileDto({
    required String email,
    required String name,
  }) = _CreateUserProfileDto;

  factory CreateUserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$CreateUserProfileDtoFromJson(json);
}

@freezed
abstract class UpdateUserProfileDto with _$UpdateUserProfileDto {
  const factory UpdateUserProfileDto({
    String? name,
  }) = _UpdateUserProfileDto;

  factory UpdateUserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserProfileDtoFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';
import '../user/user_current_family_dto.dart';

part 'auth_dto.freezed.dart';
part 'auth_dto.g.dart';

@JsonSerializable()
class AuthDto {
  // Access token - backend sends "token" or "accessToken"
  @JsonKey(name: 'token')
  final String accessToken;

  // PHASE 2: Refresh token - now required for token refresh support
  // Backend sends "refreshToken"
  @JsonKey(name: 'refreshToken')
  final String refreshToken;

  // PHASE 2: Token expiration time in seconds (e.g., 900 for 15 minutes)
  // Backend sends "expiresIn"
  @JsonKey(name: 'expiresIn')
  final int expiresIn;

  // Token type (usually "Bearer")
  @JsonKey(name: 'tokenType', defaultValue: 'Bearer')
  final String tokenType;

  final UserCurrentFamilyDto user;

  final InvitationResultDto? invitationResult;

  const AuthDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.tokenType = 'Bearer',
    required this.user,
    this.invitationResult,
  });

  factory AuthDto.fromJson(Map<String, dynamic> json) =>
      _$AuthDtoFromJson(json);
}

@JsonSerializable()
class InvitationResultDto {
  final bool processed;
  final String? invitationType;
  final String? redirectUrl;
  final bool? requiresFamilyOnboarding;
  final String? reason;

  const InvitationResultDto({
    required this.processed,
    this.invitationType,
    this.redirectUrl,
    this.requiresFamilyOnboarding,
    this.reason,
  });

  factory InvitationResultDto.fromJson(Map<String, dynamic> json) =>
      _$InvitationResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationResultDtoToJson(this);
}

@freezed
abstract class AuthUserProfileDto with _$AuthUserProfileDto {
  const factory AuthUserProfileDto({required UserCurrentFamilyDto data}) =
      _AuthUserProfileDto;

  factory AuthUserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$AuthUserProfileDtoFromJson(json);
}

@freezed
abstract class AuthConfigDto with _$AuthConfigDto {
  const factory AuthConfigDto({
    required String nodeEnv,
    required String emailUser,
    required bool hasCredentials,
    required String mockServiceTest,
  }) = _AuthConfigDto;

  factory AuthConfigDto.fromJson(Map<String, dynamic> json) =>
      _$AuthConfigDtoFromJson(json);
}

@freezed
abstract class UserExistsDto with _$UserExistsDto {
  const factory UserExistsDto({required bool exists}) = _UserExistsDto;

  factory UserExistsDto.fromJson(Map<String, dynamic> json) =>
      _$UserExistsDtoFromJson(json);
}

/// Token Refresh Response DTO
///
/// PHASE 2: OAuth 2.0 Token Refresh with rotation
/// Backend returns ONLY tokens (no user profile) on /auth/refresh
///
/// Response structure:
/// ```json
/// {
///   "accessToken": "eyJ...",
///   "refreshToken": "abc...",
///   "expiresIn": 900,
///   "tokenType": "Bearer"
/// }
/// ```
@freezed
abstract class TokenRefreshResponseDto with _$TokenRefreshResponseDto {
  const factory TokenRefreshResponseDto({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    @Default('Bearer') String tokenType,
  }) = _TokenRefreshResponseDto;

  factory TokenRefreshResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TokenRefreshResponseDtoFromJson(json);
}

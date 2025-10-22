import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_code_response_dto.freezed.dart';
part 'invite_code_response_dto.g.dart';

/// Invite Code Response Data Transfer Object
/// Mirrors backend InviteCodeResponse API response structure exactly
@freezed
abstract class InviteCodeResponseDto with _$InviteCodeResponseDto {
  const factory InviteCodeResponseDto({
    required String inviteCode,
    required DateTime expiresAt,
    String? shareUrl,
  }) = _InviteCodeResponseDto;

  factory InviteCodeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$InviteCodeResponseDtoFromJson(json);
}

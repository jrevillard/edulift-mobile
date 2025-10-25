// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_code_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InviteCodeResponseDto _$InviteCodeResponseDtoFromJson(
  Map<String, dynamic> json,
) =>
    _InviteCodeResponseDto(
      inviteCode: json['inviteCode'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      shareUrl: json['shareUrl'] as String?,
    );

Map<String, dynamic> _$InviteCodeResponseDtoToJson(
  _InviteCodeResponseDto instance,
) =>
    <String, dynamic>{
      'inviteCode': instance.inviteCode,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'shareUrl': instance.shareUrl,
    };

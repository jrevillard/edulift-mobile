// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MagicLinkRequest _$MagicLinkRequestFromJson(Map<String, dynamic> json) =>
    MagicLinkRequest(
      email: json['email'] as String,
      name: json['name'] as String?,
      inviteCode: json['inviteCode'] as String?,
      platform: json['platform'] as String? ?? 'native',
      codeChallenge: json['code_challenge'] as String,
    );

Map<String, dynamic> _$MagicLinkRequestToJson(MagicLinkRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      if (instance.name case final value?) 'name': value,
      if (instance.inviteCode case final value?) 'inviteCode': value,
      'platform': instance.platform,
      'code_challenge': instance.codeChallenge,
    };

VerifyTokenRequest _$VerifyTokenRequestFromJson(Map<String, dynamic> json) =>
    VerifyTokenRequest(
      token: json['token'] as String,
      codeVerifier: json['code_verifier'] as String?,
      originalEmail: json['original_email'] as String?,
    );

Map<String, dynamic> _$VerifyTokenRequestToJson(VerifyTokenRequest instance) =>
    <String, dynamic>{
      'token': instance.token,
      if (instance.codeVerifier case final value?) 'code_verifier': value,
      if (instance.originalEmail case final value?) 'original_email': value,
    };

RefreshTokenRequest _$RefreshTokenRequestFromJson(Map<String, dynamic> json) =>
    RefreshTokenRequest(refreshToken: json['refresh_token'] as String);

Map<String, dynamic> _$RefreshTokenRequestToJson(
  RefreshTokenRequest instance,
) => <String, dynamic>{'refresh_token': instance.refreshToken};

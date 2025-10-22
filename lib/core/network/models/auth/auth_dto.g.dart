// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthDto _$AuthDtoFromJson(Map<String, dynamic> json) => AuthDto(
  accessToken: json['token'] as String,
  refreshToken: json['refreshToken'] as String,
  expiresIn: (json['expiresIn'] as num).toInt(),
  tokenType: json['tokenType'] as String? ?? 'Bearer',
  user: UserCurrentFamilyDto.fromJson(json['user'] as Map<String, dynamic>),
  invitationResult: json['invitationResult'] == null
      ? null
      : InvitationResultDto.fromJson(
          json['invitationResult'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$AuthDtoToJson(AuthDto instance) => <String, dynamic>{
  'token': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'expiresIn': instance.expiresIn,
  'tokenType': instance.tokenType,
  'user': instance.user,
  'invitationResult': instance.invitationResult,
};

InvitationResultDto _$InvitationResultDtoFromJson(Map<String, dynamic> json) =>
    InvitationResultDto(
      processed: json['processed'] as bool,
      invitationType: json['invitationType'] as String?,
      redirectUrl: json['redirectUrl'] as String?,
      requiresFamilyOnboarding: json['requiresFamilyOnboarding'] as bool?,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$InvitationResultDtoToJson(
  InvitationResultDto instance,
) => <String, dynamic>{
  'processed': instance.processed,
  'invitationType': instance.invitationType,
  'redirectUrl': instance.redirectUrl,
  'requiresFamilyOnboarding': instance.requiresFamilyOnboarding,
  'reason': instance.reason,
};

_AuthUserProfileDto _$AuthUserProfileDtoFromJson(Map<String, dynamic> json) =>
    _AuthUserProfileDto(
      data: UserCurrentFamilyDto.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthUserProfileDtoToJson(_AuthUserProfileDto instance) =>
    <String, dynamic>{'data': instance.data};

_AuthConfigDto _$AuthConfigDtoFromJson(Map<String, dynamic> json) =>
    _AuthConfigDto(
      nodeEnv: json['nodeEnv'] as String,
      emailUser: json['emailUser'] as String,
      hasCredentials: json['hasCredentials'] as bool,
      mockServiceTest: json['mockServiceTest'] as String,
    );

Map<String, dynamic> _$AuthConfigDtoToJson(_AuthConfigDto instance) =>
    <String, dynamic>{
      'nodeEnv': instance.nodeEnv,
      'emailUser': instance.emailUser,
      'hasCredentials': instance.hasCredentials,
      'mockServiceTest': instance.mockServiceTest,
    };

_UserExistsDto _$UserExistsDtoFromJson(Map<String, dynamic> json) =>
    _UserExistsDto(exists: json['exists'] as bool);

Map<String, dynamic> _$UserExistsDtoToJson(_UserExistsDto instance) =>
    <String, dynamic>{'exists': instance.exists};

_TokenRefreshResponseDto _$TokenRefreshResponseDtoFromJson(
  Map<String, dynamic> json,
) => _TokenRefreshResponseDto(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  expiresIn: (json['expiresIn'] as num).toInt(),
  tokenType: json['tokenType'] as String? ?? 'Bearer',
);

Map<String, dynamic> _$TokenRefreshResponseDtoToJson(
  _TokenRefreshResponseDto instance,
) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'expiresIn': instance.expiresIn,
  'tokenType': instance.tokenType,
};

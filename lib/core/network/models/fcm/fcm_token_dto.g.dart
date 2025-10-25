// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_token_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FcmTokenDto _$FcmTokenDtoFromJson(Map<String, dynamic> json) => _FcmTokenDto(
      id: json['id'] as String,
      platform: json['platform'] as String,
      isActive: json['isActive'] as bool,
      deviceId: json['deviceId'] as String?,
      createdAt: json['createdAt'] as String?,
      lastUsed: json['lastUsed'] as String?,
    );

Map<String, dynamic> _$FcmTokenDtoToJson(_FcmTokenDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'platform': instance.platform,
      'isActive': instance.isActive,
      'deviceId': instance.deviceId,
      'createdAt': instance.createdAt,
      'lastUsed': instance.lastUsed,
    };

_FcmTokenListDto _$FcmTokenListDtoFromJson(Map<String, dynamic> json) =>
    _FcmTokenListDto(
      tokens: (json['tokens'] as List<dynamic>)
          .map((e) => FcmTokenDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FcmTokenListDtoToJson(_FcmTokenListDto instance) =>
    <String, dynamic>{'tokens': instance.tokens};

_ValidateTokenDto _$ValidateTokenDtoFromJson(Map<String, dynamic> json) =>
    _ValidateTokenDto(
      token: json['token'] as String,
      isValid: json['isValid'] as bool,
      isServiceAvailable: json['isServiceAvailable'] as bool,
    );

Map<String, dynamic> _$ValidateTokenDtoToJson(_ValidateTokenDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'isValid': instance.isValid,
      'isServiceAvailable': instance.isServiceAvailable,
    };

_SubscribeDto _$SubscribeDtoFromJson(Map<String, dynamic> json) =>
    _SubscribeDto(
      token: json['token'] as String,
      topic: json['topic'] as String,
      subscribed: json['subscribed'] as bool,
    );

Map<String, dynamic> _$SubscribeDtoToJson(_SubscribeDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'topic': instance.topic,
      'subscribed': instance.subscribed,
    };

_TestNotificationDto _$TestNotificationDtoFromJson(Map<String, dynamic> json) =>
    _TestNotificationDto(
      successCount: (json['successCount'] as num).toInt(),
      failureCount: (json['failureCount'] as num).toInt(),
      invalidTokens: (json['invalidTokens'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      totalTokens: (json['totalTokens'] as num).toInt(),
    );

Map<String, dynamic> _$TestNotificationDtoToJson(
  _TestNotificationDto instance,
) =>
    <String, dynamic>{
      'successCount': instance.successCount,
      'failureCount': instance.failureCount,
      'invalidTokens': instance.invalidTokens,
      'totalTokens': instance.totalTokens,
    };

_FcmStatsDto _$FcmStatsDtoFromJson(Map<String, dynamic> json) => _FcmStatsDto(
      userTokenCount: (json['userTokenCount'] as num).toInt(),
      serviceAvailable: json['serviceAvailable'] as bool,
      platforms: Map<String, int>.from(json['platforms'] as Map),
    );

Map<String, dynamic> _$FcmStatsDtoToJson(_FcmStatsDto instance) =>
    <String, dynamic>{
      'userTokenCount': instance.userTokenCount,
      'serviceAvailable': instance.serviceAvailable,
      'platforms': instance.platforms,
    };

_FcmSuccessDto _$FcmSuccessDtoFromJson(Map<String, dynamic> json) =>
    _FcmSuccessDto(
      success: json['success'] as bool,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$FcmSuccessDtoToJson(_FcmSuccessDto instance) =>
    <String, dynamic>{'success': instance.success, 'message': instance.message};

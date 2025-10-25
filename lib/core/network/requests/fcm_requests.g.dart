// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterTokenRequest _$RegisterTokenRequestFromJson(
  Map<String, dynamic> json,
) => RegisterTokenRequest(
  token: json['token'] as String,
  deviceId: json['deviceId'] as String?,
  platform: json['platform'] as String,
);

Map<String, dynamic> _$RegisterTokenRequestToJson(
  RegisterTokenRequest instance,
) => <String, dynamic>{
  'token': instance.token,
  if (instance.deviceId case final value?) 'deviceId': value,
  'platform': instance.platform,
};

ValidateTokenRequest _$ValidateTokenRequestFromJson(
  Map<String, dynamic> json,
) => ValidateTokenRequest(token: json['token'] as String);

Map<String, dynamic> _$ValidateTokenRequestToJson(
  ValidateTokenRequest instance,
) => <String, dynamic>{'token': instance.token};

SubscribeTopicRequest _$SubscribeTopicRequestFromJson(
  Map<String, dynamic> json,
) => SubscribeTopicRequest(
  token: json['token'] as String,
  topic: json['topic'] as String,
);

Map<String, dynamic> _$SubscribeTopicRequestToJson(
  SubscribeTopicRequest instance,
) => <String, dynamic>{'token': instance.token, 'topic': instance.topic};

TestNotificationRequest _$TestNotificationRequestFromJson(
  Map<String, dynamic> json,
) => TestNotificationRequest(
  title: json['title'] as String,
  body: json['body'] as String,
  data: (json['data'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  priority: json['priority'] as String?,
);

Map<String, dynamic> _$TestNotificationRequestToJson(
  TestNotificationRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'body': instance.body,
  if (instance.data case final value?) 'data': value,
  if (instance.priority case final value?) 'priority': value,
};

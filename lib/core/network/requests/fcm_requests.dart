// EduLift Mobile - FCM Request Models
// Matches backend /api/fcm-tokens/* endpoints

import 'package:json_annotation/json_annotation.dart';

part 'fcm_requests.g.dart';

/// Register FCM token request
@JsonSerializable(includeIfNull: false)
class RegisterTokenRequest {
  final String token;
  final String? deviceId;
  final String platform; // 'android', 'ios', 'web'

  RegisterTokenRequest({
    required this.token,
    this.deviceId,
    required this.platform,
  });

  factory RegisterTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterTokenRequestToJson(this);
}

/// Validate FCM token request
@JsonSerializable(includeIfNull: false)
class ValidateTokenRequest {
  final String token;

  ValidateTokenRequest({required this.token});

  factory ValidateTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$ValidateTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ValidateTokenRequestToJson(this);
}

/// Subscribe to topic request
@JsonSerializable(includeIfNull: false)
class SubscribeTopicRequest {
  final String token;
  final String topic;

  SubscribeTopicRequest({required this.token, required this.topic});

  factory SubscribeTopicRequest.fromJson(Map<String, dynamic> json) =>
      _$SubscribeTopicRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SubscribeTopicRequestToJson(this);
}

/// Test notification request
@JsonSerializable(includeIfNull: false)
class TestNotificationRequest {
  final String title;
  final String body;
  final Map<String, String>? data;
  final String? priority; // 'high' or 'normal'

  TestNotificationRequest({
    required this.title,
    required this.body,
    this.data,
    this.priority,
  });

  factory TestNotificationRequest.fromJson(Map<String, dynamic> json) =>
      _$TestNotificationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TestNotificationRequestToJson(this);
}

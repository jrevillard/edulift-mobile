import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart' hide ParseErrorLogger;
import '../utils/error_logger.dart'; // Override Retrofit's ParseErrorLogger
import 'requests/fcm_requests.dart';

part 'fcm_api_client.g.dart';

@RestApi()
abstract class FcmApiClient {
  factory FcmApiClient.create(Dio dio, {String? baseUrl}) = _FcmApiClient;

  /// Save or register an FCM token
  /// POST /api/v1/fcm-tokens
  @POST('/fcm-tokens')
  Future<FcmTokenResponse> registerToken(@Body() RegisterTokenRequest request);

  /// Get all active FCM tokens for the authenticated user
  /// GET /api/v1/fcm-tokens
  @GET('/fcm-tokens')
  Future<FcmTokenListResponse> getTokens();

  /// Delete a specific FCM token
  /// DELETE /api/v1/fcm-tokens/{token}
  @DELETE('/fcm-tokens/{token}')
  Future<BaseResponse> unregisterToken(@Path('token') String token);

  /// Validate an FCM token
  /// POST /api/v1/fcm-tokens/validate
  @POST('/fcm-tokens/validate')
  Future<ValidateTokenResponse> validateToken(
    @Body() ValidateTokenRequest request,
  );

  /// Subscribe a token to a topic
  /// POST /api/v1/fcm-tokens/subscribe
  @POST('/fcm-tokens/subscribe')
  Future<SubscribeResponse> subscribeToTopic(
    @Body() SubscribeTopicRequest request,
  );

  /// Unsubscribe a token from a topic
  /// POST /api/v1/fcm-tokens/unsubscribe
  @POST('/fcm-tokens/unsubscribe')
  Future<SubscribeResponse> unsubscribeFromTopic(
    @Body() SubscribeTopicRequest request,
  );

  /// Send a test notification to the user's devices
  /// POST /api/v1/fcm-tokens/test
  @POST('/fcm-tokens/test')
  Future<TestNotificationResponse> sendTestNotification(
    @Body() TestNotificationRequest request,
  );

  /// Get FCM token statistics
  /// GET /api/v1/fcm-tokens/stats
  @GET('/fcm-tokens/stats')
  Future<FcmStatsResponse> getStats();
}

// Response Models
@JsonSerializable(includeIfNull: false)
class BaseResponse {
  final bool success;
  final String? message;

  BaseResponse({required this.success, this.message});

  factory BaseResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BaseResponseToJson(this);
}

@JsonSerializable(includeIfNull: false)
class FcmTokenResponse {
  final bool success;
  final FcmTokenData data;

  FcmTokenResponse({required this.success, required this.data});

  factory FcmTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$FcmTokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FcmTokenResponseToJson(this);
}

@JsonSerializable(includeIfNull: false)
class FcmTokenData {
  final String id;
  final String platform;
  final bool isActive;
  final String? deviceId;
  final String? createdAt;
  final String? lastUsed;

  FcmTokenData({
    required this.id,
    required this.platform,
    required this.isActive,
    this.deviceId,
    this.createdAt,
    this.lastUsed,
  });

  factory FcmTokenData.fromJson(Map<String, dynamic> json) =>
      _$FcmTokenDataFromJson(json);
  Map<String, dynamic> toJson() => _$FcmTokenDataToJson(this);
}

@JsonSerializable(includeIfNull: false)
class FcmTokenListResponse {
  final bool success;
  final List<FcmTokenData> data;

  FcmTokenListResponse({required this.success, required this.data});

  factory FcmTokenListResponse.fromJson(Map<String, dynamic> json) =>
      _$FcmTokenListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FcmTokenListResponseToJson(this);
}

@JsonSerializable(includeIfNull: false)
class ValidateTokenResponse {
  final bool success;
  final ValidateTokenData data;

  ValidateTokenResponse({required this.success, required this.data});

  factory ValidateTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$ValidateTokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ValidateTokenResponseToJson(this);
}

@JsonSerializable(includeIfNull: false)
class ValidateTokenData {
  final String token;
  final bool isValid;
  final bool isServiceAvailable;

  ValidateTokenData({
    required this.token,
    required this.isValid,
    required this.isServiceAvailable,
  });

  factory ValidateTokenData.fromJson(Map<String, dynamic> json) =>
      _$ValidateTokenDataFromJson(json);
  Map<String, dynamic> toJson() => _$ValidateTokenDataToJson(this);
}

@JsonSerializable(includeIfNull: false)
class SubscribeResponse {
  final bool success;
  final SubscribeData data;

  SubscribeResponse({required this.success, required this.data});

  factory SubscribeResponse.fromJson(Map<String, dynamic> json) =>
      _$SubscribeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SubscribeResponseToJson(this);
}

@JsonSerializable(includeIfNull: false)
class SubscribeData {
  final String token;
  final String topic;
  final bool subscribed;

  SubscribeData({
    required this.token,
    required this.topic,
    required this.subscribed,
  });

  factory SubscribeData.fromJson(Map<String, dynamic> json) =>
      _$SubscribeDataFromJson(json);
  Map<String, dynamic> toJson() => _$SubscribeDataToJson(this);
}

@JsonSerializable(includeIfNull: false)
class TestNotificationResponse {
  final bool success;
  final TestNotificationData data;

  TestNotificationResponse({required this.success, required this.data});

  factory TestNotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$TestNotificationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TestNotificationResponseToJson(this);
}

@JsonSerializable(includeIfNull: false)
class TestNotificationData {
  final int successCount;
  final int failureCount;
  final List<String> invalidTokens;
  final int totalTokens;

  TestNotificationData({
    required this.successCount,
    required this.failureCount,
    required this.invalidTokens,
    required this.totalTokens,
  });

  factory TestNotificationData.fromJson(Map<String, dynamic> json) =>
      _$TestNotificationDataFromJson(json);
  Map<String, dynamic> toJson() => _$TestNotificationDataToJson(this);
}

@JsonSerializable(includeIfNull: false)
class FcmStatsResponse {
  final bool success;
  final FcmStatsData data;

  FcmStatsResponse({required this.success, required this.data});

  factory FcmStatsResponse.fromJson(Map<String, dynamic> json) =>
      _$FcmStatsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FcmStatsResponseToJson(this);
}

@JsonSerializable(includeIfNull: false)
class FcmStatsData {
  final int userTokenCount;
  final bool serviceAvailable;
  final Map<String, int> platforms;

  FcmStatsData({
    required this.userTokenCount,
    required this.serviceAvailable,
    required this.platforms,
  });

  factory FcmStatsData.fromJson(Map<String, dynamic> json) =>
      _$FcmStatsDataFromJson(json);
  Map<String, dynamic> toJson() => _$FcmStatsDataToJson(this);
}

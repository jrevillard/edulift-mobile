import 'package:freezed_annotation/freezed_annotation.dart';

part 'fcm_token_dto.freezed.dart';
part 'fcm_token_dto.g.dart';

/// FCM Token DTO models following 2025 clean architecture pattern
/// Returns simple DTOs instead of Response wrappers

@freezed
abstract class FcmTokenDto with _$FcmTokenDto {
  const factory FcmTokenDto({
    required String id,
    required String platform,
    required bool isActive,
    String? deviceId,
    String? createdAt,
    String? lastUsed,
  }) = _FcmTokenDto;

  factory FcmTokenDto.fromJson(Map<String, dynamic> json) =>
      _$FcmTokenDtoFromJson(json);
}

@freezed
abstract class FcmTokenListDto with _$FcmTokenListDto {
  const factory FcmTokenListDto({required List<FcmTokenDto> tokens}) =
      _FcmTokenListDto;

  factory FcmTokenListDto.fromJson(Map<String, dynamic> json) =>
      _$FcmTokenListDtoFromJson(json);
}

@freezed
abstract class ValidateTokenDto with _$ValidateTokenDto {
  const factory ValidateTokenDto({
    required String token,
    required bool isValid,
    required bool isServiceAvailable,
  }) = _ValidateTokenDto;

  factory ValidateTokenDto.fromJson(Map<String, dynamic> json) =>
      _$ValidateTokenDtoFromJson(json);
}

@freezed
abstract class SubscribeDto with _$SubscribeDto {
  const factory SubscribeDto({
    required String token,
    required String topic,
    required bool subscribed,
  }) = _SubscribeDto;

  factory SubscribeDto.fromJson(Map<String, dynamic> json) =>
      _$SubscribeDtoFromJson(json);
}

@freezed
abstract class TestNotificationDto with _$TestNotificationDto {
  const factory TestNotificationDto({
    required int successCount,
    required int failureCount,
    required List<String> invalidTokens,
    required int totalTokens,
  }) = _TestNotificationDto;

  factory TestNotificationDto.fromJson(Map<String, dynamic> json) =>
      _$TestNotificationDtoFromJson(json);
}

@freezed
abstract class FcmStatsDto with _$FcmStatsDto {
  const factory FcmStatsDto({
    required int userTokenCount,
    required bool serviceAvailable,
    required Map<String, int> platforms,
  }) = _FcmStatsDto;

  factory FcmStatsDto.fromJson(Map<String, dynamic> json) =>
      _$FcmStatsDtoFromJson(json);
}

/// Simple success DTO for operations that only need success confirmation
@freezed
abstract class FcmSuccessDto with _$FcmSuccessDto {
  const factory FcmSuccessDto({required bool success, String? message}) =
      _FcmSuccessDto;

  factory FcmSuccessDto.fromJson(Map<String, dynamic> json) =>
      _$FcmSuccessDtoFromJson(json);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_api_client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseResponse _$BaseResponseFromJson(Map<String, dynamic> json) => BaseResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$BaseResponseToJson(BaseResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      if (instance.message case final value?) 'message': value,
    };

FcmTokenResponse _$FcmTokenResponseFromJson(Map<String, dynamic> json) =>
    FcmTokenResponse(
      success: json['success'] as bool,
      data: FcmTokenData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FcmTokenResponseToJson(FcmTokenResponse instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

FcmTokenData _$FcmTokenDataFromJson(Map<String, dynamic> json) => FcmTokenData(
      id: json['id'] as String,
      platform: json['platform'] as String,
      isActive: json['isActive'] as bool,
      deviceId: json['deviceId'] as String?,
      createdAt: json['createdAt'] as String?,
      lastUsed: json['lastUsed'] as String?,
    );

Map<String, dynamic> _$FcmTokenDataToJson(FcmTokenData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'platform': instance.platform,
      'isActive': instance.isActive,
      if (instance.deviceId case final value?) 'deviceId': value,
      if (instance.createdAt case final value?) 'createdAt': value,
      if (instance.lastUsed case final value?) 'lastUsed': value,
    };

FcmTokenListResponse _$FcmTokenListResponseFromJson(
  Map<String, dynamic> json,
) =>
    FcmTokenListResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => FcmTokenData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FcmTokenListResponseToJson(
  FcmTokenListResponse instance,
) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

ValidateTokenResponse _$ValidateTokenResponseFromJson(
  Map<String, dynamic> json,
) =>
    ValidateTokenResponse(
      success: json['success'] as bool,
      data: ValidateTokenData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ValidateTokenResponseToJson(
  ValidateTokenResponse instance,
) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

ValidateTokenData _$ValidateTokenDataFromJson(Map<String, dynamic> json) =>
    ValidateTokenData(
      token: json['token'] as String,
      isValid: json['isValid'] as bool,
      isServiceAvailable: json['isServiceAvailable'] as bool,
    );

Map<String, dynamic> _$ValidateTokenDataToJson(ValidateTokenData instance) =>
    <String, dynamic>{
      'token': instance.token,
      'isValid': instance.isValid,
      'isServiceAvailable': instance.isServiceAvailable,
    };

SubscribeResponse _$SubscribeResponseFromJson(Map<String, dynamic> json) =>
    SubscribeResponse(
      success: json['success'] as bool,
      data: SubscribeData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SubscribeResponseToJson(SubscribeResponse instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

SubscribeData _$SubscribeDataFromJson(Map<String, dynamic> json) =>
    SubscribeData(
      token: json['token'] as String,
      topic: json['topic'] as String,
      subscribed: json['subscribed'] as bool,
    );

Map<String, dynamic> _$SubscribeDataToJson(SubscribeData instance) =>
    <String, dynamic>{
      'token': instance.token,
      'topic': instance.topic,
      'subscribed': instance.subscribed,
    };

TestNotificationResponse _$TestNotificationResponseFromJson(
  Map<String, dynamic> json,
) =>
    TestNotificationResponse(
      success: json['success'] as bool,
      data: TestNotificationData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TestNotificationResponseToJson(
  TestNotificationResponse instance,
) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

TestNotificationData _$TestNotificationDataFromJson(
  Map<String, dynamic> json,
) =>
    TestNotificationData(
      successCount: (json['successCount'] as num).toInt(),
      failureCount: (json['failureCount'] as num).toInt(),
      invalidTokens: (json['invalidTokens'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      totalTokens: (json['totalTokens'] as num).toInt(),
    );

Map<String, dynamic> _$TestNotificationDataToJson(
  TestNotificationData instance,
) =>
    <String, dynamic>{
      'successCount': instance.successCount,
      'failureCount': instance.failureCount,
      'invalidTokens': instance.invalidTokens,
      'totalTokens': instance.totalTokens,
    };

FcmStatsResponse _$FcmStatsResponseFromJson(Map<String, dynamic> json) =>
    FcmStatsResponse(
      success: json['success'] as bool,
      data: FcmStatsData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FcmStatsResponseToJson(FcmStatsResponse instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

FcmStatsData _$FcmStatsDataFromJson(Map<String, dynamic> json) => FcmStatsData(
      userTokenCount: (json['userTokenCount'] as num).toInt(),
      serviceAvailable: json['serviceAvailable'] as bool,
      platforms: Map<String, int>.from(json['platforms'] as Map),
    );

Map<String, dynamic> _$FcmStatsDataToJson(FcmStatsData instance) =>
    <String, dynamic>{
      'userTokenCount': instance.userTokenCount,
      'serviceAvailable': instance.serviceAvailable,
      'platforms': instance.platforms,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter

class _FcmApiClient implements FcmApiClient {
  _FcmApiClient(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<FcmTokenResponse> registerToken(RegisterTokenRequest request) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<FcmTokenResponse>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/fcm-tokens',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late FcmTokenResponse _value;
    try {
      _value = FcmTokenResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<FcmTokenListResponse> getTokens() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<FcmTokenListResponse>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/fcm-tokens',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late FcmTokenListResponse _value;
    try {
      _value = FcmTokenListResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<BaseResponse> unregisterToken(String token) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<BaseResponse>(
      Options(method: 'DELETE', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/fcm-tokens/${token}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BaseResponse _value;
    try {
      _value = BaseResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ValidateTokenResponse> validateToken(
    ValidateTokenRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<ValidateTokenResponse>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/fcm-tokens/validate',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ValidateTokenResponse _value;
    try {
      _value = ValidateTokenResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<SubscribeResponse> subscribeToTopic(
    SubscribeTopicRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<SubscribeResponse>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/fcm-tokens/subscribe',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SubscribeResponse _value;
    try {
      _value = SubscribeResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<SubscribeResponse> unsubscribeFromTopic(
    SubscribeTopicRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<SubscribeResponse>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/fcm-tokens/unsubscribe',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SubscribeResponse _value;
    try {
      _value = SubscribeResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<TestNotificationResponse> sendTestNotification(
    TestNotificationRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<TestNotificationResponse>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/fcm-tokens/test',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late TestNotificationResponse _value;
    try {
      _value = TestNotificationResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<FcmStatsResponse> getStats() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<FcmStatsResponse>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/fcm-tokens/stats',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late FcmStatsResponse _value;
    try {
      _value = FcmStatsResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

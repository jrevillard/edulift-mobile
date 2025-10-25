// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'validation_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValidationErrorResponse _$ValidationErrorResponseFromJson(
  Map<String, dynamic> json,
) =>
    ValidationErrorResponse(
      message: json['message'] as String,
      errors: (json['errors'] as List<dynamic>)
          .map((e) => ValidationError.fromJson(e as Map<String, dynamic>))
          .toList(),
      statusCode: (json['statusCode'] as num).toInt(),
    );

Map<String, dynamic> _$ValidationErrorResponseToJson(
  ValidationErrorResponse instance,
) =>
    <String, dynamic>{
      'message': instance.message,
      'errors': instance.errors,
      'statusCode': instance.statusCode,
    };

ValidationError _$ValidationErrorFromJson(Map<String, dynamic> json) =>
    ValidationError(
      field: json['field'] as String,
      message: json['message'] as String,
      code: json['code'] as String,
      rejectedValue: json['rejectedValue'],
    );

Map<String, dynamic> _$ValidationErrorToJson(ValidationError instance) =>
    <String, dynamic>{
      'field': instance.field,
      'message': instance.message,
      'code': instance.code,
      'rejectedValue': instance.rejectedValue,
    };

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      message: json['message'] as String,
      error: json['error'] as String?,
      statusCode: (json['statusCode'] as num).toInt(),
      path: json['path'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: json['details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'error': instance.error,
      'statusCode': instance.statusCode,
      'path': instance.path,
      'timestamp': instance.timestamp.toIso8601String(),
      'details': instance.details,
    };

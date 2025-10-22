import 'package:json_annotation/json_annotation.dart';

part 'validation_error.g.dart';

/// Validation error response model
@JsonSerializable()
class ValidationErrorResponse {
  final String message;
  final List<ValidationError> errors;
  final int statusCode;

  const ValidationErrorResponse({
    required this.message,
    required this.errors,
    required this.statusCode,
  });

  factory ValidationErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ValidationErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ValidationErrorResponseToJson(this);
}

/// Individual validation error
@JsonSerializable()
class ValidationError {
  final String field;
  final String message;
  final String code;
  final dynamic rejectedValue;

  const ValidationError({
    required this.field,
    required this.message,
    required this.code,
    this.rejectedValue,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) =>
      _$ValidationErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ValidationErrorToJson(this);
}

/// Error response model
@JsonSerializable()
class ErrorResponse {
  final String message;
  final String? error;
  final int statusCode;
  final String? path;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  const ErrorResponse({
    required this.message,
    this.error,
    required this.statusCode,
    this.path,
    required this.timestamp,
    this.details,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_invitation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptInvitationResponse _$AcceptInvitationResponseFromJson(
  Map<String, dynamic> json,
) =>
    AcceptInvitationResponse(
      success: json['success'] as bool,
      error: json['error'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$AcceptInvitationResponseToJson(
  AcceptInvitationResponse instance,
) =>
    <String, dynamic>{
      'success': instance.success,
      'error': instance.error,
      'message': instance.message,
    };

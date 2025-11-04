// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InviteFamilyMemberRequest _$InviteFamilyMemberRequestFromJson(
  Map<String, dynamic> json,
) => InviteFamilyMemberRequest(
  email: json['email'] as String,
  role: json['role'] as String,
  message: json['personalMessage'] as String?,
);

Map<String, dynamic> _$InviteFamilyMemberRequestToJson(
  InviteFamilyMemberRequest instance,
) => <String, dynamic>{
  'email': instance.email,
  'role': instance.role,
  'personalMessage': instance.message,
};

InviteMemberRequest _$InviteMemberRequestFromJson(Map<String, dynamic> json) =>
    InviteMemberRequest(
      email: json['email'] as String,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$InviteMemberRequestToJson(
  InviteMemberRequest instance,
) => <String, dynamic>{
  'email': instance.email,
  if (instance.role case final value?) 'role': value,
};

ValidateInviteRequest _$ValidateInviteRequestFromJson(
  Map<String, dynamic> json,
) => ValidateInviteRequest(inviteCode: json['inviteCode'] as String);

Map<String, dynamic> _$ValidateInviteRequestToJson(
  ValidateInviteRequest instance,
) => <String, dynamic>{'inviteCode': instance.inviteCode};

DeleteResponseDto _$DeleteResponseDtoFromJson(Map<String, dynamic> json) =>
    DeleteResponseDto(
      success: json['success'] as bool,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$DeleteResponseDtoToJson(DeleteResponseDto instance) =>
    <String, dynamic>{
      'success': instance.success,
      if (instance.message case final value?) 'message': value,
    };

InvitationListResponseDto _$InvitationListResponseDtoFromJson(
  Map<String, dynamic> json,
) => InvitationListResponseDto(
  invitations: (json['invitations'] as List<dynamic>)
      .map((e) => FamilyInvitationDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
);

Map<String, dynamic> _$InvitationListResponseDtoToJson(
  InvitationListResponseDto instance,
) => <String, dynamic>{
  'invitations': instance.invitations,
  'totalCount': instance.totalCount,
};

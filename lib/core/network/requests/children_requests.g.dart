// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'children_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateChildInlineRequest _$CreateChildInlineRequestFromJson(
  Map<String, dynamic> json,
) =>
    CreateChildInlineRequest(
      name: json['name'] as String,
      dateOfBirth: json['dateOfBirth'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CreateChildInlineRequestToJson(
  CreateChildInlineRequest instance,
) =>
    <String, dynamic>{
      'name': instance.name,
      if (instance.dateOfBirth case final value?) 'dateOfBirth': value,
      if (instance.notes case final value?) 'notes': value,
    };

UpdateChildInlineRequest _$UpdateChildInlineRequestFromJson(
  Map<String, dynamic> json,
) =>
    UpdateChildInlineRequest(
      name: json['name'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$UpdateChildInlineRequestToJson(
  UpdateChildInlineRequest instance,
) =>
    <String, dynamic>{
      if (instance.name case final value?) 'name': value,
      if (instance.dateOfBirth case final value?) 'dateOfBirth': value,
      if (instance.notes case final value?) 'notes': value,
    };

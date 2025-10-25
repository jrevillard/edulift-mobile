// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FamilyDto _$FamilyDtoFromJson(Map<String, dynamic> json) => _FamilyDto(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      members: (json['members'] as List<dynamic>?)
          ?.map((e) => FamilyMemberDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => ChildDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      vehicles: (json['vehicles'] as List<dynamic>?)
          ?.map((e) => VehicleDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FamilyDtoToJson(_FamilyDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'members': instance.members,
      'children': instance.children,
      'vehicles': instance.vehicles,
    };

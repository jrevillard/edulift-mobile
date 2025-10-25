// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChildDto _$ChildDtoFromJson(Map<String, dynamic> json) => _ChildDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      familyId: json['familyId'] as String?,
      age: (json['age'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ChildDtoToJson(_ChildDto instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'familyId': instance.familyId,
      'age': instance.age,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_FamilyChildrenResponseDto _$FamilyChildrenResponseDtoFromJson(
  Map<String, dynamic> json,
) =>
    _FamilyChildrenResponseDto(
      children: (json['children'] as List<dynamic>)
          .map((e) => ChildDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$FamilyChildrenResponseDtoToJson(
  _FamilyChildrenResponseDto instance,
) =>
    <String, dynamic>{
      'children': instance.children,
      'totalCount': instance.totalCount,
    };

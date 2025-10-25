// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_children_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AvailableChildrenDto _$AvailableChildrenDtoFromJson(
  Map<String, dynamic> json,
) => _AvailableChildrenDto(
  availableChildren: (json['availableChildren'] as List<dynamic>)
      .map((e) => ChildDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  groupId: json['groupId'] as String,
  week: json['week'] as String,
  day: json['day'] as String,
  time: json['time'] as String,
);

Map<String, dynamic> _$AvailableChildrenDtoToJson(
  _AvailableChildrenDto instance,
) => <String, dynamic>{
  'availableChildren': instance.availableChildren,
  'groupId': instance.groupId,
  'week': instance.week,
  'day': instance.day,
  'time': instance.time,
};

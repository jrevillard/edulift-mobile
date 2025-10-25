// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_assignment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VehicleAssignmentDto _$VehicleAssignmentDtoFromJson(
  Map<String, dynamic> json,
) =>
    _VehicleAssignmentDto(
      id: json['id'] as String,
      scheduleSlotId: json['scheduleSlotId'] as String?,
      seatOverride: (json['seatOverride'] as num?)?.toInt(),
      vehicle:
          VehicleNestedDto.fromJson(json['vehicle'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VehicleAssignmentDtoToJson(
  _VehicleAssignmentDto instance,
) =>
    <String, dynamic>{
      'id': instance.id,
      'scheduleSlotId': instance.scheduleSlotId,
      'seatOverride': instance.seatOverride,
      'vehicle': instance.vehicle,
    };

_VehicleNestedDto _$VehicleNestedDtoFromJson(Map<String, dynamic> json) =>
    _VehicleNestedDto(
      id: json['id'] as String,
      name: json['name'] as String,
      capacity: (json['capacity'] as num).toInt(),
    );

Map<String, dynamic> _$VehicleNestedDtoToJson(_VehicleNestedDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'capacity': instance.capacity,
    };

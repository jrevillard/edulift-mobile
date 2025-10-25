// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VehicleDto _$VehicleDtoFromJson(Map<String, dynamic> json) => _VehicleDto(
      id: json['id'] as String,
      name: json['name'] as String,
      familyId: json['familyId'] as String,
      capacity: (json['capacity'] as num).toInt(),
      description: json['description'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$VehicleDtoToJson(_VehicleDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'familyId': instance.familyId,
      'capacity': instance.capacity,
      'description': instance.description,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

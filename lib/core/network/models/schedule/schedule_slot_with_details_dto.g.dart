// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_slot_with_details_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleSlotWithDetailsDto _$ScheduleSlotWithDetailsDtoFromJson(
  Map<String, dynamic> json,
) => _ScheduleSlotWithDetailsDto(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  datetime: DateTime.parse(json['datetime'] as String),
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  vehicleAssignments: (json['vehicleAssignments'] as List<dynamic>)
      .map(
        (e) => VehicleAssignmentDetailsDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  childAssignments: (json['childAssignments'] as List<dynamic>)
      .map((e) => ChildAssignmentDetailsDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCapacity: (json['totalCapacity'] as num).toInt(),
  availableSeats: (json['availableSeats'] as num).toInt(),
);

Map<String, dynamic> _$ScheduleSlotWithDetailsDtoToJson(
  _ScheduleSlotWithDetailsDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'groupId': instance.groupId,
  'datetime': instance.datetime.toIso8601String(),
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'vehicleAssignments': instance.vehicleAssignments,
  'childAssignments': instance.childAssignments,
  'totalCapacity': instance.totalCapacity,
  'availableSeats': instance.availableSeats,
};

_VehicleAssignmentDetailsDto _$VehicleAssignmentDetailsDtoFromJson(
  Map<String, dynamic> json,
) => _VehicleAssignmentDetailsDto(
  id: json['id'] as String,
  scheduleSlotId: json['scheduleSlotId'] as String,
  vehicle: VehicleDto.fromJson(json['vehicle'] as Map<String, dynamic>),
  driver: json['driver'] == null
      ? null
      : DriverDto.fromJson(json['driver'] as Map<String, dynamic>),
  seatOverride: (json['seatOverride'] as num?)?.toInt(),
);

Map<String, dynamic> _$VehicleAssignmentDetailsDtoToJson(
  _VehicleAssignmentDetailsDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'scheduleSlotId': instance.scheduleSlotId,
  'vehicle': instance.vehicle,
  'driver': instance.driver,
  'seatOverride': instance.seatOverride,
};

_ChildAssignmentDetailsDto _$ChildAssignmentDetailsDtoFromJson(
  Map<String, dynamic> json,
) => _ChildAssignmentDetailsDto(
  vehicleAssignmentId: json['vehicleAssignmentId'] as String,
  child: ChildDetailsDto.fromJson(json['child'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChildAssignmentDetailsDtoToJson(
  _ChildAssignmentDetailsDto instance,
) => <String, dynamic>{
  'vehicleAssignmentId': instance.vehicleAssignmentId,
  'child': instance.child,
};

_VehicleDto _$VehicleDtoFromJson(Map<String, dynamic> json) => _VehicleDto(
  id: json['id'] as String,
  name: json['name'] as String,
  capacity: (json['capacity'] as num).toInt(),
);

Map<String, dynamic> _$VehicleDtoToJson(_VehicleDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'capacity': instance.capacity,
    };

_DriverDto _$DriverDtoFromJson(Map<String, dynamic> json) =>
    _DriverDto(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$DriverDtoToJson(_DriverDto instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_ChildDetailsDto _$ChildDetailsDtoFromJson(Map<String, dynamic> json) =>
    _ChildDetailsDto(
      id: json['id'] as String,
      name: json['name'] as String,
      familyId: json['familyId'] as String,
    );

Map<String, dynamic> _$ChildDetailsDtoToJson(_ChildDetailsDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'familyId': instance.familyId,
    };

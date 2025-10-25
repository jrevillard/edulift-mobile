// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignChildRequest _$AssignChildRequestFromJson(Map<String, dynamic> json) =>
    AssignChildRequest(
      childId: json['childId'] as String,
      vehicleAssignmentId: json['vehicleAssignmentId'] as String,
    );

Map<String, dynamic> _$AssignChildRequestToJson(AssignChildRequest instance) =>
    <String, dynamic>{
      'childId': instance.childId,
      'vehicleAssignmentId': instance.vehicleAssignmentId,
    };

CreateScheduleSlotRequest _$CreateScheduleSlotRequestFromJson(
  Map<String, dynamic> json,
) => CreateScheduleSlotRequest(
  datetime: json['datetime'] as String,
  vehicleId: json['vehicleId'] as String,
  driverId: json['driverId'] as String?,
  seatOverride: (json['seatOverride'] as num?)?.toInt(),
);

Map<String, dynamic> _$CreateScheduleSlotRequestToJson(
  CreateScheduleSlotRequest instance,
) => <String, dynamic>{
  'datetime': instance.datetime,
  'vehicleId': instance.vehicleId,
  if (instance.driverId case final value?) 'driverId': value,
  if (instance.seatOverride case final value?) 'seatOverride': value,
};

UpdateSeatOverrideRequest _$UpdateSeatOverrideRequestFromJson(
  Map<String, dynamic> json,
) => UpdateSeatOverrideRequest(
  seatOverride: (json['seatOverride'] as num?)?.toInt(),
);

Map<String, dynamic> _$UpdateSeatOverrideRequestToJson(
  UpdateSeatOverrideRequest instance,
) => <String, dynamic>{
  if (instance.seatOverride case final value?) 'seatOverride': value,
};

AssignVehicleRequest _$AssignVehicleRequestFromJson(
  Map<String, dynamic> json,
) => AssignVehicleRequest(vehicleId: json['vehicleId'] as String);

Map<String, dynamic> _$AssignVehicleRequestToJson(
  AssignVehicleRequest instance,
) => <String, dynamic>{'vehicleId': instance.vehicleId};

UpdateDriverRequest _$UpdateDriverRequestFromJson(Map<String, dynamic> json) =>
    UpdateDriverRequest(driverId: json['driverId'] as String?);

Map<String, dynamic> _$UpdateDriverRequestToJson(
  UpdateDriverRequest instance,
) => <String, dynamic>{
  if (instance.driverId case final value?) 'driverId': value,
};

RemoveVehicleRequest _$RemoveVehicleRequestFromJson(
  Map<String, dynamic> json,
) => RemoveVehicleRequest(vehicleId: json['vehicleId'] as String);

Map<String, dynamic> _$RemoveVehicleRequestToJson(
  RemoveVehicleRequest instance,
) => <String, dynamic>{'vehicleId': instance.vehicleId};

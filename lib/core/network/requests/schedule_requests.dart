// EduLift Mobile - Schedule Request Models
// Matches backend /api/schedule/* endpoints

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'schedule_requests.g.dart';

/// Assign child to vehicle request model
/// Mirrors backend schema EXACTLY (camelCase field names)
@JsonSerializable(includeIfNull: false)
class AssignChildRequest extends Equatable {
  final String childId;
  final String vehicleAssignmentId;

  const AssignChildRequest({
    required this.childId,
    required this.vehicleAssignmentId,
  });

  factory AssignChildRequest.fromJson(Map<String, dynamic> json) =>
      _$AssignChildRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AssignChildRequestToJson(this);

  @override
  List<Object?> get props => [childId, vehicleAssignmentId];
}

/// Create schedule slot request model
/// Matches backend schema: POST /api/v1/groups/:groupId/schedule-slots
///
/// Backend expects:
/// ```json
/// {
///   "datetime": "2025-10-11T07:30:00.000Z",  // ISO 8601 datetime (required)
///   "vehicleId": "cm...",                     // Vehicle CUID (required)
///   "driverId": "cm...",                      // Driver CUID (optional)
///   "seatOverride": 4                         // Seat override (optional)
/// }
/// ```
/// Note: timezone is no longer sent - backend uses authenticated user's timezone from DB
@JsonSerializable(includeIfNull: false)
class CreateScheduleSlotRequest extends Equatable {
  final String datetime;
  final String vehicleId;
  final String? driverId;
  final int? seatOverride;

  const CreateScheduleSlotRequest({
    required this.datetime,
    required this.vehicleId,
    this.driverId,
    this.seatOverride,
  });

  factory CreateScheduleSlotRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateScheduleSlotRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateScheduleSlotRequestToJson(this);

  @override
  List<Object?> get props => [datetime, vehicleId, driverId, seatOverride];
}

/// Update seat override request model
/// Matches backend: PATCH /api/v1/vehicle-assignments/:id/seat-override
@JsonSerializable(includeIfNull: false)
class UpdateSeatOverrideRequest extends Equatable {
  final int? seatOverride;

  const UpdateSeatOverrideRequest({this.seatOverride});

  factory UpdateSeatOverrideRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateSeatOverrideRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateSeatOverrideRequestToJson(this);

  @override
  List<Object?> get props => [seatOverride];
}

/// Assign vehicle request model
@JsonSerializable(includeIfNull: false)
class AssignVehicleRequest extends Equatable {
  final String vehicleId;

  const AssignVehicleRequest({required this.vehicleId});

  factory AssignVehicleRequest.fromJson(Map<String, dynamic> json) =>
      _$AssignVehicleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AssignVehicleRequestToJson(this);

  @override
  List<Object?> get props => [vehicleId];
}

/// Update driver request model
@JsonSerializable(includeIfNull: false)
class UpdateDriverRequest extends Equatable {
  final String? driverId;

  const UpdateDriverRequest({this.driverId});

  factory UpdateDriverRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateDriverRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateDriverRequestToJson(this);

  @override
  List<Object?> get props => [driverId];
}

/// Remove vehicle from slot request model
@JsonSerializable(includeIfNull: false)
class RemoveVehicleRequest extends Equatable {
  final String vehicleId;

  const RemoveVehicleRequest({required this.vehicleId});

  factory RemoveVehicleRequest.fromJson(Map<String, dynamic> json) =>
      _$RemoveVehicleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RemoveVehicleRequestToJson(this);

  @override
  List<Object?> get props => [vehicleId];
}

// NOTE: UpdateScheduleConfigRequest has been moved to group_requests.dart
// to avoid duplication. Import from there if needed.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats_dto.freezed.dart';
part 'dashboard_stats_dto.g.dart';

@freezed
abstract class DashboardStatsDto with _$DashboardStatsDto {
  const factory DashboardStatsDto({
    required int groups,
    required int children,
    required int vehicles,
    @JsonKey(name: 'this_week_trips') required int thisWeekTrips,
    @JsonKey(name: 'pending_invitations') required int pendingInvitations,
    TrendsDto? trends,
  }) = _DashboardStatsDto;

  factory DashboardStatsDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsDtoFromJson(json);
}

@freezed
abstract class TrendsDto with _$TrendsDto {
  const factory TrendsDto({
    @JsonKey(name: 'groups_change') double? groupsChange,
    @JsonKey(name: 'children_change') double? childrenChange,
    @JsonKey(name: 'vehicles_change') double? vehiclesChange,
    @JsonKey(name: 'trips_change') double? tripsChange,
  }) = _TrendsDto;

  factory TrendsDto.fromJson(Map<String, dynamic> json) =>
      _$TrendsDtoFromJson(json);
}

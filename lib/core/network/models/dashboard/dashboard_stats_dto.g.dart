// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardStatsDto _$DashboardStatsDtoFromJson(Map<String, dynamic> json) =>
    _DashboardStatsDto(
      groups: (json['groups'] as num).toInt(),
      children: (json['children'] as num).toInt(),
      vehicles: (json['vehicles'] as num).toInt(),
      thisWeekTrips: (json['this_week_trips'] as num).toInt(),
      pendingInvitations: (json['pending_invitations'] as num).toInt(),
      trends: json['trends'] == null
          ? null
          : TrendsDto.fromJson(json['trends'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DashboardStatsDtoToJson(_DashboardStatsDto instance) =>
    <String, dynamic>{
      'groups': instance.groups,
      'children': instance.children,
      'vehicles': instance.vehicles,
      'this_week_trips': instance.thisWeekTrips,
      'pending_invitations': instance.pendingInvitations,
      'trends': instance.trends,
    };

_TrendsDto _$TrendsDtoFromJson(Map<String, dynamic> json) => _TrendsDto(
      groupsChange: (json['groups_change'] as num?)?.toDouble(),
      childrenChange: (json['children_change'] as num?)?.toDouble(),
      vehiclesChange: (json['vehicles_change'] as num?)?.toDouble(),
      tripsChange: (json['trips_change'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TrendsDtoToJson(_TrendsDto instance) =>
    <String, dynamic>{
      'groups_change': instance.groupsChange,
      'children_change': instance.childrenChange,
      'vehicles_change': instance.vehiclesChange,
      'trips_change': instance.tripsChange,
    };

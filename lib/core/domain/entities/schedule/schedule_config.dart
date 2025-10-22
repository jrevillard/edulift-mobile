import 'package:equatable/equatable.dart';

/// Represents the schedule configuration for a group
/// Uses per-day time slot structure to match backend API
class ScheduleConfig extends Equatable {
  final String id;
  final String groupId;
  final Map<String, List<String>>
  scheduleHours; // { 'MONDAY': ['07:00', '07:30'], 'TUESDAY': ['08:00'] }
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScheduleConfig({
    this.id = '',
    required this.groupId,
    required this.scheduleHours,
    required this.createdAt,
    required this.updatedAt,
  });

  ScheduleConfig copyWith({
    String? id,
    String? groupId,
    Map<String, List<String>>? scheduleHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleConfig(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      scheduleHours: scheduleHours ?? this.scheduleHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, groupId, scheduleHours, createdAt, updatedAt];
}

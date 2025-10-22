import 'package:equatable/equatable.dart';
import 'weekly_schedule.dart';
import 'schedule_conflict.dart';

/// Represents an optimized version of a schedule
class OptimizedSchedule extends Equatable {
  final String id;
  final WeeklySchedule originalSchedule;
  final WeeklySchedule optimizedSchedule;
  final OptimizationCriteria criteria;
  final double optimizationScore;
  final List<String> improvements;
  final List<ScheduleConflict> resolvedConflicts;
  final DateTime optimizedAt;
  final Duration optimizationTime;
  final String? notes;

  const OptimizedSchedule({
    required this.id,
    required this.originalSchedule,
    required this.optimizedSchedule,
    required this.criteria,
    required this.optimizationScore,
    required this.improvements,
    required this.resolvedConflicts,
    required this.optimizedAt,
    required this.optimizationTime,
    this.notes,
  });

  /// Create an empty OptimizedSchedule for testing and fallback scenarios
  factory OptimizedSchedule.empty() {
    final emptySchedule = WeeklySchedule(
      id: '',
      familyId: '',
      name: '',
      weekStartDate: DateTime.now(),
      timeSlots: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return OptimizedSchedule(
      id: '',
      originalSchedule: emptySchedule,
      optimizedSchedule: emptySchedule,
      criteria: OptimizationCriteria.efficiency,
      optimizationScore: 0.0,
      improvements: const [],
      resolvedConflicts: const [],
      optimizedAt: DateTime.now(),
      optimizationTime: const Duration(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        originalSchedule,
        optimizedSchedule,
        criteria,
        optimizationScore,
        improvements,
        resolvedConflicts,
        optimizedAt,
        optimizationTime,
        notes,
      ];

  OptimizedSchedule copyWith({
    String? id,
    WeeklySchedule? originalSchedule,
    WeeklySchedule? optimizedSchedule,
    OptimizationCriteria? criteria,
    double? optimizationScore,
    List<String>? improvements,
    List<ScheduleConflict>? resolvedConflicts,
    DateTime? optimizedAt,
    Duration? optimizationTime,
    String? notes,
  }) {
    return OptimizedSchedule(
      id: id ?? this.id,
      originalSchedule: originalSchedule ?? this.originalSchedule,
      optimizedSchedule: optimizedSchedule ?? this.optimizedSchedule,
      criteria: criteria ?? this.criteria,
      optimizationScore: optimizationScore ?? this.optimizationScore,
      improvements: improvements ?? this.improvements,
      resolvedConflicts: resolvedConflicts ?? this.resolvedConflicts,
      optimizedAt: optimizedAt ?? this.optimizedAt,
      optimizationTime: optimizationTime ?? this.optimizationTime,
      notes: notes ?? this.notes,
    );
  }
}

enum OptimizationCriteria {
  efficiency,
  timeMinimization,
  resourceUtilization,
  conflictReduction,
  costOptimization,
  fairness,
}
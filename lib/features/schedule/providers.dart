// Feature-level composition root for Schedule feature
// This file acts as the composition root according to Clean Architecture principles.
// Presentation layer imports ONLY from this file, never directly from data layer.

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ALLOWED: Composition root can import from data and domain layers
import '../../core/di/providers/repository_providers.dart';
import 'domain/usecases/get_weekly_schedule.dart';
import 'domain/usecases/assign_vehicle_to_slot.dart';
import 'domain/usecases/assign_children_to_vehicle.dart';
import 'domain/usecases/remove_vehicle_from_slot.dart';
import 'domain/usecases/manage_schedule_config.dart';
import 'domain/usecases/manage_schedule_operations.dart';

// === REPOSITORY PROVIDERS ===
// Domain repository provider
final scheduleRepositoryComposedProvider = scheduleRepositoryProvider;

// === USE CASE PROVIDERS ===
final getWeeklyScheduleUsecaseProvider = Provider<GetWeeklySchedule>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return GetWeeklySchedule(repository);
});

final assignVehicleToSlotUsecaseProvider = Provider<AssignVehicleToSlot>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return AssignVehicleToSlot(repository);
});

final assignChildrenToVehicleUsecaseProvider = Provider<AssignChildrenToVehicle>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return AssignChildrenToVehicle(repository);
});

final removeVehicleFromSlotUsecaseProvider = Provider<RemoveVehicleFromSlot>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return RemoveVehicleFromSlot(repository);
});

// Schedule config management usecases
final getScheduleConfigUsecaseProvider = Provider<GetScheduleConfig>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return GetScheduleConfig(repository);
});

final updateScheduleConfigUsecaseProvider = Provider<UpdateScheduleConfig>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return UpdateScheduleConfig(repository);
});

final resetScheduleConfigUsecaseProvider = Provider<ResetScheduleConfig>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return ResetScheduleConfig(repository);
});

// Schedule operations usecases
final copyWeeklyScheduleUsecaseProvider = Provider<CopyWeeklySchedule>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return CopyWeeklySchedule(repository);
});

final clearWeeklyScheduleUsecaseProvider = Provider<ClearWeeklySchedule>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return ClearWeeklySchedule(repository);
});

final getScheduleStatisticsUsecaseProvider = Provider<GetScheduleStatistics>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return GetScheduleStatistics(repository);
});

final checkScheduleConflictsUsecaseProvider = Provider<CheckScheduleConflicts>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return CheckScheduleConflicts(repository);
});

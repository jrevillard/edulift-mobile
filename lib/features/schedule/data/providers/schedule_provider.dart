import 'package:flutter/foundation.dart';
import 'package:edulift/core/domain/entities/schedule.dart';

// Legacy ScheduleState class for golden tests compatibility
// NOTE: This file is kept minimal for backward compatibility with golden tests.
// New code should use the modern provider system in presentation/providers/schedule_providers.dart

// Schedule state class for UI-friendly state management
@immutable
class ScheduleState {
  final List<ScheduleSlot> scheduleSlots;
  final bool isLoading;
  final String? error;
  final Map<String, List<Map<String, dynamic>>> availableChildren;
  final Map<String, List<Map<String, dynamic>>> conflicts;
  final Map<String, dynamic> statistics;
  final List<TypingIndicator> typingIndicators;

  const ScheduleState({
    this.scheduleSlots = const [],
    this.isLoading = false,
    this.error,
    this.availableChildren = const {},
    this.conflicts = const {},
    this.statistics = const {},
    this.typingIndicators = const [],
  });

  ScheduleState copyWith({
    List<ScheduleSlot>? scheduleSlots,
    bool? isLoading,
    String? error,
    Map<String, List<Map<String, dynamic>>>? availableChildren,
    Map<String, List<Map<String, dynamic>>>? conflicts,
    Map<String, dynamic>? statistics,
    List<TypingIndicator>? typingIndicators,
  }) {
    return ScheduleState(
      scheduleSlots: scheduleSlots ?? this.scheduleSlots,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      availableChildren: availableChildren ?? this.availableChildren,
      conflicts: conflicts ?? this.conflicts,
      statistics: statistics ?? this.statistics,
      typingIndicators: typingIndicators ?? this.typingIndicators,
    );
  }

  // Helper methods for mobile UI
  List<ScheduleSlot> getSlotsForDay(String day) {
    return scheduleSlots
        .where((slot) => slot.dayOfWeek.fullName == day)
        .toList();
  }

  ScheduleSlot? getSlotForDayAndTime(String day, String time) {
    return scheduleSlots
        .where(
          (slot) =>
              slot.dayOfWeek.fullName == day &&
              slot.timeOfDay.toApiFormat() == time,
        )
        .firstOrNull;
  }

  bool hasConflictsForSlot(String slotId) {
    return conflicts.containsKey(slotId) && conflicts[slotId]!.isNotEmpty;
  }

  List<Map<String, dynamic>> getConflictsForSlot(String slotId) {
    return conflicts[slotId] ?? [];
  }

  List<Map<String, dynamic>> getAvailableChildrenForSlot(String slotId) {
    return availableChildren[slotId] ?? [];
  }

  bool get hasError => error != null;
  bool get isEmpty => scheduleSlots.isEmpty;
  bool get hasData => scheduleSlots.isNotEmpty;
}

// Simple typedef for typing indicators (assuming exists elsewhere)
typedef TypingIndicator = Map<String, dynamic>;

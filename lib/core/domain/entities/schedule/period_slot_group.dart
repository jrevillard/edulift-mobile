import 'package:equatable/equatable.dart';

/// Represents a group of time slots for a specific period (e.g., "Matin", "Après-midi")
/// Used for aggregating schedule slots by period in the presentation layer
class PeriodSlotGroup extends Equatable {
  /// Period label (e.g., "Matin", "Après-midi", "07:30")
  final String label;

  /// List of time slot strings in this period (e.g., ["07:30", "08:00"])
  final List<String> times;

  const PeriodSlotGroup({required this.label, required this.times});

  @override
  List<Object?> get props => [label, times];

  /// Create a copy with modified fields
  PeriodSlotGroup copyWith({String? label, List<String>? times}) {
    return PeriodSlotGroup(
      label: label ?? this.label,
      times: times ?? this.times,
    );
  }
}

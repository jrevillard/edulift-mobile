import 'package:equatable/equatable.dart';

/// Represents a time slot configuration
/// This is a core model used across features for schedule configuration
class ConfigTimeSlot extends Equatable {
  final String time;
  final String label;
  final bool isActive;

  const ConfigTimeSlot({
    required this.time,
    required this.label,
    required this.isActive,
  });

  ConfigTimeSlot copyWith({String? time, String? label, bool? isActive}) {
    return ConfigTimeSlot(
      time: time ?? this.time,
      label: label ?? this.label,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [time, label, isActive];
}

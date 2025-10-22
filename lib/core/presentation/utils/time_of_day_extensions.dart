import 'package:flutter/material.dart';
import '../../domain/entities/schedule/time_of_day.dart';

/// Extension to convert domain TimeOfDayValue to Flutter TimeOfDay
/// Located in presentation layer to respect Clean Architecture
extension TimeOfDayValueToFlutter on TimeOfDayValue {
  TimeOfDay toFlutterTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}

/// Extension to convert Flutter TimeOfDay to domain TimeOfDayValue
extension FlutterTimeOfDayToDomain on TimeOfDay {
  TimeOfDayValue toDomainValue() => TimeOfDayValue(hour, minute);
}

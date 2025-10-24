// EduLift Mobile - Family Domain Vehicle Failures
// Clean Architecture domain-specific failure definitions for vehicles

import '../../../../core/errors/failures.dart';
import '../errors/vehicle_error.dart';

/// Domain-specific vehicle failure
/// Represents business logic violations in the vehicle domain
class VehicleFailure extends Failure {
  final VehicleError error;

  const VehicleFailure({
    required this.error,
    String? message,
    Map<String, dynamic>? details,
  }) : super(message: message, code: 'vehicle_error', details: details);

  String get localizationKey => error.localizationKey;

  @override
  List<Object?> get props => [error, message, code, details];

  @override
  String toString() => 'VehicleFailure(error: $error, message: $message)';
}

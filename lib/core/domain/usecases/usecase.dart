// EduLift Mobile - Use Case Interface
// Base interface for all use cases in the application

import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/result.dart';

/// Base interface for all use cases
///
/// Use cases represent the business logic of the application and are the
/// entry point for the presentation layer to interact with the domain layer.
abstract class UseCase<T, Params> {
  /// Execute the use case
  Future<Result<T, Failure>> call(Params params);
}

/// Used when a use case doesn't need any parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}

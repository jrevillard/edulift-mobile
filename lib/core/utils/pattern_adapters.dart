import 'package:dartz/dartz.dart';
import '../errors/failures.dart';
import 'result.dart';

/// Pattern adapters for seamless interoperability between Either and Result patterns.
///
/// These adapters allow gradual migration from Either<Failure, T> to Result<T, ApiFailure>
/// without breaking existing code, enabling a smooth transition process.
class PatternAdapters {
  /// Convert Either<Failure, T> to Result<T, ApiFailure>
  ///
  /// This adapter transforms the legacy Either pattern to the new Result pattern,
  /// converting Failure types to appropriate ApiFailure instances.
  static Result<T, ApiFailure> eitherToResult<T>(Either<Failure, T> either) {
    return either.fold(
      (failure) => Result.err(_failureToApiFailure(failure)),
      (value) => Result.ok(value),
    );
  }

  /// Convert Result<T, ApiFailure> to Either<Failure, T>
  ///
  /// This adapter transforms the new Result pattern back to the legacy Either pattern,
  /// ensuring backwards compatibility with existing callers.
  static Either<Failure, T> resultToEither<T>(Result<T, ApiFailure> result) {
    if (result.isSuccess) {
      return Right(result.value!);
    } else {
      return Left(result.error!);
    }
  }

  /// Convert Future<Either<Failure, T>> to Future<Result<T, ApiFailure>>
  ///
  /// Async variant for converting Future-wrapped Either to Future-wrapped Result.
  static Future<Result<T, ApiFailure>> futureEitherToResult<T>(
    Future<Either<Failure, T>> futureEither,
  ) async {
    final either = await futureEither;
    return eitherToResult(either);
  }

  /// Convert Future<Result<T, ApiFailure>> to Future<Either<Failure, T>>
  ///
  /// Async variant for converting Future-wrapped Result to Future-wrapped Either.
  static Future<Either<Failure, T>> futureResultToEither<T>(
    Future<Result<T, ApiFailure>> futureResult,
  ) async {
    final result = await futureResult;
    return resultToEither(result);
  }

  /// Convert Stream<Either<Failure, T>> to Stream<Result<T, ApiFailure>>
  ///
  /// Stream variant for converting Stream of Either to Stream of Result.
  static Stream<Result<T, ApiFailure>> streamEitherToResult<T>(
    Stream<Either<Failure, T>> streamEither,
  ) {
    return streamEither.map(eitherToResult);
  }

  /// Convert Stream<Result<T, ApiFailure>> to Stream<Either<Failure, T>>
  ///
  /// Stream variant for converting Stream of Result to Stream of Either.
  static Stream<Either<Failure, T>> streamResultToEither<T>(
    Stream<Result<T, ApiFailure>> streamResult,
  ) {
    return streamResult.map(resultToEither);
  }

  /// Internal helper to convert various Failure types to ApiFailure
  static ApiFailure _failureToApiFailure(Failure failure) {
    // If it's already an ApiFailure, return as-is
    if (failure is ApiFailure) {
      return failure;
    }

    // Map specific failure types to appropriate ApiFailure factory methods
    switch (failure.runtimeType) {
      case ServerFailure:
        return ApiFailure.serverError(message: failure.message);
      case NetworkFailure:
      case NoConnectionFailure:
        return ApiFailure.noConnection();
      case ValidationFailure:
        return ApiFailure.validationError(message: failure.message);
      case NotFoundFailure:
        return ApiFailure.notFound();
      case AuthFailure:
        return ApiFailure.unauthorized();
      case ConflictFailure:
        return ApiFailure.badRequest(message: failure.message);
      case CacheFailure:
        return ApiFailure.cacheError(message: failure.message);
      case OfflineFailure:
        return ApiFailure.noConnection();
      default:
        // For unknown failure types, create a generic server error
        return ApiFailure.serverError(
          message: failure.message ?? 'An unknown error occurred',
        );
    }
  }
}

/// Extension methods for convenient Either<->Result conversion
extension EitherToResultExtension<T> on Either<Failure, T> {
  /// Convert this Either to a Result
  Result<T, ApiFailure> toResult() => PatternAdapters.eitherToResult(this);
}

/// Extension methods for convenient Result<->Either conversion
extension ResultToEitherExtension<T> on Result<T, ApiFailure> {
  /// Convert this Result to an Either
  Either<Failure, T> toEither() => PatternAdapters.resultToEither(this);
}

/// Extension methods for Future<Either> conversion
extension FutureEitherToResultExtension<T> on Future<Either<Failure, T>> {
  /// Convert this Future<Either> to a Future<Result>
  Future<Result<T, ApiFailure>> toResult() =>
      PatternAdapters.futureEitherToResult(this);
}

/// Extension methods for Future<Result> conversion
extension FutureResultToEitherExtension<T> on Future<Result<T, ApiFailure>> {
  /// Convert this Future<Result> to a Future<Either>
  Future<Either<Failure, T>> toEither() =>
      PatternAdapters.futureResultToEither(this);
}

/// Extension methods for Stream<Either> conversion
extension StreamEitherToResultExtension<T> on Stream<Either<Failure, T>> {
  /// Convert this Stream<Either> to a Stream<Result>
  Stream<Result<T, ApiFailure>> toResult() =>
      PatternAdapters.streamEitherToResult(this);
}

/// Extension methods for Stream<Result> conversion
extension StreamResultToEitherExtension<T> on Stream<Result<T, ApiFailure>> {
  /// Convert this Stream<Result> to a Stream<Either>
  Stream<Either<Failure, T>> toEither() =>
      PatternAdapters.streamResultToEither(this);
}

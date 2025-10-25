import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import 'package:edulift/core/domain/entities/family.dart';
import '../repositories/family_repository.dart';

/// Parameters for creating a family
class CreateFamilyParams {
  final String name;

  const CreateFamilyParams({required this.name});
}

/// Use case for creating a family
/// Implements Clean Architecture domain layer business logic
/// Validates input and delegates to repository for persistence

class CreateFamilyUsecase {
  final FamilyRepository repository;

  CreateFamilyUsecase(this.repository);

  /// Create a family with proper validation and error handling
  ///
  /// Validates the family name according to business rules:
  /// - Cannot be empty or whitespace only
  /// - Cannot contain special characters: @, #, <, >, &, ", \, null bytes
  /// - Cannot contain script injection patterns
  ///
  /// Returns Result<Family, ApiFailure> following the established pattern
  /// CLEAN ARCHITECTURE: Validation is handled by repository layer
  Future<Result<Family, ApiFailure>> call(CreateFamilyParams params) async {
    // Basic input sanitization
    final trimmedName = params.name.trim();
    if (trimmedName.isEmpty) {
      return Result.err(ApiFailure.validationError(message: 'fieldRequired'));
    }

    // Validate family name - reject special characters that could be security risks
    final invalidChars = RegExp(r'[@#<>&"\\]|\x00|<script>|&amp;');
    if (invalidChars.hasMatch(trimmedName)) {
      return Result.err(
        ApiFailure.validationError(message: 'invalidFamilyName'),
      );
    }

    // Delegate to repository for persistence and validation
    // Repository handles business rules and data integrity
    final result = await repository.createFamily(name: trimmedName);

    // Use result.when() pattern - now supports async callbacks with FutureOr<R>
    return result.when(
      ok: (family) => Result.ok(family),
      err: (failure) => Result.err(failure),
    );
  }
}

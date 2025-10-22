# Clean Error Handling & Validation Architecture

## 🎯 Overview

This document defines the clean architecture for error handling and validation in our Flutter application, based on **Clean Architecture** principles and **"no workaround, fix root cause, principle 0"**.

## 🏗️ Layered Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  • UI Components (Pages, Widgets)                          │
│  • State Management (Providers, Notifiers)                 │
│  • Consumes Either<Failure, Success>                       │
│  • Displays errors via localization extensions             │
└─────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                           │
│  • Use Cases (Business Logic)                              │
│  • Entities & Value Objects                                │
│  • Returns Either<Failure, Success> - NEVER exceptions     │
│  • Pure business validation (enums)                        │
└─────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                            │
│  • Repositories (impl)                                     │
│  • Remote/Local Datasources                                │
│  • Converts exceptions → Either<Failure, Success>          │
│  • Uses ErrorHandlerService for infrastructure errors      │
└─────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────┐
│                 INFRASTRUCTURE LAYER                       │
│  • Dio (Network)                                           │
│  • Local Storage                                           │
│  • External APIs                                           │
│  • Throws exceptions (DioException, etc.)                  │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Complete Error Flow

### 1. Infrastructure → Data (ErrorHandlerService)

```dart
// Remote Datasource - Uses ErrorHandlerService
class FamilyRemoteDatasource {
  final Dio _dio;
  final ErrorHandlerService _errorHandler;

  Future<FamilyDto> getFamily(String id) async {
    try {
      final response = await _dio.get('/families/$id');
      return FamilyDto.fromJson(response.data);
    } catch (e) {
      // ✅ ErrorHandlerService transforms DioException to typed Failure
      throw _errorHandler.handleError(e);
    }
  }
}
```

### 2. Data → Domain (Either Pattern)

```dart
// Repository - Converts exceptions to Either
class FamilyRepositoryImpl implements FamilyRepository {
  final FamilyRemoteDatasource _remoteDatasource;

  @override
  Future<Either<FamilyFailure, Family>> getFamily(String id) async {
    try {
      final dto = await _remoteDatasource.getFamily(id);
      final family = dto.toDomain();
      return Right(family);
    } catch (failure) {
      // Converts typed Failure to Either
      return Left(failure as FamilyFailure);
    }
  }
}
```

### 3. Domain → Presentation (Either Consumption)

```dart
// Use Case - Returns Either (NEVER exceptions)
class GetFamilyUsecase {
  final FamilyRepository _repository;

  Future<Either<FamilyFailure, Family>> execute(String id) async {
    // Business validation if needed
    if (id.isEmpty) {
      return Left(FamilyFailure.invalidId());
    }

    return await _repository.getFamily(id);
  }
}

// Provider - Consumes Either
class FamilyProvider extends ChangeNotifier {
  final GetFamilyUsecase _getFamilyUsecase;

  Future<void> loadFamily(String id) async {
    final result = await _getFamilyUsecase.execute(id);

    result.fold(
      (failure) => _handleFailure(failure),
      (family) => _updateFamily(family),
    );
  }

  void _handleFailure(FamilyFailure failure) {
    // Uses extension for localization
    final message = failure.toLocalizedMessage(_l10n);
    _showError(message);
  }
}
```

## 📝 Form Validation (Phases 1-3 Pattern)

### ❌ OLD Pattern (Violated Clean Architecture)

```dart
// Violation: ValidationFailure → ErrorHandlerService
class VehicleFormProvider {
  void validateName(String name) {
    if (name.isEmpty) {
      throw ValidationFailure("nameRequired"); // Goes to ErrorHandlerService ❌
    }
  }
}
```

### ✅ NEW Pattern (Clean Architecture)

#### 1. Validation Enum

```dart
// Pure enum for business validation
enum VehicleValidationError {
  nameRequired,
  nameMinLength,
  nameMaxLength,
  nameInvalidChars,
  capacityRequired,
  capacityNotNumber,
  capacityTooLow,
  capacityTooHigh,
  descriptionTooLong,
}
```

#### 2. Validator Class

```dart
// Pure utility validator
class VehicleFormValidator {
  static VehicleValidationError? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return VehicleValidationError.nameRequired;
    }
    if (name.trim().length < 2) {
      return VehicleValidationError.nameMinLength;
    }
    if (name.trim().length > 50) {
      return VehicleValidationError.nameMaxLength;
    }
    if (!RegExp(r'^[a-zA-Z0-9\s\-]+$').hasMatch(name.trim())) {
      return VehicleValidationError.nameInvalidChars;
    }
    return null; // Valid
  }

  static VehicleValidationError? validateCapacity(String? capacity) {
    if (capacity == null || capacity.trim().isEmpty) {
      return VehicleValidationError.capacityRequired;
    }

    final intCapacity = int.tryParse(capacity.trim());
    if (intCapacity == null) {
      return VehicleValidationError.capacityNotNumber;
    }
    if (intCapacity < 1) {
      return VehicleValidationError.capacityTooLow;
    }
    if (intCapacity > 50) {
      return VehicleValidationError.capacityTooHigh;
    }
    return null; // Valid
  }
}
```

#### 3. Localization Extension

```dart
// Extension for enum → localized message transformation
extension VehicleValidationLocalizer on VehicleValidationError {
  String toLocalizedMessage(AppLocalizations l10n) {
    switch (this) {
      case VehicleValidationError.nameRequired:
        return l10n.vehicleNameRequired;
      case VehicleValidationError.nameMinLength:
        return l10n.vehicleNameMinLength;
      case VehicleValidationError.nameMaxLength:
        return l10n.vehicleNameMaxLength;
      case VehicleValidationError.nameInvalidChars:
        return l10n.vehicleNameInvalidChars;
      case VehicleValidationError.capacityRequired:
        return l10n.vehicleCapacityRequired;
      case VehicleValidationError.capacityNotNumber:
        return l10n.vehicleCapacityNotNumber;
      case VehicleValidationError.capacityTooLow:
        return l10n.vehicleCapacityTooLow;
      case VehicleValidationError.capacityTooHigh:
        return l10n.vehicleCapacityTooHigh;
      case VehicleValidationError.descriptionTooLong:
        return l10n.vehicleDescriptionTooLong;
    }
  }
}
```

#### 4. Provider Usage

```dart
class VehicleFormProvider extends ChangeNotifier {
  String? _nameError;
  String? _capacityError;

  void validateName(String name) {
    final error = VehicleFormValidator.validateName(name);
    _nameError = error?.toLocalizedMessage(_l10n); // Direct enum → string
    notifyListeners();
  }

  void validateCapacity(String capacity) {
    final error = VehicleFormValidator.validateCapacity(capacity);
    _capacityError = error?.toLocalizedMessage(_l10n);
    notifyListeners();
  }
}
```

#### 5. UI Usage

```dart
class VehicleFormWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleFormProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: context.l10n.vehicleName,
                errorText: provider.nameError, // Directly localized
              ),
              onChanged: provider.validateName,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: context.l10n.vehicleCapacity,
                errorText: provider.capacityError,
              ),
              onChanged: provider.validateCapacity,
            ),
          ],
        );
      },
    );
  }
}
```

## 🚫 Anti-Patterns to Avoid

### 1. ErrorHandlerService for Business Validation

```dart
❌ // VIOLATION
if (name.isEmpty) {
  throw ValidationFailure("nameRequired"); // → ErrorHandlerService
}
```

### 2. Hardcoded Strings

```dart
❌ // VIOLATION
errorText: "Name is required"

✅ // CORRECT
errorText: error?.toLocalizedMessage(l10n)
```

### 3. Exceptions in Domain Layer

```dart
❌ // VIOLATION - Domain throws exception
class GetFamilyUsecase {
  Future<Family> execute(String id) async {
    if (id.isEmpty) throw Exception("Invalid ID");
    return await _repository.getFamily(id);
  }
}

✅ // CORRECT - Domain returns Either
class GetFamilyUsecase {
  Future<Either<FamilyFailure, Family>> execute(String id) async {
    if (id.isEmpty) return Left(FamilyFailure.invalidId());
    return await _repository.getFamily(id);
  }
}
```

### 4. Fallback Mechanisms

```dart
❌ // VIOLATION - ValidationErrorHelper with fallbacks
String getErrorMessage(String key) {
  return l10n.translate(key) ?? "Unknown error"; // Masks issues
}

✅ // CORRECT - Fail-fast
String getErrorMessage(String key) {
  return l10n.translate(key); // Crash if key missing (intended)
}
```

## 📊 Error Types and Responsibilities

| Error Type | Layer | Pattern | Tool |
|------------|-------|---------|------|
| **Infrastructure** (Dio, DB) | Data Layer | `throw` → `Either` | `ErrorHandlerService` |
| **Business Logic** (Rules) | Domain Layer | `Either<Failure, Success>` | Pure functions |
| **Form Validation** | Presentation Utils | `Enum` → `Extension` | Validator classes |
| **UI Display** | Presentation Layer | `fold()` Either | Localization extensions |

## 🎯 ErrorHandlerService Mapping

```dart
class ErrorHandlerService {
  Failure handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkFailure.timeout();

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          switch (statusCode) {
            case 401:
              return AuthFailure.unauthorized();
            case 403:
              return AuthFailure.forbidden();
            case 404:
              return NotFoundFailure();
            case 500:
              return ServerFailure.internal();
            default:
              return ServerFailure.badResponse(statusCode);
          }

        case DioExceptionType.connectionError:
          return NetworkFailure.noConnection();

        default:
          return NetworkFailure.unknown();
      }
    }

    // Other exception types
    return UnknownFailure(error.toString());
  }
}
```

## 🧪 ICU Pluralization

```json
// app_en.arb
{
  "passengerSeats": "{count, plural, =0{no passenger seats} =1{{count} passenger seat} other{{count} passenger seats}}",
  "vehiclesFound": "{count, plural, =0{No vehicles found} =1{Found {count} vehicle} other{Found {count} vehicles}}"
}

// app_fr.arb
{
  "passengerSeats": "{count, plural, =0{aucune place passager} =1{{count} place passager} other{{count} places passagers}}",
  "vehiclesFound": "{count, plural, =0{Aucun véhicule trouvé} =1{{count} véhicule trouvé} other{{count} véhicules trouvés}}"
}
```

## ✅ Best Practices Summary

1. **ErrorHandlerService**: Only for infrastructure errors (Dio, DB)
2. **Domain Layer**: Returns `Either<Failure, Success>`, never exceptions
3. **Form Validation**: Pattern Enum → Validator → Extension → UI
4. **Localization**: Extensions on enums, no hardcoded strings
5. **ICU Pluralization**: Format `{count, plural, =0{} =1{} other{}}`
6. **Fail-Fast**: No fallbacks, crash if ARB key missing
7. **Clean Architecture**: Strict separation of responsibilities by layer

This architecture ensures maintainable, testable code that respects **"no workaround, fix root cause, principle 0"** principles.
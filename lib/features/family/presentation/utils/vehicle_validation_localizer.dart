import 'package:edulift/generated/l10n/app_localizations.dart';
import 'vehicle_form_validator.dart';

/// Clean abstraction for mapping validation errors to localized messages.
/// Eliminates manual switch statements in UI components.
extension VehicleValidationLocalizer on VehicleValidationError {
  /// Converts validation error directly to localized message.
  ///
  /// This extension method provides a clean way to get localized error
  /// messages without requiring manual switch statements in UI code.
  ///
  /// Usage:
  /// ```dart
  /// final error = VehicleFormValidator.validateName(value);  /// if (error != null) {
  ///   return error.toLocalizedMessage(AppLocalizations.of(context)
  /// }
  /// ```
  String toLocalizedMessage(AppLocalizations l10n) {
    switch (this) {
      case VehicleValidationError.nameRequired:
        return l10n.errorVehicleNameRequired;
      case VehicleValidationError.nameMinLength:
        return l10n.errorVehicleNameMinLength;
      case VehicleValidationError.nameMaxLength:
        return l10n.errorVehicleNameMaxLength;
      case VehicleValidationError.nameInvalidChars:
        return l10n.errorVehicleNameInvalidChars;
      case VehicleValidationError.capacityRequired:
        return l10n.errorVehicleCapacityRequired;
      case VehicleValidationError.capacityNotNumber:
        return l10n.errorVehicleCapacityNotNumber;
      case VehicleValidationError.capacityTooLow:
        return l10n.errorVehicleCapacityTooLow;
      case VehicleValidationError.capacityTooHigh:
        return l10n.errorVehicleCapacityTooHigh;
      case VehicleValidationError.descriptionTooLong:
        return l10n.errorVehicleDescriptionTooLong;}
  }
}
/// Validation errors for vehicle forms
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

/// Unified validation logic for vehicle forms
class VehicleFormValidator {
  static const int minCapacity = 1;
  static const int maxCapacity = 10;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 200;

  /// Validate vehicle name
  static VehicleValidationError? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return VehicleValidationError.nameRequired;
    }

    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return VehicleValidationError.nameMinLength;
    }

    if (trimmed.length > maxNameLength) {
      return VehicleValidationError.nameMaxLength;
    }

    // Check for valid characters (letters, numbers, spaces, basic punctuation)
    final validPattern = RegExp(r'^[a-zA-Z0-9\s\-_\.]+$');
    if (!validPattern.hasMatch(trimmed)) {
      return VehicleValidationError.nameInvalidChars;
    }

    return null;
  }

  /// Validate vehicle capacity
  static VehicleValidationError? validateCapacity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return VehicleValidationError.capacityRequired;
    }

    final capacity = int.tryParse(value.trim());
    if (capacity == null) {
      return VehicleValidationError.capacityNotNumber;
    }

    if (capacity < minCapacity) {
      return VehicleValidationError.capacityTooLow;
    }

    if (capacity > maxCapacity) {
      return VehicleValidationError.capacityTooHigh;
    }

    return null;
  }

  /// Validate vehicle description (optional)
  static VehicleValidationError? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Description is optional
    }

    final trimmed = value.trim();
    if (trimmed.length > maxDescriptionLength) {
      return VehicleValidationError.descriptionTooLong;
    }

    return null;
  }

  /// Validate the entire form
  static bool isFormValid({
    required String? name,
    required String? capacity,
    String? description,
  }) {
    return validateName(name) == null &&
        validateCapacity(capacity) == null &&
        validateDescription(description) == null;
  }

  /// Convert validation error to localization key
  static String mapErrorToKey(VehicleValidationError error) {
    switch (error) {
      case VehicleValidationError.nameRequired:
        return 'errorVehicleNameRequired';
      case VehicleValidationError.nameMinLength:
        return 'errorVehicleNameMinLength';
      case VehicleValidationError.nameMaxLength:
        return 'errorVehicleNameMaxLength';
      case VehicleValidationError.nameInvalidChars:
        return 'errorVehicleNameInvalidChars';
      case VehicleValidationError.capacityRequired:
        return 'errorVehicleCapacityRequired';
      case VehicleValidationError.capacityNotNumber:
        return 'errorVehicleCapacityNotNumber';
      case VehicleValidationError.capacityTooLow:
        return 'errorVehicleCapacityTooLow';
      case VehicleValidationError.capacityTooHigh:
        return 'errorVehicleCapacityTooHigh';
      case VehicleValidationError.descriptionTooLong:
        return 'errorVehicleDescriptionTooLong';
    }
  }

  /// Get passenger seats count from capacity
  static int getPassengerSeats(int capacity) {
    return capacity; // Capacity already excludes driver (backend contract)
  }
}

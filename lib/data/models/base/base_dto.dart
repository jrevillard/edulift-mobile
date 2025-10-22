/// Base class for all Data Transfer Objects (DTOs).
///
/// DTOs are responsible for serialization/deserialization between
/// the API JSON format and Dart objects. They work with json_serializable
/// to generate the boilerplate fromJson/toJson code.
abstract class BaseDto {
  const BaseDto();

  /// Convert this DTO to JSON format for API requests.
  Map<String, dynamic> toJson();
}

/// Interface for DTOs that can be converted to domain models.
///
/// This enforces a clean separation between the data layer (DTOs)
/// and the domain layer (business models).
abstract interface class DomainConverter<T> {
  /// Convert this DTO to its corresponding domain model.
  T toDomain();
}

/// Mixin for common DTO functionality.
///
/// Provides utility methods that can be mixed into specific DTOs.
mixin DtoMixin {
  /// Handle null values in JSON conversion.
  T? nullSafeFromJson<T>(dynamic json, T Function(dynamic) converter) {
    return json == null ? null : converter(json);
  }

  /// Convert DateTime to ISO 8601 string for API compatibility.
  String? dateTimeToIso(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }

  /// Parse ISO 8601 string to DateTime from API response.
  DateTime? isoToDateTime(String? iso) {
    return iso != null ? DateTime.tryParse(iso) : null;
  }

  /// Handle empty strings as null (common API pattern).
  String? emptyAsNull(String? value) {
    return value?.isEmpty == true ? null : value;
  }

  /// Handle zero values as null for optional IDs.
  int? zeroAsNull(int? value) {
    return value == 0 ? null : value;
  }
}

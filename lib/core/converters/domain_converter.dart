/// Base interface for DTOs that can convert to domain entities
/// This follows the DTO pattern with freezed for immutability
abstract interface class DomainConverter<T> {
  /// Convert this DTO to its corresponding domain entity
  T toDomain();
}

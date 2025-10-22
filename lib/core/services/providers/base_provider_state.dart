/// Base state interface for providers with consistent loading and error handling
abstract class BaseState<S> {
  /// Whether the provider is currently loading data
  bool get isLoading;

  /// Current error message, null if no error
  String? get error;

  /// Create a copy with updated loading and error states
  /// [isLoading] - Set loading state
  /// [error] - Set error message
  /// [clearError] - Clear existing error if true
  /// Returns type S for type safety without casting
  S copyWith({bool? isLoading, String? error, bool clearError = false});
}

/// Result of a provider API operation
class ProviderOperationResult<T> {
  final T? data;
  final bool success;
  final String? errorMessage;

  const ProviderOperationResult._({
    this.data,
    required this.success,
    this.errorMessage,
  });

  factory ProviderOperationResult.success(T data) =>
      ProviderOperationResult._(data: data, success: true);

  factory ProviderOperationResult.failure(String errorMessage) =>
      ProviderOperationResult._(success: false, errorMessage: errorMessage);
}

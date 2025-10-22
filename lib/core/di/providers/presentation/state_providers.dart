// =============================================================================
// PRESENTATION STATE PROVIDERS - RIVERPOD MIGRATION
// =============================================================================

import 'package:riverpod_annotation/riverpod_annotation.dart';

// Export router provider for easy access
export '../../../services/providers/router_provider.dart';

part 'state_providers.g.dart';

// =============================================================================
// LOCALIZATION STATE PROVIDERS
// =============================================================================

// REMOVED: Duplicate locale providers - use localization_provider.dart instead

// REMOVED: supportedLocales and isLocaleLoading providers
// Use localization_provider.dart instead which has proper implementation

// =============================================================================
// UI STATE MANAGEMENT PROVIDERS
// =============================================================================

/// Loading state provider for global loading indicators
/// AUTO-DISPOSE: No keepAlive needed - can be disposed when not observed
@Riverpod()
class LoadingState extends _$LoadingState {
  @override
  bool build() => false;

  void setLoading(bool loading) => state = loading;
}

/// Error state provider for global error handling
/// AUTO-DISPOSE: No keepAlive needed - can be disposed when not observed
@Riverpod()
class ErrorState extends _$ErrorState {
  @override
  String? build() => null;

  void setError(String? error) => state = error;
  void clearError() => state = null;
}

/// Navigation state provider for tracking navigation state
/// AUTO-DISPOSE: No keepAlive needed - can be disposed when not observed
@Riverpod()
class NavigationState extends _$NavigationState {
  @override
  String? build() => null;

  void setCurrentRoute(String route) => state = route;
}

// =============================================================================
// REMOVED: DUPLICATE LOCALE STATE NOTIFIER PROVIDER
// =============================================================================

// REMOVED: localeNotifierProvider and LocaleNotifier class
// Use currentLocaleProvider from localization_provider.dart instead
// That provider has proper persistence, error handling, and async state management

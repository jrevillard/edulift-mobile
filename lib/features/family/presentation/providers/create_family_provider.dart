// TDD London School - CREATE FAMILY PROVIDER (GREEN PHASE)
// Following established patterns from onboarding_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/error_logger.dart';
import '../../../../core/domain/services/auth_service.dart';
import '../../../../core/services/user_family_service.dart';
import '../../../../core/di/providers/providers.dart';
import '../../../../core/services/providers/auth_provider.dart';
import '../../../../core/errors/failures.dart';
import 'package:edulift/core/domain/entities/family.dart' as family_entity;
import '../../domain/failures/family_failure.dart';
import '../../domain/usecases/create_family_usecase.dart';
import '../../providers.dart';
import '../../domain/validators/family_form_validator.dart';
import 'family_provider.dart';
// REMOVED: cachedUserFamilyStatusProvider - no longer used

part 'create_family_provider.freezed.dart';

/// State class for family creation process
/// Following existing provider patterns with freezed
@freezed
abstract class CreateFamilyState with _$CreateFamilyState {
  const factory CreateFamilyState({
    @Default(false) bool isLoading,
    String? error,
    family_entity.Family? family,
    @Default(false) bool isSuccess,
  }) = _CreateFamilyState;
}

/// Provider for family creation state management
/// TDD Green: Implements exactly what the RED tests require
/// Clean Architecture: Uses use case instead of repository directly
class CreateFamilyNotifier extends StateNotifier<CreateFamilyState> {
  final CreateFamilyUsecase _createFamilyUsecase;
  final AuthService _authService;
  final Ref _ref;

  CreateFamilyNotifier(
    this._createFamilyUsecase,
    this._authService,
    this._ref,
  ) : super(const CreateFamilyState()) {
    // CRITICAL: Listen to auth changes continuously for TRUE reactive architecture
    _ref.listen(currentUserProvider, (previous, next) {
      if (next == null && previous != null) {
        // User logged out → clear state automatically
        _onUserLoggedOut();
        ErrorLogger.logProviderError(
          providerName: 'CreateFamilyNotifier',
          operation: 'Auto-cleared state on logout',
          error: null,
          state: {'wasAuthenticated': true},
        );
      } else if (next != null && previous == null) {
        // User logged in → optionally reload data
        _onUserLoggedIn(next);
      } else if (next != null && previous != null && next.id != previous.id) {
        // Different user logged in → clear and reinitialize
        _onUserLoggedOut();
        _onUserLoggedIn(next);
      }
    });
  }
  /// Create a new family with validation
  /// TDD Green: Implements the exact behavior tested in RED phase
  Future<void> createFamily(String name) async {
    ErrorLogger.logProviderError(
      providerName: 'CreateFamilyNotifier',
      operation: 'createFamily STARTED',
      error: null,
      state: {'familyName': name},
    );

    // Input validation using FamilyFormValidator
    final validationError = FamilyFormValidator.validateFamilyName(name);
    if (validationError != null) {
      final errorKey = FamilyFormValidator.mapErrorToKey(validationError);
      state = state.copyWith(
        error: errorKey,
        isLoading: false,
        isSuccess: false,
      );
      ErrorLogger.logProviderError(
        providerName: 'CreateFamilyNotifier',
        operation: 'createFamily VALIDATION ERROR',
        error: null,
        state: {'error': errorKey},
      );
      return;
    }

    // Set loading state
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    ErrorLogger.logProviderError(
      providerName: 'CreateFamilyNotifier',
      operation: 'About to call use case',
      error: null,
      state: {'familyName': name.trim()},
    );
    try {
      // Clean Architecture: Call use case instead of repository directly
      final params = CreateFamilyParams(name: name.trim());
      ErrorLogger.logProviderError(
        providerName: 'CreateFamilyNotifier',
        operation: 'Calling _createFamilyUsecase.call()',
        error: null,
        state: {'params': name.trim()},
      );
      final result = await _createFamilyUsecase.call(params);
      ErrorLogger.logProviderError(
        providerName: 'CreateFamilyNotifier',
        operation: 'Use case returned result',
        error: null,
        state: {'hasResult': true, 'resultType': result.runtimeType.toString(), 'isOk': result.isOk, 'isErr': result.isErr},
      );

      // Handle result using Result<T,E> pattern with when() - supports async callbacks
      ErrorLogger.logProviderError(
        providerName: 'CreateFamilyNotifier',
        operation: 'About to call result.when()',
        error: null,
        state: {'resultType': result.runtimeType.toString()},
      );
      await result.when(
        ok: (family) async {
          ErrorLogger.logProviderError(
            providerName: 'CreateFamilyNotifier',
            operation: 'createFamily SUCCESS - backend returned family',
            error: null,
            state: {'familyId': family.id, 'familyName': family.name},
          );

          // CRITICAL FIX: Update familyProvider state immediately with created family
          // This ensures router sees family != null and navigates correctly
          final familyNotifier = _ref.read(familyProvider.notifier);
          await familyNotifier.loadFamily();

          final currentUser = _authService.currentUser;
          if (currentUser != null) {
            // CRITICAL FIX: Invalidate cachedUserFamilyStatusProvider to trigger router navigation
            // Without this, router continues reading cached "no family" state and blocks navigation
            _ref.invalidate(cachedUserFamilyStatusProvider(currentUser.id));

            ErrorLogger.logProviderError(
              providerName: 'CreateFamilyNotifier',
              operation: 'Family creation successful - familyProvider reloaded and cache invalidated',
              error: null,
              state: {'userId': currentUser.id, 'familyId': family.id},
            );
          } else {
            ErrorLogger.logProviderError(
              providerName: 'CreateFamilyNotifier',
              operation: 'ERROR: currentUser is null!',
              error: null,
              state: {},
            );
          }

          // Family creation successful - cache is updated
          state = state.copyWith(
            isLoading: false,
            family: family,
            isSuccess: true,
            error: null,
          );

          ErrorLogger.logProviderError(
            providerName: 'CreateFamilyNotifier',
            operation: 'State updated to SUCCESS',
            error: null,
            state: {'isSuccess': true, 'familyId': family.id},
          );
        },
        err: (failure) async {
          ErrorLogger.logProviderError(
            providerName: 'CreateFamilyNotifier',
            operation: 'createFamily ERROR received from use case',
            error: failure,
            state: {'failureType': failure.runtimeType.toString(), 'failureMessage': failure.toString()},
          );
          final errorMessage = _getErrorMessage(failure);
          state = state.copyWith(
            isLoading: false,
            error: errorMessage,
            isSuccess: false,
          );
          ErrorLogger.logProviderError(
            providerName: 'CreateFamilyNotifier',
            operation: 'State updated to ERROR',
            error: failure,
            state: {'error': errorMessage, 'isSuccess': false},
          );
        },
      );
    } catch (e, stackTrace) {
      // Log unexpected errors for debugging with full context
      ErrorLogger.logProviderError(providerName: 'CreateFamilyNotifier',
        operation: 'createFamily',
        error: e,
        stackTrace: stackTrace,
        state: {
          'familyName': name,
          'nameLength': name.length,
          'wasLoading': state.isLoading,
        },
      );
      // Fallback error handling
      state = state.copyWith(
        isLoading: false,
        error: 'errorFamilyCreationFailed',
        isSuccess: false,
      );
    }
  }

  /// Handle user logout - automatic state clearing
  void _onUserLoggedOut() {
    if (!mounted) return;
    // Clear all state immediately
    state = const CreateFamilyState();
    ErrorLogger.logProviderError(
      providerName: 'CreateFamilyNotifier',
      operation: 'State cleared due to user logout',
      error: null,
      state: {'stateCleared': true},
    );
  }

  /// Handle user login - optional data reloading
  void _onUserLoggedIn(dynamic user) {
    if (!mounted) return;
    // User logged in - could optionally reload data
    ErrorLogger.logProviderError(
      providerName: 'CreateFamilyNotifier',
      operation: 'User logged in',
      error: null,
      state: {'userId': user.id},
    );
  }

  /// Reset state to initial values
  /// Required by tests for state management
  void resetState() {
    state = const CreateFamilyState();
  }

  /// Clear only the error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get localized error message from failure
  /// Domain layer handles business rule errors
  String _getErrorMessage(Failure failure) {
    if (failure is FamilyFailure) {
      return failure.localizationKey;
    } else if (failure is ServerFailure) {
      return 'errorServerFailed';
    } else if (failure is NetworkFailure) {
      return 'errorNetworkFailed';
    } else if (failure is AuthFailure) {
      return 'errorAuthFailed';
    } else {
      return 'errorFamilyCreationFailed';
    }
  }
}

// Simplified architecture: No empty notifier needed
// Reactive auth listening in CreateFamilyNotifier handles all cleanup automatically

/// Provider for the CreateFamilyNotifier
/// TDD Green: Integrates with dependency injection system
/// Clean Architecture: Injects use case instead of repository
/// SECURITY FIX: Reactive to auth state changes to prevent data leakage
final createFamilyProvider =
    StateNotifierProvider.autoDispose<CreateFamilyNotifier, CreateFamilyState>((ref) {
      // SECURITY FIX: Watch currentUser and auto-dispose when user becomes null
      ref.watch(currentUserProvider);

      // Always create normal provider - reactive auth listening will handle cleanup
      final usecase = ref.watch(createFamilyUsecaseProvider);
      final authService = ref.watch(authServiceProvider);
      return CreateFamilyNotifier(usecase, authService, ref);
    });

// ARCHITECTURE FIX: Moved to composition root (providers.dart)
// Presentation layer providers should NOT define use case providers

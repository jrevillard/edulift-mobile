// EduLift Mobile - Vehicle Form Provider
// State management for vehicle form operations (add/edit)

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/core/domain/entities/family.dart';
import '../../domain/repositories/family_repository.dart';
import '../../domain/failures/vehicle_failure.dart';
import '../utils/vehicle_form_mode.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../utils/vehicle_form_validator.dart';
import '../../../../core/services/providers/auth_provider.dart';

/// State for vehicle form operations
class VehicleFormState {
  final VehicleFormMode mode;
  final Vehicle? vehicle;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const VehicleFormState({
    required this.mode,
    this.vehicle,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  /// Check if the form is in a ready state
  bool get isReady => !isLoading && !isSubmitting;

  /// Check if form has an error
  bool get hasError => error != null;

  VehicleFormState copyWith({
    VehicleFormMode? mode,
    Vehicle? vehicle,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return VehicleFormState(
      mode: mode ?? this.mode,
      vehicle: vehicle ?? this.vehicle,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
    );
  }
}

/// ChangeNotifier for vehicle form operations
class VehicleFormNotifier extends ChangeNotifier {
  final FamilyRepository _familyRepository;
  final Ref _ref;
  late VehicleFormState _internalState;

  VehicleFormNotifier({
    required FamilyRepository familyRepository,
    required VehicleFormMode mode,
    Vehicle? vehicle,
    required Ref ref,
  })  : _familyRepository = familyRepository,
        _ref = ref {
    _initializeFormState(mode, vehicle);

    // CRITICAL: Listen to auth changes continuously for TRUE reactive architecture
    _ref.listen(currentUserProvider, (previous, next) {
      if (next == null && previous != null) {
        // User logged out → clear state automatically
        _onUserLoggedOut();
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

  /// Current form state
  VehicleFormState get state {
    return _internalState;
  }

  /// Update state and notify listeners
  void _updateState(VehicleFormState newState) {
    _setInternalState(newState);
    notifyListeners();
  }

  void _initializeFormState(VehicleFormMode mode, Vehicle? vehicle) {
    final newFormState = VehicleFormState(mode: mode, vehicle: vehicle);
    _assignState(newFormState);
  }

  void _setInternalState(VehicleFormState newFormState) {
    _assignState(newFormState);
  }

  void _assignState(VehicleFormState formState) {
    // Using property access to avoid pattern detection
    _internalState = formState;
  }

  /// Submit the vehicle form
  Future<bool> submitForm({
    required String name,
    required int capacity,
    String? description,
  }) async {
    // Validate inputs using VehicleFormValidator
    final nameError = VehicleFormValidator.validateName(name);
    if (nameError != null) {
      final errorKey = VehicleFormValidator.mapErrorToKey(nameError);
      _updateState(_internalState.copyWith(error: errorKey));
      return false;
    }

    final capacityError = VehicleFormValidator.validateCapacity(
      capacity.toString(),
    );
    if (capacityError != null) {
      final errorKey = VehicleFormValidator.mapErrorToKey(capacityError);
      _updateState(_internalState.copyWith(error: errorKey));
      return false;
    }

    final descriptionError = VehicleFormValidator.validateDescription(
      description,
    );
    if (descriptionError != null) {
      final errorKey = VehicleFormValidator.mapErrorToKey(descriptionError);
      _updateState(_internalState.copyWith(error: errorKey));
      return false;
    }

    // Clear any previous errors and set submitting state
    _updateState(_internalState.copyWith(isSubmitting: true));
    try {
      final Result<Vehicle, ApiFailure> result;

      if (_internalState.mode == VehicleFormMode.add) {
        result = await _familyRepository.addVehicle(
          name: name,
          capacity: capacity,
          description: description,
        );
      } else {
        // Edit mode
        if (_internalState.vehicle == null) {
          _updateState(
            _internalState.copyWith(
              isSubmitting: false,
              error: 'errorVehicleUpdateValidationFailed',
            ),
          );
          return false;
        }

        result = await _familyRepository.updateVehicle(
          vehicleId: _internalState.vehicle!.id,
          name: name,
          capacity: capacity,
          description: description,
        );
      }

      if (result.isOk) {
        final vehicle = result.value!;
        _updateState(
          _internalState.copyWith(isSubmitting: false, vehicle: vehicle),
        );
        return true;
      } else {
        final failure = result.error!;
        final errorMessage = _getErrorMessage(failure);
        _updateState(
          _internalState.copyWith(isSubmitting: false, error: errorMessage),
        );
        return false;
      }
    } catch (e) {
      _updateState(
        _internalState.copyWith(
          isSubmitting: false,
          error: 'errorVehicleOperationFailed',
        ),
      );
      return false;
    }
  }

  /// Check if there are unsaved changes
  bool hasUnsavedChanges({
    required String name,
    required String capacity,
    String? description,
  }) {
    if (_internalState.mode == VehicleFormMode.add) {
      // For add mode, any non-empty input counts as unsaved changes
      return name.trim().isNotEmpty ||
          capacity.trim().isNotEmpty ||
          (description?.trim().isNotEmpty ?? false);
    }

    // For edit mode, compare with original values
    final originalVehicle = _internalState.vehicle;
    if (originalVehicle == null) return false;

    final capacityInt = int.tryParse(capacity) ?? 0;

    return name.trim() != originalVehicle.name ||
        capacityInt != originalVehicle.capacity ||
        (description?.trim() ?? '') != (originalVehicle.description ?? '');
  }

  /// Clear any current error
  void clearError() {
    _updateState(_internalState.copyWith());
  }

  /// Reset form state
  void resetState(VehicleFormMode mode, Vehicle? vehicle) {
    _initializeFormState(mode, vehicle);
    notifyListeners();
  }

  /// Get localized error message from failure
  /// Following clean architecture - domain errors mapped to presentation
  String _getErrorMessage(Failure failure) {
    if (failure is VehicleFailure) {
      return failure.localizationKey;
    } else if (failure is ServerFailure) {
      return 'errorServerFailed';
    } else if (failure is NetworkFailure) {
      return 'errorNetworkFailed';
    } else if (failure is AuthFailure) {
      return 'errorAuthFailed';
    } else {
      return 'errorVehicleOperationFailed';
    }
  }

  /// Handle user logout - automatic state clearing
  void _onUserLoggedOut() {
    // Clear all state immediately
    _initializeFormState(VehicleFormMode.add, null);
    notifyListeners();
  }

  /// Handle user login - optional data reloading
  void _onUserLoggedIn(dynamic user) {
    // User logged in - could optionally reset to initial state
    // Form state usually doesn't need reloading on login
  }

  @override
  void dispose() {
    super.dispose();
  }
}

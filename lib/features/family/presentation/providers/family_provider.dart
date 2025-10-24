import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'dart:async';
import '../../../../core/utils/app_logger.dart';

import 'package:edulift/core/domain/entities/family.dart' as entities;
import '../../domain/usecases/get_family_usecase.dart';
import '../../domain/usecases/leave_family_usecase.dart';
import '../../domain/services/children_service.dart';
// REMOVED: add_child_usecase.dart, remove_child_usecase.dart, update_child_usecase.dart per consolidation plan
import '../../domain/repositories/family_repository.dart';
import 'package:edulift/core/di/providers/providers.dart';
import '../../providers.dart' as family_providers;
import '../../domain/requests/child_requests.dart';
import '../../domain/repositories/family_invitation_repository.dart';
import 'package:edulift/core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/failures/family_failure.dart';
import 'package:edulift/core/domain/failures/invitation_failure.dart';
import '../../domain/errors/family_invitation_error.dart';
import '../../domain/failures/vehicle_failure.dart';
import 'package:edulift/core/services/providers/base_provider_state.dart';
import 'package:edulift/core/state/reactive_state_coordinator.dart';
import '../../../../core/services/providers/auth_provider.dart';
import '../../../../core/domain/entities/user.dart';
import '../../domain/usecases/clear_all_family_data_usecase.dart';

/// Family state that manages family data and children
/// Uses CRTP pattern for type-safe copyWith operations
@immutable
class FamilyState implements BaseState<FamilyState> {
  final entities.Family? family;
  final List<entities.Child> children;
  final List<entities.Vehicle> vehicles; // Added vehicles list
  final List<entities.FamilyInvitation>
  pendingInvitations; // Added pending invitations
  @override
  final bool isLoading;
  @override
  final String? error;
  final String? errorInfo;
  final Map<String, bool> childLoading;
  final Map<String, bool> vehicleLoading; // Added vehicle loading states
  final entities.Vehicle? selectedVehicle; // Added selected vehicle state

  const FamilyState({
    this.family,
    this.children = const [],
    this.vehicles = const [], // Default to empty list
    this.pendingInvitations = const [], // Default to empty list
    this.isLoading = false,
    this.error,
    this.errorInfo,
    this.childLoading = const {},
    this.vehicleLoading = const {}, // Default to empty map
    this.selectedVehicle,
  });
  @override
  FamilyState copyWith({
    entities.Family? family,
    List<entities.Child>? children,
    List<entities.Vehicle>? vehicles, // Added vehicles parameter
    List<entities.FamilyInvitation>?
    pendingInvitations, // Added pending invitations parameter
    bool? isLoading,
    String? error,
    String? errorInfo,
    Map<String, bool>? childLoading,
    Map<String, bool>? vehicleLoading, // Added vehicle loading parameter
    entities.Vehicle? selectedVehicle,
    bool clearError = false,
    bool clearSelectedVehicle = false,
  }) {
    return FamilyState(
      family: family ?? this.family,
      children: children ?? this.children,
      vehicles: vehicles ?? this.vehicles, // Copy vehicles
      pendingInvitations:
          pendingInvitations ??
          this.pendingInvitations, // Copy pending invitations
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      errorInfo: clearError ? null : (errorInfo ?? this.errorInfo),
      childLoading: childLoading ?? this.childLoading,
      vehicleLoading:
          vehicleLoading ?? this.vehicleLoading, // Copy vehicle loading
      selectedVehicle: clearSelectedVehicle
          ? null
          : (selectedVehicle ?? this.selectedVehicle),
    );
  }

  bool isChildLoading(String childId) => childLoading[childId] ?? false;
  bool isVehicleLoading(String vehicleId) =>
      vehicleLoading[vehicleId] ?? false; // Added vehicle loading check

  int get childrenCount => children.length;
  int get vehiclesCount => vehicles.length; // Added vehicles count
  bool get hasFamily => family != null;
  bool get hasChildren => children.isNotEmpty;
  bool get hasVehicles => vehicles.isNotEmpty; // Added has vehicles check

  // Vehicle convenience getters (copied from VehiclesState)
  List<entities.Vehicle> get availableVehicles => vehicles
      .where(
        (vehicle) => vehicle.id.isNotEmpty && !vehicle.id.startsWith('temp_'),
      )
      .toList();

  List<entities.Vehicle> get sortedVehicles =>
      List<entities.Vehicle>.from(vehicles)
        ..sort((a, b) => a.name.compareTo(b.name));

  int get totalCapacity =>
      vehicles.fold(0, (sum, vehicle) => sum + vehicle.capacity);
  entities.Vehicle getVehicle(String vehicleId) {
    // NO FALLBACK: Vehicle not found is a BUG that should be visible!
    try {
      return vehicles.firstWhere((vehicle) => vehicle.id == vehicleId);
    } catch (e) {
      throw Exception('Vehicle with ID $vehicleId not found');
    }
  }
}

class FamilyNotifier extends StateNotifier<FamilyState>
    with ReactiveStateCoordinator {
  // Use cases - kept for future direct usage if needed
  // ignore: unused_field
  final GetFamilyUsecase _getFamilyUsecase;
  final ChildrenService _childrenService;
  final LeaveFamilyUsecase _leaveFamilyUsecase;
  final FamilyRepository _familyRepository;
  final InvitationRepository _invitationRepository;
  final Ref _ref;

  /// Direct error handler for ReactiveStateCoordinator pattern
  final ReactiveStateCoordinatorService _coordinator =
      ReactiveStateCoordinatorService.instance;

  /// Helper method to handle failures with proper domain error handling
  String _getErrorMessage(Failure failure) {
    AppLogger.debug('🔥 [FamilyNotifier] _getErrorMessage called', {
      'failureType': failure.runtimeType.toString(),
      'failureMessage': failure.message,
      'failure': failure.toString(),
    });

    if (failure is FamilyFailure) {
      return failure.localizationKey; // Use localization key directly
    } else if (failure is InvitationFailure) {
      return failure.localizationKey; // Use localization key directly
    } else if (failure is VehicleFailure) {
      return failure.localizationKey; // Use localization key directly
    } else {
      final errorMessage = failure.message ?? 'Unknown error occurred';
      AppLogger.debug(
        '🔥 [FamilyNotifier] Using fallback error message: $errorMessage',
      );
      return errorMessage;
    }
  }

  FamilyNotifier(
    this._getFamilyUsecase,
    this._childrenService,
    this._leaveFamilyUsecase,
    this._familyRepository,
    this._invitationRepository,
    this._ref,
  ) : super(const FamilyState()) {
    // CRITICAL: Listen to auth changes continuously for TRUE reactive architecture
    _ref.listen(currentUserProvider, (previous, next) {
      if (next == null && previous != null) {
        // User logged out → clear state automatically
        _onUserLoggedOut();
        AppLogger.info('🔄 [FamilyNotifier] Auto-cleared state on logout');
      } else if (next != null && previous == null) {
        // User logged in → optionally reload data
        _onUserLoggedIn(next);
      }
    });

    // Don't call loadFamily() in constructor to avoid provider initialization conflicts
    // loadFamily() will be called when provider is first accessed
  }

  /// Handle user logout - automatic state clearing + cache cleanup
  void _onUserLoggedOut() async {
    if (!mounted) return;

    // Clear all family-related state immediately
    state = const FamilyState(); // Reset to empty state

    // CRITICAL: Also clear persistent cache (database, local storage)
    try {
      final clearAllFamilyDataUsecase = _ref.read(
        clearAllFamilyDataUsecaseProvider,
      );
      await clearAllFamilyDataUsecase.call(const ClearAllFamilyDataParams());
      AppLogger.info(
        '🔄 [FamilyNotifier] Family persistent cache cleared on logout',
      );
    } catch (e) {
      AppLogger.warning(
        '⚠️ [FamilyNotifier] Failed to clear family cache on logout: $e',
      );
    }

    AppLogger.info(
      '🔄 [FamilyNotifier] Family state + cache cleared due to user logout',
    );
  }

  /// Handle user login - optional data reloading
  void _onUserLoggedIn(User user) {
    if (!mounted) return;

    // User logged in - we could optionally reload family data here
    // For now, let the UI trigger loadFamily() when needed
    AppLogger.info('🔄 [FamilyNotifier] User logged in: ${user.id}');
  }

  /// Load family data including children / vehicules / members - ReactiveStateCoordinator pattern
  Future<void> loadFamily() async {
    if (!mounted) return; // Prevent operations after disposal

    await _coordinator.coordinateCriticalState(() {
      state = state.copyWith(isLoading: true, clearError: true);
    }, description: 'Setting loading state for family data');

    try {
      // First load family to get familyId, then load children and vehicles using the familyId
      final familyResult = await _familyRepository.getFamily();

      if (familyResult.isOk) {
        final family = familyResult.value;

        // ✅ FIX: Handle null case (user has no family - valid state)
        if (family == null) {
          await _coordinator.coordinateCriticalState(() {
            state = state.copyWith(
              children: [],
              vehicles: [],
              pendingInvitations: [],
              isLoading: false,
            );
          }, description: 'User has no family - cleared state');
          AppLogger.info('[FamilyProvider] User has no family - state cleared');
          return;
        }

        // Use children and vehicles directly from family instead of separate API calls
        final childrenData = family.children;
        final vehiclesData = family.vehicles;

        // Load pending invitations
        final invitationsResult = await _invitationRepository
            .getPendingInvitations(familyId: family.id);
        final pendingInvitationsData = invitationsResult.isOk
            ? invitationsResult.value!
            : <entities.FamilyInvitation>[];

        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(
            family: family,
            children: childrenData,
            vehicles: vehiclesData,
            pendingInvitations: pendingInvitationsData,
            isLoading: false,
          );
        }, description: 'Setting loaded family data');

        AppLogger.debug(
          '[FamilyProvider] Family loaded: ${family.name}, Children: ${childrenData.length}, Vehicles: ${vehiclesData.length}, Pending invitations: ${pendingInvitationsData.length}',
        );
      } else {
        final failure = familyResult.error!;
        final errorMessage = _getErrorMessage(failure);

        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(isLoading: false, errorInfo: errorMessage);
        }, description: 'Setting error state for family loading failure');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        '[FamilyProvider] Unexpected error during loadFamily',
        e,
        stackTrace,
      );
      await _coordinator.coordinateCriticalState(
        () {
          state = state.copyWith(
            isLoading: false,
            errorInfo: 'Unexpected error occurred',
          );
        },
        description: 'Setting error state for unexpected family loading error',
      );
    }
  }

  /// Add child - ReactiveStateCoordinator pattern with ChildrenService
  Future<void> addChild(CreateChildRequest request) async {
    if (!mounted) return; // Prevent operations after disposal

    // Ensure we have a family with ID before adding child
    final familyId = state.family?.id;
    if (familyId == null) {
      throw Exception(
        'Family ID not available - user may not be part of a family',
      );
    }

    await _coordinator.coordinateCriticalState(() {
      state = state.copyWith(isLoading: true, clearError: true);
    }, description: 'Setting loading state for add child');

    try {
      // Get familyId for children service
      final family = state.family;
      if (family == null) {
        throw Exception(
          'Family not available - user may not be part of a family',
        );
      }

      final result = await _childrenService.add(
        familyId: family.id,
        request: request,
      );

      if (result.isOk) {
        final child = result.value!;

        // Add child to local state - no need to reload entire family
        await _coordinator.coordinateCriticalState(
          () {
            final updatedChildren = [...state.children, child];
            state = state.copyWith(children: updatedChildren, isLoading: false);
          },
          description: 'Adding child to local state after successful creation',
        );

        AppLogger.debug(
          '[FamilyProvider] Child added successfully: ${child.name}',
        );
      } else {
        final failure = result.error!;
        final errorMessage = _getErrorMessage(failure);

        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(isLoading: false, errorInfo: errorMessage);
        }, description: 'Setting error state for add child failure');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error', e, stackTrace);
      await _coordinator.coordinateCriticalState(() {
        state = state.copyWith(
          isLoading: false,
          errorInfo: 'Unexpected error occurred',
        );
      }, description: 'Setting error state for unexpected add child error');
    }
  }

  /// Update child - ReactiveStateCoordinator pattern with ChildrenService
  Future<void> updateChild(String childId, UpdateChildRequest request) async {
    if (!mounted) return; // Prevent operations after disposal

    _setChildLoading(childId, true);
    try {
      // Get familyId for children service
      final family = state.family;
      if (family == null) {
        throw Exception(
          'Family not available - user may not be part of a family',
        );
      }

      final result = await _childrenService.update(
        familyId: family.id,
        params: UpdateChildParams(childId: childId, request: request),
      );

      if (result.isOk) {
        final updatedChild = result.value!;

        // Update child in local state - no need to reload entire family
        await _coordinator.coordinateCriticalState(
          () {
            final updatedChildren = state.children
                .map((child) => child.id == childId ? updatedChild : child)
                .toList();
            state = state.copyWith(children: updatedChildren);
          },
          description:
              'Updating child in local state after successful modification',
        );

        AppLogger.debug(
          '[FamilyProvider] Child updated successfully: ${updatedChild.name}',
        );
      } else {
        final failure = result.error!;
        final errorMessage = _getErrorMessage(failure);

        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(errorInfo: errorMessage);
        }, description: 'Setting error state for update child failure');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error', e, stackTrace);
      await _coordinator.coordinateCriticalState(() {
        state = state.copyWith(errorInfo: 'Unexpected error occurred');
      }, description: 'Setting error state for unexpected update child error');
    } finally {
      _setChildLoading(childId, false);
    }
  }

  /// Remove child - ReactiveStateCoordinator pattern with ChildrenService
  Future<void> removeChild(String childId) async {
    if (!mounted) return; // Prevent operations after disposal

    _setChildLoading(childId, true);
    try {
      // Get familyId for children service
      final family = state.family;
      if (family == null) {
        throw Exception(
          'Family not available - user may not be part of a family',
        );
      }

      final result = await _childrenService.remove(
        familyId: family.id,
        childId: childId,
      );

      if (result.isOk) {
        final _ = result.value;

        // Remove child from local state - no need to reload entire family
        await _coordinator.coordinateCriticalState(
          () {
            final updatedChildren = state.children
                .where((child) => child.id != childId)
                .toList();
            state = state.copyWith(children: updatedChildren);
          },
          description:
              'Removing child from local state after successful deletion',
        );

        AppLogger.debug(
          '[FamilyProvider] Child removed successfully: $childId',
        );
      } else {
        final failure = result.error!;
        final errorMessage = _getErrorMessage(failure);

        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(errorInfo: errorMessage);
        }, description: 'Setting error state for remove child failure');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error', e, stackTrace);
      await _coordinator.coordinateCriticalState(() {
        state = state.copyWith(errorInfo: 'Unexpected error occurred');
      }, description: 'Setting error state for unexpected remove child error');
    } finally {
      _setChildLoading(childId, false);
    }
  }

  // ========================================
  // VEHICLE OPERATIONS - Consolidated from VehiclesProvider
  // ========================================
  /// Load vehicles only - ReactiveStateCoordinator pattern
  Future<void> loadVehicles() async {
    // OPTIMIZATION: Use cached family vehicles instead of separate API call
    final family = state.family;
    if (family == null) {
      throw Exception(
        'Family not available - user may not be part of a family',
      );
    }

    AppLogger.debug(
      '[FamilyProvider] Loading vehicles from cached family data',
    );

    await _coordinator.coordinateCriticalState(() {
      state = state.copyWith(vehicles: family.vehicles, clearError: true);
    }, description: 'Setting vehicles from cached family data');

    AppLogger.debug(
      '[FamilyProvider] Vehicles loaded from cache: ${family.vehicles.length} vehicles',
    );
  }

  /// Add vehicle - ReactiveStateCoordinator pattern
  Future<void> addVehicle({
    required String name,
    required int capacity,
    String? description,
  }) async {
    if (!mounted) return; // Prevent operations after disposal

    // Ensure we have a family with ID before adding vehicle
    final familyId = state.family?.id;
    if (familyId == null) {
      throw Exception(
        'Family ID not available - user may not be part of a family',
      );
    }

    await _coordinator.coordinateCriticalState(() {
      state = state.copyWith(isLoading: true, clearError: true);
    }, description: 'Setting loading state for add vehicle');

    try {
      final result = await _familyRepository.addVehicle(
        name: name,
        capacity: capacity,
        description: description,
      );

      if (result.isOk) {
        final vehicle = result.value!;

        // Add vehicle to local state - no need to reload entire vehicles list
        await _coordinator.coordinateCriticalState(
          () {
            final updatedVehicles = [...state.vehicles, vehicle];
            state = state.copyWith(vehicles: updatedVehicles, isLoading: false);
          },
          description:
              'Adding vehicle to local state after successful creation',
        );

        AppLogger.debug(
          '[FamilyProvider] Vehicle added successfully: ${vehicle.name}',
        );
      } else {
        final failure = result.error!;
        final errorMessage = _getErrorMessage(failure);

        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(isLoading: false, errorInfo: errorMessage);
        }, description: 'Setting error state for add vehicle failure');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error', e, stackTrace);
      await _coordinator.coordinateCriticalState(() {
        state = state.copyWith(
          isLoading: false,
          errorInfo: 'Unexpected error occurred',
        );
      }, description: 'Setting error state for unexpected add vehicle error');
    }
  }

  /// Update vehicle - ReactiveStateCoordinator pattern
  Future<void> updateVehicle({
    required String vehicleId,
    String? name,
    int? capacity,
    String? description,
  }) async {
    if (!mounted) return; // Prevent operations after disposal

    _setVehicleLoading(vehicleId, true);
    // Ensure we have a family with ID before updating vehicle
    final familyId = state.family?.id;
    if (familyId == null) {
      _setVehicleLoading(vehicleId, false);
      throw Exception(
        'Family ID not available - user may not be part of a family',
      );
    }

    try {
      final result = await _familyRepository.updateVehicle(
        vehicleId: vehicleId,
        name: name,
        capacity: capacity,
        description: description,
      );

      if (result.isOk) {
        final updatedVehicle = result.value!;

        // Update vehicle in local state - no need to reload entire vehicles list
        await _coordinator.coordinateCriticalState(
          () {
            final updatedVehicles = state.vehicles
                .map(
                  (vehicle) =>
                      vehicle.id == vehicleId ? updatedVehicle : vehicle,
                )
                .toList();
            state = state.copyWith(
              vehicles: updatedVehicles,
              selectedVehicle: state.selectedVehicle?.id == vehicleId
                  ? updatedVehicle
                  : state.selectedVehicle,
            );
          },
          description:
              'Updating vehicle in local state after successful modification',
        );

        AppLogger.debug(
          '[FamilyProvider] Vehicle updated successfully: ${updatedVehicle.name}',
        );
      } else {
        final failure = result.error!;
        final errorMessage = _getErrorMessage(failure);

        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(errorInfo: errorMessage);
        }, description: 'Setting error state for update vehicle failure');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error', e, stackTrace);
      await _coordinator.coordinateCriticalState(
        () {
          state = state.copyWith(errorInfo: 'Unexpected error occurred');
        },
        description: 'Setting error state for unexpected update vehicle error',
      );
    } finally {
      _setVehicleLoading(vehicleId, false);
    }
  }

  /// Delete vehicle - ReactiveStateCoordinator pattern
  Future<void> deleteVehicle(String vehicleId) async {
    if (!mounted) return; // Prevent operations after disposal

    _setVehicleLoading(vehicleId, true);
    // Ensure we have a family with ID before deleting vehicle
    final familyId = state.family?.id;
    if (familyId == null) {
      _setVehicleLoading(vehicleId, false);
      throw Exception(
        'Family ID not available - user may not be part of a family',
      );
    }

    try {
      final result = await _familyRepository.deleteVehicle(
        vehicleId: vehicleId,
      );

      if (result.isOk) {
        final _ = result.value;

        // Remove vehicle from local state - no need to reload entire vehicles list
        await _coordinator.coordinateCriticalState(
          () {
            final updatedVehicles = state.vehicles
                .where((vehicle) => vehicle.id != vehicleId)
                .toList();
            state = state.copyWith(
              vehicles: updatedVehicles,
              clearSelectedVehicle: state.selectedVehicle?.id == vehicleId,
            );
          },
          description:
              'Removing vehicle from local state after successful deletion',
        );

        AppLogger.debug(
          '[FamilyProvider] Vehicle deleted successfully: $vehicleId',
        );
      } else {
        final failure = result.error!;
        final errorMessage = _getErrorMessage(failure);

        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(errorInfo: errorMessage);
        }, description: 'Setting error state for delete vehicle failure');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error', e, stackTrace);
      await _coordinator.coordinateCriticalState(
        () {
          state = state.copyWith(errorInfo: 'Unexpected error occurred');
        },
        description: 'Setting error state for unexpected delete vehicle error',
      );
    } finally {
      _setVehicleLoading(vehicleId, false);
    }
  }

  /// Select vehicle - ReactiveStateCoordinator pattern
  Future<void> selectVehicle(String vehicleId) async {
    if (!mounted) return; // Prevent operations after disposal

    _setVehicleLoading(vehicleId, true);
    // Ensure we have a family with ID before selecting vehicle
    final familyId = state.family?.id;
    if (familyId == null) {
      _setVehicleLoading(vehicleId, false);
      throw Exception(
        'Family ID not available - user may not be part of a family',
      );
    }

    try {
      // Use family data directly instead of separate API call
      final vehicle = state.vehicles.firstWhere(
        (v) => v.id == vehicleId,
        orElse: () => throw Exception('Vehicle not found in family data'),
      );

      await _coordinator.coordinateCriticalState(() {
        state = state.copyWith(selectedVehicle: vehicle);
      }, description: 'Setting selected vehicle');

      AppLogger.debug('[FamilyProvider] Vehicle selected: ${vehicle.name}');
    } catch (e) {
      final failure = ApiFailure.notFound(resource: 'Vehicle');
      // Using domain error handling
      await _coordinator.coordinateCriticalState(() {
        final errorMessage = _getErrorMessage(failure);
        state = state.copyWith(errorInfo: errorMessage);
      }, description: 'Setting error state for select vehicle failure');
    } finally {
      _setVehicleLoading(vehicleId, false);
    }
  }

  /// Clear selected vehicle
  void clearSelectedVehicle() {
    if (!mounted) return; // Prevent operations after disposal
    state = state.copyWith(clearSelectedVehicle: true);
  }

  /// Set vehicle loading state
  void _setVehicleLoading(String vehicleId, bool loading) {
    if (!mounted) return; // Prevent operations after disposal

    final newVehicleLoading = Map<String, bool>.from(state.vehicleLoading);
    if (loading) {
      newVehicleLoading[vehicleId] = true;
    } else {
      newVehicleLoading.remove(vehicleId);
    }
    state = state.copyWith(vehicleLoading: newVehicleLoading);
  }

  void _setChildLoading(String childId, bool loading) {
    if (!mounted) return; // Prevent operations after disposal

    final newChildLoading = Map<String, bool>.from(state.childLoading);
    if (loading) {
      newChildLoading[childId] = true;
    } else {
      newChildLoading.remove(childId);
    }
    state = state.copyWith(childLoading: newChildLoading);
  }

  void clearError() {
    if (!mounted) return; // Prevent operations after disposal
    state = state.copyWith(clearError: true);
  }

  entities.Child? getChild(String childId) {
    try {
      return state.children.firstWhere((child) => child.id == childId);
    } catch (e) {
      return null;
    }
  }

  /// Update member role (Admin only) - ReactiveStateCoordinator pattern
  Future<void> updateMemberRole({
    required String memberId,
    required entities.FamilyRole role,
  }) async {
    if (!mounted) return; // Prevent operations after disposal

    // Ensure we have a family with ID before updating member role
    final familyId = state.family?.id;
    if (familyId == null) {
      throw Exception(
        'Family ID not available - user may not be part of a family',
      );
    }

    await _coordinator.coordinateCriticalState(() {
      state = state.copyWith(isLoading: true, clearError: true);
    }, description: 'Setting loading state for update member role');

    try {
      final result = await _familyRepository.updateMemberRole(
        familyId: familyId,
        memberId: memberId,
        role: role.value,
      );

      if (result.isOk) {
        // Use the updated member from the REST response (already cached by repository)
        final updatedMember = result.value!;

        // Update member role in local state
        final currentFamily = state.family;
        if (currentFamily != null) {
          final updatedMembers = currentFamily.members.map((member) {
            return member.id == memberId ? updatedMember : member;
          }).toList();

          final updatedFamily = currentFamily.copyWith(members: updatedMembers);

          await _coordinator.coordinateCriticalState(
            () {
              state = state.copyWith(family: updatedFamily, isLoading: false);
            },
            description:
                'Updating member role in local state after successful update',
          );

          AppLogger.debug(
            '[FamilyProvider] Member role updated successfully: $memberId -> $role',
          );
        }
      } else {
        final failure = result.error!;
        final errorMessage = _getErrorMessage(failure);

        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(isLoading: false, errorInfo: errorMessage);
        }, description: 'Setting error state for update member role failure');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error', e, stackTrace);
      await _coordinator.coordinateCriticalState(
        () {
          state = state.copyWith(
            isLoading: false,
            errorInfo: 'Unexpected error occurred',
          );
        },
        description:
            'Setting error state for unexpected update member role error',
      );
    }
  }

  /// Remove member from family (Admin only) - ReactiveStateCoordinator pattern
  Future<void> removeMember({
    required String familyId,
    required String memberId,
  }) async {
    if (!mounted) return; // Prevent operations after disposal

    await _coordinator.coordinateCriticalState(() {
      state = state.copyWith(isLoading: true, clearError: true);
    }, description: 'Setting loading state for remove member');

    try {
      final result = await _familyRepository.removeMember(
        familyId: familyId,
        memberId: memberId,
      );

      if (result.isOk) {
        final _ = result.value;

        // Remove member from local state
        final currentFamily = state.family;
        if (currentFamily != null) {
          final updatedMembers = currentFamily.members
              .where((member) => member.id != memberId)
              .toList();

          final updatedFamily = currentFamily.copyWith(members: updatedMembers);

          await _coordinator.coordinateCriticalState(
            () {
              state = state.copyWith(family: updatedFamily, isLoading: false);
            },
            description:
                'Removing member from local state after successful deletion',
          );
        }

        AppLogger.debug(
          '[FamilyProvider] Member removed successfully: $memberId',
        );
      } else {
        final failure = result.error!;
        final errorMessage = _getErrorMessage(failure);

        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(isLoading: false, errorInfo: errorMessage);
        }, description: 'Setting error state for remove member failure');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error', e, stackTrace);
      await _coordinator.coordinateCriticalState(() {
        state = state.copyWith(
          isLoading: false,
          errorInfo: 'Unexpected error occurred',
        );
      }, description: 'Setting error state for unexpected remove member error');
    }
  }

  /// Leave family - ReactiveStateCoordinator pattern with proper use case architecture
  Future<void> leaveFamily() async {
    if (!mounted) return; // Prevent operations after disposal

    await _coordinator.coordinateCriticalState(() {
      state = state.copyWith(isLoading: true, clearError: true);
    }, description: 'Setting loading state for leave family');

    try {
      // Get familyId for leave family usecase
      final family = state.family;
      if (family == null) {
        throw Exception(
          'Family not available - user may not be part of a family',
        );
      }

      final result = await _leaveFamilyUsecase.call(
        LeaveFamilyParams(familyId: family.id),
      );

      if (result.isOk) {
        final _ = result.value!;

        // Clear family state after leaving
        await _coordinator.coordinateCriticalState(() {
          state = const FamilyState();
        }, description: 'Clearing family state after leaving');

        // The auth provider will automatically detect that user has no family
        // and navigate to onboarding. No direct navigation from presentation layer.
        // This follows clean architecture principles.
      } else {
        final failure = result.error!;
        final errorMessage = _getErrorMessage(failure);

        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(isLoading: false, errorInfo: errorMessage);
        }, description: 'Setting error state for leave family failure');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error', e, stackTrace);
      await _coordinator.coordinateCriticalState(() {
        state = state.copyWith(
          isLoading: false,
          errorInfo: 'Unexpected error occurred',
        );
      }, description: 'Setting error state for unexpected leave family error');
    }
  }

  /// Update family name (Admin only) - ReactiveStateCoordinator pattern
  Future<void> updateFamilyName(String newName) async {
    if (!mounted) return; // Prevent operations after disposal

    // Ensure we have a family with ID before updating family name
    final familyId = state.family?.id;
    if (familyId == null) {
      throw Exception(
        'Family ID not available - user may not be part of a family',
      );
    }

    await _coordinator.coordinateCriticalState(() {
      state = state.copyWith(isLoading: true, clearError: true);
    }, description: 'Setting loading state for update family name');

    try {
      final result = await _familyRepository.updateFamilyName(
        familyId: familyId,
        name: newName,
      );

      if (result.isOk) {
        final family = result.value!;

        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(family: family, isLoading: false);
        }, description: 'Setting updated family name');

        AppLogger.debug(
          '[FamilyProvider] Family name updated successfully: $newName',
        );
      } else {
        final failure = result.error!;
        final errorMessage = _getErrorMessage(failure);

        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(isLoading: false, errorInfo: errorMessage);
        }, description: 'Setting error state for update family name failure');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error', e, stackTrace);
      await _coordinator.coordinateCriticalState(
        () {
          state = state.copyWith(
            isLoading: false,
            errorInfo: 'Unexpected error occurred',
          );
        },
        description:
            'Setting error state for unexpected update family name error',
      );
    }
  }

  /// Promote member to admin (shortcut for role update)
  Future<void> promoteMemberToAdmin(String memberId) async {
    await updateMemberRole(memberId: memberId, role: entities.FamilyRole.admin);
  }

  /// Demote member from admin to regular member
  Future<void> demoteMemberToMember(String memberId) async {
    await updateMemberRole(
      memberId: memberId,
      role: entities.FamilyRole.member,
    );
  }

  /// Transfer ownership to another member (Admin only)
  /// This functionality is not fully supported by the backend API
  Future<void> transferOwnership(String newAdminId) async {
    throw UnimplementedError(
      'Ownership transfer functionality is not available in the backend API. '
      'The backend does not support transferring family ownership. '
      'Use updateMemberRole to change member roles instead.',
    );
  }

  /// REMOVED: deleteFamily method was misleading
  /// It only called leaveFamily() but claimed to delete the entire family
  /// If family deletion is needed, implement proper deletion in repository first
  /// For now, use leaveFamily() directly if user wants to leave the family

  List<entities.Child> getChildrenByGroup(String groupId) {
    // groupMemberships removed - not part of backend schema
    // Return empty list as groups are not currently supported
    return <entities.Child>[];
  }

  // REMOVED: Bulk operations for children are not supported by the backend
  // These operations were fictional and have been eliminated per architecture audit
  // Use individual add/update/remove operations instead

  // REMOVED: Search and filtering operations for children are not supported by the backend
  // These operations were fictional and have been eliminated per architecture audit
  // Use local filtering on the children list in state instead

  /// Get filtered children from current state (local filtering only - REAL implementation)
  List<entities.Child> getFilteredChildren({
    String? query,
    int? minAge,
    int? maxAge,
  }) {
    var filteredChildren = state.children;

    if (query != null && query.trim().isNotEmpty) {
      filteredChildren = filteredChildren.where((child) {
        final searchQuery = query.toLowerCase();
        return child.name.toLowerCase().contains(searchQuery);
      }).toList();
    }

    if (minAge != null || maxAge != null) {
      filteredChildren = filteredChildren.where((child) {
        final age = child.age;
        if (age == null) return false;

        if (minAge != null && age < minAge) return false;
        if (maxAge != null && age > maxAge) return false;

        return true;
      }).toList();
    }

    return filteredChildren;
  }

  /// Send family invitation to a member (Admin only) - ReactiveStateCoordinator pattern
  /// Returns Result<entities.FamilyInvitation, InvitationFailure> following PHASE2 pattern
  Future<Result<entities.FamilyInvitation, InvitationFailure>>
  sendFamilyInvitationToMember({
    required String familyId,
    required String email,
    required String role,
    String? personalMessage,
  }) async {
    // PHASE2: Handle unmounted state properly with Result pattern
    if (!mounted) {
      return const Result.err(
        InvitationFailure(
          error: InvitationError.inviteOperationFailed,
          message: 'Provider no longer mounted',
        ),
      );
    }

    await _coordinator.coordinateCriticalState(() {
      state = state.copyWith(isLoading: true, clearError: true);
    }, description: 'Setting loading state for invite member');

    try {
      // Get familyId for invitation repository
      final family = state.family;
      if (family == null) {
        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(isLoading: false);
        }, description: 'Clearing loading state');

        return const Result.err(
          InvitationFailure(
            error: InvitationError.familyIdRequired,
            message: 'Family not available - user may not be part of a family',
          ),
        );
      }

      final result = await _invitationRepository.inviteMember(
        familyId: family.id,
        email: email,
        role: role,
        personalMessage: personalMessage,
      );

      if (result.isOk) {
        final invitation = result.value!;

        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(isLoading: false);
        }, description: 'Completing invite member operation');

        // Success - invitation sent and cached locally
        AppLogger.debug(
          '[FamilyProvider] Member invitation sent successfully: $email',
        );

        // PHASE2: Return the Result directly instead of updating state
        return Result.ok(invitation);
      } else {
        final failure = result.error!;
        final errorMessage = _getErrorMessage(failure);

        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(isLoading: false, errorInfo: errorMessage);
        }, description: 'Setting error state for invite member failure');

        // PHASE2: Return Repository InvitationFailure directly to preserve enum mapping
        // Repository already mapped to correct InvitationError enum (e.g., pendingInvitationExists)
        return Result.err(failure);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error', e, stackTrace);
      await _coordinator.coordinateCriticalState(() {
        state = state.copyWith(
          isLoading: false,
          errorInfo: 'Unexpected error occurred',
        );
      }, description: 'Setting error state for unexpected invite member error');

      // PHASE2: Convert exceptions to InvitationFailure
      return Result.err(
        InvitationFailure(
          error: InvitationError.inviteOperationFailed,
          message: 'Unexpected error occurred: ${e.toString()}',
        ),
      );
    }
  }

  /// Get pending invitations (Admin only) - REAL IMPLEMENTATION
  /// Uses InvitationRepository with proper Result pattern and offline-first caching
  Future<List<entities.FamilyInvitation>> getPendingInvitations() async {
    // Ensure we have a family with ID before getting invitations
    final familyId = state.family?.id;
    if (familyId == null) {
      throw Exception(
        'Family ID not available - user may not be part of a family',
      );
    }

    try {
      // REAL: Use InvitationRepository with offline-first strategy
      final result = await _invitationRepository.getPendingInvitations(
        familyId: familyId,
      );

      if (result.isOk) {
        return result.value!;
      } else {
        throw result.error!;
      }
    } catch (e) {
      return <entities.FamilyInvitation>[];
    }
  }

  /// Cancel invitation (Admin only) - ReactiveStateCoordinator pattern
  Future<void> cancelInvitation(String invitationId) async {
    if (!mounted) return; // Prevent operations after disposal

    // Ensure we have a family with ID before canceling invitation
    final familyId = state.family?.id;
    if (familyId == null) {
      throw Exception(
        'Family ID not available - user may not be part of a family',
      );
    }

    await _coordinator.coordinateCriticalState(() {
      state = state.copyWith(isLoading: true, clearError: true);
    }, description: 'Setting loading state for cancel invitation');

    try {
      final result = await _familyRepository.cancelInvitation(
        familyId: familyId,
        invitationId: invitationId,
      );

      if (result.isOk) {
        final _ = result.value;

        // No need to refresh invitations here - they are managed separately
        // and the UI will refresh them when needed via getPendingInvitations()
        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(isLoading: false);
        }, description: 'Completing cancel invitation operation');

        AppLogger.debug(
          '[FamilyProvider] Invitation cancelled successfully for family $familyId',
        );
      } else {
        final failure = result.error!;
        final errorMessage = _getErrorMessage(failure);

        await _coordinator.coordinateCriticalState(() {
          state = state.copyWith(isLoading: false, errorInfo: errorMessage);
        }, description: 'Setting error state for cancel invitation failure');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error', e, stackTrace);
      await _coordinator.coordinateCriticalState(
        () {
          state = state.copyWith(
            isLoading: false,
            errorInfo: 'Unexpected error occurred',
          );
        },
        description:
            'Setting error state for unexpected cancel invitation error',
      );
    }
  }
}

// Simplified architecture: No empty notifier needed
// Reactive auth listening in FamilyNotifier handles all cleanup automatically

// Factory for creating FamilyNotifier to avoid circular dependencies
class FamilyNotifierFactory {
  static FamilyNotifier create(Ref ref) {
    return AutoLoadFamilyNotifier(
      ref.watch(family_providers.getFamilyUsecaseProvider),
      ref.watch(childrenServiceProvider),
      ref.watch(leaveFamilyUsecaseProvider),
      ref.watch(familyRepositoryProvider),
      ref.watch(invitationRepositoryProvider),
      ref, // Pass ref for reactive auth listening
    );
  }
}

// Provider using factory pattern to eliminate circular dependencies
// Auto-loader notifier to trigger loadFamily when first accessed
// Only loads if user is authenticated and has a family
class AutoLoadFamilyNotifier extends FamilyNotifier {
  bool _hasLoaded = false;

  AutoLoadFamilyNotifier(
    GetFamilyUsecase getFamilyUsecase,
    ChildrenService childrenService,
    LeaveFamilyUsecase leaveFamilyUsecase,
    FamilyRepository familyRepository,
    InvitationRepository invitationRepository,
    Ref ref,
  ) : super(
        getFamilyUsecase,
        childrenService,
        leaveFamilyUsecase,
        familyRepository,
        invitationRepository,
        ref,
      ) {
    // ✅ FIX: Schedule auto-load immediately in constructor
    // This ensures it runs as soon as the provider is created,
    // BEFORE the router makes any navigation decisions
    Future.microtask(() async {
      if (_shouldAutoLoad()) {
        await loadFamily();
      }
    });
  }

  bool _shouldAutoLoad() {
    // Prevent multiple loads
    if (_hasLoaded) {
      return false;
    }

    final authState = _ref.read(currentUserProvider);
    final shouldLoad = authState != null;

    AppLogger.debug(
      '[AutoLoadFamilyNotifier] _shouldAutoLoad check: '
      'authState=${authState != null}, _hasLoaded=$_hasLoaded, shouldLoad=$shouldLoad',
    );

    if (shouldLoad) {
      _hasLoaded = true;
      AppLogger.debug(
        '[AutoLoadFamilyNotifier] Auto-loading family for authenticated user: ${authState.id}',
      );
    }

    return shouldLoad;
  }
}

final familyProvider =
    StateNotifierProvider.autoDispose<FamilyNotifier, FamilyState>((ref) {
      // SECURITY FIX: Watch currentUser and auto-dispose when user becomes null
      ref.watch(currentUserProvider);

      // Always create normal provider - reactive auth listening will handle cleanup
      return FamilyNotifierFactory.create(ref);
    });

// Convenience providers - SECURITY FIX: Made auth-reactive with autoDispose
final familyChildrenProvider = Provider.autoDispose<List<entities.Child>>((
  ref,
) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return <entities.Child>[];

  return ref.watch(familyProvider.select((state) => state.children));
});

final familyDataProvider = Provider.autoDispose<entities.Family?>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null;

  return ref.watch(familyProvider.select((state) => state.family));
});

final childProvider = Provider.autoDispose.family<entities.Child?, String>((
  ref,
  childId,
) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null;

  final children = ref.watch(familyProvider.select((state) => state.children));
  try {
    return children.firstWhere((child) => child.id == childId);
  } catch (e) {
    return null;
  }
});

final familyChildrenByGroupProvider = Provider.autoDispose
    .family<List<entities.Child>, String>((ref, groupId) {
      final currentUser = ref.watch(currentUserProvider);
      if (currentUser == null) return <entities.Child>[];

      // Group functionality not implemented in backend - return empty list
      return <entities.Child>[];
    });
// Vehicle convenience providers - SECURITY FIX: Made auth-reactive with autoDispose
final familyVehiclesProvider = Provider.autoDispose<List<entities.Vehicle>>((
  ref,
) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return <entities.Vehicle>[];

  return ref.watch(familyProvider.select((state) => state.vehicles));
});

final sortedVehiclesProvider = Provider.autoDispose<List<entities.Vehicle>>((
  ref,
) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return <entities.Vehicle>[];

  return ref.watch(familyProvider.select((state) => state.sortedVehicles));
});

final availableVehiclesProvider = Provider.autoDispose<List<entities.Vehicle>>((
  ref,
) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return <entities.Vehicle>[];

  return ref.watch(familyProvider.select((state) => state.availableVehicles));
});

final selectedVehicleProvider = Provider.autoDispose<entities.Vehicle?>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null;

  return ref.watch(familyProvider.select((state) => state.selectedVehicle));
});

final vehicleProvider = Provider.autoDispose.family<entities.Vehicle?, String>((
  ref,
  vehicleId,
) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null;

  final vehicles = ref.watch(familyProvider.select((state) => state.vehicles));
  try {
    return vehicles.firstWhere((vehicle) => vehicle.id == vehicleId);
  } catch (e) {
    return null;
  }
});

final vehiclesCountProvider = Provider.autoDispose<int>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return 0;

  return ref.watch(familyProvider.select((state) => state.vehiclesCount));
});

final totalCapacityProvider = Provider.autoDispose<int>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return 0;

  return ref.watch(familyProvider.select((state) => state.totalCapacity));
});
// Note: Old vehiclesProvider has been consolidated into familyProvider
// UI components should use familyProvider for vehicle operations
// and familyVehiclesProvider for the vehicle list

/// Provider for cached family status - used by router for synchronous access
/// Returns cached family information without making API calls
/// MOVED FROM auth_provider.dart for Clean Architecture compliance
// REMOVED: cachedUserFamilyStatusProvider
// Router now uses familyRepository.getCurrentFamily() directly (offline-first)

// REMOVED: cachedUserFamilyIdProvider - obsolete since UserFamilyService simplified
// Use cachedUserFamilyStatusProvider instead for family checks

// Stub classes removed - no longer needed with reactive auth architecture

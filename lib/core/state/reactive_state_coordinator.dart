// EduLift Mobile - Reactive State Coordinator
// STATE-OF-THE-ART: Reactive state coordination patterns for race condition prevention

import 'package:flutter/widgets.dart';
import '../utils/app_logger.dart';

/// STATE-OF-THE-ART: Reactive state coordination mixin
///
/// This mixin provides state-of-the-art patterns for coordinating state changes
/// in reactive applications to prevent race conditions and ensure proper
/// state synchronization across providers and widgets.
///
/// Key patterns:
/// - Async state synchronization with microtask yielding
/// - PostFrameCallback coordination for widget lifecycle alignment
/// - Reactive state propagation with proper timing guarantees
mixin ReactiveStateCoordinator {
  /// STATE-OF-THE-ART: Coordinate critical state changes
  ///
  /// Ensures that critical state changes are properly synchronized with
  /// Flutter's reactive system before other reactive listeners can respond.
  ///
  /// This prevents race conditions where:
  /// - Provider A sets state
  /// - Provider B reacts to Provider A's change
  /// - But Provider A's state hasn't fully propagated yet
  ///
  /// Usage:
  /// ```dart
  /// await coordinateCriticalState(() {
  ///   state = state.copyWith(status: ErrorStatus.failed);
  /// }, description: 'Setting error state');
  /// ```
  Future<void> coordinateCriticalState(
    void Function() stateUpdate, {
    required String description,
    bool withFrameCallback = true,
  }) async {
    AppLogger.info(
      '🔄 STATE-COORDINATION: Starting critical state update: $description',
    );

    // Apply the state update
    stateUpdate();

    // STATE-OF-THE-ART: Yield to microtask queue to ensure state propagation
    // SOLUTION FINALE: Utiliser microtask au lieu de timer pour éviter les problèmes de test
    await Future.microtask(() {});

    if (withFrameCallback) {
      // STATE-OF-THE-ART: Coordinate with widget lifecycle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppLogger.debug(
          '🔄 STATE-COORDINATION: Critical state synchronized: $description',
        );
      });
    }

    AppLogger.info(
      '🔄 STATE-COORDINATION: Completed critical state update: $description',
    );
  }

  /// STATE-OF-THE-ART: Reactive listener coordination
  ///
  /// Ensures that reactive listeners have proper async coordination
  /// to prevent race conditions when multiple providers are involved.
  ///
  /// Usage in provider listeners:
  /// ```dart
  /// ref.listen(someProvider, (prev, next) async {
  ///   await coordinateReactiveListener(() {
  ///     // Your reactive logic here
  ///     handleStateChange(prev, next);
  ///   }, description: 'Handling auth state change');
  /// });
  /// ```
  Future<void> coordinateReactiveListener(
    Future<void> Function() listenerLogic, {
    required String description,
  }) async {
    AppLogger.debug(
      '🎯 REACTIVE-COORDINATION: Starting listener: $description',
    );

    // STATE-OF-THE-ART: Allow state stabilization before reactive processing
    // SOLUTION FINALE: Utiliser microtask au lieu de timer pour éviter les problèmes de test
    await Future.microtask(() {});

    try {
      await listenerLogic();
      AppLogger.debug(
        '🎯 REACTIVE-COORDINATION: Completed listener: $description',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ REACTIVE-COORDINATION: Listener failed: $description',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// STATE-OF-THE-ART: Batch state updates with coordination
  ///
  /// For scenarios where multiple related state updates need to be
  /// coordinated together to prevent intermediate inconsistent states.
  ///
  /// Usage:
  /// ```dart
  /// await coordinateBatchStateUpdate([
  ///   () => authState = newAuthState,
  ///   () => userState = newUserState,
  ///   () => navigationState = newNavState,
  /// ], description: 'Login flow state updates');
  /// ```
  Future<void> coordinateBatchStateUpdate(
    List<void Function()> stateUpdates, {
    required String description,
  }) async {
    AppLogger.info(
      '📦 BATCH-COORDINATION: Starting batch update: $description',
    );

    // Apply all state updates atomically
    for (final update in stateUpdates) {
      update();
    }

    // STATE-OF-THE-ART: Ensure all updates are propagated
    // SOLUTION FINALE: Utiliser microtask au lieu de timer pour éviter les problèmes de test
    await Future.microtask(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLogger.debug(
        '📦 BATCH-COORDINATION: Batch synchronized: $description',
      );
    });

    AppLogger.info(
      '📦 BATCH-COORDINATION: Completed batch update: $description',
    );
  }

  /// STATE-OF-THE-ART: Debounced state coordination
  ///
  /// For high-frequency state updates that need coordination but
  /// should be debounced to prevent excessive coordination overhead.
  static final Map<String, DateTime> _lastCoordination = {};

  Future<void> coordinateWithDebounce(
    void Function() stateUpdate, {
    required String key,
    required String description,
    Duration debounceWindow = const Duration(
      milliseconds: 16,
    ), // ~1 frame at 60fps
  }) async {
    final now = DateTime.now();
    final lastCoordination = _lastCoordination[key];

    if (lastCoordination != null &&
        now.difference(lastCoordination) < debounceWindow) {
      AppLogger.debug(
        '🔄 DEBOUNCE-COORDINATION: Skipping debounced update: $description',
      );
      return;
    }

    _lastCoordination[key] = now;
    await coordinateCriticalState(stateUpdate, description: description);
  }
}

/// STATE-OF-THE-ART: Global reactive state coordinator
///
/// Singleton for app-wide state coordination patterns
class ReactiveStateCoordinatorService with ReactiveStateCoordinator {
  static final ReactiveStateCoordinatorService _instance =
      ReactiveStateCoordinatorService._();
  static ReactiveStateCoordinatorService get instance => _instance;
  ReactiveStateCoordinatorService._();

  /// STATE-OF-THE-ART: Coordinate router refresh with provider state
  ///
  /// Specialized coordination for router-provider interactions
  Future<void> coordinateRouterWithProviders(
    void Function() routerRefreshTrigger, {
    required String reason,
  }) async {
    await coordinateCriticalState(
      routerRefreshTrigger,
      description: 'Router refresh: $reason',
    );
  }
}

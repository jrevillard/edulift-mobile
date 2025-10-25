import 'package:edulift/core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the current navigation state and pending navigation actions
@immutable
class NavigationState {
  const NavigationState({
    this.pendingRoute,
    this.routeParams = const {},
    this.trigger,
    this.timestamp,
    this.context = const {},
    this.isProcessing = false,
  });

  /// Pending route to navigate to (null means no pending navigation)
  final String? pendingRoute;

  /// Parameters to pass to the route
  final Map<String, dynamic> routeParams;

  /// What triggered this navigation intent
  final NavigationTrigger? trigger;

  /// Timestamp when this navigation state was created
  final DateTime? timestamp;

  /// Additional context data for navigation decisions
  final Map<String, dynamic> context;

  /// Whether navigation is currently being processed by the router
  final bool isProcessing;

  /// Helper to check if there's a pending navigation
  bool get hasPendingNavigation => trigger != null;

  /// Helper to check if navigation is in progress
  bool get isNavigationInProgress => hasPendingNavigation && isProcessing;

  /// Helper to clear navigation state
  factory NavigationState.cleared() => const NavigationState();

  /// Create a copy with modified fields
  NavigationState copyWith({
    String? pendingRoute,
    Map<String, dynamic>? routeParams,
    NavigationTrigger? trigger,
    DateTime? timestamp,
    Map<String, dynamic>? context,
    bool? isProcessing,
  }) {
    return NavigationState(
      pendingRoute: pendingRoute ?? this.pendingRoute,
      routeParams: routeParams ?? this.routeParams,
      trigger: trigger ?? this.trigger,
      timestamp: timestamp ?? this.timestamp,
      context: context ?? this.context,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationState &&
        other.pendingRoute == pendingRoute &&
        _mapEquals(other.routeParams, routeParams) &&
        other.trigger == trigger &&
        other.timestamp == timestamp &&
        other.isProcessing == isProcessing &&
        _mapEquals(other.context, context);
  }

  @override
  int get hashCode {
    return Object.hash(
      pendingRoute,
      _mapHash(routeParams),
      trigger,
      timestamp,
      isProcessing,
      _mapHash(context),
    );
  }

  @override
  String toString() {
    return 'NavigationState('
        'pendingRoute: $pendingRoute, '
        'routeParams: $routeParams, '
        'trigger: $trigger, '
        'timestamp: $timestamp, '
        'isProcessing: $isProcessing, '
        'context: $context'
        ')';
  }

  // Helper methods for Map comparison
  static bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) return false;
    }
    return true;
  }

  static int _mapHash(Map<String, dynamic>? map) {
    if (map == null) return 0;
    var hash = 0;
    for (final entry in map.entries) {
      hash ^= Object.hash(entry.key, entry.value);
    }
    return hash;
  }
}

/// All possible navigation triggers in the application
/// These represent WHY navigation is happening, allowing the router to make intelligent decisions
enum NavigationTrigger {
  // Authentication triggers
  authSuccess('User authenticated successfully'),
  authFailure('Authentication failed'),
  authLogout('User logged out'),

  // Magic link triggers
  magicLinkSuccess('Magic link verification successful'),
  magicLinkFailure('Magic link verification failed'),

  // Invitation triggers
  familyInvitationSuccess('Family invitation accepted successfully'),
  familyInvitationFailure('Family invitation failed'),
  groupInvitationSuccess('Group invitation accepted successfully'),
  groupInvitationFailure('Group invitation failed'),
  invitationRequiresFamilyOnboarding(
    'Invitation requires family onboarding first',
  ),

  // Onboarding triggers
  onboardingStarted('Onboarding process started'),
  onboardingCompleted('Onboarding completed'),
  familyCreated('User created a family'),
  familyJoined('User joined a family'),

  // Group triggers
  groupCreated('User created a group'),
  groupJoined('User joined a group'),
  groupLeft('User left a group'),

  // Error triggers
  errorOccurred('An error occurred requiring navigation'),
  unauthorized('User unauthorized for requested resource'),

  // Manual triggers (explicit user actions)
  userNavigation('User explicitly navigated'),

  // System triggers
  appStartup('Application starting up'),
  deepLink('Deep link accessed');

  const NavigationTrigger(this.description);
  final String description;
}

/// State notifier for managing navigation state
class NavigationStateNotifier extends StateNotifier<NavigationState> {
  NavigationStateNotifier() : super(const NavigationState());

  /// Request navigation to a specific route with context
  void navigateTo({
    required String route,
    required NavigationTrigger trigger,
    Map<String, dynamic> params = const {},
    Map<String, dynamic> context = const {},
  }) {
    final timestamp = DateTime.now();
    AppLogger.info(
      '🧭 NAVIGATION_STATE: navigateTo called\n'
      '   - Route: $route\n'
      '   - Trigger: $trigger\n'
      '   - Params: $params\n'
      '   - Context: $context\n'
      '   - Timestamp: ${timestamp.toIso8601String()}\n'
      '   - Previous state: ${state.pendingRoute} (${state.trigger})',
    );

    state = NavigationState(
      pendingRoute: route,
      routeParams: params,
      trigger: trigger,
      timestamp: timestamp,
      context: context,
    );

    AppLogger.info(
      '🧭 NAVIGATION_STATE: State updated\n'
      '   - New state: $route (${trigger.description})\n'
      '   - State hashCode: ${state.hashCode}',
    );
  }

  /// Request navigation based on a trigger only (let router decide the route)
  void triggerNavigation({
    required NavigationTrigger trigger,
    Map<String, dynamic> params = const {},
    Map<String, dynamic> context = const {},
  }) {
    state = NavigationState(
      routeParams: params,
      trigger: trigger,
      timestamp: DateTime.now(),
      context: context,
    );
  }

  /// Mark navigation as being processed by the router
  void markAsProcessing() {
    if (!state.hasPendingNavigation) return; // Nothing to process

    AppLogger.info(
      '🧭 NAVIGATION_STATE: markAsProcessing called\n'
      '   - Route: ${state.pendingRoute}\n'
      '   - Trigger: ${state.trigger}\n'
      '   - Timestamp: ${DateTime.now().toIso8601String()}',
    );

    state = state.copyWith(isProcessing: true);
  }

  /// Clear pending navigation (usually called by router after handling)
  void clearNavigation() {
    final previousRoute = state.pendingRoute;
    final previousTrigger = state.trigger;
    final wasProcessing = state.isProcessing;

    // Only clear if there's actually something to clear (idempotent)
    if (!state.hasPendingNavigation) {
      AppLogger.debug(
        '🧭 NAVIGATION_STATE: clearNavigation called but no navigation pending',
      );
      return;
    }

    AppLogger.info(
      '🧭 NAVIGATION_STATE: clearNavigation called\n'
      '   - Clearing at: ${DateTime.now().toIso8601String()}\n'
      '   - Previous route: $previousRoute\n'
      '   - Previous trigger: $previousTrigger\n'
      '   - Was processing: $wasProcessing\n'
      '   - About to clear state...',
    );

    state = NavigationState.cleared();

    AppLogger.info(
      '🧭 NAVIGATION_STATE: Navigation cleared\n'
      '   - New state: cleared\n'
      '   - New hashCode: ${state.hashCode}',
    );
  }

  /// Update navigation context without changing route/trigger
  void updateContext(Map<String, dynamic> newContext) {
    state = state.copyWith(context: {...state.context, ...newContext});
  }
}

/// Provider for navigation state
final navigationStateProvider =
    StateNotifierProvider<NavigationStateNotifier, NavigationState>(
  (ref) => NavigationStateNotifier(),
);

/// Helper methods for common navigation patterns
extension NavigationHelpers on NavigationStateNotifier {
  /// Navigate after successful authentication
  void afterAuthSuccess({Map<String, dynamic>? context}) {
    triggerNavigation(
      trigger: NavigationTrigger.authSuccess,
      context: context ?? {},
    );
  }

  /// Navigate after authentication failure
  void afterAuthFailure({String? error}) {
    triggerNavigation(
      trigger: NavigationTrigger.authFailure,
      context: {'error': error},
    );
  }

  /// Navigate after successful magic link verification
  void afterMagicLinkSuccess({Map<String, dynamic>? context}) {
    triggerNavigation(
      trigger: NavigationTrigger.magicLinkSuccess,
      context: context ?? {},
    );
  }

  /// Navigate after family invitation success
  void afterFamilyInvitationSuccess({
    required String familyId,
    String? redirectUrl,
  }) {
    navigateTo(
      route: redirectUrl ?? '/dashboard',
      trigger: NavigationTrigger.familyInvitationSuccess,
      context: {'familyId': familyId},
    );
  }

  /// Navigate after group invitation success
  void afterGroupInvitationSuccess({
    required String groupId,
    String? redirectUrl,
  }) {
    navigateTo(
      route: redirectUrl ?? '/dashboard',
      trigger: NavigationTrigger.groupInvitationSuccess,
      context: {'groupId': groupId},
    );
  }

  /// Navigate after onboarding completion
  void afterOnboardingComplete() {
    triggerNavigation(trigger: NavigationTrigger.onboardingCompleted);
  }

  /// Navigate after family creation
  void afterFamilyCreated() {
    triggerNavigation(trigger: NavigationTrigger.familyCreated);
  }

  /// Navigate when invitation requires family onboarding
  void requiresFamilyOnboarding() {
    triggerNavigation(
      trigger: NavigationTrigger.invitationRequiresFamilyOnboarding,
    );
  }
}

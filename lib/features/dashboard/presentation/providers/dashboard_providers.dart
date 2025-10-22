// CLEAN ARCHITECTURE COMPLIANT - Presentation layer providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dashboard_entities.dart';

// Type definition for callbacks without Flutter dependency
typedef CallbackFunction = void Function();
// Dashboard data providers - CLEAN: Using domain entities without UI dependencies
final recentActivitiesProvider = Provider<List<RecentActivity>>((ref) => []);
final upcomingTripsProvider = Provider<List<UpcomingTripDisplay>>((ref) => []);
// Dashboard configuration provider - CLEAN: Using config instead of callbacks
final dashboardActionsProvider = Provider<DashboardActionConfig?>(
  (ref) => null,
);
// PRESENTATION LAYER: UI-specific callback providers (properly separated)
final dashboardCallbacksProvider = Provider<DashboardCallbacks?>((ref) => null);
// Dashboard state providers
final dashboardRefreshProvider = Provider<CallbackFunction?>((ref) => null);
final dashboardLoadingProvider = Provider<bool>((ref) => false);
/// Presentation layer class for UI callbacks - CLEAN: Separated from domain
class DashboardCallbacks {
  final CallbackFunction onAddChild;
  final CallbackFunction onJoinGroup;
  final CallbackFunction onAddVehicle;

  DashboardCallbacks({
    required this.onAddChild,
    required this.onJoinGroup,
    required this.onAddVehicle,
  });
}

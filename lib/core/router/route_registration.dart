import '../../features/auth/presentation/routing/auth_route_factory.dart';
import '../../features/dashboard/presentation/routing/dashboard_route_factory.dart';
import '../../features/family/presentation/routing/family_route_factory.dart';
import '../../features/groups/presentation/routing/groups_route_factory.dart';
import '../../features/schedule/presentation/routing/schedule_route_factory.dart';
import 'shared_route_factory.dart';
import 'core_routes.dart';
import 'route_factory.dart';

/// Registers all route factories
/// This is the only place that knows about all features - composition root pattern
class RouteRegistration {
  static void registerAll() {
    // Feature routes
    RouteRegistry.register(AuthRouteFactory());
    RouteRegistry.register(DashboardRouteFactory());
    RouteRegistry.register(FamilyRouteFactory());
    RouteRegistry.register(GroupsRouteFactory());
    RouteRegistry.register(ScheduleRouteFactory());
    RouteRegistry.register(SharedRouteFactory());

    // Core/system routes (not feature-specific)
    RouteRegistry.registerAll(CoreRoutes.routes);
  }
}

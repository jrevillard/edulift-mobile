import 'package:go_router/go_router.dart';

/// Interface for feature-specific route factories
/// This allows features to register their own routes without the core router
/// needing to import presentation layer files
abstract class AppRouteFactory {
  /// Get the list of routes that this factory provides
  List<RouteBase> get routes;
}

/// Registry for route factories - core router uses this to build routes
class RouteRegistry {
  static final _factories = <AppRouteFactory>[];
  static final _directRoutes = <RouteBase>[];

  /// Register a route factory
  static void register(AppRouteFactory factory) {
    _factories.add(factory);
  }

  /// Register routes directly (for core routes that don't need a factory)
  static void registerAll(List<RouteBase> routes) {
    _directRoutes.addAll(routes);
  }

  /// Get all registered routes
  static List<RouteBase> getAllRoutes() {
    final factoryRoutes = _factories.expand((factory) => factory.routes);
    return [...factoryRoutes, ..._directRoutes];
  }

  /// Clear all factories (used for testing)
  static void clear() {
    _factories.clear();
    _directRoutes.clear();
  }
}

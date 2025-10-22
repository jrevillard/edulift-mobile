import 'package:go_router/go_router.dart';
import '../../../../core/router/route_factory.dart';
import '../../../../core/router/app_routes.dart';
import '../pages/dashboard_page.dart';

/// Route factory for dashboard feature
class DashboardRouteFactory implements AppRouteFactory {
  @override
  List<RouteBase> get routes => [
    // Dashboard
    GoRoute(
      path: AppRoutes.dashboard,
      name: 'dashboard',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: DashboardPage()),
    ),
  ];
}

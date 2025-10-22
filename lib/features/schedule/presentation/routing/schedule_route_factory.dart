import 'package:go_router/go_router.dart';
import '../../../../core/router/route_factory.dart';
import '../../../../core/router/app_routes.dart';
import '../pages/schedule_page.dart';
import '../pages/create_schedule_page.dart';

/// Route factory for schedule feature
class ScheduleRouteFactory implements AppRouteFactory {
  @override
  List<RouteBase> get routes => [
    // Schedule
    GoRoute(
      path: AppRoutes.schedule,
      name: 'schedule',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: SchedulePage()),
      routes: [
        GoRoute(
          path: 'create',
          name: 'create-schedule',
          builder: (context, state) => const CreateSchedulePage(),
        ),
      ],
    ),
  ];
}

import 'package:go_router/go_router.dart';
import '../../../core/router/route_factory.dart';
import '../../../core/router/app_routes.dart';
import '../presentation/widgets/profile/profile_page.dart';

/// Route factory for shared presentation features
class SharedRouteFactory implements AppRouteFactory {
  @override
  List<RouteBase> get routes => [
        // Profile
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ];
}

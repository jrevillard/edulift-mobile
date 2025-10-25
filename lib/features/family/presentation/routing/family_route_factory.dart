import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import '../../../../core/router/route_factory.dart';
import '../../../../core/router/app_routes.dart';
import '../pages/add_child_page.dart';
import '../pages/edit_child_page.dart';
import '../pages/create_family_page.dart';
import '../pages/family_invitation_page.dart';
import '../pages/add_vehicle_page.dart';
import '../pages/edit_vehicle_page.dart';
import '../pages/vehicle_details_page.dart';
import '../pages/invite_member_page.dart';
import '../pages/family_management_screen.dart';

/// Route factory for family feature
class FamilyRouteFactory implements AppRouteFactory {
  @override
  List<RouteBase> get routes => [
    // Family creation (standalone route without navigation shell)
    GoRoute(
      path: AppRoutes.createFamily,
      name: 'create-family',
      builder: (context, state) => const CreateFamilyPage(),
    ),
    // Family management
    GoRoute(
      path: AppRoutes.family,
      name: 'family',
      // Use builder for simplicity - GoRouter manages page keys automatically
      builder: (context, state) => const FamilyManagementScreen(),
      routes: [
        GoRoute(
          path: 'add-child',
          name: 'add-child',
          builder: (context, state) => const AddChildPage(),
        ),
        GoRoute(
          path: 'invite',
          name: 'invite-member',
          builder: (context, state) => const InviteMemberPage(),
        ),
        GoRoute(
          path: 'children/:childId/edit',
          name: 'edit-child',
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            return EditChildPage(childId: childId);
          },
        ),
        GoRoute(
          path: 'child/:childId',
          name: 'child-details',
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            return _ChildDetailsPage(childId: childId);
          },
        ),
        // Routes for vehicles moved directly under family
        GoRoute(
          path: 'vehicles/add',
          name: 'add-vehicle',
          builder: (context, state) => const AddVehiclePage(),
        ),
        GoRoute(
          path: 'vehicles/:vehicleId',
          name: 'vehicle-details',
          builder: (context, state) {
            final vehicleId = state.pathParameters['vehicleId']!;
            return VehicleDetailsPage(vehicleId: vehicleId);
          },
        ),
        GoRoute(
          path: 'vehicles/:vehicleId/edit',
          name: 'edit-vehicle',
          builder: (context, state) {
            final vehicleId = state.pathParameters['vehicleId']!;
            return EditVehiclePage(vehicleId: vehicleId);
          },
        ),
      ],
    ),

    // Family invitation routes (deep links and web compatibility)
    GoRoute(
      path: '/invite/:code',
      name: 'invitation',
      builder: (context, state) {
        final code = state.pathParameters['code']!;
        return FamilyInvitationPage(inviteCode: code);
      },
    ),
    GoRoute(
      path: '/family-invitation',
      name: 'family-invitation',
      builder: (context, state) {
        final code = state.uri.queryParameters['code'];
        return FamilyInvitationPage(inviteCode: code);
      },
    ),
  ];
}

// Local placeholder page that was previously in app_router.dart
class _ChildDetailsPage extends StatelessWidget {
  final String childId;

  const _ChildDetailsPage({required this.childId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.childDetailsTitle)),
      body: Center(child: Text(l10n.childIdLabel(childId))),
    );
  }
}

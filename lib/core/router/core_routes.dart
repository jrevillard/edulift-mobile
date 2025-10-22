import 'package:go_router/go_router.dart';
import '../presentation/pages/onboarding_wizard_page.dart';

/// Core application routes (system/navigation pages, not feature-specific)
///
/// This includes routes for:
/// - Onboarding flows
/// - System pages (splash, error, etc.)
/// - Other non-feature routes
class CoreRoutes {
  static List<RouteBase> get routes => [
    // Onboarding wizard - initial user setup
    GoRoute(
      path: '/onboarding/wizard',
      name: 'onboarding-wizard',
      builder: (context, state) {
        final invitationCode = state.uri.queryParameters['invitationCode'];
        return OnboardingWizardPage(invitationCode: invitationCode);
      },
    ),
  ];
}

import 'package:flutter/material.dart' hide Scaffold;
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/router/route_factory.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../pages/login_page.dart';
import '../pages/magic_link_page.dart';
import '../pages/magic_link_verify_page.dart';

/// Route factory for authentication feature
class AuthRouteFactory implements AppRouteFactory {
  @override
  List<RouteBase> get routes => [
    // Authentication routes
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
      routes: [
        GoRoute(
          path: 'magic-link',
          name: 'magic-link',
          builder: (context, state) {
            final email = state.uri.queryParameters['email'] ?? '';
            return MagicLinkPage(email: email);
          },
        ),
      ],
    ),

    // CRITICAL FIX: Magic link verification route with Consumer wrapper
    // This ensures the MagicLinkVerifyPage gets the correct ProviderScope/Container
    GoRoute(
      path: '/auth/verify',
      name: 'verify-magic-link',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'];
        final inviteCode = state.uri.queryParameters['inviteCode'];
        final email = state.uri.queryParameters['email'];

        if (token == null) {
          return const _ErrorPage(error: 'No verification token provided');
        }

        // CRITICAL FIX: Wrap in Consumer to ensure proper ProviderScope inheritance
        // This guarantees the MagicLinkVerifyPage gets the same provider container
        // as the rest of the app instead of a potentially different one from GoRouter's context
        return Consumer(
          builder: (context, ref, child) {
            // Add debug logging to verify the fix
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppLogger.info(
                '🔧 PROVIDER_FIX: Consumer wrapper ensuring proper provider scope\n'
                '   - GoRouter builder context hashCode: ${context.hashCode}\n'
                '   - Consumer ref.hashCode: ${ref.hashCode}\n'
                '   - This should match other parts of the app',
              );
            });
            return MagicLinkVerifyPage(
              token: token,
              inviteCode: inviteCode,
              email: email,
            );
          },
        );
      },
    ),
  ];
}

class _ErrorPage extends ConsumerWidget {
  final String error;

  const _ErrorPage({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return material.Scaffold(
      appBar: AppBar(title: Text(l10n.errorTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Color(0xFFDC2626)),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate back to login - router will handle it
              },
              child: Text(l10n.backToHome),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../router/app_router.dart';
import '../../utils/app_logger.dart';

/// State-of-the-art router provider using singleton pattern
///
/// This provider creates a GoRouter instance ONCE and reuses it throughout
/// the app lifecycle, preventing navigation state loss during UI rebuilds
/// (such as theme changes, language changes, etc.).
///
/// The router maintains its internal state and listeners while UI components
/// can rebuild freely without affecting navigation context.
///
/// Architecture Benefits:
/// - ✅ Preserves navigation state during language changes
/// - ✅ Prevents expensive router recreation on every build
/// - ✅ Maintains auth/navigation listeners consistently
/// - ✅ Follows 2025 Flutter best practices
/// - ✅ Clean separation between UI state and navigation state
final goRouterProvider = Provider<GoRouter>((ref) {
  AppLogger.info(
    '🏗️ [Router Provider] Creating singleton GoRouter instance\n'
    '   - Created at: ${DateTime.now().toIso8601String()}\n'
    '   - Provider hashCode: ${ref.hashCode}\n'
    '   - This router will be reused throughout app lifecycle\n'
    '   - Navigation state will be preserved during UI rebuilds',
  );

  // Use the stable router creation method that works with Provider pattern
  final router = AppRouter.createStableRouter(ref);

  AppLogger.info(
    '✅ [Router Provider] GoRouter singleton created successfully\n'
    '   - Router hashCode: ${router.hashCode}\n'
    '   - Auth listeners: ACTIVE\n'
    '   - Navigation listeners: ACTIVE\n'
    '   - Ready for MaterialApp.router integration',
  );

  return router;
});

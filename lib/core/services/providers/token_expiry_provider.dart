import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_logger.dart';

/// SIMPLE SOLUTION: Token Expiry Notification Provider
///
/// Uses Riverpod StateProvider to notify when tokens expire.
/// This respects Clean Architecture:
/// - Infrastructure layer updates this provider
/// - Presentation layer listens to this provider
/// - No direct dependencies between Infrastructure → Presentation

/// Token expiry event data
class TokenExpiredEvent {
  final int statusCode;
  final String? endpoint;
  final DateTime timestamp;

  const TokenExpiredEvent({
    required this.statusCode,
    this.endpoint,
    required this.timestamp,
  });

  @override
  String toString() =>
      'TokenExpiredEvent(statusCode: $statusCode, endpoint: $endpoint)';
}

/// Simple StateProvider for token expiry events
///
/// When token expires (403/401), Infrastructure updates this provider.
/// AuthProvider listens to changes and triggers logout.
final tokenExpiredProvider = StateProvider<TokenExpiredEvent?>((ref) => null);

/// Utility class for triggering token expiry notifications
class TokenExpiryNotifier {
  static void notifyTokenExpired(
    Ref ref, {
    required int statusCode,
    String? endpoint,
  }) {
    final event = TokenExpiredEvent(
      statusCode: statusCode,
      endpoint: endpoint,
      timestamp: DateTime.now(),
    );

    AppLogger.info('🔑 TokenExpiryNotifier: Token expired - $event');

    // Update the provider to notify listeners
    ref.read(tokenExpiredProvider.notifier).state = event;
  }

  /// Clear the token expired state (called after logout is handled)
  static void clearTokenExpiredState(Ref ref) {
    ref.read(tokenExpiredProvider.notifier).state = null;
  }
}

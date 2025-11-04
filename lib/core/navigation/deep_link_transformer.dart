/// Deep link transformation utilities
///
/// Centralizes the logic for transforming edulift:// and HTTPS scheme URIs to app routes.
/// Used by both DeepLinkService and GoRouter to ensure consistency.
library;

import '../config/environment_config.dart';

/// Transforms edulift:// and HTTPS scheme URIs to internal app routes
///
/// Examples:
/// - `edulift://groups/join?code=ABC` → `/group-invitation?code=ABC`
/// - `https://transport.tanjama.fr/groups/join?code=ABC` → `/group-invitation?code=ABC`
/// - `edulift://families/join?code=XYZ` → `/family-invitation?code=XYZ`
/// - Other URIs → `null` (not handled by this transformer)
String? transformInvitationDeepLink(Uri uri) {
  // Only transform edulift:// and https:// scheme URIs
  if (uri.scheme != 'edulift' && uri.scheme != 'https') {
    return null;
  }

  // For HTTPS links, validate domain from config
  if (uri.scheme == 'https') {
    final config = EnvironmentConfig.getConfig();
    final baseUrl = config.deepLinkBaseUrl;
    final configUri = Uri.parse(baseUrl);

    if (uri.host != configUri.host) {
      return null;
    }
  }

  // Transform group invitation deep links
  if (uri.host == 'groups' || uri.path.startsWith('groups/')) {
    final code = uri.queryParameters['code'];
    return '/group-invitation${code != null ? '?code=$code' : ''}';
  }

  // Transform family invitation deep links
  if (uri.host == 'families' || uri.path.startsWith('families/')) {
    final code = uri.queryParameters['code'];
    return '/family-invitation${code != null ? '?code=$code' : ''}';
  }

  // Not an invitation deep link - don't transform
  return null;
}

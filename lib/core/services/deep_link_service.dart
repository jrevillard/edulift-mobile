// EduLift Mobile - Deep Link Service
// Handles custom URL schemes and deep link processing for multi-platform magic links

import 'dart:io';
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:protocol_handler/protocol_handler.dart';
import '../utils/app_logger.dart';
import '../errors/failures.dart';
import '../utils/result.dart';
import '../domain/entities/auth_entities.dart';

import '../domain/services/deep_link_service.dart';

/// Deep link service implementation

/// Deep link service implementation with singleton pattern
///
/// SINGLETON PATTERN: Prevents multiple instances that would cause
/// conflicting protocol handlers and file watchers.
class DeepLinkServiceImpl implements DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  Function(DeepLinkResult)? _deepLinkHandler;
  Timer? _fileWatcher;

  static const String _customScheme = 'edulift';
  static const String _devLinkFile = '/tmp/edulift-deeplink';

  // SINGLETON PATTERN - Prevents multiple protocol handlers
  static DeepLinkServiceImpl? _instance;

  /// Private constructor - prevents direct instantiation
  /// CRITICAL: This prevents multiple DeepLinkServiceImpl instances
  /// that cause conflicting protocol handlers and file watchers.
  DeepLinkServiceImpl._();

  /// Singleton instance getter - ONLY way to get DeepLinkServiceImpl
  ///
  /// ARCHITECTURE REQUIREMENT: All providers MUST use this method instead
  /// of creating new instances with DeepLinkServiceImpl().
  /// This ensures only one protocol handler and file watcher exists.
  static DeepLinkServiceImpl getInstance() {
    _instance ??= DeepLinkServiceImpl._();
    return _instance!;
  }

  @override
  Future<Result<void, Failure>> initialize() async {
    try {
      AppLogger.info('🔗 Initializing DeepLinkService');
      AppLogger.debug(
        '🔧 Platform: ${Platform.operatingSystem}\n'
        '📱 Custom scheme: $_customScheme',
      );

      // Register protocol handler for desktop platforms
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        AppLogger.debug(
          '🖥️ Registering protocol handler for desktop platform: ${Platform.operatingSystem}',
        );
        try {
          await protocolHandler.register(_customScheme);
          AppLogger.info('✅ Protocol handler registered successfully');
        } catch (e) {
          AppLogger.warning(
            '⚠️ Protocol handler registration failed (non-critical): $e',
          );
        }
      }

      // Set up deep link listening for all platforms
      _appLinks.uriLinkStream.listen(
        (Uri uri) {
          AppLogger.info('📱 Deep link received via stream: $uri');
          _handleIncomingDeepLink(uri);
        },
        onError: (error) {
          AppLogger.error('❌ Deep link stream error', error);
        },
      );

      // Check for initial deep link (cold start scenario)
      try {
        final initialUri = await _appLinks.getInitialLink();
        if (initialUri != null) {
          AppLogger.info(
            '🚀 Initial deep link found (cold start): $initialUri',
          );
          _handleIncomingDeepLink(initialUri);
        } else {
          AppLogger.debug('ℹ️ No initial deep link found');
        }
      } catch (e) {
        AppLogger.warning('⚠️ Failed to get initial deep link: $e');
      }

      // DON'T start file watcher here - wait until handler is set
      // This ensures we don't process deep links before the app is ready

      AppLogger.info('✅ DeepLinkService initialized successfully');
      return const Result.ok(null);
    } catch (e, stackTrace) {
      AppLogger.error(
        '💥❌ DeepLinkService initialization failed',
        e,
        stackTrace,
      );
      return Result.err(
        ApiFailure.serverError(
          message: 'Failed to initialize deep link service: $e',
        ),
      );
    }
  }

  @override
  Future<DeepLinkResult?> getInitialDeepLink() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        return parseDeepLink(initialUri.toString());
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get initial deep link', e);
      return null;
    }
  }

  @override
  void setDeepLinkHandler(Function(DeepLinkResult)? handler) {
    _deepLinkHandler = handler;
    if (handler != null) {
      AppLogger.debug('🎯 Deep link handler set');

      // Start file watcher now that handler is ready (only once)
      if (_fileWatcher == null) {
        _startDevFileWatcher();
      }
    } else {
      AppLogger.debug('🧹 Deep link handler cleared');
    }
  }

  @override
  DeepLinkResult? parseDeepLink(String url) {
    try {
      AppLogger.debug('🔍 Parsing deep link: $url');
      final uri = Uri.parse(url);

      // Only process our custom scheme
      if (uri.scheme != _customScheme) {
        AppLogger.debug('⏭️ Ignoring non-edulift scheme: ${uri.scheme}');
        return null;
      }

      AppLogger.debug(
        '✅ Valid edulift scheme detected\n'
        '📍 Host: ${uri.host}, Path: ${uri.path}\n'
        '🔗 Query parameters: ${uri.queryParameters}',
      );

      // Extract path information from URI
      final path = _extractPath(uri);
      AppLogger.debug('📂 Extracted path: "$path"');

      // SECURITY: Validate paths to prevent malformed URIs from getting stuck
      // Only allow known valid deep link paths
      final validPaths = {
        'auth/verify', // Magic link verification
        'groups/join', // Group invitations
        'families/join', // Family invitations
        'dashboard', // Dashboard shortcuts
        '', // Empty path (defaults to dashboard)
      };

      if (path.isNotEmpty && !validPaths.contains(path)) {
        AppLogger.warning(
          '❌ SECURITY: Invalid deep link path detected: "$path" - rejecting deep link',
        );
        return null;
      }

      final rawParameters = Map<String, String>.from(uri.queryParameters);

      // Convert empty strings to null for consistent null handling
      final parameters = Map<String, String>.fromEntries(
        rawParameters.entries.where((entry) => entry.value.isNotEmpty),
      );

      // Enhanced validation for magic link tokens
      final token = parameters['token'];
      if (token != null) {
        AppLogger.info('🪄 Magic token detected in deep link');
        if (token.length < 10) {
          AppLogger.warning('⚠️ Token appears too short, may be invalid');
        }
      }

      // Extract email with URL decoding
      final rawEmail = parameters['email'];
      final decodedEmail =
          rawEmail != null ? Uri.decodeComponent(rawEmail) : null;

      // Support both 'code' and 'inviteCode' parameters for backend compatibility
      final inviteCode = parameters['code'] ?? parameters['inviteCode'];

      final result = DeepLinkResult(
        inviteCode: inviteCode,
        magicToken: token,
        email: decodedEmail,
        path: path,
        parameters: parameters,
      );

      AppLogger.info(
        '🎯 Deep link parsed successfully: path="$path" ${result.hasMagicLink ? "magic-link" : ""} ${result.hasInvitation ? "invitation" : ""}',
      );

      return result;
    } catch (e) {
      AppLogger.error('Failed to parse deep link: $url', e);
      return null;
    }
  }

  /// Extract path from URI host and path components
  /// Maps edulift:// URLs to router paths based on frontend patterns
  String _extractPath(Uri uri) {
    // Handle the path based on URI structure
    var path = '';

    // Check if host contains the main path component
    if (uri.host.isNotEmpty) {
      path = uri.host;

      // Append additional path segments if they exist
      if (uri.path.isNotEmpty && uri.path != '/') {
        // Remove leading slash and append
        final pathSegment =
            uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
        if (pathSegment.isNotEmpty) {
          path = '$path/$pathSegment';
        }
      }
    } else if (uri.path.isNotEmpty && uri.path != '/') {
      // Use path component if no host
      path = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
    }

    AppLogger.debug('🗺️ Path mapping: "${uri.host}${uri.path}" -> "$path"');
    return path;
  }

  @override
  String generateNativeDeepLink(String token, {String? inviteCode}) {
    final params = {'token': token};
    if (inviteCode != null) {
      params['inviteCode'] = inviteCode;
    }

    final query = params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');

    return '$_customScheme://auth/verify?$query';
  }

  void _handleIncomingDeepLink(Uri uri) {
    final result = parseDeepLink(uri.toString());

    if (result == null || result.isEmpty) {
      AppLogger.warning('⚠️ Empty or invalid deep link received: $uri');
      return;
    }

    AppLogger.info('📥 Processing deep link: $result');

    // Handle magic link deep links - delegate to app-level navigation
    if (result.hasMagicLink && result.magicToken != null) {
      AppLogger.info(
        '🪄 Magic link deep link detected, delegating to app navigation...',
      );
      // Don't process directly - let the app navigation handle the UI flow
    }

    // Notify handler if set
    AppLogger.debug(
      '🔍 Handler check: ${_deepLinkHandler != null ? "SET (hashCode: ${_deepLinkHandler.hashCode})" : "NULL"}',
    );
    if (_deepLinkHandler != null) {
      AppLogger.info('🎯 Calling deep link handler with result: $result');
      try {
        _deepLinkHandler!(result);
        AppLogger.debug('✅ Handler executed successfully');
      } catch (e, stack) {
        AppLogger.error('❌ Handler execution failed', e, stack);
      }
    } else {
      AppLogger.warning(
        '⚠️ No deep link handler set - cannot process: $result',
      );
    }
  }

  void _startDevFileWatcher() {
    // Only in development and Linux environment (devcontainer)
    if (Platform.isLinux && Platform.environment.containsKey('DEVCONTAINER')) {
      AppLogger.info('📁 Starting devcontainer file watcher for deep links');

      _fileWatcher = Timer.periodic(const Duration(milliseconds: 500), (
        timer,
      ) async {
        try {
          final file = File(_devLinkFile);
          if (await file.exists()) {
            final content = await file.readAsString();
            final url = content.trim();

            // Process all valid deep links (allow reuse for error recovery)
            if (url.isNotEmpty && url.startsWith(_customScheme)) {
              AppLogger.info('📂 Dev file deep link detected: $url');

              // Parse and handle the deep link
              final uri = Uri.parse(url);
              _handleIncomingDeepLink(uri);

              // Clean up the file after processing
              try {
                await file.delete();
              } catch (e) {
                AppLogger.debug('Could not delete dev link file: $e');
              }
            }
          }
        } catch (e) {
          // Silently ignore file system errors (file might not exist)
        }
      });
    }
  }

  @override
  void dispose() {
    AppLogger.info('🧹 DeepLinkService disposed');
    _fileWatcher?.cancel();
    _deepLinkHandler = null;
  }
}

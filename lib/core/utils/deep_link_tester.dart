// EduLift Mobile - Deep Link Testing Utility
// Comprehensive testing and validation for deep link functionality

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../domain/services/deep_link_service.dart';
import 'app_logger.dart';

/// Deep link testing and validation utility
class DeepLinkTester {
  /// Test various deep link formats to ensure parsing works correctly
  static void runComprehensiveTests(DeepLinkService deepLinkService) {
    if (kDebugMode) {
      AppLogger.info('🧪 Running comprehensive deep link tests...');

      final testCases = [
        // Magic link verification
        'edulift://auth/verify?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test',
        'edulift://auth/verify?token=test123&email=test.user@localhost',
        'edulift://auth/verify?token=test123&inviteCode=FAM123',
        'edulift://auth/verify?token=test123&email=test.user@localhost&inviteCode=FAM123',

        // Family invitations
        'edulift://invite/FAM123',
        'edulift://invite?code=FAM123',

        // Edge cases
        'edulift://',
        'edulift://unknown',
        'https://edulift.app/auth/verify?token=test123', // Should be ignored
        'mailto:test.user@localhost', // Should be ignored
        // Malformed URLs
        'edulift://auth/verify', // No token
        'edulift://auth/verify?', // Empty query
        'edulift://auth/verify?token=', // Empty token
      ];

      for (final testUrl in testCases) {
        _testDeepLinkParsing(deepLinkService, testUrl);
      }

      AppLogger.info('✅ Deep link tests completed');
    }
  }

  /// Test parsing of individual deep link
  static void _testDeepLinkParsing(
    DeepLinkService deepLinkService,
    String url,
  ) {
    try {
      AppLogger.debug('🔍 Testing: $url');
      final result = deepLinkService.parseDeepLink(url);

      if (result != null) {
        final details = {
          'hasMagicLink': result.hasMagicLink,
          'hasInvitation': result.hasInvitation,
          'magicToken': result.magicToken?.substring(
            0,
            (result.magicToken?.length ?? 0).clamp(0, 10),
          ),
          'inviteCode': result.inviteCode,
          'email': result.email,
          'parameters': result.parameters,
        };
        AppLogger.debug('  ✅ Parsed: $details');
      } else {
        AppLogger.debug('  ⏭️ Ignored (as expected for invalid URLs)');
      }
    } catch (e) {
      AppLogger.warning('  ❌ Failed to parse: $e');
    }
  }

  /// Simulate deep link reception for development testing
  static Future<void> simulateDeepLink(
    DeepLinkService deepLinkService,
    String url,
  ) async {
    if (!kDebugMode) return;

    AppLogger.info('🎭 Simulating deep link: $url');

    try {
      final result = deepLinkService.parseDeepLink(url);
      if (result != null) {
        // This would normally trigger the deep link handler
        AppLogger.info('📨 Simulated deep link would trigger: $result');
      } else {
        AppLogger.warning('⚠️ Simulated deep link was ignored');
      }
    } catch (e) {
      AppLogger.error('❌ Deep link simulation failed', e);
    }
  }

  /// Create a test deep link file for development (Linux/devcontainer only)
  static Future<void> createTestDeepLinkFile(String url) async {
    if (!kDebugMode || !Platform.isLinux) return;

    try {
      const filePath = '/tmp/edulift-deeplink';
      final file = File(filePath);
      await file.writeAsString(url);

      AppLogger.info('📁 Created test deep link file: $filePath');
      AppLogger.info('📄 Content: $url');
      AppLogger.info('ℹ️ The DeepLinkService will pick this up automatically');
    } catch (e) {
      AppLogger.error('❌ Failed to create test deep link file', e);
    }
  }

  /// Generate test URLs for various scenarios
  static List<String> generateTestUrls(DeepLinkService deepLinkService) {
    return [
      // Basic magic link
      deepLinkService.generateNativeDeepLink('test_token_123'),

      // Magic link with invitation
      deepLinkService.generateNativeDeepLink(
        'test_token_456',
        inviteCode: 'FAM789',
      ),

      // Complex token
      deepLinkService.generateNativeDeepLink(
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c',
      ),
    ];
  }

  /// Validate deep link configuration at runtime
  static Future<bool> validateConfiguration(
    DeepLinkService deepLinkService,
  ) async {
    AppLogger.info('🔧 Validating deep link configuration...');

    var isValid = true;

    try {
      // Test service initialization
      final initResult = await deepLinkService.initialize();
      initResult.when(
        err: (error) {
          AppLogger.error('❌ DeepLinkService initialization failed: $error');
          isValid = false;
        },
        ok: (success) {
          AppLogger.debug('✅ DeepLinkService initialization successful');
        },
      );

      // Test URL parsing
      const testUrl = 'edulift://auth/verify?token=test123';
      final parseResult = deepLinkService.parseDeepLink(testUrl);
      if (parseResult == null || !parseResult.hasMagicLink) {
        AppLogger.error('❌ Basic URL parsing failed');
        isValid = false;
      } else {
        AppLogger.debug('✅ Basic URL parsing successful');
      }

      // Test URL generation
      final generatedUrl = deepLinkService.generateNativeDeepLink('test_token');
      if (!generatedUrl.startsWith('edulift://')) {
        AppLogger.error('❌ URL generation failed');
        isValid = false;
      } else {
        AppLogger.debug('✅ URL generation successful');
      }
    } catch (e) {
      AppLogger.error('❌ Configuration validation error', e);
      isValid = false;
    }

    AppLogger.info(
      isValid
          ? '✅ Deep link configuration is valid'
          : '❌ Deep link configuration has issues',
    );
    return isValid;
  }
}

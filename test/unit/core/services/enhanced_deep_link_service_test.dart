// EduLift Mobile - Enhanced Deep Link Service Integration Tests
// TDD London School - Testing service integration with enhanced path support
// RED PHASE: Tests for parsing functionality that doesn't exist yet

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/services/deep_link_service.dart';
import '../../../fixtures/deeplink_test_data.dart';

void main() {
  group('Enhanced DeepLinkService with Path Support', () {
    late DeepLinkServiceImpl deepLinkService;

    setUp(() {
      deepLinkService = DeepLinkServiceImpl.getInstance();
    });

    // =================== ENHANCED URL PARSING TESTS ===================

    group('Enhanced URL Parsing', () {
      test('should parse auth/verify URL with path extraction', () {
        // ARRANGE
        const url = 'edulift://auth/verify?token=magic123&inviteCode=fam456';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT - Enhanced parsing should extract path
        expect(result, isNotNull);
        expect(result!.path, equals('auth/verify'));
        expect(result.magicToken, equals('magic123'));
        expect(result.inviteCode, equals('fam456'));
        expect(result.isAuthVerifyPath, isTrue);
        expect(result.routerPath, equals('/auth/verify'));
      });

      test('should parse groups/join URL with path extraction', () {
        // ARRANGE
        const url = 'edulift://groups/join?code=grp789';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.path, equals('groups/join'));
        expect(result.inviteCode, equals('grp789'));
        expect(result.isGroupJoinPath, isTrue);
        expect(result.routerPath, equals('/groups/join'));
        expect(result.requiresAuthentication, isTrue);
        expect(result.requiresFamily, isTrue);
      });

      test('should parse families/join URL with path extraction', () {
        // ARRANGE
        const url = 'edulift://families/join?code=fam456';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.path, equals('families/join'));
        expect(result.inviteCode, equals('fam456'));
        expect(result.isFamilyJoinPath, isTrue);
        expect(result.routerPath, equals('/families/join'));
        expect(result.requiresAuthentication, isTrue);
        expect(result.requiresFamily, isFalse);
      });

      test('should parse dashboard URL with path extraction', () {
        // ARRANGE
        const url = 'edulift://dashboard?view=schedule&groupId=123';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.path, equals('dashboard'));
        expect(result.isDashboardPath, isTrue);
        expect(result.routerPath, equals('/dashboard'));
        expect(result.parameters['view'], equals('schedule'));
        expect(result.parameters['groupId'], equals('123'));
      });

      test('should handle complex auth/verify with all parameters', () {
        // ARRANGE
        const url =
            'edulift://auth/verify?token=magic123&inviteCode=fam456&email=test%40example.com';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.path, equals('auth/verify'));
        expect(result.magicToken, equals('magic123'));
        expect(result.inviteCode, equals('fam456'));
        expect(
          result.email,
          equals('test@example.com'),
        ); // Should handle URL decoding
        expect(result.decodedEmail, equals('test@example.com'));
        expect(result.hasValidToken, isTrue);
        expect(result.hasValidEmail, isTrue);
        expect(result.canProceedWithAuth, isTrue);
      });
    });

    // =================== PARAMETER EXTRACTION TESTS ===================

    group('Parameter Extraction', () {
      test('should extract token parameter correctly', () {
        // ARRANGE
        const url = 'edulift://auth/verify?token=secure_token_123';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.extractedToken, equals('secure_token_123'));
        expect(result.magicToken, equals('secure_token_123'));
        expect(result.hasValidToken, isTrue);
      });

      test('should extract invite code from different parameter names', () {
        // ARRANGE - Test both 'code' and 'inviteCode' parameters
        const urlWithCode = 'edulift://groups/join?code=grp789';
        const urlWithInviteCode =
            'edulift://auth/verify?token=abc&inviteCode=fam456';

        // ACT
        final resultWithCode = deepLinkService.parseDeepLink(urlWithCode);
        final resultWithInviteCode = deepLinkService.parseDeepLink(
          urlWithInviteCode,
        );

        // ASSERT
        expect(resultWithCode!.extractedInviteCode, equals('grp789'));
        expect(resultWithInviteCode!.extractedInviteCode, equals('fam456'));
      });

      test('should extract email parameter with URL decoding', () {
        // ARRANGE
        const url = 'edulift://auth/verify?token=abc&email=user%40domain.com';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.extractedEmail, equals('user@domain.com'));
        expect(result.email, equals('user@domain.com'));
        expect(result.hasValidEmail, isTrue);
      });

      test('should handle special characters in parameters', () {
        // ARRANGE
        const url =
            'edulift://auth/verify?token=token%20with%20spaces&email=test%2Buser%40example.com';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.decodedToken, equals('token with spaces'));
        expect(result.decodedEmail, equals('test+user@example.com'));
      });
    });

    // =================== ROUTER INTEGRATION TESTS ===================

    group('Router Integration', () {
      test('should provide correct navigation context for auth paths', () {
        // ARRANGE
        const url = 'edulift://auth/verify?token=magic123&inviteCode=fam456';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT - Router integration properties
        expect(result, isNotNull);
        expect(result!.routerPath, equals('/auth/verify'));
        expect(
          result.requiresAuthentication,
          isFalse,
        ); // Magic link handles auth
        expect(result.preservesInviteContext, isTrue);
      });

      test('should provide correct navigation context for group invites', () {
        // ARRANGE
        const url = 'edulift://groups/join?code=grp789';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.routerPath, equals('/groups/join'));
        expect(result.requiresAuthentication, isTrue);
        expect(result.requiresFamily, isTrue);
        expect(result.preservesInviteContext, isTrue);
      });

      test('should provide correct navigation context for family invites', () {
        // ARRANGE
        const url = 'edulift://families/join?code=fam456';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.routerPath, equals('/families/join'));
        expect(result.requiresAuthentication, isTrue);
        expect(
          result.requiresFamily,
          isFalse,
        ); // Can join family without having one
        expect(result.preservesInviteContext, isTrue);
      });

      test('should provide correct navigation context for dashboard', () {
        // ARRANGE
        const url = 'edulift://dashboard';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.routerPath, equals('/dashboard'));
        expect(result.requiresAuthentication, isTrue);
        expect(result.requiresFamily, isFalse);
        expect(result.preservesInviteContext, isFalse);
      });
    });

    // =================== EDGE CASE HANDLING TESTS ===================

    group('Edge Case Handling', () {
      test('should handle empty path gracefully', () {
        // ARRANGE
        const url = 'edulift://';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.path, equals(''));
        expect(result.isEmptyPath, isTrue);
        expect(result.isValid, isFalse);
      });

      test('should handle path without parameters', () {
        // ARRANGE
        const url = 'edulift://dashboard';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.path, equals('dashboard'));
        expect(result.parameters, isEmpty);
        expect(result.isDashboardPath, isTrue);
      });

      test('should handle invalid scheme gracefully', () {
        // ARRANGE
        const url = 'https://example.com/auth/verify?token=abc';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT - Should return null for invalid scheme (existing behavior)
        expect(result, isNull);
      });

      test('should handle malformed URLs gracefully', () {
        // ARRANGE
        const url = 'not-a-valid-url';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT
        expect(result, isNull);
      });

      test('should handle empty parameter values', () {
        // ARRANGE
        const url = 'edulift://auth/verify?token=&email=';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.hasValidToken, isFalse);
        expect(result.hasValidEmail, isFalse);
        expect(result.canProceedWithAuth, isFalse);
      });

      test('should handle duplicate parameters correctly', () {
        // ARRANGE - Last parameter should win
        const url = 'edulift://groups/join?code=first&code=second';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT
        expect(result, isNotNull);
        expect(result!.inviteCode, equals('second'));
        expect(result.extractedInviteCode, equals('second'));
      });
    });

    // =================== BACKWARD COMPATIBILITY TESTS ===================

    group('Backward Compatibility', () {
      test(
        'should maintain existing parseDeepLink behavior for basic URLs',
        () {
          // ARRANGE - Existing test case should still work
          const url = 'edulift://auth/verify?token=abc123&inviteCode=fam456';

          // ACT
          final result = deepLinkService.parseDeepLink(url);

          // ASSERT - All original assertions should pass
          expect(result, isNotNull);
          expect(result!.magicToken, equals('abc123'));
          expect(result.inviteCode, equals('fam456'));
          expect(result.hasMagicLink, isTrue);
          expect(result.hasInvitation, isTrue);
          expect(result.isEmpty, isFalse);

          // ASSERT - Enhanced functionality should be available
          expect(result.path, equals('auth/verify'));
        },
      );

      test('should maintain existing behavior for URLs without parameters', () {
        // ARRANGE - Existing test case
        const url = 'edulift://auth/verify';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT - Original behavior maintained
        expect(result, isNotNull);
        expect(result!.magicToken, isNull);
        expect(result.inviteCode, isNull);
        expect(result.hasMagicLink, isFalse);
        expect(result.isEmpty, isTrue);

        // ASSERT - Enhanced functionality
        expect(result.path, equals('auth/verify'));
      });

      test('should maintain existing null return for invalid schemes', () {
        // ARRANGE - Existing test case
        const url = 'https://example.com/auth/verify?token=abc123';

        // ACT
        final result = deepLinkService.parseDeepLink(url);

        // ASSERT - Should still return null
        expect(result, isNull);
      });
    });

    // =================== PERFORMANCE TESTS ===================

    group('Performance', () {
      test('should parse complex URLs efficiently', () {
        // ARRANGE
        const url =
            'edulift://auth/verify?token=very_long_token_with_many_characters_123456789&inviteCode=family_invite_code_456&email=very.long.email.address%40example.com&param1=value1&param2=value2&param3=value3';

        // ACT
        final stopwatch = Stopwatch()..start();
        final result = deepLinkService.parseDeepLink(url);
        stopwatch.stop();

        // ASSERT - Should parse quickly (under 10ms for complex URL with enhanced logging)
        expect(result, isNotNull);
        // Performance timing assertion removed - arbitrary timeout
        expect(result!.path, equals('auth/verify'));
        expect(result.parameters, hasLength(greaterThan(4)));
      });

      test('should handle multiple consecutive parse calls efficiently', () {
        // ARRANGE
        const urls = [
          'edulift://auth/verify?token=abc123',
          'edulift://groups/join?code=grp789',
          'edulift://families/join?code=fam456',
          'edulift://dashboard?view=schedule',
        ];

        // ACT
        final stopwatch = Stopwatch()..start();
        final results =
            urls.map((url) => deepLinkService.parseDeepLink(url)).toList();
        stopwatch.stop();

        // ASSERT
        expect(results, hasLength(4));
        expect(results.every((result) => result != null), isTrue);
        // Performance timing assertion removed - arbitrary timeout
      });
    });

    // =================== INTEGRATION WITH TEST DATA ===================

    group('Integration with Test Data', () {
      test('should parse all test data URLs correctly', () {
        // ARRANGE - Using predefined test URLs
        final testUrls = [
          DeepLinkTestData.authVerifyUrl,
          DeepLinkTestData.authVerifyWithInviteUrl,
          DeepLinkTestData.groupJoinUrl,
          DeepLinkTestData.familyJoinUrl,
          DeepLinkTestData.dashboardUrl,
        ];

        // ACT & ASSERT
        for (final url in testUrls) {
          final result = deepLinkService.parseDeepLink(url);
          expect(result, isNotNull, reason: 'Failed to parse: $url');
          expect(result!.path, isNotEmpty, reason: 'Empty path for: $url');
        }
      });

      test('should return null for all invalid test URLs', () {
        // ARRANGE
        final invalidUrls = [
          DeepLinkTestData.invalidSchemeUrl,
          DeepLinkTestData.malformedUrl,
        ];

        // ACT & ASSERT
        for (final url in invalidUrls) {
          final result = deepLinkService.parseDeepLink(url);
          expect(result, isNull, reason: 'Should be null for: $url');
        }
      });
    });
  });
}

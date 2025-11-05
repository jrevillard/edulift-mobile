// EduLift Mobile - Deep Link Service Unit Tests
// Tests the deep link parsing and extraction functionality comprehensively

import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/core/services/deep_link_service.dart';
import 'package:edulift/core/domain/entities/auth_entities.dart';

void main() {
  group('DeepLinkService - Pure Logic Tests', () {
    late DeepLinkServiceImpl deepLinkService;

    setUp(() {
      deepLinkService = DeepLinkServiceImpl.getInstance();
    });

    group('Scheme Validation Logic', () {
      test('should accept edulift:// scheme URLs', () {
        // Given - edulift:// scheme is always accepted regardless of domain
        const testCases = [
          'edulift://auth/verify?token=abc123',
          'edulift://groups/join?code=grp789',
          'edulift://families/join?code=fam123',
          'edulift://auth/verify?token=abc123&email=user%40example.com',
          'edulift://groups/join?code=backup123', // Tests 'code' parameter support
        ];

        for (final url in testCases) {
          // When
          final result = deepLinkService.parseDeepLink(url);

          // Then - All edulift:// URLs should be accepted
          expect(
            result,
            isNotNull,
            reason: 'edulift:// URL should be accepted: $url',
          );
          expect(
            result!.path,
            isIn(['auth/verify', 'groups/join', 'families/join']),
          );
        }
      });

      test('should reject HTTP/HTTPS URLs from unauthorized domains in dev', () {
        // Given - HTTP/HTTPS URLs are rejected in dev due to domain validation
        const testCases = [
          'https://example.fr/auth/verify?token=abc123',
          'http://example.fr/groups/join?code=grp789',
          'https://transport.tanjama.fr:50443/families/join?code=fam123',
          'https://localhost:3001/auth/verify?token=abc123',
          'http://127.0.0.1:3001/groups/join?code=grp789',
        ];

        for (final url in testCases) {
          // When
          final result = deepLinkService.parseDeepLink(url);

          // Then - Should be rejected due to domain validation in dev
          expect(
            result,
            isNull,
            reason: 'HTTP/HTTPS URL should be rejected in dev: $url',
          );
        }
      });

      test('should reject unsupported schemes', () {
        // Given - Unsupported schemes should always be rejected
        const testCases = [
          'otherapp://auth/verify?token=abc123',
          'mailto:test@example.com',
          'tel:+1234567890',
          'ftp://files.com/auth/verify?token=abc123',
          'file:///path/to/auth/verify?token=abc123',
        ];

        for (final url in testCases) {
          // When
          final result = deepLinkService.parseDeepLink(url);

          // Then - Should reject unsupported schemes
          expect(
            result,
            isNull,
            reason: 'Unsupported scheme should be rejected: $url',
          );
        }
      });
    });

    group('Path Extraction Logic', () {
      test('should extract path correctly from edulift:// URLs', () {
        // Given - Test path extraction for custom scheme (host + path)
        const testCases = [
          {
            'url': 'edulift://auth/verify?token=abc123',
            'expectedPath': 'auth/verify',
            'description': 'Simple auth path',
          },
          {
            'url': 'edulift://groups/join?code=grp789',
            'expectedPath': 'groups/join',
            'description': 'Group invitation path',
          },
          {
            'url': 'edulift://families/join?code=fam123',
            'expectedPath': 'families/join',
            'description': 'Family invitation path',
          },
          {
            'url': 'edulift://auth/verify/path?token=abc123',
            'expectedPath': null, // Invalid path - will be rejected
            'description': 'Invalid nested path',
          },
        ];

        for (final testCase in testCases) {
          // When
          final url = testCase['url'] as String;
          final result = deepLinkService.parseDeepLink(url);

          // Then
          if (testCase['expectedPath'] != null) {
            expect(result, isNotNull, reason: testCase['description']!);
            expect(result!.path, equals(testCase['expectedPath']!));
          } else {
            expect(result, isNull, reason: testCase['description']!);
          }
        }
      });

      test('should extract path correctly from authorized HTTP/HTTPS URLs', () {
        // Given - A service instance with whitelisted domain for testing
        final testableService = DeepLinkServiceImpl.testable(
          authorizedDomains: ['example.fr'],
        );

        // Test 1: Basic HTTPS path extraction
        const httpsUrl = 'https://example.fr/auth/verify?token=abc123';
        final httpsResult = testableService.parseDeepLink(httpsUrl);

        // The extraction logic correctly extracts 'auth/verify' as the path
        expect(httpsResult, isNotNull);
        expect(httpsResult!.path, equals('auth/verify'));

        // Test 2: Basic HTTP path extraction
        const httpUrl = 'http://example.fr/groups/join?code=grp789';
        final httpResult = testableService.parseDeepLink(httpUrl);

        // The extraction logic correctly extracts 'groups/join' as the path
        expect(httpResult, isNotNull);
        expect(httpResult!.path, equals('groups/join'));

        // Test 3: HTTPS with families path
        const familiesUrl = 'https://example.fr/families/join?code=fam123';
        final familiesResult = testableService.parseDeepLink(familiesUrl);

        // The extraction logic correctly extracts 'families/join' as the path
        expect(familiesResult, isNotNull);
        expect(familiesResult!.path, equals('families/join'));

        // Test 4: Invalid path should be rejected even if domain is authorized
        const invalidPathUrl = 'https://example.fr/invalid/path?token=abc123';
        final invalidResult = testableService.parseDeepLink(invalidPathUrl);

        // The security validation should reject invalid paths
        expect(invalidResult, isNull);
      });

      test('should validate security whitelist correctly', () {
        // Given - Test security path validation
        const validPaths = ['auth/verify', 'groups/join', 'families/join'];
        const invalidPaths = [
          'dashboard',
          'admin/settings',
          'api/v1/auth/verify',
          'invalid/path',
          'auth/login',
          'auth/register',
          'groups/list',
          'families/create',
        ];

        // Test valid paths with edulift:// (always passes domain validation)
        for (final path in validPaths) {
          final url = 'edulift://$path?token=test123';
          final result = deepLinkService.parseDeepLink(url);
          expect(
            result,
            isNotNull,
            reason: 'Valid path should be accepted: $path',
          );
          expect(result!.path, equals(path));
        }

        // Test invalid paths with edulift://
        for (final path in invalidPaths) {
          final url = 'edulift://$path?token=test123';
          final result = deepLinkService.parseDeepLink(url);
          expect(
            result,
            isNull,
            reason: 'Invalid path should be rejected: $path',
          );
        }
      });
    });

    group('Parameter Extraction Logic', () {
      test('should extract magic token correctly', () {
        // Given
        const url = 'edulift://auth/verify?token=abc123xyz';

        // When
        final result = deepLinkService.parseDeepLink(url);

        // Then
        expect(result, isNotNull);
        expect(result!.path, equals('auth/verify'));
        expect(result.magicToken, equals('abc123xyz'));
        expect(result.hasMagicLink, isTrue);
        expect(result.hasInvitation, isFalse);
      });

      test('should extract invitation code correctly', () {
        // Given - Test both 'code' and 'inviteCode' parameters
        const testCases = [
          'edulift://groups/join?code=grp789',
          'edulift://families/join?inviteCode=fam123',
          'edulift://groups/join?code=backup123', // Backend compatibility
        ];

        for (final url in testCases) {
          // When
          final result = deepLinkService.parseDeepLink(url);

          // Then
          expect(result, isNotNull, reason: 'URL should be accepted: $url');
          expect(result!.hasInvitation, isTrue);
          expect(result.inviteCode, isNotNull);
          expect(result.inviteCode!.isNotEmpty, isTrue);
        }
      });

      test('should handle email URL decoding correctly', () {
        // Given
        const url =
            'edulift://auth/verify?token=abc123&email=user%40example.com';

        // When
        final result = deepLinkService.parseDeepLink(url);

        // Then
        expect(result, isNotNull);
        expect(result!.email, equals('user@example.com'));
        expect(result.magicToken, equals('abc123'));
      });

      test('should handle multiple parameters correctly', () {
        // Given
        const url =
            'edulift://auth/verify?token=abc123&email=user%40example.com&inviteCode=fam456&source=newsletter';

        // When
        final result = deepLinkService.parseDeepLink(url);

        // Then
        expect(result, isNotNull);
        expect(result!.path, equals('auth/verify'));
        expect(result.magicToken, equals('abc123'));
        expect(result.email, equals('user@example.com'));
        expect(result.inviteCode, equals('fam456'));
        expect(result.parameters['source'], equals('newsletter'));
      });

      test('should filter out empty parameters correctly', () {
        // Given
        const url =
            'edulift://auth/verify?token=abc123&inviteCode=&email=user%40example.com&campaign=';

        // When
        final result = deepLinkService.parseDeepLink(url);

        // Then
        expect(result, isNotNull);
        expect(result!.magicToken, equals('abc123'));
        expect(result.inviteCode, isNull); // Empty string becomes null
        expect(result.email, equals('user@example.com'));
        expect(
          result.parameters['campaign'],
          isNull,
        ); // Empty values filtered out
      });
    });

    group('Deep Link Generation Logic', () {
      test('should generate consistent deep links', () {
        // Given
        const token = 'abc123xyz';
        const inviteCode = 'fam456';

        // When
        final result1 = deepLinkService.generateNativeDeepLink(
          token,
          inviteCode: inviteCode,
        );
        final result2 = deepLinkService.generateNativeDeepLink(
          token,
          inviteCode: inviteCode,
        );

        // Then
        expect(result1, equals(result2));
        expect(result1, contains('token=abc123xyz'));
        expect(result1, contains('inviteCode=fam456'));
        expect(result1, contains('auth/verify'));
      });

      test('should generate parsable deep links', () {
        // Given
        const token = 'token123xyz';
        const inviteCode = 'invite456';

        // When
        final generated = deepLinkService.generateNativeDeepLink(
          token,
          inviteCode: inviteCode,
        );
        final parsed = deepLinkService.parseDeepLink(generated);

        // Then
        expect(parsed, isNotNull);
        expect(parsed!.path, equals('auth/verify'));
        expect(parsed.magicToken, equals(token));
        expect(parsed.inviteCode, equals(inviteCode));
        expect(parsed.hasMagicLink, isTrue);
        expect(parsed.hasInvitation, isTrue);
      });

      test('should handle special characters in generation', () {
        // Given
        const token = 'abc 123&test';
        const inviteCode = 'fam@456#test';

        // When
        final result = deepLinkService.generateNativeDeepLink(
          token,
          inviteCode: inviteCode,
        );

        // Then
        expect(result, contains('token=abc%20123%26test'));
        expect(result, contains('inviteCode=fam%40456%23test'));
        expect(result, contains('auth/verify'));
      });
    });

    group('DeepLinkResult Entity Logic', () {
      test('should correctly identify magic link presence', () {
        // Given
        const result = DeepLinkResult(
          magicToken: 'abc123',
          path: 'auth/verify',
        );

        // Then
        expect(result.hasMagicLink, isTrue);
        expect(result.hasInvitation, isFalse);
        expect(result.isEmpty, isFalse);
      });

      test('should correctly identify invitation presence', () {
        // Given
        const result = DeepLinkResult(
          inviteCode: 'fam456',
          path: 'groups/join',
        );

        // Then
        expect(result.hasMagicLink, isFalse);
        expect(result.hasInvitation, isTrue);
        expect(result.isEmpty, isFalse);
      });

      test('should correctly identify empty result', () {
        // Given
        const result = DeepLinkResult();

        // Then
        expect(result.isEmpty, isTrue);
        expect(result.hasMagicLink, isFalse);
        expect(result.hasInvitation, isFalse);
      });

      test('should correctly identify complete result', () {
        // Given
        const result = DeepLinkResult(
          magicToken: 'abc123',
          inviteCode: 'fam456',
          email: 'user@example.com',
          path: 'auth/verify',
          parameters: {'token': 'abc123', 'inviteCode': 'fam456'},
        );

        // Then
        expect(result.hasMagicLink, isTrue);
        expect(result.hasInvitation, isTrue);
        expect(result.isEmpty, isFalse);
        expect(result.path, equals('auth/verify'));
        expect(result.email, equals('user@example.com'));
      });
    });

    group('Malformed URL Handling', () {
      test('should reject malformed URLs gracefully', () {
        // Given
        const malformedUrls = [
          '', // Empty string
          'not-a-url', // Invalid format
          '://', // Missing scheme
          'edulift://', // No path
        ];

        for (final url in malformedUrls) {
          // When
          final result = deepLinkService.parseDeepLink(url);

          // Then
          expect(result, isNull, reason: 'Should reject malformed URL: "$url"');
        }
      });

      test('should handle parameter without value correctly', () {
        // Given - Parameter without value is treated as empty string
        const url = 'edulift://auth/verify?token';

        // When
        final result = deepLinkService.parseDeepLink(url);

        // Then - Service accepts this as valid but token is empty (filtered out)
        expect(
          result,
          isNotNull,
          reason: 'Parameter without value is technically valid',
        );
        expect(result!.path, equals('auth/verify'));
        expect(result.magicToken, isNull); // Empty string becomes null
        expect(result.hasMagicLink, isFalse);
      });

      test('should handle empty query correctly', () {
        // Given - URL with empty query is technically valid but has no parameters
        const url = 'edulift://auth/verify?';

        // When
        final result = deepLinkService.parseDeepLink(url);

        // Then - Service accepts this as valid with no parameters
        expect(result, isNotNull, reason: 'Empty query is technically valid');
        expect(result!.path, equals('auth/verify'));
        expect(result.magicToken, isNull);
        expect(result.hasMagicLink, isFalse);
      });

      test('should handle empty parameter values', () {
        // Given
        const url = 'edulift://auth/verify?token=';

        // When
        final result = deepLinkService.parseDeepLink(url);

        // Then
        expect(result, isNotNull);
        expect(result!.magicToken, isNull); // Empty string becomes null
        expect(result.hasMagicLink, isFalse);
      });
    });

    group('HTTP/HTTPS Logic with Testable Constructor', () {
      test('should extract parameters correctly from authorized HTTP URLs', () {
        // Given - A service instance with whitelisted domain for testing
        final testableService = DeepLinkServiceImpl.testable(
          authorizedDomains: ['example.fr'],
        );
        const url =
            'http://example.fr/auth/verify?token=abc123&email=user%40example.com';

        // When
        final result = testableService.parseDeepLink(url);

        // Then - Should successfully extract parameters since domain is authorized
        expect(result, isNotNull);
        expect(result!.path, equals('auth/verify'));
        expect(result.magicToken, equals('abc123'));
        expect(result.email, equals('user@example.com'));
        expect(result.hasMagicLink, isTrue);
      });

      test('should extract parameters correctly from authorized HTTPS URLs', () {
        // Given - A service instance with whitelisted domain for testing
        final testableService = DeepLinkServiceImpl.testable(
          authorizedDomains: ['example.fr'],
        );
        const url =
            'https://example.fr/groups/join?code=grp789&inviteCode=backup123&source=newsletter';

        // When
        final result = testableService.parseDeepLink(url);

        // Then - Should successfully extract parameters since domain is authorized
        expect(result, isNotNull);
        expect(result!.path, equals('groups/join'));
        expect(
          result.inviteCode,
          equals('grp789'),
        ); // 'code' parameter takes precedence
        expect(result.parameters['inviteCode'], equals('backup123'));
        expect(result.parameters['source'], equals('newsletter'));
        expect(result.hasInvitation, isTrue);
      });

      test('should extract complex parameters from HTTPS URLs with ports', () {
        // Given - A service instance with whitelisted domain for testing
        final testableService = DeepLinkServiceImpl.testable(
          authorizedDomains: ['example.fr'],
        );
        const urlWithPort =
            'https://example.fr:8443/families/join?code=fam123&role=member&expires=2024-12-31';

        // When
        final result = testableService.parseDeepLink(urlWithPort);

        // Then - Should successfully extract parameters since domain is authorized (port doesn't affect domain validation)
        expect(result, isNotNull);
        expect(result!.path, equals('families/join'));
        expect(result.inviteCode, equals('fam123'));
        expect(result.parameters['role'], equals('member'));
        expect(result.parameters['expires'], equals('2024-12-31'));
        expect(result.hasInvitation, isTrue);
      });

      test('should handle UTM parameters in authorized HTTP/HTTPS URLs', () {
        // Given - A service instance with whitelisted domain for testing
        final testableService = DeepLinkServiceImpl.testable(
          authorizedDomains: ['example.fr'],
        );
        const utmUrl =
            'https://example.fr/auth/verify?token=abc123&utm_source=email&utm_medium=newsletter&utm_campaign=winter2024';

        // When
        final result = testableService.parseDeepLink(utmUrl);

        // Then - Should successfully extract all parameters including UTM
        expect(result, isNotNull);
        expect(result!.path, equals('auth/verify'));
        expect(result.magicToken, equals('abc123'));
        expect(result.parameters['utm_source'], equals('email'));
        expect(result.parameters['utm_medium'], equals('newsletter'));
        expect(result.parameters['utm_campaign'], equals('winter2024'));
        expect(result.hasMagicLink, isTrue);

        // Verify all parameters are preserved
        expect(result.parameters.length, equals(4)); // token + 3 UTM params
      });

      test(
        'should handle special characters in authorized HTTP/HTTPS parameters',
        () {
          // Given - A service instance with whitelisted domain for testing
          final testableService = DeepLinkServiceImpl.testable(
            authorizedDomains: ['example.fr'],
          );
          const specialCharUrl =
              'https://example.fr/auth/verify?token=abc%20123&email=user%2Btest%40example.com&name=Jean%20Dupont';

          // When
          final result = testableService.parseDeepLink(specialCharUrl);

          // Then - Should successfully extract and decode parameters
          expect(result, isNotNull);
          expect(result!.path, equals('auth/verify'));
          expect(
            result.magicToken,
            equals('abc 123'),
          ); // URL decoded automatically
          expect(
            result.parameters['email'],
            equals('user+test@example.com'),
          ); // URL decoded
          expect(
            result.parameters['name'],
            equals('Jean Dupont'),
          ); // URL decoded
          expect(result.hasMagicLink, isTrue);
        },
      );

      test(
        'should reject unauthorized domains even with testable constructor',
        () {
          // Given - A service instance that does NOT whitelist the target domain
          final testableService = DeepLinkServiceImpl.testable(
            authorizedDomains: ['legit.com'],
          );
          const unauthorizedUrl =
              'https://malicious.com/auth/verify?token=abc123';

          // When
          final result = testableService.parseDeepLink(unauthorizedUrl);

          // Then - Should reject due to domain validation
          expect(result, isNull);
        },
      );
    });
  });
}

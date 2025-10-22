// EduLift Mobile - Deep Link Service Unit Tests
// Tests the deep link handling functionality for multi-platform magic links

import 'package:flutter_test/flutter_test.dart';

import 'package:edulift/core/services/deep_link_service.dart';
import 'package:edulift/core/domain/entities/auth_entities.dart';

void main() {
  group('DeepLinkService', () {
    late DeepLinkServiceImpl deepLinkService;
    // MockIMagicLinkService available if needed

    setUp(() {
      // MockIMagicLinkService setup removed
      deepLinkService = DeepLinkServiceImpl.getInstance();
    });

    group('parseDeepLink', () {
      test('should parse valid edulift:// magic link URL', () {
        // Given
        const url = 'edulift://auth/verify?token=abc123&inviteCode=fam456';

        // When
        final result = deepLinkService.parseDeepLink(url);

        // Then
        expect(result, isNotNull);
        expect(result!.magicToken, equals('abc123'));
        expect(result.inviteCode, equals('fam456'));
        expect(result.hasMagicLink, isTrue);
        expect(result.hasInvitation, isTrue);
      });

      test('should parse magic link URL without invitation code', () {
        // Given
        const url = 'edulift://auth/verify?token=abc123';

        // When
        final result = deepLinkService.parseDeepLink(url);

        // Then
        expect(result, isNotNull);
        expect(result!.magicToken, equals('abc123'));
        expect(result.inviteCode, isNull);
        expect(result.hasMagicLink, isTrue);
        expect(result.hasInvitation, isFalse);
      });

      test('should return null for non-edulift scheme', () {
        // Given
        const url = 'https://example.com/auth/verify?token=abc123';

        // When
        final result = deepLinkService.parseDeepLink(url);

        // Then
        expect(result, isNull);
      });

      test('should return null for malformed URL', () {
        // Given
        const url = 'not-a-valid-url';

        // When
        final result = deepLinkService.parseDeepLink(url);

        // Then
        expect(result, isNull);
      });

      test('should handle URL with no query parameters', () {
        // Given
        const url = 'edulift://auth/verify';

        // When
        final result = deepLinkService.parseDeepLink(url);

        // Then
        expect(result, isNotNull);
        expect(result!.magicToken, isNull);
        expect(result.inviteCode, isNull);
        expect(result.hasMagicLink, isFalse);
        expect(result.isEmpty, isTrue);
      });
    });

    group('generateNativeDeepLink', () {
      test('should generate deep link with token only', () {
        // Given
        const token = 'abc123';

        // When
        final result = deepLinkService.generateNativeDeepLink(token);

        // Then
        expect(result, equals('edulift://auth/verify?token=abc123'));
      });

      test('should generate deep link with token and invitation code', () {
        // Given
        const token = 'abc123';
        const inviteCode = 'fam456';

        // When
        final result = deepLinkService.generateNativeDeepLink(
          token,
          inviteCode: inviteCode,
        );

        // Then
        expect(
          result,
          equals('edulift://auth/verify?token=abc123&inviteCode=fam456'),
        );
      });

      test('should URL encode parameters', () {
        // Given
        const token = 'abc 123';
        const inviteCode = 'fam&456';

        // When
        final result = deepLinkService.generateNativeDeepLink(
          token,
          inviteCode: inviteCode,
        );

        // Then
        expect(result, contains('token=abc%20123'));
        expect(result, contains('inviteCode=fam%26456'));
      });
    });

    group('DeepLinkResult integration', () {
      test('should correctly identify magic link', () {
        // Given
        const result = DeepLinkResult(
          magicToken: 'abc123',
          inviteCode: 'fam456',
        );

        // Then
        expect(result.hasMagicLink, isTrue);
        expect(result.hasInvitation, isTrue);
        expect(result.isEmpty, isFalse);
      });

      test('should correctly identify empty result', () {
        // Given
        const result = DeepLinkResult();

        // Then
        expect(result.isEmpty, isTrue);
        expect(result.hasMagicLink, isFalse);
      });
    });
  });
}

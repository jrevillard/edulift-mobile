// EduLift Mobile - Enhanced DeepLinkResult Entity Tests
// TDD London School - Testing the enhanced interface with path support
// RED PHASE: Tests for functionality that doesn't exist yet

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/auth_entities.dart';
import '../../../../fixtures/deeplink_test_data.dart';

void main() {
  group('Enhanced DeepLinkResult with Path Support', () {
    // =================== PATH EXTRACTION TESTS ===================

    group('Path Extraction', () {
      test('should extract path from auth/verify URL', () {
        // ARRANGE - Testing the enhanced interface
        const result = DeepLinkResult(
          magicToken: 'magic123',
          path: 'auth/verify',
          parameters: {'token': 'magic123'},
        );

        // ASSERT - New path property should be available
        expect(result.path, equals('auth/verify'));
        expect(result.magicToken, equals('magic123'));
        expect(result.isAuthVerifyPath, isTrue);
      });

      test('should extract path from groups/join URL', () {
        // ARRANGE
        const result = DeepLinkResult(
          inviteCode: 'grp789',
          path: 'groups/join',
          parameters: {'code': 'grp789'},
        );

        // ASSERT
        expect(result.path, equals('groups/join'));
        expect(result.inviteCode, equals('grp789'));
        expect(result.isGroupJoinPath, isTrue);
      });

      test('should extract path from families/join URL', () {
        // ARRANGE
        const result = DeepLinkResult(
          inviteCode: 'fam456',
          path: 'families/join',
          parameters: {'code': 'fam456'},
        );

        // ASSERT
        expect(result.path, equals('families/join'));
        expect(result.inviteCode, equals('fam456'));
        expect(result.isFamilyJoinPath, isTrue);
      });

      test('should extract path from dashboard URL', () {
        // ARRANGE
        const result = DeepLinkResult(
          path: 'dashboard',
          parameters: {'view': 'schedule'},
        );

        // ASSERT
        expect(result.path, equals('dashboard'));
        expect(result.isDashboardPath, isTrue);
        expect(result.parameters['view'], equals('schedule'));
      });

      test('should handle empty path gracefully', () {
        // ARRANGE
        const result = DeepLinkResult(path: '');

        // ASSERT
        expect(result.path, equals(''));
        expect(result.isEmptyPath, isTrue);
        expect(
          result.isDashboardPath,
          isTrue,
        ); // Empty path routes to dashboard
        expect(result.isAuthVerifyPath, isFalse);
      });
    });

    // =================== BACKWARD COMPATIBILITY TESTS ===================

    group('Backward Compatibility', () {
      test('should maintain existing properties when path is added', () {
        // ARRANGE - Enhanced constructor with all original properties
        const result = DeepLinkResult(
          magicToken: 'magic123',
          inviteCode: 'fam456',
          email: 'test@example.com',
          path: 'auth/verify',
          parameters: {
            'token': 'magic123',
            'inviteCode': 'fam456',
            'email': 'test@example.com',
          },
        );

        // ASSERT - All original getters must work
        expect(result.magicToken, equals('magic123'));
        expect(result.inviteCode, equals('fam456'));
        expect(result.email, equals('test@example.com'));
        expect(result.hasMagicLink, isTrue);
        expect(result.hasInvitation, isTrue);
        expect(result.isEmpty, isFalse);

        // ASSERT - New path functionality
        expect(result.path, equals('auth/verify'));
      });

      test('should default path to null when not provided', () {
        // ARRANGE - Legacy constructor without path
        const result = DeepLinkResult(
          magicToken: 'magic123',
          parameters: {'token': 'magic123'},
        );

        // ASSERT - Should provide sensible default
        expect(result.path, isNull);
        expect(result.magicToken, equals('magic123'));
        expect(result.hasMagicLink, isTrue);
        expect(result.routerPath, equals('/dashboard')); // Default fallback
      });

      test('should maintain original isEmpty logic', () {
        // ARRANGE - Test all combinations
        const emptyResult = DeepLinkResult(path: 'dashboard');
        const tokenOnlyResult = DeepLinkResult(
          magicToken: 'abc',
          path: 'auth/verify',
        );
        const inviteOnlyResult = DeepLinkResult(
          inviteCode: 'xyz',
          path: 'groups/join',
        );
        const bothResult = DeepLinkResult(
          magicToken: 'abc',
          inviteCode: 'xyz',
          path: 'auth/verify',
        );

        // ASSERT - Original isEmpty behavior unchanged
        expect(emptyResult.isEmpty, isTrue);
        expect(tokenOnlyResult.isEmpty, isFalse);
        expect(inviteOnlyResult.isEmpty, isFalse);
        expect(bothResult.isEmpty, isFalse);
      });
    });

    // =================== ROUTER INTEGRATION TESTS ===================

    group('Router Integration', () {
      test('should provide correct router path for auth/verify', () {
        // ARRANGE
        const result = DeepLinkResult(
          magicToken: 'magic123',
          path: 'auth/verify',
          parameters: {'token': 'magic123'},
        );

        // ASSERT - Router-compatible path getters
        expect(result.routerPath, equals('/auth/verify'));
        expect(result.requiresAuthentication, isFalse);
        expect(result.preservesInviteContext, isTrue);
      });

      test('should provide correct router path for groups/join', () {
        // ARRANGE
        const result = DeepLinkResult(
          inviteCode: 'grp789',
          path: 'groups/join',
          parameters: {'code': 'grp789'},
        );

        // ASSERT
        expect(result.routerPath, equals('/groups/join'));
        expect(result.requiresAuthentication, isTrue);
        expect(result.requiresFamily, isTrue);
        expect(result.preservesInviteContext, isTrue);
      });

      test('should provide correct router path for families/join', () {
        // ARRANGE
        const result = DeepLinkResult(
          inviteCode: 'fam456',
          path: 'families/join',
          parameters: {'code': 'fam456'},
        );

        // ASSERT
        expect(result.routerPath, equals('/families/join'));
        expect(result.requiresAuthentication, isTrue);
        expect(result.requiresFamily, isFalse);
        expect(result.preservesInviteContext, isTrue);
      });

      test('should provide correct router path for dashboard', () {
        // ARRANGE
        const result = DeepLinkResult(
          path: 'dashboard',
          parameters: {'view': 'schedule'},
        );

        // ASSERT
        expect(result.routerPath, equals('/dashboard'));
        expect(result.requiresAuthentication, isTrue);
        expect(result.requiresFamily, isFalse);
        expect(result.preservesInviteContext, isFalse);
      });
    });

    // =================== PARAMETER HANDLING TESTS ===================

    group('Parameter Handling', () {
      test('should extract token from parameters correctly', () {
        // ARRANGE
        const result = DeepLinkResult(
          magicToken: 'extracted_token',
          path: 'auth/verify',
          parameters: {'token': 'extracted_token', 'other': 'value'},
        );

        // ASSERT
        expect(result.extractedToken, equals('extracted_token'));
        expect(result.magicToken, equals('extracted_token'));
        expect(result.hasValidToken, isTrue);
      });

      test(
        'should extract invite code from parameters with different keys',
        () {
          // ARRANGE - Test both 'code' and 'inviteCode' parameter names
          const resultWithCode = DeepLinkResult(
            inviteCode: 'grp789',
            path: 'groups/join',
            parameters: {'code': 'grp789'},
          );

          const resultWithInviteCode = DeepLinkResult(
            inviteCode: 'fam456',
            path: 'auth/verify',
            parameters: {'inviteCode': 'fam456'},
          );

          // ASSERT
          expect(resultWithCode.extractedInviteCode, equals('grp789'));
          expect(resultWithInviteCode.extractedInviteCode, equals('fam456'));
        },
      );

      test('should extract email from parameters correctly', () {
        // ARRANGE
        const result = DeepLinkResult(
          email: 'test@example.com',
          path: 'auth/verify',
          parameters: {'email': 'test@example.com'},
        );

        // ASSERT
        expect(result.extractedEmail, equals('test@example.com'));
        expect(result.email, equals('test@example.com'));
        expect(result.hasValidEmail, isTrue);
      });

      test('should handle URL-encoded parameters', () {
        // ARRANGE
        const result = DeepLinkResult(
          email: 'test@example.com',
          magicToken: 'magic 123',
          path: 'auth/verify',
          parameters: {'email': 'test%40example.com', 'token': 'magic%20123'},
        );

        // ASSERT - Should handle URL decoding
        expect(result.decodedEmail, equals('test@example.com'));
        expect(result.decodedToken, equals('magic 123'));
      });
    });

    // =================== EDGE CASE TESTS ===================

    group('Edge Cases', () {
      test('should handle invalid URLs gracefully', () {
        // ARRANGE
        const result = DeepLinkResult(path: '');

        // ASSERT
        expect(result.isValid, isFalse);
        expect(result.path, equals(''));
        expect(result.isEmpty, isTrue);
      });

      test('should handle missing required parameters', () {
        // ARRANGE - auth/verify without token
        const authWithoutToken = DeepLinkResult(path: 'auth/verify');

        // group/join without code
        const groupWithoutCode = DeepLinkResult(path: 'groups/join');

        // ASSERT
        expect(authWithoutToken.hasValidToken, isFalse);
        expect(authWithoutToken.canProceedWithAuth, isFalse);
        expect(groupWithoutCode.hasValidInviteCode, isFalse);
        expect(groupWithoutCode.canProceedWithInvite, isFalse);
      });

      test('should handle empty parameter values', () {
        // ARRANGE
        const result = DeepLinkResult(
          path: 'auth/verify',
          parameters: {'token': '', 'email': ''},
        );

        // ASSERT
        expect(result.hasValidToken, isFalse);
        expect(result.hasValidEmail, isFalse);
        expect(result.canProceedWithAuth, isFalse);
      });

      test('should handle special characters in path', () {
        // ARRANGE
        const result = DeepLinkResult(
          path: 'auth-verify/special',
          parameters: {'token': 'abc123'},
        );

        // ASSERT
        expect(result.path, equals('auth-verify/special'));
        expect(result.isAuthVerifyPath, isFalse); // Exact match required
        expect(result.isCustomPath, isTrue);
      });

      test('should handle duplicate parameters gracefully', () {
        // ARRANGE - In real URL parsing, last parameter wins
        const result = DeepLinkResult(
          inviteCode: 'final_code',
          path: 'groups/join',
          parameters: {
            'code': 'final_code',
          }, // Simulates last parameter winning
        );

        // ASSERT
        expect(result.inviteCode, equals('final_code'));
        expect(result.extractedInviteCode, equals('final_code'));
      });
    });

    // =================== IMMUTABILITY TESTS ===================

    group('Immutability', () {
      test('should be immutable after construction', () {
        // ARRANGE
        const result = DeepLinkResult(
          magicToken: 'magic123',
          inviteCode: 'fam456',
          email: 'test@example.com',
          path: 'auth/verify',
          parameters: {'token': 'magic123'},
        );

        // ASSERT - All properties should be final/immutable
        expect(result.magicToken, equals('magic123'));
        expect(result.inviteCode, equals('fam456'));
        expect(result.email, equals('test@example.com'));
        expect(result.path, equals('auth/verify'));

        // ASSERT - Parameters map should be immutable
        expect(
          () => result.parameters['new_key'] = 'value',
          throwsUnsupportedError,
        );
      });

      test('should support equality comparison', () {
        // ARRANGE
        const result1 = DeepLinkResult(
          magicToken: 'magic123',
          path: 'auth/verify',
          parameters: {'token': 'magic123'},
        );

        const result2 = DeepLinkResult(
          magicToken: 'magic123',
          path: 'auth/verify',
          parameters: {'token': 'magic123'},
        );

        const result3 = DeepLinkResult(
          magicToken: 'different',
          path: 'auth/verify',
          parameters: {'token': 'different'},
        );

        // ASSERT - Should implement proper equality
        expect(result1 == result2, isTrue);
        expect(result1 == result3, isFalse);
        expect(result1.hashCode == result2.hashCode, isTrue);
      });
    });

    // =================== INTEGRATION WITH EXISTING TESTS ===================

    group('Integration with Test Data', () {
      test('should work with DeepLinkTestData fixtures', () {
        // ARRANGE - Using pre-built test data
        final authResult = DeepLinkTestData.authVerifyResult;
        final groupResult = DeepLinkTestData.groupJoinResult;
        final familyResult = DeepLinkTestData.familyJoinResult;
        final dashboardResult = DeepLinkTestData.dashboardResult;

        // ASSERT - Test data should be valid
        expect(authResult.path, equals('auth/verify'));
        expect(authResult.magicToken, equals('magic123'));

        expect(groupResult.path, equals('groups/join'));
        expect(groupResult.inviteCode, equals('grp789'));

        expect(familyResult.path, equals('families/join'));
        expect(familyResult.inviteCode, equals('fam456'));

        expect(dashboardResult.path, equals('dashboard'));
        expect(dashboardResult.isEmpty, isTrue); // No tokens or invite codes
      });
    });
  });

  // =================== LEGACY TESTS (Ensuring no breaking changes) ===================

  group('Legacy DeepLinkResult Compatibility', () {
    test('should maintain all existing getter behavior', () {
      // ARRANGE - Create result using original constructor style
      const result = DeepLinkResult(
        magicToken: 'magic123',
        inviteCode: 'fam456',
        email: 'test@example.com',
        parameters: {
          'token': 'magic123',
          'inviteCode': 'fam456',
          'email': 'test@example.com',
        },
      );

      // ASSERT - All original getters must work exactly as before
      expect(result.magicToken, equals('magic123'));
      expect(result.inviteCode, equals('fam456'));
      expect(result.email, equals('test@example.com'));
      expect(result.parameters, isA<Map<String, String>>());
      expect(result.hasInvitation, isTrue);
      expect(result.hasMagicLink, isTrue);
      expect(result.isEmpty, isFalse);
    });

    test('should work with existing test patterns', () {
      // ARRANGE - Replicate existing test patterns
      const result = DeepLinkResult(magicToken: 'abc123', inviteCode: 'fam456');

      // ASSERT - Original test assertions should still pass
      expect(result.hasMagicLink, isTrue);
      expect(result.hasInvitation, isTrue);
      expect(result.isEmpty, isFalse);
    });

    test('should handle empty constructor as before', () {
      // ARRANGE
      const result = DeepLinkResult();

      // ASSERT - Original empty behavior
      expect(result.isEmpty, isTrue);
      expect(result.hasMagicLink, isFalse);
      expect(result.hasInvitation, isFalse);
      expect(result.magicToken, isNull);
      expect(result.inviteCode, isNull);
      expect(result.email, isNull);
    });
  });
}

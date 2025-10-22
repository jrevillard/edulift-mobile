// EduLift Mobile - Comprehensive DeepLinkResult Entity Tests
// Following FLUTTER_TESTING_RESEARCH_2025.md - Domain Entity Testing
// Unit tests for enhanced DeepLinkResult with all getters and validation logic

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/auth_entities.dart';
import '../../../../fixtures/deeplink_test_data.dart';

void main() {
  group('DeepLinkResult - Comprehensive Entity Tests', () {
    // =================== CONSTRUCTOR TESTS ===================

    group('Constructor', () {
      test('should create instance with all parameters', () {
        // ARRANGE & ACT
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

        // ASSERT
        expect(result.magicToken, equals('magic123'));
        expect(result.inviteCode, equals('fam456'));
        expect(result.email, equals('test@example.com'));
        expect(result.path, equals('auth/verify'));
        expect(result.parameters, hasLength(3));
      });

      test('should create instance with minimal parameters', () {
        // ARRANGE & ACT
        const result = DeepLinkResult();

        // ASSERT
        expect(result.magicToken, isNull);
        expect(result.inviteCode, isNull);
        expect(result.email, isNull);
        expect(result.path, isNull);
        expect(result.parameters, isEmpty);
      });

      test('should handle backward compatibility without path', () {
        // ARRANGE & ACT
        const result = DeepLinkResult(
          magicToken: 'magic123',
          inviteCode: 'fam456',
          email: 'test@example.com',
          parameters: {'token': 'magic123'},
        );

        // ASSERT - Path should be null for backward compatibility
        expect(result.path, isNull);
        expect(result.magicToken, equals('magic123'));
        expect(result.inviteCode, equals('fam456'));
      });
    });

    // =================== ORIGINAL GETTERS TESTS (Backward Compatibility) ===================

    group('Original Getters - Backward Compatibility', () {
      test('hasInvitation should return true when inviteCode exists', () {
        // ARRANGE
        const result = DeepLinkResult(inviteCode: 'fam456');

        // ACT & ASSERT
        expect(result.hasInvitation, isTrue);
      });

      test('hasInvitation should return false when inviteCode is null', () {
        // ARRANGE
        const result = DeepLinkResult();

        // ACT & ASSERT
        expect(result.hasInvitation, isFalse);
      });

      test('hasMagicLink should return true when magicToken exists', () {
        // ARRANGE
        const result = DeepLinkResult(magicToken: 'magic123');

        // ACT & ASSERT
        expect(result.hasMagicLink, isTrue);
      });

      test('hasMagicLink should return false when magicToken is null', () {
        // ARRANGE
        const result = DeepLinkResult();

        // ACT & ASSERT
        expect(result.hasMagicLink, isFalse);
      });

      test('isEmpty should return true when no token or invite', () {
        // ARRANGE
        const result = DeepLinkResult(
          path: 'dashboard',
          parameters: {'view': 'schedule'},
        );

        // ACT & ASSERT
        expect(result.isEmpty, isTrue);
      });

      test('isEmpty should return false when token exists', () {
        // ARRANGE
        const result = DeepLinkResult(magicToken: 'magic123');

        // ACT & ASSERT
        expect(result.isEmpty, isFalse);
      });

      test('isEmpty should return false when invite exists', () {
        // ARRANGE
        const result = DeepLinkResult(inviteCode: 'fam456');

        // ACT & ASSERT
        expect(result.isEmpty, isFalse);
      });
    });

    // =================== PATH SUPPORT GETTERS ===================

    group('Path Support Getters', () {
      test('hasPath should return true when path exists and not empty', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'auth/verify');

        // ACT & ASSERT
        expect(result.hasPath, isTrue);
      });

      test('hasPath should return false when path is null', () {
        // ARRANGE
        const result = DeepLinkResult();

        // ACT & ASSERT
        expect(result.hasPath, isFalse);
      });

      test('hasPath should return false when path is empty', () {
        // ARRANGE
        const result = DeepLinkResult(path: '');

        // ACT & ASSERT
        expect(result.hasPath, isFalse);
      });

      test('isEmptyPath should return true when path is null', () {
        // ARRANGE
        const result = DeepLinkResult();

        // ACT & ASSERT
        expect(result.isEmptyPath, isTrue);
      });

      test('isEmptyPath should return true when path is empty string', () {
        // ARRANGE
        const result = DeepLinkResult(path: '');

        // ACT & ASSERT
        expect(result.isEmptyPath, isTrue);
      });

      test('isEmptyPath should return false when path exists', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'auth/verify');

        // ACT & ASSERT
        expect(result.isEmptyPath, isFalse);
      });
    });

    // =================== PATH IDENTIFICATION GETTERS ===================

    group('Path Identification Getters', () {
      test('isAuthVerifyPath should return true for auth/verify path', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'auth/verify');

        // ACT & ASSERT
        expect(result.isAuthVerifyPath, isTrue);
        expect(result.isGroupJoinPath, isFalse);
        expect(result.isFamilyJoinPath, isFalse);
        expect(result.isDashboardPath, isFalse);
      });

      test('isGroupJoinPath should return true for groups/join path', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'groups/join');

        // ACT & ASSERT
        expect(result.isGroupJoinPath, isTrue);
        expect(result.isAuthVerifyPath, isFalse);
        expect(result.isFamilyJoinPath, isFalse);
        expect(result.isDashboardPath, isFalse);
      });

      test('isFamilyJoinPath should return true for families/join path', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'families/join');

        // ACT & ASSERT
        expect(result.isFamilyJoinPath, isTrue);
        expect(result.isAuthVerifyPath, isFalse);
        expect(result.isGroupJoinPath, isFalse);
        expect(result.isDashboardPath, isFalse);
      });

      test('isDashboardPath should return true for dashboard path', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'dashboard');

        // ACT & ASSERT
        expect(result.isDashboardPath, isTrue);
        expect(result.isAuthVerifyPath, isFalse);
        expect(result.isGroupJoinPath, isFalse);
        expect(result.isFamilyJoinPath, isFalse);
      });

      test(
        'all path identification getters should return false for unknown path',
        () {
          // ARRANGE
          const result = DeepLinkResult(path: 'unknown/path');

          // ACT & ASSERT
          expect(result.isAuthVerifyPath, isFalse);
          expect(result.isGroupJoinPath, isFalse);
          expect(result.isFamilyJoinPath, isFalse);
          expect(result.isDashboardPath, isFalse);
        },
      );

      test(
        'path identification getters should return correct values for null path',
        () {
          // ARRANGE
          const result = DeepLinkResult();

          // ACT & ASSERT
          expect(result.isAuthVerifyPath, isFalse);
          expect(result.isGroupJoinPath, isFalse);
          expect(result.isFamilyJoinPath, isFalse);
          expect(result.isDashboardPath, isTrue); // null path means dashboard
        },
      );
    });

    // =================== ROUTER INTEGRATION GETTERS ===================

    group('Router Integration Getters', () {
      test('routerPath should return correct path for auth/verify', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'auth/verify');

        // ACT & ASSERT
        expect(result.routerPath, equals('/auth/verify'));
      });

      test('routerPath should return correct path for groups/join', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'groups/join');

        // ACT & ASSERT
        expect(result.routerPath, equals('/groups/join'));
      });

      test('routerPath should return correct path for families/join', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'families/join');

        // ACT & ASSERT
        expect(result.routerPath, equals('/families/join'));
      });

      test('routerPath should return correct path for dashboard', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'dashboard');

        // ACT & ASSERT
        expect(result.routerPath, equals('/dashboard'));
      });

      test('routerPath should return dashboard for null path', () {
        // ARRANGE
        const result = DeepLinkResult();

        // ACT & ASSERT
        expect(result.routerPath, equals('/dashboard'));
      });

      test('routerPath should return dashboard for empty path', () {
        // ARRANGE
        const result = DeepLinkResult(path: '');

        // ACT & ASSERT
        expect(result.routerPath, equals('/dashboard'));
      });

      test('routerPath should handle unknown paths correctly', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'unknown/path');

        // ACT & ASSERT
        expect(result.routerPath, equals('/unknown/path'));
      });
    });

    // =================== NAVIGATION CONTEXT GETTERS ===================

    group('Navigation Context Getters', () {
      test('requiresAuthentication should return false for auth/verify', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'auth/verify');

        // ACT & ASSERT
        expect(
          result.requiresAuthentication,
          isFalse,
        ); // Magic link handles auth
      });

      test('requiresAuthentication should return true for groups/join', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'groups/join');

        // ACT & ASSERT
        expect(result.requiresAuthentication, isTrue);
      });

      test('requiresAuthentication should return true for families/join', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'families/join');

        // ACT & ASSERT
        expect(result.requiresAuthentication, isTrue);
      });

      test('requiresAuthentication should return true for dashboard', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'dashboard');

        // ACT & ASSERT
        expect(result.requiresAuthentication, isTrue);
      });

      test('requiresFamily should return false for auth/verify', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'auth/verify');

        // ACT & ASSERT
        expect(result.requiresFamily, isFalse);
      });

      test('requiresFamily should return true for groups/join', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'groups/join');

        // ACT & ASSERT
        expect(result.requiresFamily, isTrue); // Must have family to join group
      });

      test('requiresFamily should return false for families/join', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'families/join');

        // ACT & ASSERT
        expect(
          result.requiresFamily,
          isFalse,
        ); // Can join without existing family
      });

      test('requiresFamily should return false for dashboard', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'dashboard');

        // ACT & ASSERT
        expect(result.requiresFamily, isFalse);
      });

      test('preservesInviteContext should return true for auth/verify', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'auth/verify');

        // ACT & ASSERT
        expect(result.preservesInviteContext, isTrue);
      });

      test('preservesInviteContext should return true for groups/join', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'groups/join');

        // ACT & ASSERT
        expect(result.preservesInviteContext, isTrue);
      });

      test('preservesInviteContext should return true for families/join', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'families/join');

        // ACT & ASSERT
        expect(result.preservesInviteContext, isTrue);
      });

      test('preservesInviteContext should return false for dashboard', () {
        // ARRANGE
        const result = DeepLinkResult(path: 'dashboard');

        // ACT & ASSERT
        expect(result.preservesInviteContext, isFalse);
      });
    });

    // =================== VALIDATION GETTERS ===================

    group('Validation Getters', () {
      test('hasValidToken should return true for non-empty token', () {
        // ARRANGE
        const result = DeepLinkResult(magicToken: 'valid_token_123');

        // ACT & ASSERT
        expect(result.hasValidToken, isTrue);
      });

      test('hasValidToken should return false for null token', () {
        // ARRANGE
        const result = DeepLinkResult();

        // ACT & ASSERT
        expect(result.hasValidToken, isFalse);
      });

      test('hasValidToken should return false for empty token', () {
        // ARRANGE
        const result = DeepLinkResult(magicToken: '');

        // ACT & ASSERT
        expect(result.hasValidToken, isFalse);
      });

      test('hasValidEmail should return true for valid email', () {
        // ARRANGE
        const result = DeepLinkResult(email: 'user@example.com');

        // ACT & ASSERT
        expect(result.hasValidEmail, isTrue);
      });

      test('hasValidEmail should return false for null email', () {
        // ARRANGE
        const result = DeepLinkResult();

        // ACT & ASSERT
        expect(result.hasValidEmail, isFalse);
      });

      test('hasValidEmail should return false for empty email', () {
        // ARRANGE
        const result = DeepLinkResult(email: '');

        // ACT & ASSERT
        expect(result.hasValidEmail, isFalse);
      });

      test(
        'canProceedWithAuth should return true with valid token and email',
        () {
          // ARRANGE
          const result = DeepLinkResult(
            path: 'auth/verify',
            magicToken: 'valid_token',
            email: 'user@example.com',
          );

          // ACT & ASSERT
          expect(result.canProceedWithAuth, isTrue);
        },
      );

      test('canProceedWithAuth should return true with only valid token', () {
        // ARRANGE
        const result = DeepLinkResult(
          path: 'auth/verify',
          magicToken: 'valid_token',
        );

        // ACT & ASSERT
        expect(result.canProceedWithAuth, isTrue);
      });

      test('canProceedWithAuth should return false without token', () {
        // ARRANGE
        const result = DeepLinkResult(email: 'user@example.com');

        // ACT & ASSERT
        expect(result.canProceedWithAuth, isFalse);
      });

      test('canProceedWithAuth should return false with empty token', () {
        // ARRANGE
        const result = DeepLinkResult(
          magicToken: '',
          email: 'user@example.com',
        );

        // ACT & ASSERT
        expect(result.canProceedWithAuth, isFalse);
      });

      test(
        'isValid should return true for valid deeplink with path and content',
        () {
          // ARRANGE
          const result = DeepLinkResult(
            path: 'auth/verify',
            magicToken: 'valid_token',
          );

          // ACT & ASSERT
          expect(result.isValid, isTrue);
        },
      );

      test('isValid should return false for empty path without content', () {
        // ARRANGE
        const result = DeepLinkResult(path: '');

        // ACT & ASSERT
        expect(result.isValid, isFalse);
      });

      test('isValid should return false for null path without content', () {
        // ARRANGE
        const result = DeepLinkResult();

        // ACT & ASSERT
        expect(result.isValid, isFalse);
      });
    });

    // =================== PARAMETER EXTRACTION GETTERS ===================

    group('Parameter Extraction Getters', () {
      test('extractedToken should return token from parameters', () {
        // ARRANGE
        const result = DeepLinkResult(
          magicToken: 'magic123',
          parameters: {'token': 'magic123'},
        );

        // ACT & ASSERT
        expect(result.extractedToken, equals('magic123'));
      });

      test('extractedInviteCode should return code from parameters', () {
        // ARRANGE
        const result = DeepLinkResult(
          inviteCode: 'fam456',
          parameters: {'code': 'fam456'},
        );

        // ACT & ASSERT
        expect(result.extractedInviteCode, equals('fam456'));
      });

      test('extractedInviteCode should return inviteCode from parameters', () {
        // ARRANGE
        const result = DeepLinkResult(
          inviteCode: 'fam456',
          parameters: {'inviteCode': 'fam456'},
        );

        // ACT & ASSERT
        expect(result.extractedInviteCode, equals('fam456'));
      });

      test('extractedEmail should return email from parameters', () {
        // ARRANGE
        const result = DeepLinkResult(
          email: 'user@example.com',
          parameters: {'email': 'user@example.com'},
        );

        // ACT & ASSERT
        expect(result.extractedEmail, equals('user@example.com'));
      });

      test('decodedToken should handle URL decoding', () {
        // ARRANGE
        const result = DeepLinkResult(
          magicToken: 'token with spaces',
          parameters: {'token': 'token%20with%20spaces'},
        );

        // ACT & ASSERT
        expect(result.decodedToken, equals('token with spaces'));
      });

      test('decodedEmail should handle URL decoding', () {
        // ARRANGE
        const result = DeepLinkResult(
          email: 'user+test@example.com',
          parameters: {'email': 'user%2Btest%40example.com'},
        );

        // ACT & ASSERT
        expect(result.decodedEmail, equals('user+test@example.com'));
      });
    });

    // =================== INTEGRATION WITH TEST DATA ===================

    group('Integration with Test Data', () {
      test('should work correctly with auth verify test data', () {
        // ARRANGE
        final result = DeepLinkTestData.authVerifyResult;

        // ACT & ASSERT
        expect(result.isAuthVerifyPath, isTrue);
        expect(result.hasValidToken, isTrue);
        expect(result.canProceedWithAuth, isTrue);
        expect(result.requiresAuthentication, isFalse);
        expect(result.preservesInviteContext, isTrue);
      });

      test('should work correctly with group join test data', () {
        // ARRANGE
        final result = DeepLinkTestData.groupJoinResult;

        // ACT & ASSERT
        expect(result.isGroupJoinPath, isTrue);
        expect(result.hasInvitation, isTrue);
        expect(result.requiresAuthentication, isTrue);
        expect(result.requiresFamily, isTrue);
        expect(result.preservesInviteContext, isTrue);
      });

      test('should work correctly with family join test data', () {
        // ARRANGE
        final result = DeepLinkTestData.familyJoinResult;

        // ACT & ASSERT
        expect(result.isFamilyJoinPath, isTrue);
        expect(result.hasInvitation, isTrue);
        expect(result.requiresAuthentication, isTrue);
        expect(result.requiresFamily, isFalse);
        expect(result.preservesInviteContext, isTrue);
      });

      test('should work correctly with dashboard test data', () {
        // ARRANGE
        final result = DeepLinkTestData.dashboardResult;

        // ACT & ASSERT
        expect(result.isDashboardPath, isTrue);
        expect(result.requiresAuthentication, isTrue);
        expect(result.requiresFamily, isFalse);
        expect(result.preservesInviteContext, isFalse);
      });
    });
  });
}

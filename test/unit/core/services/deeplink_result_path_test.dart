// DeepLinkResult Path Navigation Test
// Tests the path-aware navigation properties and routing logic

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/domain/entities/auth_entities.dart';

void main() {
  group('DeepLinkResult Path Navigation', () {
    group('Path Detection', () {
      test('should detect auth/verify path correctly', () {
        const result = DeepLinkResult(
          path: 'auth/verify',
          magicToken: 'test-token',
          parameters: {'token': 'test-token'},
        );

        expect(result.hasPath, true);
        expect(result.isAuthVerifyPath, true);
        expect(result.routerPath, '/auth/verify');
      });

      test('should detect families/join path correctly', () {
        const result = DeepLinkResult(
          path: 'families/join',
          inviteCode: 'family-code',
          parameters: {'code': 'family-code'},
        );

        expect(result.hasPath, true);
        expect(result.isFamilyJoinPath, true);
        expect(result.routerPath, '/families/join');
      });

      test('should detect groups/join path correctly', () {
        const result = DeepLinkResult(
          path: 'groups/join',
          inviteCode: 'group-code',
          parameters: {'code': 'group-code'},
        );

        expect(result.hasPath, true);
        expect(result.isGroupJoinPath, true);
        expect(result.routerPath, '/groups/join');
      });

      test('should handle dashboard path correctly', () {
        const result = DeepLinkResult(path: 'dashboard');

        expect(result.hasPath, true);
        expect(result.isDashboardPath, true);
        expect(result.routerPath, '/dashboard');
      });

      test('should fallback to dashboard when no path', () {
        const result = DeepLinkResult(
          magicToken: 'token',
          parameters: {'token': 'token'},
        );

        expect(result.hasPath, false);
        expect(result.isDashboardPath, true);
        expect(result.routerPath, '/dashboard');
      });
    });

    group('Parameter Extraction', () {
      test('should extract magic token from parameters', () {
        const result = DeepLinkResult(
          path: 'auth/verify',
          parameters: {'token': 'extracted-token', 'email': 'test@example.com'},
        );

        expect(result.extractedToken, 'extracted-token');
        expect(result.extractedEmail, 'test@example.com');
      });

      test('should extract invite code from parameters', () {
        const result = DeepLinkResult(
          path: 'families/join',
          parameters: {'code': 'extracted-code'},
        );

        expect(result.extractedInviteCode, 'extracted-code');
      });

      test(
        'should prefer parameter values over constructor values in extraction',
        () {
          const result = DeepLinkResult(
            path: 'auth/verify',
            magicToken: 'constructor-token',
            email: 'constructor@example.com',
            inviteCode: 'constructor-code',
            parameters: {
              'token': 'param-token',
              'email': 'param@example.com',
              'code': 'param-code',
            },
          );

          // Constructor values are still accessible directly
          expect(result.magicToken, 'constructor-token');
          expect(result.email, 'constructor@example.com');
          expect(result.inviteCode, 'constructor-code');

          // But extracted values prefer parameters over constructor values
          expect(result.extractedToken, 'param-token');
          expect(result.extractedEmail, 'param@example.com');
          expect(result.extractedInviteCode, 'param-code');
        },
      );

      test(
        'should fallback to constructor values when parameters are missing',
        () {
          const result = DeepLinkResult(
            path: 'auth/verify',
            magicToken: 'constructor-token',
            email: 'constructor@example.com',
            inviteCode: 'constructor-code',
          );

          // Extracted values should fallback to constructor values
          expect(result.extractedToken, 'constructor-token');
          expect(result.extractedEmail, 'constructor@example.com');
          expect(result.extractedInviteCode, 'constructor-code');
        },
      );
    });

    group('Route Type Detection', () {
      test('should detect custom paths correctly', () {
        const result = DeepLinkResult(path: 'custom/route/path');

        expect(result.hasPath, true);
        expect(result.isCustomPath, true);
        expect(result.isAuthVerifyPath, false);
        expect(result.isGroupJoinPath, false);
        expect(result.isFamilyJoinPath, false);
        expect(result.isDashboardPath, false);
      });

      test('should detect authentication requirements', () {
        const authVerify = DeepLinkResult(path: 'auth/verify');
        const groupJoin = DeepLinkResult(path: 'groups/join');
        const familyJoin = DeepLinkResult(path: 'families/join');
        const dashboard = DeepLinkResult(path: 'dashboard');

        expect(authVerify.requiresAuthentication, false);
        expect(groupJoin.requiresAuthentication, true);
        expect(familyJoin.requiresAuthentication, true);
        expect(dashboard.requiresAuthentication, true);
      });

      test('should detect family requirements', () {
        const authVerify = DeepLinkResult(path: 'auth/verify');
        const groupJoin = DeepLinkResult(path: 'groups/join');
        const familyJoin = DeepLinkResult(path: 'families/join');

        expect(authVerify.requiresFamily, false);
        expect(groupJoin.requiresFamily, true);
        expect(familyJoin.requiresFamily, false);
      });

      test('should detect invite context preservation', () {
        const authVerify = DeepLinkResult(path: 'auth/verify');
        const groupJoin = DeepLinkResult(path: 'groups/join');
        const familyJoin = DeepLinkResult(path: 'families/join');
        const dashboard = DeepLinkResult(path: 'dashboard');

        expect(authVerify.preservesInviteContext, true);
        expect(groupJoin.preservesInviteContext, true);
        expect(familyJoin.preservesInviteContext, true);
        expect(dashboard.preservesInviteContext, false);
      });
    });

    group('Backward Compatibility', () {
      test('should maintain backward compatibility with legacy properties', () {
        const magicLinkResult = DeepLinkResult(
          magicToken: 'magic-token',
          email: 'test@example.com',
        );

        const inviteResult = DeepLinkResult(inviteCode: 'invite-code');

        const emptyResult = DeepLinkResult();

        expect(magicLinkResult.hasMagicLink, true);
        expect(magicLinkResult.hasInvitation, false);
        expect(magicLinkResult.isEmpty, false);

        expect(inviteResult.hasMagicLink, false);
        expect(inviteResult.hasInvitation, true);
        expect(inviteResult.isEmpty, false);

        expect(emptyResult.hasMagicLink, false);
        expect(emptyResult.hasInvitation, false);
        expect(emptyResult.isEmpty, true);
      });
    });

    group('Navigation URL Building', () {
      test('should build correct URLs for path-aware navigation', () {
        const authResult = DeepLinkResult(
          path: 'auth/verify',
          parameters: {
            'token': 'test-token-123',
            'email': 'user@example.com',
            'inviteCode': 'invite-123',
          },
        );

        const familyResult = DeepLinkResult(
          path: 'families/join',
          parameters: {'code': 'family-code-456'},
        );

        const groupResult = DeepLinkResult(
          path: 'groups/join',
          parameters: {'code': 'group-code-789'},
        );

        // Test that we can build the router paths correctly
        expect(authResult.routerPath, '/auth/verify');
        expect(familyResult.routerPath, '/families/join');
        expect(groupResult.routerPath, '/groups/join');

        // Test URL building logic (simulating what the handler does)
        final authUri = Uri(
          path: authResult.routerPath,
          queryParameters: authResult.parameters,
        );
        expect(
          authUri.toString(),
          '/auth/verify?token=test-token-123&email=user%40example.com&inviteCode=invite-123',
        );

        final familyUri = Uri(
          path: familyResult.routerPath,
          queryParameters: familyResult.parameters,
        );
        expect(familyUri.toString(), '/families/join?code=family-code-456');

        final groupUri = Uri(
          path: groupResult.routerPath,
          queryParameters: groupResult.parameters,
        );
        expect(groupUri.toString(), '/groups/join?code=group-code-789');
      });

      test('should handle empty parameters correctly', () {
        const result = DeepLinkResult(path: 'dashboard');

        final uri = Uri(
          path: result.routerPath,
          queryParameters: result.parameters.isEmpty ? null : result.parameters,
        );

        expect(uri.toString(), '/dashboard');
      });
    });
  });
}

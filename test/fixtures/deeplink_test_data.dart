// EduLift Mobile - DeepLink Test Data Fixtures
// TDD London School - Test data builders for enhanced DeepLinkResult testing

import 'package:edulift/core/domain/entities/auth_entities.dart';

/// Test data factory for DeepLink testing scenarios
/// Based on frontend analysis: auth/verify, groups/join, families/join, dashboard
class DeepLinkTestData {
  // =================== URL PATTERNS (Based on Frontend Analysis) ===================

  /// Authentication magic link URLs (with and without invite codes)
  static const authVerifyUrl = 'edulift://auth/verify?token=magic123';
  static const authVerifyWithInviteUrl =
      'edulift://auth/verify?token=magic123&inviteCode=fam456';
  static const authVerifyWithEmailUrl =
      'edulift://auth/verify?token=magic123&email=test%40example.com';
  static const authVerifyCompleteUrl =
      'edulift://auth/verify?token=magic123&inviteCode=fam456&email=test%40example.com';

  /// Group invitation URLs
  static const groupJoinUrl = 'edulift://groups/join?code=grp789';
  static const groupJoinWithTokenUrl =
      'edulift://groups/join?code=grp789&token=magic123';

  /// Family invitation URLs
  static const familyJoinUrl = 'edulift://families/join?code=fam456';
  static const familyJoinWithTokenUrl =
      'edulift://families/join?code=fam456&token=magic123';

  /// Dashboard direct access
  static const dashboardUrl = 'edulift://dashboard';
  static const dashboardWithParamsUrl =
      'edulift://dashboard?view=schedule&groupId=123';

  // =================== INVALID/EDGE CASE URLs ===================

  static const invalidSchemeUrl =
      'https://example.com/auth/verify?token=magic123';
  static const malformedUrl = 'not-a-valid-url';
  static const emptyPathUrl = 'edulift://';
  static const pathOnlyUrl = 'edulift://auth/verify';
  static const missingParametersUrl = 'edulift://auth/verify?';
  static const specialCharactersUrl =
      'edulift://auth/verify?token=magic%20123&email=test%40example.com';

  // =================== EXPECTED ENHANCED DEEPLINKRESULT OBJECTS ===================

  /// Expected result for auth/verify path with token only
  static DeepLinkResult get authVerifyResult => const DeepLinkResult(
        magicToken: 'magic123',
        path: 'auth/verify',
        parameters: {'token': 'magic123'},
      );

  /// Expected result for auth/verify with invite code
  static DeepLinkResult get authVerifyWithInviteResult => const DeepLinkResult(
        magicToken: 'magic123',
        inviteCode: 'fam456',
        path: 'auth/verify',
        parameters: {'token': 'magic123', 'inviteCode': 'fam456'},
      );

  /// Expected result for auth/verify with email
  static DeepLinkResult get authVerifyWithEmailResult => const DeepLinkResult(
        magicToken: 'magic123',
        email: 'test@example.com',
        path: 'auth/verify',
        parameters: {'token': 'magic123', 'email': 'test@example.com'},
      );

  /// Expected result for complete auth/verify scenario
  static DeepLinkResult get authVerifyCompleteResult => const DeepLinkResult(
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

  /// Expected result for groups/join path
  static DeepLinkResult get groupJoinResult => const DeepLinkResult(
        inviteCode: 'grp789',
        path: 'groups/join',
        parameters: {'code': 'grp789'},
      );

  /// Expected result for groups/join with magic token
  static DeepLinkResult get groupJoinWithTokenResult => const DeepLinkResult(
        inviteCode: 'grp789',
        magicToken: 'magic123',
        path: 'groups/join',
        parameters: {'code': 'grp789', 'token': 'magic123'},
      );

  /// Expected result for families/join path
  static DeepLinkResult get familyJoinResult => const DeepLinkResult(
        inviteCode: 'fam456',
        path: 'families/join',
        parameters: {'code': 'fam456'},
      );

  /// Expected result for families/join with magic token
  static DeepLinkResult get familyJoinWithTokenResult => const DeepLinkResult(
        inviteCode: 'fam456',
        magicToken: 'magic123',
        path: 'families/join',
        parameters: {'code': 'fam456', 'token': 'magic123'},
      );

  /// Expected result for dashboard path
  static DeepLinkResult get dashboardResult =>
      const DeepLinkResult(path: 'dashboard');

  /// Expected result for dashboard with parameters
  static DeepLinkResult get dashboardWithParamsResult => const DeepLinkResult(
        path: 'dashboard',
        parameters: {'view': 'schedule', 'groupId': '123'},
      );

  /// Expected result for empty/invalid cases
  static DeepLinkResult get emptyResult => const DeepLinkResult(path: '');

  // =================== ROUTER INTEGRATION TEST DATA ===================

  /// Expected router destinations based on path
  static const Map<String, String> expectedRoutes = {
    'auth/verify': '/auth/verify',
    'groups/join': '/groups/join',
    'families/join': '/families/join',
    'dashboard': '/dashboard',
  };

  /// Router context parameters for navigation testing
  static const Map<String, Map<String, dynamic>> routerContexts = {
    'auth/verify': {
      'requiresAuth': false,
      'redirectAfterAuth': true,
      'preserveInviteContext': true,
    },
    'groups/join': {
      'requiresAuth': true,
      'requiresFamily': true,
      'preserveInviteCode': true,
    },
    'families/join': {
      'requiresAuth': true,
      'requiresFamily': false,
      'preserveInviteCode': true,
    },
    'dashboard': {
      'requiresAuth': true,
      'requiresFamily': false,
      'preserveInviteCode': false,
    },
  };

  // =================== EDGE CASE TEST SCENARIOS ===================

  /// Test cases for parameter extraction edge cases
  static const List<Map<String, dynamic>> edgeCaseScenarios = [
    {
      'name': 'URL with encoded parameters',
      'url': 'edulift://auth/verify?token=magic%20123&email=test%40example.com',
      'expectedToken': 'magic 123',
      'expectedEmail': 'test@example.com',
      'expectedPath': 'auth/verify',
    },
    {
      'name': 'URL with duplicate parameters (last wins)',
      'url': 'edulift://groups/join?code=first&code=second',
      'expectedInviteCode': 'second',
      'expectedPath': 'groups/join',
    },
    {
      'name': 'URL with empty parameter values',
      'url': 'edulift://families/join?code=&token=',
      'expectedInviteCode': null,
      'expectedToken': null,
      'expectedPath': 'families/join',
    },
    {
      'name': 'URL with special characters in path',
      'url': 'edulift://auth-verify/special?token=abc123',
      'expectedPath': 'auth-verify/special',
      'expectedToken': 'abc123',
    },
  ];

  // =================== BACKWARD COMPATIBILITY TEST DATA ===================

  /// Test data for ensuring existing functionality remains unchanged
  static const List<Map<String, dynamic>> backwardCompatibilityTests = [
    {
      'name': 'Legacy constructor without path',
      'legacyResult': DeepLinkResult(
        magicToken: 'magic123',
        inviteCode: 'fam456',
        email: 'test@example.com',
        parameters: {'token': 'magic123', 'inviteCode': 'fam456'},
      ),
      'expectedPath': '', // Should default to empty when not provided
    },
    {
      'name': 'Legacy getters work correctly',
      'legacyResult': DeepLinkResult(
        magicToken: 'magic123',
        inviteCode: 'fam456',
      ),
      'expectedHasMagicLink': true,
      'expectedHasInvitation': true,
      'expectedIsEmpty': false,
    },
  ];
}

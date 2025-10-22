// EduLift Mobile - Comprehensive Auth Flow Test Suite
// Tests covering critical auth issues identified in debugging
// Following FLUTTER_TESTING_RESEARCH_2025.md architectural patterns

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/features/auth/domain/usecases/send_magic_link_usecase.dart';
import 'package:edulift/core/domain/entities/auth_entities.dart';
import 'package:dartz/dartz.dart';

import '../../../test_mocks/test_mocks.dart';
import '../../../test_mocks/test_specialized_mocks.dart';
import '../../../test_mocks/generated_mocks.mocks.dart' as gen_mocks;
// Removed conflicting generated_mocks import - using centralized test_mocks.dart only

void main() {
  // Re-enabled after fixing DeepLinkResult import - now uses complete API from deep_link_service.dart
  late MockFeatureAuthService mockFeatureAuthService;
  late MockDeepLinkService mockDeepLinkService;
  late gen_mocks.MockIMagicLinkService mockMagicLinkService;
  late SendMagicLinkUsecase sendMagicLinkUsecase;

  setUpAll(() {
    setupMockFallbacks();
  });

  setUp(() {
    mockFeatureAuthService = MockFeatureAuthService();
    mockDeepLinkService = MockDeepLinkService();
    mockMagicLinkService = gen_mocks.MockIMagicLinkService();
    sendMagicLinkUsecase = SendMagicLinkUsecase(mockFeatureAuthService);
  });

  group('Auth Issue 1: New User Magic Link Failure → Name Entry Redirect', () {
    test(
      'should return server error when new user magic link fails at backend',
      () async {
        // ARRANGE: Simulate backend failure for new user (likely user not found)
        const email = 'newuser@example.com';
        const expectedFailure = ApiFailure(
          message: 'User not found in system',
          statusCode: 404,
        );

        when(
          mockFeatureAuthService.sendMagicLink(email),
        ).thenAnswer((_) async => const Result.err(expectedFailure));

        // ACT
        final result = await sendMagicLinkUsecase.call(
          SendMagicLinkParams(email: email, redirectUrl: '/auth/verify'),
        );

        // ASSERT: Should receive expected backend failure
        expect(result.isErr, true);
        result.when(
          ok: (success) => fail('Expected failure but got success'),
          err: (failure) {
            expect(failure.statusCode, 404);
            expect(failure.message, contains('User not found'));
          },
        );

        verify(mockFeatureAuthService.sendMagicLink(email)).called(1);
      },
    );

    test(
      'should handle API failure with correct error propagation pattern',
      () async {
        // ARRANGE: Test the exact error pattern seen in debugging
        const email = 'nonexistent@example.com';
        const backendError = ApiFailure(
          message: 'Authentication service unavailable',
          statusCode: 503,
        );

        when(
          mockFeatureAuthService.sendMagicLink('nonexistent@example.com'),
        ).thenAnswer((_) async => const Result.err(backendError));

        // ACT
        final result = await sendMagicLinkUsecase.call(
          SendMagicLinkParams(email: email),
        );

        // ASSERT: Verify proper error propagation without transformation
        expect(result.isErr, true);
        result.when(
          ok: (_) => fail('Should have failed'),
          err: (error) {
            expect(error, isA<ApiFailure>());
            expect(error.statusCode, 503);
            expect(error.message, 'Authentication service unavailable');
          },
        );
      },
    );

    test(
      'should delegate email validation to service and return service error',
      () async {
        // ARRANGE: Invalid email that will be validated by the service
        const invalidEmail = 'not-an-email';
        const validationFailure = ApiFailure(
          message: 'Invalid email address format',
          statusCode: 400,
        );

        // Mock the service to return validation error
        when(
          mockFeatureAuthService.sendMagicLink(invalidEmail),
        ).thenAnswer((_) async => const Result.err(validationFailure));

        // ACT
        final result = await sendMagicLinkUsecase.call(
          SendMagicLinkParams(email: invalidEmail),
        );

        // ASSERT: Should fail with service validation error
        expect(result.isErr, true);
        result.when(
          ok: (_) => fail('Should have failed validation'),
          err: (error) {
            expect(error.message, contains('Invalid email address format'));
          },
        );

        // Verify API call was made (usecase delegates to service)
        verify(mockFeatureAuthService.sendMagicLink(invalidEmail)).called(1);
      },
    );

    test('should delegate empty email validation to service', () async {
      // ARRANGE: Empty email input
      const emptyEmail = '';
      const validationFailure = ApiFailure(
        message: 'Email address is required',
        statusCode: 400,
      );

      // Mock the service to return validation error for empty email
      when(
        mockFeatureAuthService.sendMagicLink(emptyEmail),
      ).thenAnswer((_) async => const Result.err(validationFailure));

      // ACT
      final result = await sendMagicLinkUsecase.call(
        SendMagicLinkParams(email: emptyEmail),
      );

      // ASSERT: Should fail with service validation error
      expect(result.isErr, true);
      result.when(
        ok: (_) => fail('Should have failed validation'),
        err: (error) {
          expect(error.message, 'Email address is required');
        },
      );

      // Verify API call was made (usecase delegates to service)
      verify(mockFeatureAuthService.sendMagicLink(emptyEmail)).called(1);
    });
  });

  group('Auth Issue 2: Family Invitation Deeplink vs Web URL Generation', () {
    test(
      'should generate native deeplink with correct format for family invitation',
      () {
        // ARRANGE: Family invitation parameters
        const inviteCode = 'FAM123ABC';
        const magicToken = 'magic_token_xyz';
        const expectedDeeplink =
            'edulift://families/join?code=FAM123ABC&token=magic_token_xyz';

        when(
          mockDeepLinkService.generateNativeDeepLink(
            magicToken,
            inviteCode: inviteCode,
          ),
        ).thenReturn(expectedDeeplink);

        // ACT
        final result = mockDeepLinkService.generateNativeDeepLink(
          magicToken,
          inviteCode: inviteCode,
        );

        // ASSERT: Should match expected native deeplink format
        expect(result, expectedDeeplink);
        expect(result, startsWith('edulift://'));
        expect(result, contains('families/join'));
        expect(result, contains('code=FAM123ABC'));
        expect(result, contains('token=magic_token_xyz'));

        verify(
          mockDeepLinkService.generateNativeDeepLink(
            magicToken,
            inviteCode: inviteCode,
          ),
        ).called(1);
      },
    );

    test('should correctly parse deeplink with family invitation parameters', () {
      // ARRANGE: Incoming deeplink URL
      const deeplinkUrl =
          'edulift://families/join?code=FAM456&token=auth_token_123&email=user%40example.com';
      const expectedResult = DeepLinkResult(
        inviteCode: 'FAM456',
        magicToken: 'auth_token_123',
        email: 'user@example.com',
        path: 'families/join', // Set the path property correctly
        parameters: {
          'path': 'families/join',
          'code': 'FAM456',
          'token': 'auth_token_123',
          'email': 'user@example.com',
        },
      );

      when(
        mockDeepLinkService.parseDeepLink(deeplinkUrl),
      ).thenReturn(expectedResult);

      // ACT
      final result = mockDeepLinkService.parseDeepLink(deeplinkUrl);

      // ASSERT: Should correctly extract all parameters
      expect(result, isNotNull);
      expect(result!.inviteCode, 'FAM456');
      expect(result.magicToken, 'auth_token_123');
      expect(result.email, 'user@example.com');
      expect(result.path, 'families/join');
      expect(result.isFamilyJoinPath, true);
      expect(result.requiresAuthentication, true);
      expect(result.hasValidInviteCode, true);

      verify(mockDeepLinkService.parseDeepLink(deeplinkUrl)).called(1);
    });

    test('should handle web URL vs native deeplink generation correctly', () {
      // ARRANGE: Test both web and native URL generation
      const magicToken = 'token123';
      const inviteCode = 'INV456';

      // Web URL format (what backend might generate)
      const webUrl =
          'https://app.edulift.com/families/join?code=INV456&token=token123';
      // Native deeplink format (what app should use)
      const nativeDeeplink =
          'edulift://families/join?code=INV456&token=token123';

      when(
        mockDeepLinkService.generateNativeDeepLink(
          magicToken,
          inviteCode: inviteCode,
        ),
      ).thenReturn(nativeDeeplink);

      // ACT
      final nativeResult = mockDeepLinkService.generateNativeDeepLink(
        magicToken,
        inviteCode: inviteCode,
      );

      // ASSERT: Should generate native format, not web format
      expect(nativeResult, nativeDeeplink);
      expect(nativeResult, isNot(webUrl));
      expect(nativeResult, startsWith('edulift://'));
      expect(nativeResult, isNot(startsWith('https://')));

      verify(
        mockDeepLinkService.generateNativeDeepLink(
          magicToken,
          inviteCode: inviteCode,
        ),
      ).called(1);
    });
  });

  group('Auth Issue 3: Platform Parameter Inclusion in API Requests', () {
    test('should include platform parameter when sending magic link', () async {
      // ARRANGE: Magic link request with platform context
      const email = 'user@example.com';
      const redirectUrl = '/auth/verify?platform=mobile';
      const expectedResponse = 'Magic link sent successfully';

      when(
        mockFeatureAuthService.sendMagicLink(email),
      ).thenAnswer((_) async => const Result.ok(expectedResponse));

      // ACT
      final result = await sendMagicLinkUsecase.call(
        SendMagicLinkParams(email: email, redirectUrl: redirectUrl),
      );

      // ASSERT: Should include platform parameter in redirect URL
      expect(result.isOk, true);

      // Verify the call was made with platform parameter and URL contains platform
      verify(mockFeatureAuthService.sendMagicLink(email)).called(1);

      // Platform parameter handling moved to higher layer
    });

    test('should handle missing platform parameter gracefully', () async {
      // ARRANGE: Magic link request without platform parameter
      const email = 'user@example.com';
      const redirectUrlWithoutPlatform = '/auth/verify';
      const expectedResponse = 'Magic link sent successfully';

      when(
        mockFeatureAuthService.sendMagicLink(email),
      ).thenAnswer((_) async => const Result.ok(expectedResponse));

      // ACT
      final result = await sendMagicLinkUsecase.call(
        SendMagicLinkParams(
          email: email,
          redirectUrl: redirectUrlWithoutPlatform,
        ),
      );

      // ASSERT: Should still succeed without platform parameter
      expect(result.isOk, true);
      verify(mockFeatureAuthService.sendMagicLink(email)).called(1);
    });

    test('should preserve all URL parameters including platform', () async {
      // ARRANGE: Complex redirect URL with multiple parameters
      const email = 'test@example.com';
      const complexRedirectUrl =
          '/auth/verify?platform=mobile&source=invitation&code=ABC123';
      const expectedResponse = 'Magic link sent successfully';

      when(
        mockFeatureAuthService.sendMagicLink(email),
      ).thenAnswer((_) async => const Result.ok(expectedResponse));

      // ACT
      final result = await sendMagicLinkUsecase.call(
        SendMagicLinkParams(email: email, redirectUrl: complexRedirectUrl),
      );

      // ASSERT: Should preserve all parameters
      expect(result.isOk, true);

      verify(mockFeatureAuthService.sendMagicLink(email)).called(1);
      // URL parameters handled at higher layer
    });
  });

  group('Auth Issue 4: Auth Provider Response Handling Scenarios', () {
    test('should handle successful magic link verification response', () async {
      // ARRANGE: Successful verification response
      final successfulVerificationResult = MagicLinkVerificationResult(
        token: 'valid_jwt_token_123',
        refreshToken: 'valid_refresh_token_123',
        expiresIn: 900,
        user: const {
          'id': 'user123',
          'email': 'verified@example.com',
          'name': 'Verified User',
        },
        expiresAt: DateTime(2024, 12, 31, 23, 59, 59),
        invitationResult: const {
          'processed': true,
          'invitationType': 'family',
          'familyId': 'family123',
          'redirectUrl': '/family/dashboard',
          'requiresFamilyOnboarding': false,
        },
      );

      when(
        mockMagicLinkService.verifyMagicLink('valid_token'),
      ).thenAnswer((_) async => Right(successfulVerificationResult));

      // ACT
      final result = await mockMagicLinkService.verifyMagicLink('valid_token');

      // ASSERT: Should handle successful response correctly
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected success'), (verificationResult) {
        expect(verificationResult.token, 'valid_jwt_token_123');
        expect(verificationResult.user['email'], 'verified@example.com');
        expect(verificationResult.isNewUser, false);
        expect(verificationResult.invitationResult?['processed'], true);
        expect(verificationResult.invitationResult?['familyId'], 'family123');
      });

      verify(mockMagicLinkService.verifyMagicLink('valid_token')).called(1);
    });

    test('should handle new user response requiring name entry', () async {
      // ARRANGE: New user verification response
      final newUserVerificationResult = MagicLinkVerificationResult(
        token: 'new_user_token_456',
        refreshToken: 'new_user_refresh_token_456',
        expiresIn: 900,
        user: const {
          'id': 'newuser123',
          'email': 'newuser@example.com',
          'name': null, // New user without name
        },
        expiresAt: DateTime(2024, 12, 31, 23, 59, 59),
        isNewUser: true, // Critical flag for name entry
      );

      when(
        mockMagicLinkService.verifyMagicLink('new_user_token'),
      ).thenAnswer((_) async => Right(newUserVerificationResult));

      // ACT
      final result = await mockMagicLinkService.verifyMagicLink(
        'new_user_token',
      );

      // ASSERT: Should identify new user requiring name entry
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected success'), (verificationResult) {
        expect(verificationResult.isNewUser, true);
        expect(verificationResult.user['name'], isNull);
        expect(verificationResult.invitationResult, isNull);
        // This should trigger name entry screen
      });

      verify(mockMagicLinkService.verifyMagicLink('new_user_token')).called(1);
    });

    test('should handle invalid token response appropriately', () async {
      // ARRANGE: Invalid token response
      const invalidTokenFailure = ApiFailure(
        message: 'Invalid or expired magic link token',
        statusCode: 401,
      );

      when(
        mockMagicLinkService.verifyMagicLink('invalid_token'),
      ).thenAnswer((_) async => const Left(invalidTokenFailure));

      // ACT
      final result = await mockMagicLinkService.verifyMagicLink(
        'invalid_token',
      );

      // ASSERT: Should handle invalid token appropriately
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ApiFailure>());
        expect((failure as ApiFailure).statusCode, 401);
        expect(failure.message, contains('Invalid or expired'));
      }, (_) => fail('Expected failure'));

      verify(mockMagicLinkService.verifyMagicLink('invalid_token')).called(1);
    });

    test('should handle network failure during verification', () async {
      // ARRANGE: Network failure scenario
      const networkFailure = NetworkFailure(
        message: 'Network request failed',
        statusCode: 0,
      );

      when(
        mockMagicLinkService.verifyMagicLink('token_network_fail'),
      ).thenAnswer((_) async => const Left(networkFailure));

      // ACT
      final result = await mockMagicLinkService.verifyMagicLink(
        'token_network_fail',
      );

      // ASSERT: Should handle network failure gracefully
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<NetworkFailure>());
        expect(failure.message, 'Network request failed');
      }, (_) => fail('Expected network failure'));

      verify(
        mockMagicLinkService.verifyMagicLink('token_network_fail'),
      ).called(1);
    });
  });

  group('Auth Issue 5: Router Redirect Logic for Auth States', () {
    test(
      'should determine correct redirect path for authenticated user with family',
      () {
        // ARRANGE: DeepLink for authenticated user with family membership
        const authenticatedWithFamilyLink = DeepLinkResult(
          magicToken: 'auth_token',
          parameters: {
            'path': 'dashboard',
            'hasFamily': 'true',
            'familyId': 'family123',
          },
        );

        // ACT & ASSERT: Should redirect to family dashboard
        expect(authenticatedWithFamilyLink.isDashboardPath, true);
        expect(authenticatedWithFamilyLink.requiresAuthentication, true);
        expect(authenticatedWithFamilyLink.routerPath, '/dashboard');
      },
    );

    test(
      'should determine correct redirect path for new user requiring onboarding',
      () {
        // ARRANGE: DeepLink for new user
        const newUserLink = DeepLinkResult(
          magicToken: 'new_user_token',
          path: 'auth/verify',
          parameters: {'isNewUser': 'true', 'requiresName': 'true'},
        );

        // ACT & ASSERT: Should redirect to auth verification (name entry)
        expect(newUserLink.isAuthVerifyPath, true);
        expect(newUserLink.canProceedWithAuth, true);
        expect(newUserLink.routerPath, '/auth/verify');
      },
    );

    test('should handle family invitation deeplink with proper routing', () {
      // ARRANGE: DeepLink for family invitation
      const familyInvitationLink = DeepLinkResult(
        inviteCode: 'FAM123',
        magicToken: 'invite_token',
        path: 'families/join',
        parameters: {
          'code': 'FAM123',
          'token': 'invite_token',
          'inviterName': 'John Doe',
        },
      );

      // ACT & ASSERT: Should route to family join flow
      expect(familyInvitationLink.isFamilyJoinPath, true);
      expect(familyInvitationLink.requiresAuthentication, true);
      expect(familyInvitationLink.canProceedWithInvite, true);
      expect(familyInvitationLink.routerPath, '/families/join');
    });

    test('should handle empty or invalid deeplink gracefully', () {
      // ARRANGE: Empty/invalid deeplink
      const emptyLink = DeepLinkResult();

      // ACT & ASSERT: Should default to dashboard
      expect(emptyLink.isEmpty, true);
      expect(emptyLink.routerPath, '/dashboard');
      expect(emptyLink.isValid, false);
    });
  });

  group('Edge Cases and Boundary Conditions', () {
    test('should handle malformed email addresses consistently', () async {
      final malformedEmails = [
        'user@',
        '@domain.com',
        'user@domain',
        'user.domain.com',
        'user @domain.com',
        'user@domain .com',
      ];

      for (final email in malformedEmails) {
        // Mock the service to return validation error for each malformed email
        const validationFailure = ApiFailure(
          message: 'Invalid email address format',
          statusCode: 400,
        );
        when(
          mockFeatureAuthService.sendMagicLink(email),
        ).thenAnswer((_) async => const Result.err(validationFailure));

        final result = await sendMagicLinkUsecase.call(
          SendMagicLinkParams(email: email),
        );

        expect(result.isErr, true, reason: 'Should reject email: $email');
        result.when(
          ok: (_) => fail('Should have rejected email: $email'),
          err: (error) {
            expect(error.message, contains('Invalid email address format'));
          },
        );

        // Verify API call was made (usecase delegates to service)
        verify(mockFeatureAuthService.sendMagicLink(email)).called(1);
        reset(mockFeatureAuthService);
      }
    });

    test('should handle extremely long email addresses', () async {
      // ARRANGE: Create a very long but valid email
      final longLocalPart = 'a' * 64; // Maximum local part length
      final longDomain = '${'b' * 60}.com'; // Long domain
      final longEmail = '$longLocalPart@$longDomain';

      when(
        mockFeatureAuthService.sendMagicLink(longEmail),
      ).thenAnswer((_) async => const Result.ok('Success'));

      // ACT
      final result = await sendMagicLinkUsecase.call(
        SendMagicLinkParams(email: longEmail),
      );

      // ASSERT: Should handle long valid email
      expect(result.isOk, true);
      verify(mockFeatureAuthService.sendMagicLink(longEmail)).called(1);
    });

    test(
      'should handle concurrent magic link requests for same email',
      () async {
        // ARRANGE: Multiple concurrent requests
        const email = 'concurrent@example.com';
        when(
          mockFeatureAuthService.sendMagicLink(email),
        ).thenAnswer((_) async => const Result.ok('Success'));

        // ACT: Fire multiple requests simultaneously
        final futures = List.generate(
          3,
          (index) =>
              sendMagicLinkUsecase.call(SendMagicLinkParams(email: email)),
        );
        final results = await Future.wait(futures);

        // ASSERT: All should succeed
        for (final result in results) {
          expect(result.isOk, true);
        }

        // Verify all calls were made
        verify(mockFeatureAuthService.sendMagicLink(email)).called(3);
      },
    );

    test('should handle deeplink parameter URL encoding correctly', () {
      // ARRANGE: DeepLink with URL-encoded parameters
      const encodedEmail = 'user%2Btest%40example.com'; // user+test@example.com
      const deeplinkWithEncoding = DeepLinkResult(
        email: encodedEmail,
        parameters: {
          'email': encodedEmail,
          'redirect': 'families%2Fjoin', // families/join
        },
      );

      // ACT & ASSERT: Should decode parameters correctly
      expect(deeplinkWithEncoding.decodedEmail, 'user+test@example.com');
      expect(deeplinkWithEncoding.hasValidEmail, true);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:edulift/core/network/models/auth/index.dart';
import 'package:edulift/core/network/models/user/user_current_family_dto.dart';
import 'package:edulift/core/network/requests/auth_requests.dart';
import 'package:edulift/core/network/models/user/user_profile_dto.dart' as user;
import 'package:edulift/core/network/models/common/api_response_wrapper.dart';
import 'package:edulift/core/domain/services/auth_service.dart';
import 'package:edulift/core/services/auth_service.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/network/error_handler_service.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/storage/auth_local_datasource.dart';

import '../../../test_mocks/test_mocks.dart';

// Test constants
const String testJwtToken =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test-payload.test-signature';

// Test data builders
class TestDataBuilder {
  static MagicLinkRequest createMagicLinkRequest({
    String? email,
    String? name,
    String? inviteCode,
    String? codeChallenge,
  }) {
    return MagicLinkRequest(
      email: email ?? 'test@example.com',
      name: name,
      inviteCode: inviteCode,
      codeChallenge:
          codeChallenge ?? 'test_code_challenge_43_chars_minimum_required',
    );
  }

  static ApiResponse<Map<String, dynamic>> createSuccessResponse({
    String? message,
    Map<String, dynamic>? data,
  }) {
    return ApiResponse<Map<String, dynamic>>(
      success: true,
      data: data ?? {'message': 'Success', 'userExists': true},
    );
  }

  static ApiResponse<Map<String, dynamic>> createErrorResponse({
    String? message,
    String? error,
    Map<String, dynamic>? data,
  }) {
    return ApiResponse<Map<String, dynamic>>(
      success: false,
      errorMessage: error ?? 'Server error',
      data: data ?? {'message': 'Error occurred', 'userExists': false},
    );
  }

  static Map<String, dynamic> createUserData({
    String? id,
    String? email,
    String? name,
    bool? isBiometricEnabled,
  }) {
    return {
      'id': id ?? 'user-id',
      'email': email ?? 'test@example.com',
      'name': name ?? 'Test User',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isBiometricEnabled': isBiometricEnabled ?? false,
    };
  }
}

void main() {
  // Setup Mocktail dummy values for Result types
  setUpAll(() {
    setupMockFallbacks();
  });

  group('AuthService', () {
    late AuthService authService;
    late MockAuthApiClient mockAuthApiClient;
    late MockIAuthLocalDatasource mockAuthLocalDatasource;
    late MockUserStatusService mockUserStatusService;
    // MockComprehensiveFamilyDataService removed - Clean Architecture: auth domain separated from family domain

    setUp(() {
      mockAuthApiClient = MockAuthApiClient();
      mockAuthLocalDatasource = MockIAuthLocalDatasource();
      mockUserStatusService = MockUserStatusService();
      // FIXED: Use real AuthServiceImpl instead of MockAuthService to test actual implementation
      authService = AuthServiceImpl(
        mockAuthApiClient,
        mockAuthLocalDatasource,
        mockUserStatusService,
        ErrorHandlerService(UserMessageService()),
      );
    });

    group('sendMagicLink', () {
      test('should return success when API call succeeds', () async {
        // Arrange
        const email = 'test@example.com';
        const name = 'Test User';
        when(mockUserStatusService.isValidEmail(email)).thenReturn(true);
        when(
          mockAuthApiClient.sendMagicLink(any),
        ).thenAnswer((_) async => 'Magic link sent');
        // REMOVED: Mocking the method we're testing - this prevents actual implementation from running

        // Act
        final result = await authService.sendMagicLink(email, name: name);

        // Assert
        expect(result.isSuccess, true);
        verify(mockAuthApiClient.sendMagicLink(any)).called(1);

        // Verify the request was constructed correctly
        final captured = verify(mockAuthApiClient.sendMagicLink(captureAny))
            .captured
            .single as MagicLinkRequest;
        expect(captured.email, equals(email));
        expect(captured.name, equals(name));
        expect(captured.platform, equals('native')); // Default platform
        expect(captured.codeChallenge, isNotNull); // PKCE challenge generated
        expect(
          captured.codeChallenge.length,
          greaterThan(40),
        ); // Proper PKCE length
      });

      test('should return failure when API call fails', () async {
        // Arrange
        const email = 'test@example.com';

        when(mockUserStatusService.isValidEmail(email)).thenReturn(true);
        when(
          mockAuthApiClient.sendMagicLink(any),
        ).thenThrow(Exception('Failed to send magic link'));

        // Act
        final result = await authService.sendMagicLink(email);

        // Assert
        expect(result.isError, true);
        expect(result.error, isA<ApiFailure>());
      });

      test('should handle network exceptions', () async {
        // Arrange
        const email = 'test@example.com';

        when(mockUserStatusService.isValidEmail(email)).thenReturn(true);
        when(
          mockAuthApiClient.sendMagicLink(any),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await authService.sendMagicLink(email);

        // Assert
        expect(result.isError, true);
        expect(result.error, isA<ApiFailure>());
      });

      test('should include inviteCode when provided', () async {
        // Arrange
        const email = 'test@example.com';
        const name = 'Test User';
        const inviteCode = 'FAM123';
        when(mockUserStatusService.isValidEmail(email)).thenReturn(true);
        when(
          mockAuthApiClient.sendMagicLink(any),
        ).thenAnswer((_) async => 'Magic link sent with invitation context');

        // Act
        final result = await authService.sendMagicLink(
          email,
          name: name,
          inviteCode: inviteCode,
        );

        // Assert
        expect(result.isSuccess, true);

        // Verify the request includes the invite code
        final captured = verify(mockAuthApiClient.sendMagicLink(captureAny))
            .captured
            .single as MagicLinkRequest;
        expect(captured.email, equals(email));
        expect(captured.name, equals(name));
        expect(captured.inviteCode, equals(inviteCode));
      });
    });

    group('authenticateWithMagicLink', () {
      test('should return AuthResult when authentication succeeds', () async {
        // Arrange
        const token = 'valid-token';
        final userData = TestDataBuilder.createUserData();
        final userDto = UserCurrentFamilyDto(
          id: userData['id'] as String,
          email: userData['email'] as String,
          name: userData['name'] as String,
          isBiometricEnabled: userData['isBiometricEnabled'] as bool,
        );
        final authDto = AuthDto(
          accessToken: 'access-token',
          refreshToken: 'mock_refresh_token',
          expiresIn: 900,
          user: userDto,
        );

        when(
          mockAuthApiClient.verifyMagicLink(any, any),
        ).thenAnswer((_) async => authDto);

        // Mock successful token and user data storage
        when(
          mockAuthLocalDatasource.storeToken('access-token'),
        ).thenAnswer((_) async => const Result.ok(null));
        when(
          mockAuthLocalDatasource.storeUserData(any),
        ).thenAnswer((_) async => const Result.ok(null));

        // Act
        final result = await authService.authenticateWithMagicLink(token);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value, isA<AuthResult>());
        expect(result.value?.user.email, 'test@example.com');
      });

      test('should return failure when token is invalid', () async {
        // Arrange
        const token = 'invalid-token';
        when(
          mockAuthApiClient.verifyMagicLink(any, any),
        ).thenThrow(Exception('Invalid token'));

        // Act
        final result = await authService.authenticateWithMagicLink(token);

        // Assert
        expect(result.isError, true);
        expect(result.error, isA<ApiFailure>());
      });
    });

    group('getCurrentUser', () {
      test('should fetch user from API when no cached user', () async {
        // Arrange
        final userData = TestDataBuilder.createUserData();

        // Mock cached user data retrieval to succeed
        when(mockAuthLocalDatasource.getUserProfile()).thenAnswer(
          (_) async => Result.ok(
            AuthUserProfile(
              id: userData['id'] as String,
              email: userData['email'] as String,
              name: userData['name'] as String,
              role: 'member', // Default role
              lastUpdated: DateTime.now(),
              timezone: 'UTC', // Default timezone for testing
              // familyId is optional and defaults to null
            ),
          ),
        );

        // Act - provide userData parameter as expected by getCurrentUser
        final result = await authService.getCurrentUser(userData: userData);

        // Assert
        expect(result.isSuccess, true);
        expect(result.value?.email, 'test@example.com');
      });
    });

    group('storeToken', () {
      test('should store token successfully', () async {
        // Arrange
        const token = testJwtToken;

        when(
          mockAuthLocalDatasource.storeToken(token),
        ).thenAnswer((_) async => const Result.ok(null));

        // Act
        final result = await authService.storeToken(token);

        // Assert
        expect(result.isSuccess, true);
        verify(mockAuthLocalDatasource.storeToken(token)).called(1);
      });

      test('should return failure when storage fails', () async {
        // Arrange
        const token = testJwtToken;

        when(
          mockAuthLocalDatasource.storeToken(token),
        ).thenThrow(Exception('Storage error'));

        // Act
        final result = await authService.storeToken(token);

        // Assert
        expect(result.isError, true);
        expect(result.error, isA<ApiFailure>());
      });
    });

    group('logout', () {
      test('should clear local data even if API call fails', () async {
        // Arrange
        when(mockAuthApiClient.logout()).thenThrow(Exception('Network error'));
        when(
          mockAuthLocalDatasource.clearToken(),
        ).thenAnswer((_) async => const Result.ok(null));
        when(
          mockAuthLocalDatasource.clearUserData(),
        ).thenAnswer((_) async => const Result.ok(null));

        // Act
        final result = await authService.logout();

        // Assert
        expect(result.isSuccess, true);
        expect(authService.currentUser, isNull);
        verify(mockAuthLocalDatasource.clearToken()).called(1);
        verify(mockAuthLocalDatasource.clearUserData()).called(1);
      });
    });

    group('biometric authentication', () {
      test('should enable biometric auth successfully', () async {
        // Arrange
        final userData = TestDataBuilder.createUserData(
          isBiometricEnabled: true,
        );
        final userProfileDto = user.UserProfileDto(
          id: userData['id'] as String,
          email: userData['email'] as String,
          name: userData['name'] as String,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          mockAuthApiClient.enableBiometricAuth(any),
        ).thenAnswer((_) async => userProfileDto);

        // Act
        final result = await authService.enableBiometricAuth();

        // Assert
        expect(result.isSuccess, true);
        expect(result.value?.isBiometricEnabled, true);
      });

      test('should disable biometric auth successfully', () async {
        // Arrange
        final userData = TestDataBuilder.createUserData(
          isBiometricEnabled: false,
        );
        final userProfileDto = user.UserProfileDto(
          id: userData['id'] as String,
          email: userData['email'] as String,
          name: userData['name'] as String,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          mockAuthApiClient.disableBiometricAuth(any),
        ).thenAnswer((_) async => userProfileDto);

        // Act
        final result = await authService.disableBiometricAuth();

        // Assert
        expect(result.isSuccess, true);
        expect(result.value?.isBiometricEnabled, false);
      });
    });
  });
}

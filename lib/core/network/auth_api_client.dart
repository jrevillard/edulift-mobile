import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'models/auth/index.dart';
import 'models/user/user_profile_dto.dart';
import 'requests/auth_requests.dart';

part 'auth_api_client.g.dart';

/// Authentication API Client - State-of-the-Art 2025 Architecture
///
/// **Key Changes from Legacy Pattern:**
/// - API clients return DTOs as before (Retrofit requirement)
/// - Interceptor ensures responses are wrapped in proper JSON structure
/// - Repositories parse responses into ApiResponse<T> and use .unwrap() for error handling
/// - Transparent, maintainable API communication flow
///
/// Backend routes: /api/v1/auth/{magic-link, verify, refresh, logout, profile, test-config}
@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient.create(Dio dio, {String? baseUrl}) = _AuthApiClient;

  /// Request magic link for authentication
  /// POST /api/v1/auth/magic-link
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<String> and call .unwrap()
  @POST('/auth/magic-link')
  Future<String> sendMagicLink(@Body() MagicLinkRequest request);

  /// Verify magic link and get JWT token
  /// POST /api/v1/auth/verify
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<AuthDto> and call .unwrap()
  /// **Invitation Support**: inviteCode query parameter allows backend to process group/family invitations
  @POST('/auth/verify')
  Future<AuthDto> verifyMagicLink(
    @Body() VerifyTokenRequest request,
    @Query('inviteCode') String? inviteCode,
  );

  /// Refresh JWT token
  /// POST /api/v1/auth/refresh
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<AuthDto> and call .unwrap()
  @POST('/auth/refresh')
  Future<AuthDto> refreshToken(@Body() RefreshTokenRequest request);

  /// Logout (client-side token invalidation)
  /// POST /api/v1/auth/logout
  ///
  /// **Architecture Note**: Returns void directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<void> and call .unwrap()
  @POST('/auth/logout')
  Future<void> logout();

  /// Update user profile (protected route)
  /// PUT /api/v1/auth/profile
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<UserProfileDto> and call .unwrap()
  @PUT('/auth/profile')
  Future<UserProfileDto> updateProfile(@Body() UpdateProfileRequest request);

  /// Test endpoint to verify email service configuration
  /// GET /api/v1/auth/test-config
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<AuthConfigDto> and call .unwrap()
  @GET('/auth/test-config')
  Future<AuthConfigDto> getAuthConfig();

  /// Enable biometric authentication for user
  /// PUT /api/v1/auth/biometric/enable
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<UserProfileDto> and call .unwrap()
  @PUT('/auth/biometric/enable')
  Future<UserProfileDto> enableBiometricAuth(
    @Body() Map<String, dynamic> request,
  );

  /// Disable biometric authentication for user
  /// PUT /api/v1/auth/biometric/disable
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<UserProfileDto> and call .unwrap()
  @PUT('/auth/biometric/disable')
  Future<UserProfileDto> disableBiometricAuth(
    @Body() Map<String, dynamic> request,
  );

  /// Check if user exists
  /// GET /api/v1/auth/users/exists
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<UserExistsDto> and call .unwrap()
  @GET('/auth/users/exists')
  Future<UserExistsDto> checkUserExists(@Query('email') String email);

  /// Create user profile
  /// POST /api/v1/auth/users/profile
  ///
  /// **Architecture Note**: Returns DTO directly (Retrofit requirement)
  /// **Repository Pattern**: Repository will parse response into ApiResponse<UserProfileDto> and call .unwrap()
  @POST('/auth/users/profile')
  Future<UserProfileDto> createUserProfile(
    @Body() CreateUserProfileRequest request,
  );
}

// Request models are now imported from requests/auth_requests.dart

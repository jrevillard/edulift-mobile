import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/entities/user.dart';

abstract class AuthRepository {
  /// Send a magic link to the user's email
  Future<Result<String, ApiFailure>> sendMagicLink(
    String email,
    String? redirectUrl,
    String? inviteCode,
  );

  /// Verify the magic link token and authenticate the user
  Future<Result<AuthenticationResult, ApiFailure>> verifyMagicLinkToken(
    String token,
  );

  /// Refresh the user's authentication token
  Future<Result<AuthenticationResult, ApiFailure>> refreshToken(
    String refreshToken,
  );

  /// Get the current authenticated user
  Future<Result<User, ApiFailure>> getCurrentUser({bool forceRefresh = false});

  /// Update user profile information
  Future<Result<User, ApiFailure>> updateUserProfile(
    UpdateUserProfileRequest request,
  );

  /// Logout the current user
  Future<Result<void, ApiFailure>> logout();

  /// Check if the user is authenticated
  Future<Result<bool, ApiFailure>> isAuthenticated();

  /// Get auth configuration (magic link enabled, biometric enabled, etc.)
  Future<Result<AuthConfig, ApiFailure>> getAuthConfig();
}

class AuthenticationResult {
  final String accessToken;
  final String refreshToken;
  final User user;
  final DateTime expiresAt;

  AuthenticationResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user, 
    required this.expiresAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthenticationResult &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.user == user &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^
        refreshToken.hashCode ^
        user.hashCode ^
        expiresAt.hashCode;
  }
}

class UpdateUserProfileRequest {
  final String? name;
  final String? preferredLanguage;
  final String? timezone;
  final Map<String, dynamic>? accessibilityPreferences;

  UpdateUserProfileRequest({
    this.name,
    this.preferredLanguage, 
    this.timezone,
    this.accessibilityPreferences,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateUserProfileRequest &&
        other.name == name &&
        other.preferredLanguage == preferredLanguage &&
        other.timezone == timezone &&
        other.accessibilityPreferences == accessibilityPreferences;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        preferredLanguage.hashCode ^
        timezone.hashCode ^
        accessibilityPreferences.hashCode;
  }
}

class AuthConfig {
  final bool isMagicLinkEnabled;
  final bool isBiometricEnabled;
  final int tokenExpiryMinutes;

  const AuthConfig({
    required this.isMagicLinkEnabled,
    required this.isBiometricEnabled, 
    required this.tokenExpiryMinutes,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthConfig &&
        other.isMagicLinkEnabled == isMagicLinkEnabled &&
        other.isBiometricEnabled == isBiometricEnabled &&
        other.tokenExpiryMinutes == tokenExpiryMinutes;
  }

  @override
  int get hashCode {
    return isMagicLinkEnabled.hashCode ^
        isBiometricEnabled.hashCode ^
        tokenExpiryMinutes.hashCode;
  }
}

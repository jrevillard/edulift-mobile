// EduLift Mobile - Authentication Service Interface (Domain Layer)
// Abstract interface for authentication operations

import '../../domain/entities/user.dart';
import '../../errors/failures.dart';
import '../../utils/result.dart';
import '../../storage/auth_local_datasource.dart';

/// Authentication result containing user and token
class AuthResult {
  final User user;
  final String token;
  final InvitationResult? invitationResult;

  const AuthResult({
    required this.user,
    required this.token,
    this.invitationResult,
  });
}

/// Result of invitation processing during magic link verification
class InvitationResult {
  final bool processed;
  final String? invitationType;
  final String? redirectUrl;
  final bool? requiresFamilyOnboarding;
  final String? reason;

  const InvitationResult({
    required this.processed,
    this.invitationType,
    this.redirectUrl,
    this.requiresFamilyOnboarding,
    this.reason,
  });
}

/// Authentication service interface providing secure authentication methods
/// This belongs in the domain layer as it defines business rules for authentication
abstract class AuthService {
  Future<Result<void, Failure>> sendMagicLink(
    String email, {
    String? name,
    String? inviteCode,
  });
  Future<Result<AuthResult, Failure>> authenticateWithMagicLink(
    String token, {
    String? inviteCode,
  });

  /// Authenticate user with already verified magic link data (prevents double API call)
  Future<Result<AuthResult, Failure>> authenticateWithVerifiedData({
    required String token,
    required String refreshToken,
    required int expiresIn,
    required Map<String, dynamic> userData,
  });
  Future<Result<User, Failure>> getCurrentUser({
    bool forceRefresh = false,
    Map<String, dynamic>? userData,
  });
  // Refresh token removed - single token architecture
  Future<Result<User, Failure>> enableBiometricAuth();
  Future<Result<User, Failure>> disableBiometricAuth();
  Future<Result<User, Failure>> updateUserTimezone(String timezone);
  Future<Result<void, Failure>> logout();

  // Additional methods needed by magic_link_service
  Future<Result<void, Failure>> storeToken(String token);
  Future<Result<void, Failure>> updateCurrentUser(User user);

  /// Authenticate user with biometric verification
  Future<Result<AuthResult, Failure>> authenticateWithBiometrics(String email);
  User? get currentUser;

  // Additional methods needed by tests and full auth functionality
  Future<Result<AuthUserProfile?, Failure>> getUserProfile();
  Future<Result<void, Failure>> saveAuthState(AuthState state);
  Future<Result<AuthState?, Failure>> getAuthState();
  Future<Result<bool, Failure>> isAuthenticated();
  Future<Result<void, Failure>> clearSession();
  Future<Result<void, Failure>> cleanupExpiredTokens();
  Future<Result<bool, Failure>> isStorageHealthy();
  Future<Result<void, Failure>> clearUserData();
}

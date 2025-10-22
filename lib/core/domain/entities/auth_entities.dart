// EduLift Mobile - Auth Entities (Consolidated Domain Layer)
// Consolidated auth-related entities from magic_link_entities.dart and deep_link_service.dart

/// Magic link request context data (Domain Entity)
class MagicLinkContext {
  final String? name;
  final String? inviteCode;
  final String userAgent;
  final String timestamp;
  final Map<String, dynamic>? additionalData;

  const MagicLinkContext({
    this.name,
    this.inviteCode,
    required this.userAgent,
    required this.timestamp,
    this.additionalData,
  });
}

/// Magic link verification result (Domain Entity)
class MagicLinkVerificationResult {
  final String token; // Access token (JWT) from backend
  final String refreshToken; // PHASE 2: Refresh token for token renewal
  final int expiresIn; // PHASE 2: Expiration time in seconds
  final Map<String, dynamic> user;
  final DateTime expiresAt;
  final Map<String, dynamic>? invitationResult; // Full invitation result object
  final bool isNewUser;

  const MagicLinkVerificationResult({
    required this.token,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
    required this.expiresAt,
    this.invitationResult,
    this.isNewUser = false,
  });

  // Helper getters for invitation details
  bool get hasInvitation => invitationResult != null;
  bool get invitationProcessed => invitationResult?['processed'] == true;
  String? get invitationType => invitationResult?['invitationType'];
  String? get familyId => invitationResult?['familyId'];
  String? get redirectUrl => invitationResult?['redirectUrl'];
  bool get requiresFamilyOnboarding =>
      invitationResult?['requiresFamilyOnboarding'] == true;
  String? get invitationError => invitationResult?['reason'];

  // Enhanced getters for complex invitation scenarios
  bool get hasInvitationError => invitationResult?['processed'] == false;
  bool get hasCurrentFamily => invitationResult?['userCurrentFamily'] != null;
  bool get canLeaveCurrentFamily =>
      invitationResult?['canLeaveCurrentFamily'] == true;
  String? get currentFamilyName =>
      invitationResult?['userCurrentFamily']?['name'];
  String? get currentUserRole =>
      invitationResult?['userCurrentFamily']?['userRole'];
  String? get cannotLeaveReason => invitationResult?['cannotLeaveReason'];
}

/// Deep link result structure with enhanced path and validation support
class DeepLinkResult {
  final String? inviteCode;
  final String? magicToken;
  final String? email;
  final String? path; // Router path for navigation
  final Map<String, String> parameters;

  const DeepLinkResult({
    this.inviteCode,
    this.magicToken,
    this.email,
    this.path, // Optional parameter - backward compatible
    this.parameters = const {},
  });

  // =================== ORIGINAL GETTERS (Backward Compatible) ===================
  bool get hasInvitation => inviteCode != null;
  bool get hasMagicLink => magicToken != null;
  bool get isEmpty => inviteCode == null && magicToken == null;

  // =================== PATH SUPPORT ===================
  bool get hasPath => path != null && path!.isNotEmpty;
  bool get isEmptyPath => path == null || path!.isEmpty;
  String get routerPath => hasPath ? '/$path' : '/dashboard';

  // =================== ROUTE TYPE DETECTION ===================
  bool get isAuthVerifyPath => path == 'auth/verify';
  bool get isGroupJoinPath => path == 'groups/join';
  bool get isFamilyJoinPath => path == 'families/join';
  bool get isDashboardPath => path == 'dashboard' || path == null || path == '';
  bool get isCustomPath =>
      hasPath &&
      !isAuthVerifyPath &&
      !isGroupJoinPath &&
      !isFamilyJoinPath &&
      !isDashboardPath;

  // =================== AUTHENTICATION & AUTHORIZATION ===================
  bool get requiresAuthentication =>
      isGroupJoinPath || isFamilyJoinPath || isDashboardPath;
  bool get requiresFamily => isGroupJoinPath;
  bool get preservesInviteContext =>
      isAuthVerifyPath || isGroupJoinPath || isFamilyJoinPath;

  // =================== PARAMETER EXTRACTION ===================
  String? get extractedToken => parameters['token'] ?? magicToken;
  String? get extractedInviteCode =>
      parameters['code'] ?? parameters['inviteCode'] ?? inviteCode;
  String? get extractedEmail => parameters['email'] ?? email;

  // =================== VALIDATION ===================
  bool get hasValidToken =>
      extractedToken != null && extractedToken!.isNotEmpty;
  bool get hasValidInviteCode =>
      extractedInviteCode != null && extractedInviteCode!.isNotEmpty;
  bool get hasValidEmail => decodedEmail != null && decodedEmail!.contains('@');
  bool get canProceedWithAuth => isAuthVerifyPath && hasValidToken;
  bool get canProceedWithInvite =>
      (isGroupJoinPath || isFamilyJoinPath) && hasValidInviteCode;
  bool get isValid =>
      hasPath && (hasValidToken || hasValidInviteCode || isDashboardPath);

  // =================== URL DECODING ===================
  String? get decodedEmail =>
      extractedEmail != null ? Uri.decodeComponent(extractedEmail!) : null;
  String? get decodedToken =>
      extractedToken != null ? Uri.decodeComponent(extractedToken!) : null;

  // =================== EQUALITY & HASH CODE ===================
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeepLinkResult &&
          runtimeType == other.runtimeType &&
          inviteCode == other.inviteCode &&
          magicToken == other.magicToken &&
          email == other.email &&
          path == other.path &&
          _mapEquals(parameters, other.parameters);

  @override
  int get hashCode =>
      inviteCode.hashCode ^
      magicToken.hashCode ^
      email.hashCode ^
      path.hashCode ^
      parameters.hashCode;

  bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

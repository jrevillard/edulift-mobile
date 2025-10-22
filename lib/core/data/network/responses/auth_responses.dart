// EduLift Mobile - Authentication Response Models
// Matches backend /api/auth/* endpoints

/// Authentication response model
class AuthResponse {
  final String token;
  final int? expiresIn;
  final String? tokenType;
  final UserInfo? user;

  const AuthResponse({
    required this.token,
    this.expiresIn,
    this.tokenType = 'Bearer',
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      expiresIn: json['expiresIn'] as int?,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      user: json['user'] != null
          ? UserInfo.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expiresIn': expiresIn,
      'tokenType': tokenType,
      'user': user?.toJson(),
    };
  }
}

/// User information in auth response
class UserInfo {
  final String id;
  final String email;
  final String? name;
  final Map<String, dynamic>? metadata;

  const UserInfo({
    required this.id,
    required this.email,
    this.name,
    this.metadata,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name, 'metadata': metadata};
  }
}

/// Legacy magic link response model (kept for future API alignment)
/// This represents the ideal response structure for future backend updates
class MagicLinkResponse {
  final bool success;
  final String message;
  final String? linkId;
  final int? expiresIn;

  const MagicLinkResponse({
    required this.success,
    required this.message,
    this.linkId,
    this.expiresIn,
  });

  factory MagicLinkResponse.fromJson(Map<String, dynamic> json) {
    return MagicLinkResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      linkId: json['linkId'] as String?,
      expiresIn: json['expiresIn'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'linkId': linkId,
      'expiresIn': expiresIn,
    };
  }
}

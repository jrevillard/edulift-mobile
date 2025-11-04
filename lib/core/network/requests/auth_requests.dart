// EduLift Mobile - Authentication Request Models
// Matches backend /api/auth/* endpoints

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_requests.g.dart';

/// Login request model
class LoginRequest extends Equatable {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(email: json['email'], password: json['password']);
  }

  Map<String, dynamic> toJson() => {'email': email, 'password': password};

  @override
  List<Object?> get props => [email, password];
}

/// Magic link request model
@JsonSerializable(includeIfNull: false)
class MagicLinkRequest extends Equatable {
  final String email;
  final String? name;
  final String? inviteCode;

  @JsonKey(name: 'code_challenge')
  final String codeChallenge; // PKCE: SHA256 hash of code_verifier

  const MagicLinkRequest({
    required this.email,
    this.name,
    this.inviteCode,
    required this.codeChallenge,
  });

  factory MagicLinkRequest.fromJson(Map<String, dynamic> json) =>
      _$MagicLinkRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MagicLinkRequestToJson(this);

  @override
  List<Object?> get props => [email, name, inviteCode, codeChallenge];
}

/// Verify magic link request model
class VerifyMagicLinkRequest extends Equatable {
  final String token;

  const VerifyMagicLinkRequest({required this.token});

  factory VerifyMagicLinkRequest.fromJson(Map<String, dynamic> json) {
    return VerifyMagicLinkRequest(token: json['token']);
  }

  Map<String, dynamic> toJson() => {'token': token};

  @override
  List<Object?> get props => [token];
}

// Refresh token removed - using single token architecture

/// Verify token request model (alias for VerifyMagicLinkRequest)
@JsonSerializable(includeIfNull: false)
class VerifyTokenRequest extends Equatable {
  final String token;
  @JsonKey(name: 'code_verifier')
  final String? codeVerifier;
  @JsonKey(name: 'original_email')
  final String? originalEmail;

  const VerifyTokenRequest({
    required this.token,
    this.codeVerifier,
    this.originalEmail,
  });

  factory VerifyTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyTokenRequestToJson(this);

  @override
  List<Object?> get props => [token, codeVerifier, originalEmail];
}

/// Refresh token request model
@JsonSerializable(includeIfNull: false)
class RefreshTokenRequest extends Equatable {
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  const RefreshTokenRequest({required this.refreshToken});

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);

  @override
  List<Object?> get props => [refreshToken];
}

/// Update profile request model
class UpdateProfileRequest extends Equatable {
  final String? name;
  final String? email;
  final String? timezone;

  const UpdateProfileRequest({this.name, this.email, this.timezone});

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) {
    return UpdateProfileRequest(
      name: json['name'],
      email: json['email'],
      timezone: json['timezone'],
    );
  }

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (email != null) 'email': email,
    if (timezone != null) 'timezone': timezone,
  };

  @override
  List<Object?> get props => [name, email, timezone];
}

/// Create user profile request model
class CreateUserProfileRequest extends Equatable {
  final String name;
  final String email;

  const CreateUserProfileRequest({required this.name, required this.email});

  factory CreateUserProfileRequest.fromJson(Map<String, dynamic> json) {
    return CreateUserProfileRequest(name: json['name'], email: json['email']);
  }

  Map<String, dynamic> toJson() => {'name': name, 'email': email};

  @override
  List<Object?> get props => [name, email];
}

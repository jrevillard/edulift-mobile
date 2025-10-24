// EduLift Mobile - PKCE (Proof Key for Code Exchange) Utilities
// Using standard Dart crypto library for RFC 7636 compliance

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// PKCE utilities using the standard Dart crypto library
/// Following RFC 7636 specification for OAuth 2.0 PKCE
class PKCEUtils {
  static const int _codeVerifierLength = 128;
  static const String _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  /// Generate a cryptographically secure code_verifier using standard crypto
  static String generateCodeVerifier() {
    final random = Random.secure();
    final codeVerifier = String.fromCharCodes(
      List.generate(
        _codeVerifierLength,
        (index) => _chars.codeUnitAt(random.nextInt(_chars.length)),
      ),
    );
    return codeVerifier;
  }

  /// Generate code_challenge from code_verifier using standard crypto SHA256
  /// Per RFC 7636: code_challenge = BASE64URL-ENCODE(SHA256(ASCII(code_verifier)))
  static String generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    final base64String = base64.encode(digest.bytes);

    // Convert to base64url (no padding, URL-safe)
    return base64String
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');
  }

  /// Generate a complete PKCE pair using standard crypto
  static Map<String, String> generatePKCEPair() {
    final codeVerifier = generateCodeVerifier();
    final codeChallenge = generateCodeChallenge(codeVerifier);

    return {'code_verifier': codeVerifier, 'code_challenge': codeChallenge};
  }
}

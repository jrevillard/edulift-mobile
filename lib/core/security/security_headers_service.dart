import 'dart:convert';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../services/adaptive_storage_service.dart';

/// Security headers service implementing state-of-the-art HTTP security
/// Provides OWASP-compliant security headers and request signing

class SecurityHeadersService {
  final AdaptiveStorageService _secureStorage;
  SecurityHeadersService(this._secureStorage);

  static const String _nonceKey = 'request_nonce';
  static const String _sessionIdKey = 'session_id';
  static const String _csrfTokenKey = 'csrf_token';

  /// Generate security headers for API requests
  Future<Map<String, String>> generateSecurityHeaders({
    String? customNonce,
    bool includeCSRF = true,
    bool includeIntegrity = true,
  }) async {
    final headers = <String, String>{};

    // Content Security Policy
    headers['Content-Security-Policy'] = _generateCSP();

    // X-Frame-Options
    headers['X-Frame-Options'] = 'DENY';

    // X-Content-Type-Options
    headers['X-Content-Type-Options'] = 'nosniff';

    // X-XSS-Protection
    headers['X-XSS-Protection'] = '1; mode=block';

    // Referrer Policy
    headers['Referrer-Policy'] = 'strict-origin-when-cross-origin';

    // Permissions Policy
    headers['Permissions-Policy'] = _generatePermissionsPolicy();

    // Strict Transport Security (for HTTPS)
    headers['Strict-Transport-Security'] =
        'max-age=31536000; includeSubDomains; preload';

    // X-Requested-With
    headers['X-Requested-With'] = 'XMLHttpRequest';

    // Request ID for tracing
    headers['X-Request-ID'] = _generateRequestId();

    // Nonce for request validation
    final nonce = customNonce ?? await _generateNonce();
    headers['X-Request-Nonce'] = nonce;

    // Timestamp for request freshness
    headers['X-Request-Timestamp'] = DateTime.now().millisecondsSinceEpoch
        .toString();

    // CSRF Token
    if (includeCSRF) {
      final csrfToken = await _getOrGenerateCSRFToken();
      headers['X-CSRF-Token'] = csrfToken;
    }

    // API Version
    headers['X-API-Version'] = '1.0';

    // Client Information
    headers['X-Client-Type'] = 'mobile';
    headers['X-Client-Version'] = '2.0.0';
    headers['X-Client-Platform'] = defaultTargetPlatform.name;

    // Security Level
    headers['X-Security-Level'] = kDebugMode ? 'development' : 'production';

    // Request Integrity (if requested)
    if (includeIntegrity) {
      headers['X-Request-Integrity'] = await _generateRequestIntegrity(headers);
    }

    return headers;
  }

  /// Generate Content Security Policy
  String _generateCSP() {
    final policies = [
      "default-src 'self'",
      "script-src 'self' 'unsafe-inline'", // Needed for Flutter web
      "style-src 'self' 'unsafe-inline'", // Needed for Flutter web
      "img-src 'self' data: https:",
      "font-src 'self' data:",
      "connect-src 'self' https://api.edulift.com wss://ws.edulift.com",
      "frame-ancestors 'none'",
      "base-uri 'self'",
      "form-action 'self'",
      'upgrade-insecure-requests',
    ];

    return policies.join('; ');
  }

  /// Generate Permissions Policy
  String _generatePermissionsPolicy() {
    final policies = [
      'camera=()',
      'microphone=()',
      'geolocation=(self)',
      'payment=()',
      'fullscreen=(self)',
      'accelerometer=()',
      'gyroscope=()',
      'magnetometer=()',
      'usb=()',
      'sync-xhr=()',
    ];

    return policies.join(', ');
  }

  /// Generate unique request ID
  String _generateRequestId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'req_${timestamp}_$random';
  }

  /// Generate or retrieve nonce
  Future<String> _generateNonce() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    final nonce = 'nonce_${timestamp}_$random';

    await _secureStorage.storeEncryptedData(
      _nonceKey,
      jsonEncode({'nonce': nonce, 'timestamp': timestamp}),
    );

    return nonce;
  }

  /// Get or generate CSRF token
  Future<String> _getOrGenerateCSRFToken() async {
    try {
      final stored = await _secureStorage.getEncryptedData(_csrfTokenKey);
      if (stored != null) {
        final data = jsonDecode(stored);
        final timestamp = data['timestamp'] as int?;
        final token = data['token'] as String?;

        // Check if token is still valid (24 hours)
        if (timestamp != null && token != null) {
          final tokenAge = DateTime.now().millisecondsSinceEpoch - timestamp;
          if (tokenAge < 24 * 60 * 60 * 1000) {
            return token;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Error retrieving CSRF token: $e',
          name: 'SecurityHeaders',
        );
      }
    }

    // Generate new token
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999999);
    final token = 'csrf_${timestamp}_$random';

    await _secureStorage.storeEncryptedData(
      _csrfTokenKey,
      jsonEncode({'token': token, 'timestamp': timestamp}),
    );

    return token;
  }

  /// Generate request integrity hash
  Future<String> _generateRequestIntegrity(Map<String, String> headers) async {
    try {
      // Create a canonical representation of headers
      final sortedHeaders = Map.fromEntries(
        headers.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );

      final headerString = sortedHeaders.entries
          .map((e) => '${e.key}:${e.value}')
          .join('|');

      // Generate HMAC-SHA256 hash
      final key = await _getIntegrityKey();
      final hmac = Hmac(sha256, utf8.encode(key));
      final digest = hmac.convert(utf8.encode(headerString));

      return base64Encode(digest.bytes);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Error generating request integrity: $e',
          name: 'SecurityHeaders',
        );
      }
      return '';
    }
  }

  /// Get or generate integrity key
  Future<String> _getIntegrityKey() async {
    const keyName = 'integrity_key';
    try {
      final stored = await _secureStorage.getEncryptedData(keyName);
      if (stored != null) {
        final data = jsonDecode(stored);
        if (data['key'] != null) {
          return data['key'];
        }
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Error retrieving integrity key: $e',
          name: 'SecurityHeaders',
        );
      }
    }

    // Generate new key
    final random = Random.secure();
    final keyBytes = List.generate(32, (index) => random.nextInt(256));
    final key = base64Encode(keyBytes);

    await _secureStorage.storeEncryptedData(
      keyName,
      jsonEncode({'key': key, 'generated': DateTime.now().toIso8601String()}),
    );

    return key;
  }

  /// Validate incoming response headers
  static bool validateResponseHeaders(Map<String, String> headers) {
    final requiredHeaders = [
      'x-content-type-options',
      'x-frame-options',
      'strict-transport-security',
    ];

    for (final header in requiredHeaders) {
      if (!headers.containsKey(header.toLowerCase())) {
        if (kDebugMode) {
          developer.log(
            'Missing required security header: $header',
            name: 'SecurityHeaders',
          );
        }
        return false;
      }
    }

    // Validate Strict-Transport-Security
    final hsts = headers['strict-transport-security']?.toLowerCase();
    if (hsts != null && !hsts.contains('max-age=')) {
      if (kDebugMode) {
        developer.log('Invalid HSTS header', name: 'SecurityHeaders');
      }
      return false;
    }

    // Validate X-Content-Type-Options
    final contentTypeOptions = headers['x-content-type-options']?.toLowerCase();
    if (contentTypeOptions != 'nosniff') {
      if (kDebugMode) {
        developer.log(
          'Invalid X-Content-Type-Options header',
          name: 'SecurityHeaders',
        );
      }
      return false;
    }

    return true;
  }

  /// Generate secure session ID
  Future<String> generateSessionId() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure();
    final randomBytes = List.generate(16, (index) => random.nextInt(256));
    final sessionData = '$timestamp:${base64Encode(randomBytes)}';

    final hash = sha256.convert(utf8.encode(sessionData));
    final sessionId = base64Encode(hash.bytes);

    await _secureStorage.storeEncryptedData(
      _sessionIdKey,
      jsonEncode({'sessionId': sessionId, 'created': timestamp}),
    );

    return sessionId;
  }

  /// Get current session ID
  Future<String?> getCurrentSessionId() async {
    try {
      final stored = await _secureStorage.getEncryptedData(_sessionIdKey);
      if (stored != null) {
        final data = jsonDecode(stored);
        final created = data['created'] as int?;
        final sessionId = data['sessionId'] as String?;

        // Check if session is still valid (8 hours)
        if (created != null && sessionId != null) {
          final sessionAge = DateTime.now().millisecondsSinceEpoch - created;
          if (sessionAge < 8 * 60 * 60 * 1000) {
            return sessionId;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Error retrieving session ID: $e',
          name: 'SecurityHeaders',
        );
      }
    }

    return null;
  }

  /// Clear security tokens
  Future<void> clearSecurityTokens() async {
    try {
      await Future.wait([
        _secureStorage.storeEncryptedData(_nonceKey, jsonEncode({})),
        _secureStorage.storeEncryptedData(_csrfTokenKey, jsonEncode({})),
        _secureStorage.storeEncryptedData(_sessionIdKey, jsonEncode({})),
      ]);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Error clearing security tokens: $e',
          name: 'SecurityHeaders',
        );
      }
    }
  }

  /// Generate API signature for request authentication
  Future<String> generateApiSignature({
    required String method,
    required String path,
    required String timestamp,
    String? body,
  }) async {
    try {
      // Create signature payload
      final payload = [
        method.toUpperCase(),
        path,
        timestamp,
        body ?? '',
      ].join('\n');

      // Get signing key
      final signingKey = await _getSigningKey();

      // Generate HMAC-SHA256 signature
      final hmac = Hmac(sha256, utf8.encode(signingKey));
      final digest = hmac.convert(utf8.encode(payload));

      return base64Encode(digest.bytes);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Error generating API signature: $e',
          name: 'SecurityHeaders',
        );
      }
      return '';
    }
  }

  /// Get or generate signing key
  Future<String> _getSigningKey() async {
    const keyName = 'api_signing_key';
    try {
      final stored = await _secureStorage.getEncryptedData(keyName);
      if (stored != null) {
        final data = jsonDecode(stored);
        if (data['key'] != null) {
          return data['key'];
        }
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Error retrieving signing key: $e',
          name: 'SecurityHeaders',
        );
      }
    }

    // Generate new signing key
    final random = Random.secure();
    final keyBytes = List.generate(64, (index) => random.nextInt(256));
    final key = base64Encode(keyBytes);

    await _secureStorage.storeEncryptedData(
      keyName,
      jsonEncode({'key': key, 'generated': DateTime.now().toIso8601String()}),
    );

    return key;
  }

  /// Validate request timestamp to prevent replay attacks
  static bool validateRequestTimestamp(String timestamp) {
    try {
      final requestTime = int.parse(timestamp);
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final timeDiff = (currentTime - requestTime).abs();

      // Allow requests within 5 minutes
      return timeDiff < 5 * 60 * 1000;
    } catch (e) {
      return false;
    }
  }

  /// Generate rate limiting token
  static String generateRateLimitToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'rate_${timestamp}_$random';
  }
}

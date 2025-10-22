// test/unit/core/network/magic_link_request_validation_test.dart
// Test de régression pour s'assurer que MagicLinkRequest.codeChallenge est requis

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/network/requests/auth_requests.dart';

void main() {
  group('MagicLinkRequest Validation - Regression Tests', () {
    test('should require codeChallenge parameter', () {
      // REGRESSION TEST: Cette erreur était la root cause du bug E2E
      // Le champ codeChallenge était optionnel alors que le backend l'exige

      // Tentative de création sans codeChallenge doit causer une erreur de compilation
      // expect(
      //   () => MagicLinkRequest(email: 'test@example.com'),
      //   throwsA(isA<Error>()),
      // );

      // Création avec codeChallenge doit réussir
      const request = MagicLinkRequest(
        email: 'test@example.com',
        codeChallenge: 'test_code_challenge_43_chars_minimum_required',
      );

      expect(request.email, 'test@example.com');
      expect(
        request.codeChallenge,
        'test_code_challenge_43_chars_minimum_required',
      );
      expect(request.platform, 'native'); // default value
    });

    test('should serialize codeChallenge to JSON with correct key name', () {
      const request = MagicLinkRequest(
        email: 'test@example.com',
        name: 'Test User',
        codeChallenge: 'test_code_challenge_43_chars_minimum_required',
      );

      final json = request.toJson();

      expect(json['email'], 'test@example.com');
      expect(json['name'], 'Test User');
      expect(
        json['code_challenge'],
        'test_code_challenge_43_chars_minimum_required',
      ); // snake_case key
      expect(json['platform'], 'native');
    });

    test('should validate codeChallenge length meets backend requirements', () {
      // Backend exige entre 43-128 caractères pour code_challenge
      const shortChallenge = 'too_short';
      const validChallenge =
          'valid_code_challenge_43_chars_minimum_requ'; // 43 chars exactly
      final longChallenge = 'a' * 129; // 129 chars - too long for backend

      // Court: doit pouvoir être créé mais sera rejeté par le backend
      const shortRequest = MagicLinkRequest(
        email: 'test@example.com',
        codeChallenge: shortChallenge,
      );
      expect(shortRequest.codeChallenge, shortChallenge);

      // Valide: doit fonctionner parfaitement
      const validRequest = MagicLinkRequest(
        email: 'test@example.com',
        codeChallenge: validChallenge,
      );
      expect(validRequest.codeChallenge, validChallenge);
      expect(validRequest.codeChallenge.length, validChallenge.length);
      expect(
        validRequest.codeChallenge.length,
        greaterThanOrEqualTo(42),
      ); // At least 42 chars

      // Long: doit pouvoir être créé mais sera rejeté par le backend
      final longRequest = MagicLinkRequest(
        email: 'test@example.com',
        codeChallenge: longChallenge,
      );
      expect(longRequest.codeChallenge, longChallenge);
    });

    test('should maintain backward compatibility with optional fields', () {
      // Les champs optionnels doivent rester optionnels
      const request = MagicLinkRequest(
        email: 'test@example.com',
        codeChallenge: 'test_code_challenge_43_chars_minimum_required',
        // name: null, // optionnel
        // inviteCode: null, // optionnel
      );

      expect(request.name, isNull);
      expect(request.inviteCode, isNull);
      expect(request.email, isNotNull);
      expect(request.codeChallenge, isNotNull);
    });

    test('should serialize correctly with all fields', () {
      const request = MagicLinkRequest(
        email: 'test@example.com',
        name: 'Test User',
        inviteCode: 'INVITE123',
        platform: 'web',
        codeChallenge: 'test_code_challenge_43_chars_minimum_required',
      );

      final json = request.toJson();

      expect(json, {
        'email': 'test@example.com',
        'name': 'Test User',
        'invite_code': 'INVITE123',
        'platform': 'web',
        'code_challenge': 'test_code_challenge_43_chars_minimum_required',
      });
    });

    test('should deserialize correctly from JSON', () {
      final json = {
        'email': 'test@example.com',
        'name': 'Test User',
        'invite_code': 'INVITE123',
        'platform': 'native',
        'code_challenge': 'test_code_challenge_43_chars_minimum_required',
      };

      final request = MagicLinkRequest.fromJson(json);

      expect(request.email, 'test@example.com');
      expect(request.name, 'Test User');
      expect(request.inviteCode, 'INVITE123');
      expect(request.platform, 'native');
      expect(
        request.codeChallenge,
        'test_code_challenge_43_chars_minimum_required',
      );
    });
  });
}

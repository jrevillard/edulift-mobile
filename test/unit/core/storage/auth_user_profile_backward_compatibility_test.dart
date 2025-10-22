import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/storage/auth_local_datasource.dart';
import 'dart:convert';

void main() {
  group('AuthUserProfile backward compatibility', () {
    test('should parse old cached profile without timezone field', () {
      // Arrange - simulate old cached profile JSON without timezone
      final oldProfileJson = {
        'id': 'user-123',
        'email': 'test@example.com',
        'name': 'Test User',
        'familyId': 'family-456',
        'role': 'member',
        'lastUpdated': '2024-01-15T10:30:00.000Z',
        // NOTE: No 'timezone' field - simulates old cached data
      };

      // Act - parse the old profile
      final profile = AuthUserProfile.fromJson(oldProfileJson);

      // Assert - should successfully parse with timezone as null
      expect(profile.id, 'user-123');
      expect(profile.email, 'test@example.com');
      expect(profile.name, 'Test User');
      expect(profile.familyId, 'family-456');
      expect(profile.role, 'member');
      expect(profile.timezone, isNull); // Should be null for old profiles
    });

    test('should parse new cached profile with timezone field', () {
      // Arrange - new profile with timezone
      final newProfileJson = {
        'id': 'user-123',
        'email': 'test@example.com',
        'name': 'Test User',
        'familyId': 'family-456',
        'role': 'member',
        'lastUpdated': '2024-01-15T10:30:00.000Z',
        'timezone': 'America/New_York',
      };

      // Act
      final profile = AuthUserProfile.fromJson(newProfileJson);

      // Assert
      expect(profile.id, 'user-123');
      expect(profile.email, 'test@example.com');
      expect(profile.name, 'Test User');
      expect(profile.familyId, 'family-456');
      expect(profile.role, 'member');
      expect(profile.timezone, 'America/New_York');
    });

    test('should serialize profile with timezone to JSON', () {
      // Arrange
      final profile = AuthUserProfile(
        id: 'user-123',
        email: 'test@example.com',
        name: 'Test User',
        familyId: 'family-456',
        role: 'member',
        lastUpdated: DateTime.parse('2024-01-15T10:30:00.000Z'),
        timezone: 'Europe/Paris',
      );

      // Act
      final json = profile.toJson();

      // Assert
      expect(json['id'], 'user-123');
      expect(json['email'], 'test@example.com');
      expect(json['timezone'], 'Europe/Paris');
    });

    test('should serialize profile without timezone to JSON with null', () {
      // Arrange
      final profile = AuthUserProfile(
        id: 'user-123',
        email: 'test@example.com',
        name: 'Test User',
        familyId: 'family-456',
        role: 'member',
        lastUpdated: DateTime.parse('2024-01-15T10:30:00.000Z'),
        // timezone not provided - should be null
      );

      // Act
      final json = profile.toJson();

      // Assert
      expect(json['id'], 'user-123');
      expect(json['timezone'], isNull);
    });

    test('should round-trip old profile through JSON without losing data', () {
      // Arrange - simulate reading old profile from cache
      final oldCachedJson = jsonEncode({
        'id': 'user-123',
        'email': 'test@example.com',
        'name': 'Test User',
        'familyId': null,
        'role': 'member',
        'lastUpdated': '2024-01-15T10:30:00.000Z',
      });

      // Act - parse and re-serialize
      final parsed = AuthUserProfile.fromJson(
        jsonDecode(oldCachedJson) as Map<String, dynamic>,
      );
      final reserialized = jsonEncode(parsed.toJson());
      final reparsed = AuthUserProfile.fromJson(
        jsonDecode(reserialized) as Map<String, dynamic>,
      );

      // Assert - data should be preserved
      expect(reparsed.id, 'user-123');
      expect(reparsed.email, 'test@example.com');
      expect(reparsed.timezone, isNull); // timezone remains null
    });
  });
}

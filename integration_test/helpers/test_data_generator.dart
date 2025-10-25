// EduLift Mobile E2E - Test Data Generator
// Generates unique test data to ensure complete test isolation
// Each test gets its own unique namespace preventing data conflicts

import 'package:uuid/uuid.dart';

/// Generates unique test data to ensure test isolation
/// Each test gets its own unique namespace preventing conflicts
///
/// Usage:
/// ```dart
/// final email = TestDataGenerator.generateUniqueEmail();
/// final familyName = TestDataGenerator.generateUniqueFamilyName();
/// ```
class TestDataGenerator {
  static const _uuid = Uuid();
  static int _lastTimestamp = 0;

  /// Generate unique email with timestamp and UUID
  /// Format: test_<timestamp>_<uuid>@e2e.edulift.com
  ///
  /// Example: test_1704123456789_a1b2c3d4@e2e.edulift.com
  static String generateUniqueEmail() {
    var timestamp = DateTime.now().millisecondsSinceEpoch;

    // Ensure uniqueness by incrementing if same timestamp
    if (timestamp <= _lastTimestamp) {
      timestamp = _lastTimestamp + 1;
    }
    _lastTimestamp = timestamp;

    final uuid = _uuid.v4().substring(0, 8);
    return 'test_${timestamp}_${uuid}@e2e.edulift.com';
  }

  /// Generate unique email with prefix for test categorization
  /// Format: <prefix>_<timestamp>_<uuid>@e2e.edulift.com
  ///
  /// Example: auth_1704123456789_a1b2c3d4@e2e.edulift.com
  ///
  /// Recommended prefixes:
  /// - 'auth' for authentication tests
  /// - 'family' for family management tests
  /// - 'invite' for invitation tests
  /// - 'group' for group management tests
  static String generateEmailWithPrefix(String prefix) {
    var timestamp = DateTime.now().millisecondsSinceEpoch;

    // Ensure uniqueness by incrementing if same timestamp
    if (timestamp <= _lastTimestamp) {
      timestamp = _lastTimestamp + 1;
    }
    _lastTimestamp = timestamp;

    final uuid = _uuid.v4().substring(0, 8);
    return '${prefix}_${timestamp}_${uuid}@e2e.edulift.com';
  }

  /// Generate unique family name
  /// Format: Family_<timestamp>_<uuid>
  ///
  /// Example: Family_1704123456789_a1b2c3d4
  static String generateUniqueFamilyName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uuid = _uuid.v4().substring(0, 8);
    return 'Family_${timestamp}_${uuid}';
  }

  /// Generate unique child name
  /// Format: <Name> <UUID letters only>
  ///
  /// Example: Emma abcdefgh
  static String generateUniqueChildName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uuid = _uuid
        .v4()
        .replaceAll('-', '')
        .replaceAll(RegExp(r'[0-9]'), '')
        .toLowerCase(); // Force lowercase for consistency
    final names = [
      'Emma',
      'Liam',
      'Olivia',
      'Noah',
      'Ava',
      'Ethan',
      'Sophia',
      'Mason',
    ];
    final name = names[timestamp % names.length];
    return '$name ${uuid.substring(0, 8)}';
  }

  /// Generate unique vehicle name
  /// Format: <VehicleType> <Timestamp> <UUID>
  ///
  /// Example: Honda Civic 1704123456789 a1b2c3d4
  static String generateUniqueVehicleName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uuid = _uuid
        .v4()
        .substring(0, 8)
        .toLowerCase(); // Force lowercase for consistency
    final vehicles = [
      'Honda Civic',
      'Toyota Camry',
      'Ford Focus',
      'Nissan Sentra',
      'Hyundai Elantra',
      'Mazda 3',
    ];
    final vehicle = vehicles[timestamp % vehicles.length];
    return '$vehicle $timestamp $uuid';
  }

  /// Generate unique group name
  /// Format: Group_<timestamp>_<uuid>
  ///
  /// Example: Group_1704123456789_a1b2c3d4
  static String generateUniqueGroupName() {
    var timestamp = DateTime.now().millisecondsSinceEpoch;

    // Ensure uniqueness by incrementing if same timestamp
    if (timestamp <= _lastTimestamp) {
      timestamp = _lastTimestamp + 1;
    }
    _lastTimestamp = timestamp;

    final uuid = _uuid.v4().substring(0, 8);
    return 'Group_${timestamp}_${uuid}';
  }

  /// Generate unique name
  /// Format: Name_<timestamp>
  ///
  /// Example: Name_1704123456789
  static String generateUniqueName() {
    var timestamp = DateTime.now().millisecondsSinceEpoch;

    // Ensure uniqueness by incrementing if same timestamp
    if (timestamp <= _lastTimestamp) {
      timestamp = _lastTimestamp + 1;
    }
    _lastTimestamp = timestamp;

    return 'Name_${timestamp}';
  }

  /// Generate unique invitation code
  /// Format: INV_<timestamp>_<uuid_upper>
  ///
  /// Example: INV_1704123456789_A1B2C3D4
  static String generateUniqueInvitationCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uuid = _uuid.v4().substring(0, 8).toUpperCase();
    return 'INV_${timestamp}_${uuid}';
  }

  /// Generate unique phone number (for testing)
  /// Format: +1555<timestamp_last_7_digits>
  ///
  /// Example: +15551234567
  static String generateUniquePhoneNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final last7Digits = timestamp.toString().substring(
          timestamp.toString().length - 7,
        );
    return '+1555${last7Digits}';
  }

  /// Generate a set of unique data for a complete user profile
  ///
  /// Returns a map with all common user data fields
  static Map<String, String> generateUniqueUserProfile({String? prefix}) {
    final email = prefix != null
        ? generateEmailWithPrefix(prefix)
        : generateUniqueEmail();

    return {'email': email, 'name': generateUniqueName()};
  }

  /// Generate a set of unique data for a complete family
  ///
  /// Returns a map with family data including admin user profile
  static Map<String, dynamic> generateUniqueFamilyProfile({String? prefix}) {
    final adminProfile = generateUniqueUserProfile(prefix: prefix);

    return {
      'familyName': generateUniqueFamilyName(),
      'admin': adminProfile,
      'invitationCode': generateUniqueInvitationCode(),
    };
  }

  /// Generate debugging info for test data (useful for troubleshooting)
  ///
  /// Returns human-readable info about the generated data
  static String debugInfo(String data) {
    final now = DateTime.now();
    return '''
Generated test data: $data
Timestamp: ${now.toIso8601String()}
Milliseconds: ${now.millisecondsSinceEpoch}
''';
  }
}

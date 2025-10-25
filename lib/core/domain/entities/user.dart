// EduLift Mobile - User Domain Entity
// SPARC-Driven Development with Neural Coordination
// Agent: flutter-architect-lead

import 'package:equatable/equatable.dart';

// Sentinel value for copyWith nullable fields
const Object _noValue = Object();

/// User domain entity following Clean Architecture principles
/// Represents the authenticated user in the application domain
class User extends Equatable {
  /// Unique identifier for the user
  final String id;

  /// User's email address (used for authentication)
  final String email;

  /// Display name of the user
  final String name;

  /// User creation timestamp
  final DateTime createdAt;

  /// Last updated timestamp
  final DateTime updatedAt;

  /// User's preferred language (ISO 639-1 code)
  final String? preferredLanguage;

  /// User's timezone (IANA timezone identifier)
  final String? timezone;

  /// User's role in the global system (for future admin features)
  final UserRole role;

  /// Whether the user has completed onboarding
  final bool hasCompletedOnboarding;

  /// User's accessibility preferences
  final AccessibilityPreferences accessibilityPreferences;
  final bool isBiometricEnabled;

  // CLEAN ARCHITECTURE: familyId and familyRole moved to UserFamilyExtension
  // These fields are now provided by the family domain through extension methods

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.preferredLanguage,
    this.timezone,
    this.role = UserRole.user,
    this.hasCompletedOnboarding = false,
    this.accessibilityPreferences = const AccessibilityPreferences(),
    this.isBiometricEnabled = false,
  });

  /// Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? preferredLanguage = _noValue,
    Object? timezone = _noValue,
    UserRole? role,
    bool? hasCompletedOnboarding,
    AccessibilityPreferences? accessibilityPreferences,
    bool? isBiometricEnabled,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferredLanguage: preferredLanguage == _noValue
          ? this.preferredLanguage
          : preferredLanguage as String?,
      timezone: timezone == _noValue ? this.timezone : timezone as String?,
      role: role ?? this.role,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      accessibilityPreferences:
          accessibilityPreferences ?? this.accessibilityPreferences,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }

  /// Get user's initials for avatar display
  String get initials {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return '';

    final parts = trimmedName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';

    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }

  /// Check if user is an admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if user has completed setup
  bool get isSetupComplete => hasCompletedOnboarding;

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    createdAt,
    updatedAt,
    preferredLanguage,
    timezone,
    role,
    hasCompletedOnboarding,
    accessibilityPreferences,
    isBiometricEnabled,
  ];

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role)';
  }
}

/// User role enumeration for authorization
enum UserRole {
  /// Regular user with standard permissions
  user,

  /// Administrator with elevated permissions
  admin;

  /// Create UserRole from string value
  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'user':
      default:
        return UserRole.user;
    }
  }
}

/// Accessibility preferences for inclusive design
class AccessibilityPreferences extends Equatable {
  /// Enable high contrast mode
  final bool highContrast;

  /// Larger touch targets for motor impairment support
  final bool largeTouchTargets;

  /// Reduce motion for vestibular disorder support
  final bool reduceMotion;

  /// Text scaling factor (1.0 = default, up to 2.0)
  final double textScaleFactor;

  /// Enable voice navigation
  final bool voiceNavigation;

  /// Screen reader optimization
  final bool screenReaderOptimized;

  /// Haptic feedback preferences
  final HapticFeedbackLevel hapticFeedback;

  const AccessibilityPreferences({
    this.highContrast = false,
    this.largeTouchTargets = false,
    this.reduceMotion = false,
    this.textScaleFactor = 1.0,
    this.voiceNavigation = false,
    this.screenReaderOptimized = false,
    this.hapticFeedback = HapticFeedbackLevel.medium,
  });

  /// Create copy with updated preferences
  AccessibilityPreferences copyWith({
    bool? highContrast,
    bool? largeTouchTargets,
    bool? reduceMotion,
    double? textScaleFactor,
    bool? voiceNavigation,
    bool? screenReaderOptimized,
    HapticFeedbackLevel? hapticFeedback,
  }) {
    return AccessibilityPreferences(
      highContrast: highContrast ?? this.highContrast,
      largeTouchTargets: largeTouchTargets ?? this.largeTouchTargets,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      voiceNavigation: voiceNavigation ?? this.voiceNavigation,
      screenReaderOptimized:
          screenReaderOptimized ?? this.screenReaderOptimized,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    );
  }

  /// Check if any accessibility features are enabled
  bool get hasAccessibilityFeatures {
    return highContrast ||
        largeTouchTargets ||
        reduceMotion ||
        textScaleFactor > 1.0 ||
        voiceNavigation ||
        screenReaderOptimized ||
        hapticFeedback != HapticFeedbackLevel.medium;
  }

  @override
  List<Object?> get props => [
    highContrast,
    largeTouchTargets,
    reduceMotion,
    textScaleFactor,
    voiceNavigation,
    screenReaderOptimized,
    hapticFeedback,
  ];
}

/// Haptic feedback intensity levels
enum HapticFeedbackLevel {
  /// No haptic feedback
  none,

  /// Light haptic feedback
  light,

  /// Medium haptic feedback (default)
  medium,

  /// Strong haptic feedback
  strong;

  /// Create HapticFeedbackLevel from string value
  static HapticFeedbackLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'none':
        return HapticFeedbackLevel.none;
      case 'light':
        return HapticFeedbackLevel.light;
      case 'medium':
        return HapticFeedbackLevel.medium;
      case 'strong':
        return HapticFeedbackLevel.strong;
      default:
        return HapticFeedbackLevel.medium;
    }
  }
}

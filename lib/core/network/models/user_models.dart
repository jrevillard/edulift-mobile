// User-related API models for EduLift Mobile
// SPARC-Driven Development with Neural Coordination

/// User model for API responses
class UserModel {
  final String id;
  final String email;
  final String? name;
  final String timezone;
  final bool isBiometricEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.timezone = 'UTC',
    this.isBiometricEnabled = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      timezone: json['timezone'] as String? ?? 'UTC',
      isBiometricEnabled: json['isBiometricEnabled'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'timezone': timezone,
    'isBiometricEnabled': isBiometricEnabled,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

/// User status check response model
class UserStatusModel {
  final bool exists;
  final bool hasProfile;
  final bool requiresName;
  final String email;
  final UserModel? user;

  const UserStatusModel({
    required this.exists,
    required this.hasProfile,
    required this.requiresName,
    required this.email,
    this.user,
  });

  factory UserStatusModel.fromJson(Map<String, dynamic> json) {
    return UserStatusModel(
      exists: json['exists'] as bool,
      hasProfile: json['hasProfile'] as bool? ?? false,
      requiresName: json['requiresName'] as bool? ?? false,
      email: json['email'] as String,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isNewUser => !exists;
  bool get needsProfileSetup => !hasProfile || requiresName;
}

/// Response model for auth configuration
class AuthConfigResponse {
  final Map<String, dynamic> config;

  const AuthConfigResponse({required this.config});

  factory AuthConfigResponse.fromJson(Map<String, dynamic> json) {
    return AuthConfigResponse(config: json);
  }
}

/// Dashboard statistics model
class DashboardStatsModel {
  final int count;

  const DashboardStatsModel({required this.count});

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(count: json['count'] as int? ?? 0);
  }
}

/// Today's schedule model
class TodayScheduleModel {
  final String id;

  const TodayScheduleModel({required this.id});

  factory TodayScheduleModel.fromJson(Map<String, dynamic> json) {
    return TodayScheduleModel(id: json['id'] as String? ?? 'today');
  }
}

/// Weekly schedule model
class WeeklyScheduleModel {
  final String id;

  const WeeklyScheduleModel({required this.id});

  factory WeeklyScheduleModel.fromJson(Map<String, dynamic> json) {
    return WeeklyScheduleModel(id: json['id'] as String? ?? 'weekly');
  }
}

/// Activity model for recent activity
class ActivityModel {
  final String id;

  const ActivityModel({required this.id});

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(id: json['id'] as String);
  }
}

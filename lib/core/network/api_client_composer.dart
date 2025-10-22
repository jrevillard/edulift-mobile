// EduLift Mobile - API Client Composer
// SPARC-Driven Development with Neural Coordination
// Agent: FlutterSpecialist - Phase 2C API Client Decomposition

import 'auth_api_client.dart';
import 'family_api_client.dart';
import 'group_api_client.dart';
import 'schedule_api_client.dart';

/// Composer that provides unified access to all specialized API clients
/// Implements Interface Segregation and Dependency Inversion principles

class ApiClientComposer {
  final AuthApiClient authApiClient;
  final FamilyApiClient familyApiClient;
  final GroupApiClient groupApiClient;
  final ScheduleApiClient scheduleApiClient;

  const ApiClientComposer({
    required this.authApiClient,
    required this.familyApiClient,
    required this.groupApiClient,
    required this.scheduleApiClient,
  });

  /// Access to authentication and dashboard operations
  AuthApiClient get auth => authApiClient;

  /// Access to family, children, and vehicle operations
  FamilyApiClient get family => familyApiClient;

  /// Access to group and invitation operations
  GroupApiClient get group => groupApiClient;

  /// Access to schedule and assignment operations
  ScheduleApiClient get schedule => scheduleApiClient;
}

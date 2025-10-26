// EduLift Mobile - Family Remote Data Source Interface
// Clean Architecture data source abstraction

import 'package:edulift/core/domain/entities/family.dart';

/// Abstract interface for family remote data source
/// Defines all remote data operations without implementation details
abstract class FamilyRemoteDataSource {
  // ========================================
  // FAMILY OPERATIONS
  // ========================================

  /// Get current user's family from server
  Future<Family> getCurrentFamily();

  /// Create a new family on server
  Future<Family> createFamily({required String name});

  /// Update family name on server
  Future<Family> updateFamilyName({required String name});

  // ========================================
  // CHILDREN OPERATIONS
  // ========================================

  /// Get all family children from server
  Future<List<Child>> getFamilyChildren();

  /// Add new child to family on server
  Future<Child> addChild({required String name, int? age});

  // ========================================
  // VEHICLE OPERATIONS
  // ========================================

  /// Add new vehicle to family on server
  Future<Vehicle> addVehicle({
    required String name,
    required int capacity,
    String? description,
  });
}

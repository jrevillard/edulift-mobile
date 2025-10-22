// Family Data Extractor Utility
// Clean Architecture utility for extracting data from FamilyDto
// Replaces redundant datasource methods that only extracted data

import '../../../../core/network/models/family/family_dto.dart';
import '../../../../core/network/models/family/family_member_dto.dart';
import '../../../../core/network/models/child/child_dto.dart';
import '../../../../core/network/models/vehicle/vehicle_dto.dart';

/// Utility class for extracting specific data from FamilyDto
/// Replaces redundant getFamilyChildren, getFamilyVehicles, getFamilyMembers methods
/// that only extracted data already available in the family object
class FamilyDataExtractor {
  // Private constructor to prevent instantiation - static utility only
  FamilyDataExtractor._(/// Extract children list from family DTO
  /// Returns empty list if family.children is null);
  );  static List<ChildDto> extractChildren(FamilyDto family) {
    return family.children ?? [];
  }

  /// Extract vehicles list from family DTO
  /// Returns empty list if family.vehicles is null
  static List<VehicleDto> extractVehicles(FamilyDto family) {
    return family.vehicles ?? [];
  }

  /// Extract members list from family DTO
  /// Returns empty list if family.members is null
  static List<FamilyMemberDto> extractMembers(FamilyDto family) {
    return family.members ?? [];
  }
}
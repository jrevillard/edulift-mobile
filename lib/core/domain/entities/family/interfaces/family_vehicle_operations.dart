import '../vehicle.dart';

/// Interface for family vehicle operations following Interface Segregation Principle
/// Separates vehicle-related concerns from core family data
abstract class FamilyVehicleOperations {
  /// Get all family vehicles
  List<Vehicle> getVehicles();

  /// Get total number of vehicles
  int getTotalVehicles();

  /// Get vehicle by ID
  Vehicle? getVehicleById(String vehicleId);

  /// Check if family has any vehicles
  bool hasVehicles();

  /// Get vehicle names for display
  List<String> getVehicleNames();
}

/// Implementation of family vehicle operations
class FamilyVehicleOperationsImpl implements FamilyVehicleOperations {
  final List<Vehicle> _vehicles;

  const FamilyVehicleOperationsImpl(this._vehicles);

  @override
  List<Vehicle> getVehicles() => List.unmodifiable(_vehicles);

  @override
  int getTotalVehicles() => _vehicles.length;

  @override
  Vehicle? getVehicleById(String vehicleId) {
    try {
      return _vehicles.firstWhere((vehicle) => vehicle.id == vehicleId);
    } catch (_) {
      return null;
    }
  }

  @override
  bool hasVehicles() => _vehicles.isNotEmpty;

  @override
  List<String> getVehicleNames() {
    return _vehicles.map((vehicle) => vehicle.name).toList();
  }
}

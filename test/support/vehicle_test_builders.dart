// Vehicle Test Builders and Fixtures
// Comprehensive test data builders for Vehicle entity testing

import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';

/// Vehicle entity builder for tests
class VehicleTestBuilder {
  String _id = 'test-vehicle-123';
  String _name = 'Test Vehicle';
  String _familyId = 'test-family-123';
  int _capacity = 5;
  String? _description;
  DateTime? _createdAt;
  DateTime? _updatedAt;

  /// Set vehicle ID
  VehicleTestBuilder withId(String id) {
    _id = id;
    return this;
  }

  /// Set vehicle name
  VehicleTestBuilder withName(String name) {
    _name = name;
    return this;
  }

  /// Set family ID
  VehicleTestBuilder withFamilyId(String familyId) {
    _familyId = familyId;
    return this;
  }

  /// Set vehicle capacity
  VehicleTestBuilder withCapacity(int capacity) {
    _capacity = capacity;
    return this;
  }

  /// Set vehicle description
  VehicleTestBuilder withDescription(String? description) {
    _description = description;
    return this;
  }

  /// Set creation date
  VehicleTestBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  /// Set update date
  VehicleTestBuilder withUpdatedAt(DateTime updatedAt) {
    _updatedAt = updatedAt;
    return this;
  }

  /// Build small car for testing
  VehicleTestBuilder asSmallCar() {
    return withName(
      'Small Car',
    ).withCapacity(4).withDescription('Compact vehicle for small family');
  }

  /// Build large van for testing
  VehicleTestBuilder asLargeVan() {
    return withName(
      'Family Van',
    ).withCapacity(8).withDescription('Large van for extended family trips');
  }

  /// Build school bus for testing
  VehicleTestBuilder asSchoolBus() {
    return withName(
      'School Bus',
    ).withCapacity(25).withDescription('Bus for school transportation');
  }

  /// Build vehicle without description
  VehicleTestBuilder withoutDescription() {
    return withDescription(null);
  }

  /// Build vehicle with minimum capacity
  VehicleTestBuilder withMinimumCapacity() {
    return withCapacity(1);
  }

  /// Build vehicle with maximum capacity
  VehicleTestBuilder withMaximumCapacity() {
    return withCapacity(50);
  }

  /// Build vehicle with edge case name
  VehicleTestBuilder withEdgeCaseName() {
    return withName('A'); // Single character name
  }

  /// Build vehicle with long name
  VehicleTestBuilder withLongName() {
    return withName(
      'Very Long Vehicle Name That Exceeds Normal Length Expectations',
    );
  }

  /// Build vehicle with special characters in name
  VehicleTestBuilder withSpecialCharacters() {
    return withName(
      'Special-Vehicle_123 (Test)',
    ).withDescription('Vehicle with special chars: @#\$%^&*()');
  }

  /// Build vehicle for performance testing
  VehicleTestBuilder forPerformanceTesting(int index) {
    return withId('perf-vehicle-$index')
        .withName('Performance Vehicle $index')
        .withCapacity((index % 10) + 1) // Capacity between 1-10
        .withDescription('Performance test vehicle number $index');
  }

  /// Build the vehicle entity
  Vehicle build() {
    final now = DateTime.now();
    return Vehicle(
      id: _id,
      name: _name,
      familyId: _familyId,
      capacity: _capacity,
      description: _description,
      createdAt: _createdAt ?? now,
      updatedAt: _updatedAt ?? now,
    );
  }

  /// Reset builder to default values
  void reset() {
    _id = 'test-vehicle-123';
    _name = 'Test Vehicle';
    _familyId = 'test-family-123';
    _capacity = 5;
    _description = null;
    _createdAt = null;
    _updatedAt = null;
  }
}

/// Vehicle list builder for creating multiple vehicles
class VehicleListTestBuilder {
  final List<Vehicle> _vehicles = [];

  /// Add a vehicle to the list
  VehicleListTestBuilder addVehicle(Vehicle vehicle) {
    _vehicles.add(vehicle);
    return this;
  }

  /// Add a vehicle using builder
  VehicleListTestBuilder addVehicleFromBuilder(VehicleTestBuilder builder) {
    _vehicles.add(builder.build());
    return this;
  }

  /// Add multiple vehicles with different capacities
  VehicleListTestBuilder withVariedCapacities(String familyId) {
    _vehicles.addAll([
      VehicleTestBuilder()
          .withId('small-car')
          .withName('Small Car')
          .withFamilyId(familyId)
          .withCapacity(4)
          .build(),
      VehicleTestBuilder()
          .withId('suv')
          .withName('SUV')
          .withFamilyId(familyId)
          .withCapacity(7)
          .build(),
      VehicleTestBuilder()
          .withId('van')
          .withName('Van')
          .withFamilyId(familyId)
          .withCapacity(12)
          .build(),
    ]);
    return this;
  }

  /// Add vehicles for large family
  VehicleListTestBuilder forLargeFamily(String familyId) {
    for (var i = 1; i <= 5; i++) {
      _vehicles.add(
        VehicleTestBuilder()
            .withId('family-vehicle-$i')
            .withName('Family Vehicle $i')
            .withFamilyId(familyId)
            .withCapacity(5 + i)
            .withDescription('Vehicle #$i for large family')
            .build(),
      );
    }
    return this;
  }

  /// Add vehicles for performance testing
  VehicleListTestBuilder forPerformanceTesting(String familyId, int count) {
    for (var i = 0; i < count; i++) {
      _vehicles.add(
        VehicleTestBuilder()
            .forPerformanceTesting(i)
            .withFamilyId(familyId)
            .build(),
      );
    }
    return this;
  }

  /// Build the vehicle list
  List<Vehicle> build() {
    return List.from(_vehicles);
  }

  /// Get count of vehicles
  int get count => _vehicles.length;

  /// Clear all vehicles
  VehicleListTestBuilder clear() {
    _vehicles.clear();
    return this;
  }
}

/// Vehicle result builders for API responses
class VehicleResultBuilder {
  /// Build successful vehicle result
  static Result<Vehicle, ApiFailure> success(Vehicle vehicle) {
    return Result.ok(vehicle);
  }

  /// Build successful vehicle list result
  static Result<List<Vehicle>, ApiFailure> successList(List<Vehicle> vehicles) {
    return Result.ok(vehicles);
  }

  /// Build API failure result
  static Result<Vehicle, ApiFailure> failure({
    String message = 'Vehicle operation failed',
    int statusCode = 400,
    Map<String, dynamic>? details,
  }) {
    return Result.err(
      ApiFailure(
        message: message,
        statusCode: statusCode,
        details: details ?? {},
      ),
    );
  }

  /// Build vehicle list failure result
  static Result<List<Vehicle>, ApiFailure> listFailure({
    String message = 'Failed to load vehicles',
    int statusCode = 500,
    Map<String, dynamic>? details,
  }) {
    return Result.err(
      ApiFailure(
        message: message,
        statusCode: statusCode,
        details: details ?? {},
      ),
    );
  }

  /// Build validation failure for vehicle
  static Result<Vehicle, ApiFailure> validationFailure() {
    return const Result.err(
      ApiFailure(
        message: 'Vehicle validation failed',
        statusCode: 422,
        details: {
          'field_errors': {
            'name': ['Name is required'],
            'capacity': ['Capacity must be greater than 0'],
          },
        },
      ),
    );
  }

  /// Build network failure
  static Result<Vehicle, ApiFailure> networkFailure() {
    return const Result.err(
      ApiFailure(message: 'Network connection failed', statusCode: 0),
    );
  }

  /// Build not found failure
  static Result<Vehicle, ApiFailure> notFoundFailure() {
    return const Result.err(
      ApiFailure(message: 'Vehicle not found', statusCode: 404),
    );
  }

  /// Build unauthorized failure
  static Result<Vehicle, ApiFailure> unauthorizedFailure() {
    return const Result.err(
      ApiFailure(message: 'Unauthorized access to vehicle', statusCode: 401),
    );
  }
}

/// Vehicle test scenarios for comprehensive testing
class VehicleTestScenarios {
  /// Get typical family vehicles
  static List<Vehicle> typicalFamilyVehicles(String familyId) {
    return VehicleListTestBuilder().withVariedCapacities(familyId).build();
  }

  /// Get edge case vehicles for testing validation
  static List<Vehicle> edgeCaseVehicles(String familyId) {
    return [
      VehicleTestBuilder()
          .withEdgeCaseName()
          .withFamilyId(familyId)
          .withMinimumCapacity()
          .build(),
      VehicleTestBuilder()
          .withLongName()
          .withFamilyId(familyId)
          .withMaximumCapacity()
          .build(),
      VehicleTestBuilder()
          .withSpecialCharacters()
          .withFamilyId(familyId)
          .build(),
    ];
  }

  /// Get vehicles for UI update testing
  static VehicleUIUpdateTestData uiUpdateTestData(String familyId) {
    final initialVehicles = [
      VehicleTestBuilder()
          .withId('existing-1')
          .withName('Existing Vehicle 1')
          .withFamilyId(familyId)
          .withCapacity(5)
          .build(),
      VehicleTestBuilder()
          .withId('existing-2')
          .withName('Existing Vehicle 2')
          .withFamilyId(familyId)
          .withCapacity(7)
          .build(),
    ];

    final newVehicle = VehicleTestBuilder()
        .withId('new-vehicle')
        .withName('New Added Vehicle')
        .withFamilyId(familyId)
        .withCapacity(8)
        .withDescription('Newly added vehicle for testing')
        .build();

    return VehicleUIUpdateTestData(
      initialVehicles: initialVehicles,
      newVehicle: newVehicle,
      updatedVehiclesList: [...initialVehicles, newVehicle],
    );
  }
}

/// Data structure for UI update testing
class VehicleUIUpdateTestData {
  final List<Vehicle> initialVehicles;
  final Vehicle newVehicle;
  final List<Vehicle> updatedVehiclesList;

  const VehicleUIUpdateTestData({
    required this.initialVehicles,
    required this.newVehicle,
    required this.updatedVehiclesList,
  });
}

/// Convenience functions for quick vehicle test data creation
class VehicleTestBuilders {
  /// Quick vehicle builder
  static VehicleTestBuilder vehicle() => VehicleTestBuilder();

  /// Quick vehicle list builder
  static VehicleListTestBuilder vehicleList() => VehicleListTestBuilder();

  /// Quick small car
  static Vehicle smallCar([String? familyId]) => VehicleTestBuilder()
      .asSmallCar()
      .withFamilyId(familyId ?? 'test-family')
      .build();

  /// Quick large van
  static Vehicle largeVan([String? familyId]) => VehicleTestBuilder()
      .asLargeVan()
      .withFamilyId(familyId ?? 'test-family')
      .build();

  /// Quick school bus
  static Vehicle schoolBus([String? familyId]) => VehicleTestBuilder()
      .asSchoolBus()
      .withFamilyId(familyId ?? 'test-family')
      .build();

  /// Success result with vehicle
  static Result<Vehicle, ApiFailure> successResult(Vehicle vehicle) =>
      VehicleResultBuilder.success(vehicle);

  /// Success result with vehicle list
  static Result<List<Vehicle>, ApiFailure> successListResult(
    List<Vehicle> vehicles,
  ) => VehicleResultBuilder.successList(vehicles);

  /// Failure result
  static Result<Vehicle, ApiFailure> failureResult([String? message]) =>
      VehicleResultBuilder.failure(message: message ?? 'Test failure');
}

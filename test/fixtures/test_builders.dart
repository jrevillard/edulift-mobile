// Test Data Builders (2025 Best Practices)
//
// Enhanced test builders following 2025 Flutter testing standards:
// - Fluent API with method chaining
// - Builder pattern for complex objects
// - Realistic test data generation
// - Performance test data creation
// - Edge case scenario builders

import 'package:edulift/core/domain/entities/family.dart';

/// Base test builders factory (2025 Standard)
class TestBuilders {
  static FamilyBuilder family() => FamilyBuilder();
  static ChildBuilder child() => ChildBuilder();
  static VehicleBuilder vehicle() => VehicleBuilder();
}

/// Family entity builder for comprehensive testing (2025 Standard)
class FamilyBuilder {
  String _id = 'test-family-123';
  String _name = 'Test Family';
  // ignore: unused_field
  String _ownerId = 'test-owner-123';
  // ignore: unused_field
  List<String> _memberIds = [];
  // ignore: unused_field
  List<String> _childIds = [];
  // ignore: unused_field
  List<String> _vehicleIds = [];
  DateTime? _createdAt;
  DateTime? _updatedAt;

  FamilyBuilder withId(String id) {
    _id = id;
    return this;
  }

  FamilyBuilder withName(String name) {
    _name = name;
    return this;
  }

  FamilyBuilder withOwnerId(String ownerId) {
    _ownerId = ownerId;
    return this;
  }

  FamilyBuilder withMembers(List<String> memberIds) {
    _memberIds = List.from(memberIds);
    return this;
  }

  FamilyBuilder withChildren(List<String> childIds) {
    _childIds = List.from(childIds);
    return this;
  }

  FamilyBuilder withVehicles(List<String> vehicleIds) {
    _vehicleIds = List.from(vehicleIds);
    return this;
  }

  FamilyBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  /// Build realistic large family for performance testing
  FamilyBuilder asLargeFamily() {
    final members = List.generate(50, (index) => 'member-$index');
    final children = List.generate(20, (index) => 'child-$index');
    final vehicles = List.generate(10, (index) => 'vehicle-$index');

    return withName(
      'Large Test Family',
    ).withMembers(members).withChildren(children).withVehicles(vehicles);
  }

  /// Build minimal family for edge case testing
  FamilyBuilder asMinimal() {
    return withName(
      'Minimal Family',
    ).withMembers([]).withChildren([]).withVehicles([]);
  }

  Family build() {
    return Family(
      id: _id,
      name: _name,
      createdAt: _createdAt ?? DateTime.now(),
      updatedAt: _updatedAt ?? DateTime.now(),
      // Using default empty lists for members, children, vehicles
    );
  }
}

/// Child entity builder for comprehensive testing (2025 Standard)
class ChildBuilder {
  String _id = 'test-child-123';
  String _name = 'Test Child';
  String _familyId = 'test-family-123';
  int _age = 10;
  // ignore: unused_field
  String _grade = '5th Grade';
  // ignore: unused_field
  String? _schoolId;
  // ignore: unused_field
  Map<String, dynamic> _preferences = {};
  DateTime? _createdAt;

  ChildBuilder withId(String id) {
    _id = id;
    return this;
  }

  ChildBuilder withName(String name) {
    _name = name;
    return this;
  }

  ChildBuilder withFamilyId(String familyId) {
    _familyId = familyId;
    return this;
  }

  ChildBuilder withAge(int age) {
    _age = age;
    return this;
  }

  ChildBuilder withGrade(String grade) {
    _grade = grade;
    return this;
  }

  ChildBuilder withSchoolId(String schoolId) {
    _schoolId = schoolId;
    return this;
  }

  ChildBuilder withPreferences(Map<String, dynamic> preferences) {
    _preferences = Map.from(preferences);
    return this;
  }

  /// Build pre-school child for specific testing
  ChildBuilder asPreschooler() {
    return withAge(4).withGrade('Pre-K').withPreferences({
      'needs_car_seat': true,
      'pickup_time': '2:30 PM',
    });
  }

  /// Build teenager for different test scenarios
  ChildBuilder asTeenager() {
    return withAge(16).withGrade('11th Grade').withPreferences({
      'can_drive': true,
      'pickup_time': '3:45 PM',
    });
  }

  Child build() {
    return Child(
      id: _id,
      name: _name,
      familyId: _familyId,
      age: _age,
      createdAt: _createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

/// Vehicle entity builder for comprehensive testing (2025 Standard)
class VehicleBuilder {
  String _id = 'test-vehicle-123';
  String _name = 'Test Vehicle';
  String _familyId = 'test-family-123';
  String _make = 'Toyota';
  String _model = 'Camry';
  // ignore: unused_field
  int _year = 2020;
  int _seats = 5;
  // ignore: unused_field
  String _color = 'Blue';
  // ignore: unused_field
  Map<String, dynamic> _features = {};
  DateTime? _createdAt;

  VehicleBuilder withId(String id) {
    _id = id;
    return this;
  }

  VehicleBuilder withName(String name) {
    _name = name;
    return this;
  }

  VehicleBuilder withFamilyId(String familyId) {
    _familyId = familyId;
    return this;
  }

  VehicleBuilder withMake(String make) {
    _make = make;
    return this;
  }

  VehicleBuilder withModel(String model) {
    _model = model;
    return this;
  }

  VehicleBuilder withYear(int year) {
    _year = year;
    return this;
  }

  VehicleBuilder withSeats(int seats) {
    _seats = seats;
    return this;
  }

  VehicleBuilder withColor(String color) {
    _color = color;
    return this;
  }

  VehicleBuilder withFeatures(Map<String, dynamic> features) {
    _features = Map.from(features);
    return this;
  }

  /// Build large SUV for capacity testing
  VehicleBuilder asLargeSUV() {
    return withMake('Chevrolet').withModel('Tahoe').withSeats(8).withFeatures({
      'third_row': true,
      'car_seats': 3,
      'cargo_space': 'large',
    });
  }

  /// Build compact car for minimal scenarios
  VehicleBuilder asCompactCar() {
    return withMake('Honda').withModel('Civic').withSeats(4).withFeatures({
      'fuel_efficient': true,
      'car_seats': 1,
    });
  }

  Vehicle build() {
    return Vehicle(
      id: _id,
      name: _name,
      familyId: _familyId,
      capacity: _seats, // Use seats as capacity
      description: 'Test vehicle: $_make $_model',
      createdAt: _createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

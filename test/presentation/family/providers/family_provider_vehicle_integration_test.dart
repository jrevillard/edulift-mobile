// Unit test to verify vehicle functionality after architectural refactor
// Tests verify that vehicles have been successfully consolidated into FamilyProvider

import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/features/family/presentation/providers/family_provider.dart';
import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/core/domain/entities/family.dart' as entities;

void main() {
  group('FamilyProvider Vehicle Integration Tests', () {
    final mockVehicles = <Vehicle>[
      Vehicle(
        id: 'vehicle1',
        familyId: 'family1',
        name: 'Honda Civic',
        capacity: 4,
        description: 'Family car',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Vehicle(
        id: 'vehicle2',
        familyId: 'family1',
        name: 'Toyota Camry',
        capacity: 5,
        description: 'Main vehicle',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final mockFamily = entities.Family(
      id: 'family1',
      name: 'Test Family',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('FamilyState correctly manages vehicle data', () {
      // Test initial state
      const initialState = FamilyState();
      expect(initialState.vehicles, isEmpty);
      expect(initialState.hasVehicles, isFalse);
      expect(initialState.vehiclesCount, 0);
      expect(initialState.totalCapacity, 0);

      // Test state with vehicles
      final stateWithVehicles = initialState.copyWith(
        family: mockFamily,
        vehicles: mockVehicles,
      );

      expect(stateWithVehicles.vehicles, equals(mockVehicles));
      expect(stateWithVehicles.hasVehicles, isTrue);
      expect(stateWithVehicles.vehiclesCount, 2);
      expect(stateWithVehicles.totalCapacity, equals(9)); // 4 + 5
    });

    test('vehicle convenience getters work correctly', () {
      final state = const FamilyState().copyWith(
        family: mockFamily,
        vehicles: mockVehicles,
      );

      // Test sortedVehicles
      final sortedVehicles = state.sortedVehicles;
      expect(
        sortedVehicles.first.name,
        equals('Honda Civic'),
      ); // Alphabetical order
      expect(sortedVehicles.last.name, equals('Toyota Camry'));

      // Test availableVehicles (filters out temporary vehicles)
      final availableVehicles = state.availableVehicles;
      expect(
        availableVehicles,
        equals(mockVehicles),
      ); // Both vehicles should be available

      // Test getVehicle
      final vehicle1 = state.getVehicle('vehicle1');
      expect(vehicle1.name, equals('Honda Civic'));

      // NO FALLBACK: Vehicle not found should throw exception
      expect(() => state.getVehicle('fake_id'), throwsException);
    });

    test('vehicle loading states work correctly', () {
      const initialState = FamilyState();

      // Initially no loading states
      expect(initialState.isVehicleLoading('vehicle1'), isFalse);
      expect(initialState.vehicleLoading, isEmpty);

      // Set loading state
      final loadingState = initialState.copyWith(
        vehicleLoading: {'vehicle1': true},
      );

      expect(loadingState.isVehicleLoading('vehicle1'), isTrue);
      expect(loadingState.isVehicleLoading('vehicle2'), isFalse);

      // Clear loading state
      final clearedState = loadingState.copyWith(
        vehicleLoading: <String, bool>{},
      );

      expect(clearedState.isVehicleLoading('vehicle1'), isFalse);
    });

    test('copyWith handles all vehicle-related fields correctly', () {
      const initialState = FamilyState();

      final updatedState = initialState.copyWith(
        family: mockFamily,
        vehicles: mockVehicles,
        vehicleLoading: {'vehicle1': true},
        selectedVehicle: mockVehicles.first,
      );

      expect(updatedState.family, equals(mockFamily));
      expect(updatedState.vehicles, equals(mockVehicles));
      expect(updatedState.vehicleLoading, equals({'vehicle1': true}));
      expect(updatedState.selectedVehicle, equals(mockVehicles.first));

      // Verify original state unchanged
      expect(initialState.vehicles, isEmpty);
      expect(initialState.family, isNull);
    });

    test('familyVehiclesProvider convenience provider works', () {
      // This test verifies that the new convenience providers are properly structured
      // We can't easily test the providers without a container, but we can verify
      // that the state getters they rely on work correctly

      final state = const FamilyState().copyWith(vehicles: mockVehicles);

      // These are the same getters the convenience providers use
      expect(state.vehicles, equals(mockVehicles));
      expect(state.sortedVehicles.length, equals(2));
      expect(state.availableVehicles.length, equals(2));
      expect(state.vehiclesCount, equals(2));
      expect(state.totalCapacity, equals(9));
    });
  });
}

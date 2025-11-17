import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/features/schedule/presentation/models/displayable_time_slot.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/core/domain/entities/family/child_assignment.dart';

void main() {
  group('DisplayableTimeSlot', () {
    late ScheduleSlot mockScheduleSlot;
    late VehicleAssignment mockVehicleAssignment;

    setUp(() {
      mockVehicleAssignment = VehicleAssignment(
        id: 'va1',
        scheduleSlotId: 'slot1',
        vehicleId: 'vehicle1',
        assignedAt: DateTime.now(),
        assignedBy: 'user1',
        vehicleName: 'Test Vehicle',
        capacity: 4,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        childAssignments: [
          ChildAssignment.transportation(
            id: 'ca1',
            childId: 'child1',
            groupId: 'group1',
            scheduleSlotId: 'slot1',
            vehicleAssignmentId: 'va1',
            assignedAt: DateTime.now(),
            status: AssignmentStatus.confirmed,
            assignmentDate: DateTime.now(),
          ),
        ],
      );

      mockScheduleSlot = ScheduleSlot(
        id: 'slot1',
        groupId: 'group1',
        dayOfWeek: DayOfWeek.monday,
        timeOfDay: const TimeOfDayValue(8, 0),
        week: '2024-W15',
        vehicleAssignments: [mockVehicleAssignment],
        maxVehicles: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    group('constructor and basic properties', () {
      test('crée DisplayableTimeSlot avec données valides', () {
        // Arrange & Act
        final displayableSlot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: '2024-W15',
          scheduleSlot: mockScheduleSlot,
          existsInBackend: true,
        );

        // Assert
        expect(displayableSlot.dayOfWeek, equals(DayOfWeek.monday));
        expect(displayableSlot.timeOfDay.hour, equals(8));
        expect(displayableSlot.timeOfDay.minute, equals(0));
        expect(displayableSlot.week, equals('2024-W15'));
        expect(displayableSlot.scheduleSlot, equals(mockScheduleSlot));
        expect(displayableSlot.existsInBackend, isTrue);
      });

      test('crée DisplayableTimeSlot sans scheduleSlot', () {
        // Arrange & Act
        const displayableSlot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.tuesday,
          timeOfDay: TimeOfDayValue(15, 30),
          week: '2024-W15',
          existsInBackend: false,
        );

        // Assert
        expect(displayableSlot.dayOfWeek, equals(DayOfWeek.tuesday));
        expect(displayableSlot.timeOfDay.hour, equals(15));
        expect(displayableSlot.timeOfDay.minute, equals(30));
        expect(displayableSlot.week, equals('2024-W15'));
        expect(displayableSlot.scheduleSlot, isNull);
        expect(displayableSlot.existsInBackend, isFalse);
      });
    });

    group('hasVehicles getter', () {
      test('retourne true quand il y a des véhicules assignés', () {
        // Arrange & Act
        final displayableSlot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: '2024-W15',
          scheduleSlot: mockScheduleSlot,
          existsInBackend: true,
        );

        // Assert
        expect(displayableSlot.hasVehicles, isTrue);
      });

      test('retourne false quand il n\'y a pas de véhicules assignés', () {
        // Arrange
        final emptySlot = ScheduleSlot(
          id: 'slot2',
          groupId: 'group1',
          dayOfWeek: DayOfWeek.wednesday,
          timeOfDay: const TimeOfDayValue(10, 0),
          week: '2024-W15',
          vehicleAssignments: const [],
          maxVehicles: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final displayableSlot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.wednesday,
          timeOfDay: const TimeOfDayValue(10, 0),
          week: '2024-W15',
          scheduleSlot: emptySlot,
          existsInBackend: true,
        );

        // Assert
        expect(displayableSlot.hasVehicles, isFalse);
      });

      test('retourne false quand le scheduleSlot est null', () {
        // Arrange & Act
        const displayableSlot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.thursday,
          timeOfDay: TimeOfDayValue(14, 0),
          week: '2024-W15',
          existsInBackend: false,
        );

        // Assert
        expect(displayableSlot.hasVehicles, isFalse);
      });
    });

    group('vehicleCount getter', () {
      test('retourne le nombre correct de véhicules', () {
        // Arrange & Act
        final displayableSlot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: '2024-W15',
          scheduleSlot: mockScheduleSlot,
          existsInBackend: true,
        );

        // Assert
        expect(displayableSlot.vehicleCount, equals(1));
      });

      test('retourne 0 quand il n\'y a pas de véhicules', () {
        // Arrange
        final emptySlot = ScheduleSlot(
          id: 'slot3',
          groupId: 'group1',
          dayOfWeek: DayOfWeek.friday,
          timeOfDay: const TimeOfDayValue(16, 0),
          week: '2024-W15',
          vehicleAssignments: const [],
          maxVehicles: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final displayableSlot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.friday,
          timeOfDay: const TimeOfDayValue(16, 0),
          week: '2024-W15',
          scheduleSlot: emptySlot,
          existsInBackend: true,
        );

        // Assert
        expect(displayableSlot.vehicleCount, equals(0));
      });

      test('retourne 0 quand le scheduleSlot est null', () {
        // Arrange & Act
        const displayableSlot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.saturday,
          timeOfDay: TimeOfDayValue(9, 0),
          week: '2024-W15',
          existsInBackend: false,
        );

        // Assert
        expect(displayableSlot.vehicleCount, equals(0));
      });
    });

    group('canAddVehicle getter', () {
      test(
        'retourne true quand le slot n\'existe pas encore dans le backend',
        () {
          // Arrange & Act
          const displayableSlot = DisplayableTimeSlot(
            dayOfWeek: DayOfWeek.sunday,
            timeOfDay: TimeOfDayValue(11, 0),
            week: '2024-W15',
            existsInBackend: false,
          );

          // Assert
          expect(displayableSlot.canAddVehicle, isTrue);
        },
      );

      test('retourne true quand il y a de la capacité disponible', () {
        // Arrange & Act
        final displayableSlot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: '2024-W15',
          scheduleSlot: mockScheduleSlot, // 1 vehicle, max 3
          existsInBackend: true,
        );

        // Assert
        expect(displayableSlot.canAddVehicle, isTrue);
      });

      test('retourne false quand le slot est à pleine capacité', () {
        // Arrange
        final fullSlot = ScheduleSlot(
          id: 'slot4',
          groupId: 'group1',
          dayOfWeek: DayOfWeek.tuesday,
          timeOfDay: const TimeOfDayValue(12, 0),
          week: '2024-W15',
          vehicleAssignments: [
            VehicleAssignment(
              id: 'va1',
              scheduleSlotId: 'slot4',
              vehicleId: 'vehicle1',
              assignedAt: DateTime.now(),
              assignedBy: 'user1',
              vehicleName: 'Vehicle 1',
              capacity: 4,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            VehicleAssignment(
              id: 'va2',
              scheduleSlotId: 'slot4',
              vehicleId: 'vehicle2',
              assignedAt: DateTime.now(),
              assignedBy: 'user1',
              vehicleName: 'Vehicle 2',
              capacity: 4,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ],
          maxVehicles: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final displayableSlot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.tuesday,
          timeOfDay: const TimeOfDayValue(12, 0),
          week: '2024-W15',
          scheduleSlot: fullSlot,
          existsInBackend: true,
        );

        // Assert
        expect(displayableSlot.canAddVehicle, isFalse);
      });

      test('retourne false quand maxVehicles est 0', () {
        // Arrange
        final noCapacitySlot = ScheduleSlot(
          id: 'slot5',
          groupId: 'group1',
          dayOfWeek: DayOfWeek.wednesday,
          timeOfDay: const TimeOfDayValue(13, 0),
          week: '2024-W15',
          vehicleAssignments: const [],
          maxVehicles: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final displayableSlot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.wednesday,
          timeOfDay: const TimeOfDayValue(13, 0),
          week: '2024-W15',
          scheduleSlot: noCapacitySlot,
          existsInBackend: true,
        );

        // Assert
        expect(displayableSlot.canAddVehicle, isFalse);
      });
    });

    group('vehicleAssignments getter', () {
      test('retourne la liste des assignations de véhicules', () {
        // Arrange & Act
        final displayableSlot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: '2024-W15',
          scheduleSlot: mockScheduleSlot,
          existsInBackend: true,
        );

        // Assert
        expect(
          displayableSlot.vehicleAssignments,
          isA<List<VehicleAssignment>>(),
        );
        expect(displayableSlot.vehicleAssignments.length, equals(1));
        expect(
          displayableSlot.vehicleAssignments.first.vehicleId,
          equals('vehicle1'),
        );
      });

      test('retourne une liste vide quand il n\'y a pas de véhicules', () {
        // Arrange
        final emptySlot = ScheduleSlot(
          id: 'slot6',
          groupId: 'group1',
          dayOfWeek: DayOfWeek.thursday,
          timeOfDay: const TimeOfDayValue(15, 0),
          week: '2024-W15',
          vehicleAssignments: const [],
          maxVehicles: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final displayableSlot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.thursday,
          timeOfDay: const TimeOfDayValue(15, 0),
          week: '2024-W15',
          scheduleSlot: emptySlot,
          existsInBackend: true,
        );

        // Assert
        expect(displayableSlot.vehicleAssignments, isEmpty);
      });

      test('retourne une liste vide quand le scheduleSlot est null', () {
        // Arrange & Act
        const displayableSlot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.friday,
          timeOfDay: TimeOfDayValue(17, 0),
          week: '2024-W15',
          existsInBackend: false,
        );

        // Assert
        expect(displayableSlot.vehicleAssignments, isEmpty);
      });
    });

    group('compositeKey getter', () {
      test('génère une clé composite unique', () {
        // Arrange & Act
        final displayableSlot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: '2024-W15',
          scheduleSlot: mockScheduleSlot,
          existsInBackend: true,
        );

        // Assert
        expect(displayableSlot.compositeKey, equals('monday_08:00'));
      });

      test('génère des clés différentes pour des slots différents', () {
        // Arrange
        final slot1 = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: '2024-W15',
          scheduleSlot: mockScheduleSlot,
          existsInBackend: true,
        );

        const slot2 = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.tuesday,
          timeOfDay: TimeOfDayValue(8, 0),
          week: '2024-W15',
          existsInBackend: false,
        );

        const slot3 = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(15, 30),
          week: '2024-W15',
          existsInBackend: false,
        );

        // Act & Assert
        expect(slot1.compositeKey, equals('monday_08:00'));
        expect(slot2.compositeKey, equals('tuesday_08:00'));
        expect(slot3.compositeKey, equals('monday_15:30'));
        expect(slot1.compositeKey, isNot(equals(slot2.compositeKey)));
        expect(slot1.compositeKey, isNot(equals(slot3.compositeKey)));
        expect(slot2.compositeKey, isNot(equals(slot3.compositeKey)));
      });

      test('génère la même clé pour des slots identiques', () {
        // Arrange
        const slot1 = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.wednesday,
          timeOfDay: TimeOfDayValue(10, 15),
          week: '2024-W15',
          existsInBackend: false,
        );

        final slot2 = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.wednesday,
          timeOfDay: const TimeOfDayValue(10, 15),
          week: '2024-W16', // Différente semaine mais même jour/heure
          scheduleSlot: mockScheduleSlot,
          existsInBackend: true,
        );

        // Act & Assert
        expect(slot1.compositeKey, equals(slot2.compositeKey));
        expect(slot1.compositeKey, equals('wednesday_10:15'));
      });
    });

    group('Freezed functionality', () {
      test('sérialisation et désérialisation fonctionnent', () {
        // Arrange
        final original = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: '2024-W15',
          scheduleSlot: mockScheduleSlot,
          existsInBackend: true,
        );

        // Act & Assert
        expect(original, isA<DisplayableTimeSlot>());
        expect(original.dayOfWeek, equals(DayOfWeek.monday));
        expect(original.existsInBackend, isTrue);
      });

      test('égalité fonctionne correctement', () {
        // Arrange
        final slot1 = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: '2024-W15',
          scheduleSlot: mockScheduleSlot,
          existsInBackend: true,
        );

        final slot2 = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: '2024-W15',
          scheduleSlot: mockScheduleSlot,
          existsInBackend: true,
        );

        final slot3 = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.tuesday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: '2024-W15',
          scheduleSlot: mockScheduleSlot,
          existsInBackend: true,
        );

        // Act & Assert
        expect(slot1, equals(slot2));
        expect(slot1, isNot(equals(slot3)));
      });

      test('toString contient les informations pertinentes', () {
        // Arrange & Act
        final displayableSlot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: const TimeOfDayValue(8, 0),
          week: '2024-W15',
          scheduleSlot: mockScheduleSlot,
          existsInBackend: true,
        );

        // Assert
        final stringRepresentation = displayableSlot.toString();
        expect(stringRepresentation, contains('DisplayableTimeSlot'));
        expect(
          stringRepresentation,
          contains('Monday'),
        ); // L'enum utilise la casse Pascal
        expect(stringRepresentation, contains('08:00'));
      });
    });

    group('edge cases', () {
      test('gère les minutes avec format correct', () {
        // Arrange & Act
        const slot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.friday,
          timeOfDay: TimeOfDayValue(14, 5),
          week: '2024-W15',
          existsInBackend: false,
        );

        // Assert
        expect(slot.compositeKey, equals('friday_14:05'));
      });

      test('gère minuit correctement', () {
        // Arrange & Act
        const slot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.saturday,
          timeOfDay: TimeOfDayValue(0, 0),
          week: '2024-W15',
          existsInBackend: false,
        );

        // Assert
        expect(slot.compositeKey, equals('saturday_00:00'));
      });

      test('gère 23h59 correctement', () {
        // Arrange & Act
        const slot = DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.sunday,
          timeOfDay: TimeOfDayValue(23, 59),
          week: '2024-W15',
          existsInBackend: false,
        );

        // Assert
        expect(slot.compositeKey, equals('sunday_23:59'));
      });
    });
  });
}

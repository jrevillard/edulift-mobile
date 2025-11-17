import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/features/schedule/presentation/widgets/mobile/period_card_widget.dart';
import 'package:edulift/features/schedule/presentation/widgets/mobile/day_card_widget.dart';
import 'package:edulift/features/schedule/presentation/widgets/mobile/schedule_week_cards.dart';
import 'package:edulift/core/domain/entities/family/vehicle.dart';
import 'package:edulift/core/domain/entities/family/child.dart';
import 'package:edulift/core/domain/entities/schedule/day_of_week.dart';
import 'package:edulift/core/domain/entities/schedule/time_of_day.dart';
import 'package:edulift/features/schedule/presentation/models/displayable_time_slot.dart';
import '../../../../../../test/support/test_app_configuration.dart';

void main() {
  group('Responsive Design Tests', () {
    late List<DisplayableTimeSlot> testDisplayableSlots;
    late Map<String, Vehicle> testVehicles;
    late Map<String, Child> testChildren;

    setUpAll(() async {
      // Initialiser les localisations pour tous les tests du groupe
      await TestAppConfiguration.initialize();
    });

    setUp(() {
      testDisplayableSlots = [
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(8, 0),
          week: '2024-W03',
          existsInBackend: true,
        ),
        const DisplayableTimeSlot(
          dayOfWeek: DayOfWeek.monday,
          timeOfDay: TimeOfDayValue(14, 0),
          week: '2024-W03',
          existsInBackend: true,
        ),
      ];

      testVehicles = {
        'vehicle_1': Vehicle(
          id: 'vehicle_1',
          name: 'Vehicle 1',
          familyId: 'family_1',
          capacity: 4,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      };

      testChildren = {
        'child_1': Child(
          id: 'child_1',
          name: 'John Doe',
          familyId: 'family_1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      };
    });

    Widget createTestWidget({required Widget child}) {
      return TestAppConfiguration.createTestWidget(child: child);
    }

    group('PeriodCardWidget Responsive Tests', () {
      testWidgets('adapts layout on mobile screen', (
        WidgetTester tester,
      ) async {
        // Set mobile screen size
        await tester.binding.setSurfaceSize(const Size(375, 667)); // iPhone SE

        await tester.pumpWidget(
          createTestWidget(
            child: PeriodCardWidget(
              key: const Key('test_period_card_mobile'),
              periodName: 'Morning',
              displayableSlots: testDisplayableSlots,
              onSlotTap: (slot) {},
              childrenMap: testChildren,
            ),
          ),
        );

        expect(find.byType(PeriodCardWidget), findsOneWidget);
        expect(find.byKey(const Key('period_card_morning')), findsOneWidget);

        // Verify mobile-specific layout elements
        expect(find.byType(Column), findsWidgets);
        // Mobile should have compact layout
        final periodCard = tester.widget<Container>(
          find.byKey(const Key('period_card_morning')),
        );
        expect(periodCard.margin, const EdgeInsets.only(top: 8));

        // Reset screen size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('adapts layout on tablet screen', (
        WidgetTester tester,
      ) async {
        // Set tablet screen size
        await tester.binding.setSurfaceSize(const Size(768, 1024)); // iPad

        await tester.pumpWidget(
          createTestWidget(
            child: PeriodCardWidget(
              key: const Key('test_period_card_tablet'),
              periodName: 'Morning',
              displayableSlots: testDisplayableSlots,
              vehicles: testVehicles,
              onSlotTap: (slot) {},
              childrenMap: testChildren,
            ),
          ),
        );

        expect(find.byType(PeriodCardWidget), findsOneWidget);
        expect(find.byKey(const Key('period_card_morning')), findsOneWidget);

        // Tablet should have more space for layout
        expect(find.byType(Column), findsWidgets);

        // Reset screen size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('adapts layout on desktop screen', (
        WidgetTester tester,
      ) async {
        // Set desktop screen size
        await tester.binding.setSurfaceSize(const Size(1200, 800));

        await tester.pumpWidget(
          createTestWidget(
            child: PeriodCardWidget(
              key: const Key('test_period_card_desktop'),
              periodName: 'Morning',
              displayableSlots: testDisplayableSlots,
              vehicles: testVehicles,
              onSlotTap: (slot) {},
              childrenMap: testChildren,
            ),
          ),
        );

        expect(find.byType(PeriodCardWidget), findsOneWidget);
        expect(find.byKey(const Key('period_card_morning')), findsOneWidget);

        // Desktop should have maximum space for content
        expect(find.byType(Column), findsWidgets);

        // Reset screen size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('handles orientation change', (WidgetTester tester) async {
        // Start in portrait
        await tester.binding.setSurfaceSize(const Size(375, 667));

        await tester.pumpWidget(
          createTestWidget(
            child: PeriodCardWidget(
              key: const Key('test_period_card_orientation'),
              periodName: 'Morning',
              displayableSlots: testDisplayableSlots,
              onSlotTap: (slot) {},
              childrenMap: testChildren,
            ),
          ),
        );

        expect(find.byType(PeriodCardWidget), findsOneWidget);

        // Change to landscape
        await tester.binding.setSurfaceSize(const Size(667, 375));
        await tester.pumpAndSettle();

        expect(find.byType(PeriodCardWidget), findsOneWidget);
        expect(find.byKey(const Key('period_card_morning')), findsOneWidget);

        // Widget should adapt to new orientation
        expect(find.byType(Column), findsWidgets);

        // Reset screen size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('maintains functionality across screen sizes', (
        WidgetTester tester,
      ) async {
        final screenSizes = [
          const Size(375, 667), // Mobile
          const Size(768, 1024), // Tablet
          const Size(1200, 800), // Desktop
        ];

        for (var i = 0; i < screenSizes.length; i++) {
          final size = screenSizes[i];

          await tester.binding.setSurfaceSize(size);

          await tester.pumpWidget(
            createTestWidget(
              child: PeriodCardWidget(
                key: Key('test_period_card_responsive_$i'),
                periodName: 'Morning',
                displayableSlots: testDisplayableSlots,
                onSlotTap: (slot) {
                  // Slot tap callback for testing
                },
                childrenMap: testChildren,
              ),
            ),
          );

          expect(find.byType(PeriodCardWidget), findsOneWidget);
          expect(find.byKey(const Key('period_card_morning')), findsOneWidget);

          // Test tap functionality on each screen size
          await tester.tap(find.byType(PeriodCardWidget));
          await tester.pumpAndSettle();

          // Clean up for next iteration
          await tester.pumpWidget(Container());
        }

        // Reset screen size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('DayCardWidget Responsive Tests', () {
      testWidgets('adapts layout for different screen widths', (
        WidgetTester tester,
      ) async {
        final testDate = DateTime(2024, 1, 15);

        // Test various screen widths
        final screenSizes = [
          const Size(320, 568), // Small mobile
          const Size(375, 667), // Regular mobile
          const Size(414, 896), // Large mobile
          const Size(768, 1024), // Tablet
          const Size(1024, 768), // Large tablet
        ];

        for (var i = 0; i < screenSizes.length; i++) {
          final size = screenSizes[i];

          await tester.binding.setSurfaceSize(size);

          await tester.pumpWidget(
            createTestWidget(
              child: DayCardWidget(
                key: Key('test_day_card_responsive_$i'),
                date: testDate,
                displayableSlots: testDisplayableSlots,
                onSlotTap: (slot) {},
                childrenMap: testChildren,
              ),
            ),
          );

          expect(find.byType(DayCardWidget), findsOneWidget);
          expect(
            find.byKey(Key('day_card_${testDate.millisecondsSinceEpoch}')),
            findsOneWidget,
          );

          // Should maintain core functionality regardless of screen size
          expect(find.byIcon(Icons.calendar_today), findsOneWidget);

          // Clean up for next iteration
          await tester.pumpWidget(Container());
        }

        // Reset screen size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('handles content overflow on small screens', (
        WidgetTester tester,
      ) async {
        // Set very small screen size
        await tester.binding.setSurfaceSize(const Size(280, 500));

        final testDate = DateTime(2024, 1, 15);

        await tester.pumpWidget(
          createTestWidget(
            child: DayCardWidget(
              key: const Key('test_day_card_small_screen'),
              date: testDate,
              displayableSlots: testDisplayableSlots,
              onSlotTap: (slot) {},
              childrenMap: testChildren,
            ),
          ),
        );

        expect(find.byType(DayCardWidget), findsOneWidget);
        // Widget should render without overflow errors
        expect(tester.takeException(), isNull);

        // Reset screen size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('utilizes extra space on large screens', (
        WidgetTester tester,
      ) async {
        // Set large screen size
        await tester.binding.setSurfaceSize(const Size(1920, 1080));

        final testDate = DateTime(2024, 1, 15);

        await tester.pumpWidget(
          createTestWidget(
            child: DayCardWidget(
              key: const Key('test_day_card_large_screen'),
              date: testDate,
              displayableSlots: testDisplayableSlots,
              onSlotTap: (slot) {},
              childrenMap: testChildren,
            ),
          ),
        );

        expect(find.byType(DayCardWidget), findsOneWidget);
        // Widget should utilize available space effectively
        expect(find.byType(Card), findsOneWidget);

        // Reset screen size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('ScheduleWeekCards Responsive Tests', () {
      testWidgets('adapts week layout on different screen sizes', (
        WidgetTester tester,
      ) async {
        // Create a week's worth of slots
        final weekSlots = [
          for (final day in DayOfWeek.values)
            DisplayableTimeSlot(
              dayOfWeek: day,
              timeOfDay: const TimeOfDayValue(9, 0),
              week: '2024-W03',
              existsInBackend: true,
            ),
        ];

        final screenSizes = [
          const Size(375, 667), // Mobile portrait
          const Size(667, 375), // Mobile landscape
          const Size(768, 1024), // Tablet portrait
          const Size(1024, 768), // Tablet landscape
        ];

        for (var i = 0; i < screenSizes.length; i++) {
          final size = screenSizes[i];

          await tester.binding.setSurfaceSize(size);

          await tester.pumpWidget(
            createTestWidget(
              child: ScheduleWeekCards(
                key: Key('test_week_cards_responsive_$i'),
                displayableSlots: weekSlots,
                onSlotTap: (slot) {},
                vehicles: testVehicles,
                childrenMap: testChildren,
                isSlotInPast: (slot) => false,
              ),
            ),
          );

          expect(find.byType(ScheduleWeekCards), findsOneWidget);
          expect(find.byType(DayCardWidget), findsNWidgets(7));

          // Clean up for next iteration
          await tester.pumpWidget(Container());
        }

        // Reset screen size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('handles scroll behavior on small screens', (
        WidgetTester tester,
      ) async {
        // Set mobile screen size
        await tester.binding.setSurfaceSize(const Size(375, 667));

        // Create many slots to test scrolling
        final manySlots = [
          for (final day in DayOfWeek.values)
            for (var hour = 8; hour <= 18; hour += 2)
              DisplayableTimeSlot(
                dayOfWeek: day,
                timeOfDay: TimeOfDayValue(hour, 0),
                week: '2024-W03',
                existsInBackend: true,
              ),
        ];

        await tester.pumpWidget(
          createTestWidget(
            child: ScheduleWeekCards(
              key: const Key('test_week_cards_scroll'),
              displayableSlots: manySlots,
              onSlotTap: (slot) {},
              vehicles: testVehicles,
              childrenMap: testChildren,
              isSlotInPast: (slot) => false,
            ),
          ),
        );

        expect(find.byType(ScheduleWeekCards), findsOneWidget);
        expect(find.byType(DayCardWidget), findsNWidgets(7));

        // Test scrolling
        await tester.fling(
          find.byType(SingleChildScrollView),
          const Offset(0, -300),
          1000,
        );
        await tester.pumpAndSettle();

        // Should still render correctly after scrolling
        expect(find.byType(ScheduleWeekCards), findsOneWidget);

        // Reset screen size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('maintains week structure across orientations', (
        WidgetTester tester,
      ) async {
        final weekSlots = [
          for (final day in DayOfWeek.values.take(5)) // Week days only
            DisplayableTimeSlot(
              dayOfWeek: day,
              timeOfDay: const TimeOfDayValue(9, 0),
              week: '2024-W03',
              existsInBackend: true,
            ),
        ];

        // Test portrait
        await tester.binding.setSurfaceSize(const Size(375, 667));

        await tester.pumpWidget(
          createTestWidget(
            child: ScheduleWeekCards(
              key: const Key('test_week_cards_portrait'),
              displayableSlots: weekSlots,
              onSlotTap: (slot) {},
              configuredDays: DayOfWeek.values
                  .take(5)
                  .toList(), // Week days only
              vehicles: testVehicles,
              childrenMap: testChildren,
              isSlotInPast: (slot) => false,
            ),
          ),
        );

        expect(find.byType(ScheduleWeekCards), findsOneWidget);
        expect(find.byType(DayCardWidget), findsNWidgets(5));

        // Test landscape
        await tester.binding.setSurfaceSize(const Size(667, 375));
        await tester.pumpAndSettle();

        expect(find.byType(ScheduleWeekCards), findsOneWidget);
        expect(find.byType(DayCardWidget), findsNWidgets(5));

        // Reset screen size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Performance and Stability Tests', () {
      testWidgets('handles rapid screen size changes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            child: PeriodCardWidget(
              key: const Key('test_period_card_performance'),
              periodName: 'Morning',
              displayableSlots: testDisplayableSlots,
              onSlotTap: (slot) {},
              childrenMap: testChildren,
            ),
          ),
        );

        final sizes = [
          const Size(320, 568),
          const Size(375, 667),
          const Size(414, 896),
          const Size(768, 1024),
          const Size(1024, 768),
        ];

        // Rapidly change screen sizes
        for (final size in sizes) {
          await tester.binding.setSurfaceSize(size);
          await tester
              .pump(); // Don't wait for settle to simulate rapid changes
        }

        await tester.pumpAndSettle();

        // Should still render correctly after rapid changes
        expect(find.byType(PeriodCardWidget), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Reset screen size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('maintains state during responsive changes', (
        WidgetTester tester,
      ) async {
        var tapCount = 0;

        await tester.pumpWidget(
          createTestWidget(
            child: PeriodCardWidget(
              key: const Key('test_period_card_state'),
              periodName: 'Morning',
              displayableSlots: testDisplayableSlots,
              onSlotTap: (slot) => tapCount++,
              childrenMap: testChildren,
            ),
          ),
        );

        // Tap to increase count
        await tester.tap(find.byType(PeriodCardWidget));
        await tester.pumpAndSettle();

        // Change screen size
        await tester.binding.setSurfaceSize(const Size(768, 1024));
        await tester.pumpAndSettle();

        // Widget should still be functional
        expect(find.byType(PeriodCardWidget), findsOneWidget);

        // Reset screen size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('handles edge case screen sizes', (
        WidgetTester tester,
      ) async {
        final edgeSizes = [
          const Size(320, 500), // Small but realistic mobile
          const Size(2000, 2000), // Very large
        ];

        for (var i = 0; i < edgeSizes.length; i++) {
          final size = edgeSizes[i];

          await tester.binding.setSurfaceSize(size);

          await tester.pumpWidget(
            createTestWidget(
              child: PeriodCardWidget(
                key: Key('test_edge_case_$i'),
                periodName: 'Morning',
                displayableSlots: testDisplayableSlots,
                onSlotTap: (slot) {},
                childrenMap: testChildren,
              ),
            ),
          );

          // Should render without crashing
          expect(find.byType(PeriodCardWidget), findsOneWidget);
          expect(tester.takeException(), isNull);

          // Clean up
          await tester.pumpWidget(Container());
        }

        // Reset screen size
        await tester.binding.setSurfaceSize(null);
      });
    });
  });
}

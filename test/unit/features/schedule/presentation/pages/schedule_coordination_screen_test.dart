import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/features/schedule/presentation/pages/schedule_coordination_screen.dart';

void main() {
  group('ScheduleCoordinationScreen Tests', () {
    testWidgets('should display app bar with correct title', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: ScheduleCoordinationScreen()),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Schedule Coordination'), findsOneWidget);
    });

    testWidgets('should display date selector with navigation buttons', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: ScheduleCoordinationScreen()),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('should display view selector with day, week, month options', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: ScheduleCoordinationScreen()),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(SegmentedButton<ScheduleView>), findsOneWidget);
      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
    });

    testWidgets('should display sample events in day view', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: ScheduleCoordinationScreen()),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('School Drop-off - Emma'), findsOneWidget);
      expect(find.text('Soccer Practice - Lucas'), findsOneWidget);
      expect(find.text('Riverside Elementary School'), findsOneWidget);
      expect(find.text('Central Park Soccer Field'), findsOneWidget);
    });

    testWidgets('should show conflict warning badge when conflicts exist', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: ScheduleCoordinationScreen()),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byIcon(Icons.warning), findsWidgets);
      expect(find.byType(Badge), findsOneWidget);
    });

    testWidgets('should display conflict banner when conflicts exist', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: ScheduleCoordinationScreen()),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(
        find.text('Schedule conflicts detected. Tap to resolve.'),
        findsOneWidget,
      );
      expect(find.text('Vehicle double-booked'), findsOneWidget);
    });

    testWidgets('should display floating action button for adding events', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: ScheduleCoordinationScreen()),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should display refresh button in app bar', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: ScheduleCoordinationScreen()),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should display filter button in app bar', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: ScheduleCoordinationScreen()),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('should switch between day, week, and month views', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: ScheduleCoordinationScreen()),
      );

      // Act
      await tester.pumpWidget(widget);

      // Test week view
      await tester.tap(find.text('Week'));
      await tester.pump();
      expect(find.text('Week view implementation'), findsOneWidget);

      // Test month view
      await tester.tap(find.text('Month'));
      await tester.pump();
      expect(find.text('Month view implementation'), findsOneWidget);

      // Test day view
      await tester.tap(find.text('Day'));
      await tester.pump();
      expect(find.text('School Drop-off - Emma'), findsOneWidget);
    });

    testWidgets('should display event cards with correct information', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: ScheduleCoordinationScreen()),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert - Check event details
      expect(find.text('Sarah Johnson'), findsOneWidget); // Driver
      expect(find.text('Mike Johnson'), findsOneWidget); // Driver
      expect(find.text('Family SUV'), findsOneWidget); // Vehicle
      expect(find.text('Compact Car'), findsOneWidget); // Vehicle
      expect(find.text('Confirmed'), findsOneWidget); // Status
      expect(find.text('Pending'), findsOneWidget); // Status
    });

    testWidgets('should navigate dates when using arrow buttons', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: ScheduleCoordinationScreen()),
      );

      // Act
      await tester.pumpWidget(widget);

      // Test next day button
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      expect(find.text('Tomorrow'), findsOneWidget);

      // Test previous day button
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('should show empty state when no events for selected date', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: ScheduleCoordinationScreen()),
      );

      // Act - Navigate to a date with no events
      await tester.pumpWidget(widget);
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      // Assert
      expect(find.text('No events scheduled'), findsOneWidget);
      expect(find.text('Tap + to add a new event'), findsOneWidget);
      expect(find.byIcon(Icons.event_available), findsOneWidget);
    });

    testWidgets('should display event icons based on event type', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: ScheduleCoordinationScreen()),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byIcon(Icons.school), findsOneWidget); // Drop-off event
      expect(
        find.byIcon(Icons.sports_soccer),
        findsOneWidget,
      ); // Activity event
    });

    testWidgets('should show correct time formatting in event cards', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: ScheduleCoordinationScreen()),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert - Check that time information is displayed
      expect(find.textContaining('-'), findsWidgets); // Time range format
    });

    testWidgets('should show loading indicator when refreshing', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: ScheduleCoordinationScreen()),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump(); // Start refresh

      // Assert - Loading state should be visible briefly
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

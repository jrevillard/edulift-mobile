import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/features/schedule/presentation/pages/create_schedule_page.dart';
import '../../../../../../test/support/test_app_configuration.dart';

void main() {
  group('CreateSchedulePage Tests', () {
    setUpAll(() async {
      // Initialize test environment with proper localization
      await TestAppConfiguration.initialize();
    });

    testWidgets('should display correct title and content', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = CreateSchedulePage();

      // Act
      await tester.pumpWidget(
        TestAppConfiguration.createBareTestWidget(child: widget, locale: 'en'),
      );

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.add_circle), findsOneWidget);
      expect(find.text('Create Trip'), findsWidgets);
      expect(find.text('Trip creation form to implement'), findsOneWidget);
    });

    testWidgets('should have save button in app bar', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = CreateSchedulePage();

      // Act
      await tester.pumpWidget(
        TestAppConfiguration.createBareTestWidget(child: widget, locale: 'en'),
      );

      // Assert
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should display centered content with proper styling', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = CreateSchedulePage();

      // Act
      await tester.pumpWidget(
        TestAppConfiguration.createBareTestWidget(child: widget, locale: 'en'),
      );

      // Assert
      // Find the specific Center that contains a Padding which contains a Column
      final centerFinder = find.byType(Center).first;
      final centerWidget = tester.widget<Center>(centerFinder);
      expect(centerWidget.child, isA<Padding>());

      // Find the Padding and verify it contains a Column
      final paddingFinder = find.descendant(
        of: centerFinder,
        matching: find.byType(Padding),
      );
      final paddingWidget = tester.widget<Padding>(paddingFinder);
      expect(paddingWidget.child, isA<Column>());

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.add_circle));
      // Icon size is now responsive - check that it's within reasonable range
      expect(
        iconWidget.size,
        greaterThan(50.0),
      ); // Should be between 56-72 depending on screen
      expect(iconWidget.size, lessThan(80.0));
      expect(iconWidget.color, equals(Colors.grey));

      final columnWidget = tester.widget<Column>(find.byType(Column));
      expect(columnWidget.mainAxisAlignment, equals(MainAxisAlignment.center));
    });
  });
}

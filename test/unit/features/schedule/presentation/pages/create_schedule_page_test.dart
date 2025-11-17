import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/features/schedule/presentation/pages/create_schedule_page.dart';

void main() {
  group('CreateSchedulePage Tests', () {
    testWidgets('should display correct title and content', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: CreateSchedulePage()),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.add_circle), findsOneWidget);
      expect(find.text('Create Trip'), findsWidgets);
      expect(find.text('Trip creation form to be implemented'), findsOneWidget);
    });

    testWidgets('should have save button in app bar', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: CreateSchedulePage()),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should display centered content with proper styling', (
      WidgetTester tester,
    ) async {
      // Arrange
      const widget = ProviderScope(
        child: MaterialApp(home: CreateSchedulePage()),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      final centerWidget = tester.widget<Center>(find.byType(Center));
      expect(centerWidget.child, isA<Column>());

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.add_circle));
      expect(iconWidget.size, equals(64.0));
      expect(iconWidget.color, equals(Colors.grey));

      final columnWidget = tester.widget<Column>(find.byType(Column));
      expect(columnWidget.mainAxisAlignment, equals(MainAxisAlignment.center));
    });
  });
}

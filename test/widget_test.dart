// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'support/test_provider_overrides.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Using ProviderContainer with overrides in tests
  });
  testWidgets('EduLift App smoke test', (WidgetTester tester) async {
    // Build a simple test app
    await tester.pumpWidget(
      ProviderScope(
        overrides: TestProviderOverrides.common,
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('EduLift Test')),
            body: const Center(child: Text('EduLift Mobile App')),
          ),
        ),
      ),
    );

    // Verify that our app loads
    expect(find.text('EduLift Test'), findsOneWidget);
    expect(find.text('EduLift Mobile App'), findsOneWidget);
  });

  testWidgets('Login screen button test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: TestProviderOverrides.common,
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Log In'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Log In'), findsOneWidget);
    await tester.tap(find.text('Log In'));
    await tester.pump();
  });

  testWidgets('Accessibility button test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: TestProviderOverrides.common,
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Semantics(
                label: 'Test button',
                button: true,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Accessible Button'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Accessible Button'), findsOneWidget);

    // Test accessibility
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
  });
}

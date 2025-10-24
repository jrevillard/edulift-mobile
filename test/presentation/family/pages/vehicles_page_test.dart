// EduLift Mobile - Vehicles Page Widget Tests
// Widget tests for vehicles page - Updated to use FamilyProvider

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/features/family/presentation/pages/vehicles_page.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';

void main() {
  group('VehiclesPage Tests', () {
    testWidgets('should display vehicles page correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: VehiclesPage(),
          ),
        ),
      );

      expect(find.byType(VehiclesPage), findsOneWidget);
    });
  });
}

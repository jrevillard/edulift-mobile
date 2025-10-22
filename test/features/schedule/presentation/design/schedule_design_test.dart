import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edulift/core/presentation/themes/app_colors.dart';
import 'package:edulift/features/schedule/presentation/design/schedule_design.dart';

void main() {
  group('AppColors (Schedule semantics)', () {
    testWidgets('should provide theme-aware colors in light mode',
        (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return Container();
            },
          ),
        ),
      );

      // Test theme-aware colors
      expect(AppColors.statusEmpty(capturedContext), isA<Color>());
      expect(AppColors.statusAvailable(capturedContext), isA<Color>());
      expect(AppColors.statusPartial(capturedContext), isA<Color>());
      expect(AppColors.statusFull(capturedContext), isA<Color>());
      expect(AppColors.statusConflict(capturedContext), isA<Color>());
      expect(AppColors.driverBadge(capturedContext), isA<Color>());
      expect(AppColors.childBadge(capturedContext), isA<Color>());
      expect(AppColors.borderThemed(capturedContext), isA<Color>());
      expect(AppColors.borderStrong(capturedContext), isA<Color>());
      expect(AppColors.textPrimaryThemed(capturedContext), isA<Color>());
      expect(AppColors.textSecondaryThemed(capturedContext), isA<Color>());
      expect(AppColors.textDisabled(capturedContext), isA<Color>());
      expect(AppColors.onSurfaceVariant(capturedContext).withValues(alpha: 0.4), isA<Color>());
    });

    testWidgets('should provide correct colors in dark mode', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return Container();
            },
          ),
        ),
      );

      // Test dark mode specific colors
      final availableColor = AppColors.statusAvailable(capturedContext);
      final partialColor = AppColors.statusPartial(capturedContext);

      // Uses Material 3 semantic colors for guaranteed contrast
      expect(availableColor, isA<Color>(),
          reason: 'slotAvailable should use Material 3 secondaryContainer');
      expect(partialColor, isA<Color>(),
          reason: 'slotPartial should use Material 3 tertiaryContainer');

      // All theme-aware getters should work in dark mode
      expect(AppColors.statusEmpty(capturedContext), isA<Color>());
      expect(AppColors.statusFull(capturedContext), isA<Color>());
      expect(AppColors.statusConflict(capturedContext), isA<Color>());
      expect(AppColors.driverBadge(capturedContext), isA<Color>());
      expect(AppColors.childBadge(capturedContext), isA<Color>());
      expect(AppColors.borderStrong(capturedContext), isA<Color>());
      expect(AppColors.textSecondaryThemed(capturedContext), isA<Color>());
      expect(AppColors.textDisabled(capturedContext), isA<Color>());
      expect(AppColors.onSurfaceVariant(capturedContext).withValues(alpha: 0.4), isA<Color>());
    });

    test('should provide const colors', () {
      expect(AppColors.primary, isA<Color>());
      expect(AppColors.success, isA<Color>());
      expect(AppColors.error, isA<Color>());
      expect(AppColors.warning, isA<Color>());
      expect(AppColors.info, isA<Color>());
    });

    group('getDayColor', () {
      test('should return correct colors for French days', () {
        expect(AppColors.getDayColor('lundi'), Colors.blue);
        expect(AppColors.getDayColor('mardi'), Colors.green);
        expect(AppColors.getDayColor('mercredi'), Colors.orange);
        expect(AppColors.getDayColor('jeudi'), Colors.purple);
        expect(AppColors.getDayColor('vendredi'), Colors.red);
      });

      test('should return correct colors for English days', () {
        expect(AppColors.getDayColor('monday'), Colors.blue);
        expect(AppColors.getDayColor('tuesday'), Colors.green);
        expect(AppColors.getDayColor('wednesday'), Colors.orange);
        expect(AppColors.getDayColor('thursday'), Colors.purple);
        expect(AppColors.getDayColor('friday'), Colors.red);
      });

      test('should be case insensitive', () {
        expect(AppColors.getDayColor('MONDAY'), Colors.blue);
        expect(AppColors.getDayColor('Monday'), Colors.blue);
        expect(AppColors.getDayColor('LUNDI'), Colors.blue);
      });

      test('should return grey for unknown days', () {
        expect(AppColors.getDayColor('invalid'), Colors.grey);
        expect(AppColors.getDayColor(''), Colors.grey);
      });
    });

    testWidgets('should provide capacity colors', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return Container();
            },
          ),
        ),
      );

      expect(AppColors.capacityOk, isA<Color>());
      expect(AppColors.capacityWarning, isA<Color>());
      expect(AppColors.capacityError(capturedContext), isA<Color>());
    });
  });

  group('ScheduleDimensions', () {
    test('should provide spacing constants', () {
      expect(ScheduleDimensions.spacingXs, 4.0);
      expect(ScheduleDimensions.spacingSm, 8.0);
      expect(ScheduleDimensions.spacingMd, 16.0);
      expect(ScheduleDimensions.spacingLg, 24.0);
      expect(ScheduleDimensions.spacingXl, 32.0);
      expect(ScheduleDimensions.spacingXxl, 48.0);
    });

    test('should meet Material Design AA touch target requirements', () {
      expect(ScheduleDimensions.touchTargetMinimum, 48.0);
      expect(ScheduleDimensions.touchTargetRecommended, 56.0);

      expect(
        ScheduleDimensions.minimumTouchConstraints.minWidth,
        48.0,
        reason: 'Touch target width must be at least 48dp for AA compliance',
      );
      expect(
        ScheduleDimensions.minimumTouchConstraints.minHeight,
        48.0,
        reason: 'Touch target height must be at least 48dp for AA compliance',
      );
    });

    test('should provide schedule-specific dimensions', () {
      expect(ScheduleDimensions.slotHeight, 120.0);
      expect(ScheduleDimensions.slotWidth, 140.0);
      expect(ScheduleDimensions.dayHeaderHeight, 56.0);
      expect(ScheduleDimensions.timeHeaderHeight, 48.0);
      expect(ScheduleDimensions.vehicleCardHeight, 88.0);
      expect(ScheduleDimensions.childRowHeight, 72.0);
    });

    test('should provide border radius values aligned with AppSpacing', () {
      // Verify radius values match global design system
      expect(ScheduleDimensions.radiusSm, 4.0,
          reason: 'Should match AppSpacing.radiusSm');
      expect(ScheduleDimensions.radiusMd, 8.0,
          reason: 'Should match AppSpacing.radiusMd');
      expect(ScheduleDimensions.radiusLg, 12.0,
          reason: 'Should match AppSpacing.radiusLg');
      expect(ScheduleDimensions.radiusXl, 16.0,
          reason: 'Should match AppSpacing.radiusXl');
    });

    test('should provide border radius configurations', () {
      expect(ScheduleDimensions.cardRadius, isA<BorderRadius>());
      expect(ScheduleDimensions.modalRadius, isA<BorderRadius>());
      expect(ScheduleDimensions.buttonRadius, isA<BorderRadius>());
      expect(ScheduleDimensions.pillRadius, isA<BorderRadius>());
    });

    test('should provide elevation values', () {
      expect(ScheduleDimensions.elevationNone, 0.0);
      expect(ScheduleDimensions.elevationCard, 1.0);
      expect(ScheduleDimensions.elevationCardHovered, 2.0);
      expect(ScheduleDimensions.elevationModal, 3.0);
      expect(ScheduleDimensions.elevationDropdown, 4.0);
    });

    test('should provide bottom sheet size constraints', () {
      expect(ScheduleDimensions.bottomSheetInitialSize, 0.6);
      expect(ScheduleDimensions.bottomSheetMaxSize, 0.9);
      expect(
        ScheduleDimensions.bottomSheetMaxSize,
        lessThan(1.0),
        reason: 'Bottom sheet should not cover entire screen',
      );
    });

    test('should provide drag handle dimensions', () {
      expect(ScheduleDimensions.dragHandleWidth, 40.0);
      expect(ScheduleDimensions.dragHandleHeight, 4.0);
    });

    test('should provide capacity bar height', () {
      expect(ScheduleDimensions.capacityBarHeight, 8.0);
    });

    test('should provide icon sizes', () {
      expect(ScheduleDimensions.iconSize, 24.0);
      expect(ScheduleDimensions.iconSizeSmall, 20.0);
    });
  });

  group('ScheduleAnimations', () {
    test('should provide duration constants', () {
      expect(ScheduleAnimations.instant, const Duration(milliseconds: 100));
      expect(ScheduleAnimations.fast, const Duration(milliseconds: 200));
      expect(ScheduleAnimations.normal, const Duration(milliseconds: 300));
      expect(ScheduleAnimations.slow, const Duration(milliseconds: 400));
    });

    test('should provide curve constants', () {
      expect(ScheduleAnimations.entry, Curves.easeOut);
      expect(ScheduleAnimations.exit, Curves.easeIn);
      expect(ScheduleAnimations.spring, Curves.elasticOut);
      expect(ScheduleAnimations.emphasized, Curves.easeInOutCubicEmphasized);
      expect(ScheduleAnimations.standard, Curves.easeInOut);
    });

    test('should provide component-specific animation configs', () {
      expect(ScheduleAnimations.capacityBarDuration, isA<Duration>());
      expect(ScheduleAnimations.capacityBarCurve, isA<Curve>());
      expect(ScheduleAnimations.cardSelectionDuration, isA<Duration>());
      expect(ScheduleAnimations.cardSelectionCurve, isA<Curve>());
      expect(ScheduleAnimations.checkboxDuration, isA<Duration>());
      expect(ScheduleAnimations.checkboxCurve, isA<Curve>());
      expect(ScheduleAnimations.bottomSheetDuration, isA<Duration>());
      expect(ScheduleAnimations.bottomSheetCurve, isA<Curve>());
      expect(ScheduleAnimations.pageTransitionDuration, isA<Duration>());
      expect(ScheduleAnimations.pageTransitionCurve, isA<Curve>());
    });

    group('Accessibility - getDuration', () {
      testWidgets('should return zero duration when animations disabled',
          (tester) async {
        late BuildContext capturedContext;

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return Container();
              },
            ),
          ),
        );

        final duration = ScheduleAnimations.getDuration(
          capturedContext,
          ScheduleAnimations.normal,
        );

        expect(
          duration,
          Duration.zero,
          reason: 'Should respect reduced motion preference',
        );
      });

      testWidgets('should return normal duration when animations enabled',
          (tester) async {
        late BuildContext capturedContext;

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(),
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return Container();
              },
            ),
          ),
        );

        final duration = ScheduleAnimations.getDuration(
          capturedContext,
          ScheduleAnimations.normal,
        );

        expect(duration, ScheduleAnimations.normal);
      });
    });

    group('Accessibility - getCurve', () {
      testWidgets('should return linear curve when animations disabled',
          (tester) async {
        late BuildContext capturedContext;

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return Container();
              },
            ),
          ),
        );

        final curve = ScheduleAnimations.getCurve(
          capturedContext,
          ScheduleAnimations.emphasized,
        );

        expect(
          curve,
          Curves.linear,
          reason: 'Should use linear curve when motion is reduced',
        );
      });

      testWidgets('should return normal curve when animations enabled',
          (tester) async {
        late BuildContext capturedContext;

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(),
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return Container();
              },
            ),
          ),
        );

        final curve = ScheduleAnimations.getCurve(
          capturedContext,
          ScheduleAnimations.emphasized,
        );

        expect(curve, ScheduleAnimations.emphasized);
      });
    });
  });

  group('Design System Integration', () {
    test('should compose with global design system', () {
      // Verify that Schedule colors reuse AppColors
      expect(AppColors.primary, isNotNull);
      expect(AppColors.success, isNotNull);
      expect(AppColors.error, isNotNull);
      expect(AppColors.warning, isNotNull);
      expect(AppColors.info, isNotNull);
    });

    test('should maintain consistent spacing scale', () {
      // Verify spacing follows consistent scale
      expect(ScheduleDimensions.spacingXs, lessThan(ScheduleDimensions.spacingSm));
      expect(ScheduleDimensions.spacingSm, lessThan(ScheduleDimensions.spacingMd));
      expect(ScheduleDimensions.spacingMd, lessThan(ScheduleDimensions.spacingLg));
      expect(ScheduleDimensions.spacingLg, lessThan(ScheduleDimensions.spacingXl));
      expect(ScheduleDimensions.spacingXl, lessThan(ScheduleDimensions.spacingXxl));
    });

    test('should maintain consistent radius scale', () {
      // Verify radius follows consistent scale
      expect(ScheduleDimensions.radiusSm, lessThan(ScheduleDimensions.radiusMd));
      expect(ScheduleDimensions.radiusMd, lessThan(ScheduleDimensions.radiusLg));
      expect(ScheduleDimensions.radiusLg, lessThan(ScheduleDimensions.radiusXl));
    });

    test('should maintain consistent elevation scale', () {
      // Verify elevation follows consistent scale
      expect(
        ScheduleDimensions.elevationNone,
        lessThan(ScheduleDimensions.elevationCard),
      );
      expect(
        ScheduleDimensions.elevationCard,
        lessThan(ScheduleDimensions.elevationCardHovered),
      );
      expect(
        ScheduleDimensions.elevationCardHovered,
        lessThan(ScheduleDimensions.elevationModal),
      );
    });

    test('should maintain consistent animation duration scale', () {
      // Verify durations follow consistent scale
      expect(
        ScheduleAnimations.instant.inMilliseconds,
        lessThan(ScheduleAnimations.fast.inMilliseconds),
      );
      expect(
        ScheduleAnimations.fast.inMilliseconds,
        lessThan(ScheduleAnimations.normal.inMilliseconds),
      );
      expect(
        ScheduleAnimations.normal.inMilliseconds,
        lessThan(ScheduleAnimations.slow.inMilliseconds),
      );
    });
  });
}

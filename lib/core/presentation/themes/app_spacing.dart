// EduLift Mobile - App Spacing
// Consistent spacing values throughout the application

import 'package:flutter/widgets.dart';

/// Application spacing constants
class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  // Spacing values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border radius values
  static const double radiusXs = 2.0;
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;

  // Common spacing widgets for convenience
  static const Widget v2 = SizedBox(height: xs / 2);
  static const Widget v4 = SizedBox(height: xs);
  static const Widget v8 = SizedBox(height: sm);
  static const Widget v12 = SizedBox(height: 12.0);
  static const Widget v16 = SizedBox(height: md);
  static const Widget v20 = SizedBox(height: 20.0);
  static const Widget v24 = SizedBox(height: lg);
  static const Widget v32 = SizedBox(height: xl);
  static const Widget v48 = SizedBox(height: xxl);

  static const Widget h2 = SizedBox(width: xs / 2);
  static const Widget h4 = SizedBox(width: xs);
  static const Widget h8 = SizedBox(width: sm);
  static const Widget h12 = SizedBox(width: 12.0);
  static const Widget h16 = SizedBox(width: md);
  static const Widget h20 = SizedBox(width: 20.0);
  static const Widget h24 = SizedBox(width: lg);
  static const Widget h32 = SizedBox(width: xl);
  static const Widget h48 = SizedBox(width: xxl);

  // Padding presets
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // Horizontal padding presets
  static const EdgeInsets paddingHorizontalXs = EdgeInsets.symmetric(
    horizontal: xs,
  );
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(
    horizontal: sm,
  );
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(
    horizontal: lg,
  );
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(
    horizontal: xl,
  );

  // Vertical padding presets
  static const EdgeInsets paddingVerticalXs = EdgeInsets.symmetric(
    vertical: xs,
  );
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(
    vertical: sm,
  );
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(
    vertical: md,
  );
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(
    vertical: lg,
  );
  static const EdgeInsets paddingVerticalXl = EdgeInsets.symmetric(
    vertical: xl,
  );
}
